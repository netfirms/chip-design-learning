// fft8_tb.v -- self-checking testbench for fft8.v
//
// Each test frame of 8 complex samples is pushed through the hardware and
// the result is compared with a floating-point DFT (divided by 8, like the
// hardware). Fixed-point truncation in 3 stages can cost a few LSBs, so
// results within TOL LSBs of the exact value pass.
//
// Frames: impulse, DC, a cosine on bin 1, a complex exponential on bin 3,
// full-scale corner cases, and random data. Results go to
// build/fft8_out.csv for `make plot`.

`timescale 1ns/1ps
`default_nettype none

module fft8_tb;

    localparam W   = 16;
    localparam TOL = 3;
    localparam real PI = 3.14159265358979;

    reg                 clk = 1'b0, rst_n = 1'b0;
    reg                 in_valid = 1'b0;
    wire                in_ready;
    reg  signed [W-1:0] in_re = 0, in_im = 0;
    wire                out_valid;
    wire [2:0]          out_idx;
    wire signed [W:0]   out_re, out_im;

    fft8 #(.W(W)) dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .in_ready(in_ready), .in_re(in_re), .in_im(in_im),
        .out_valid(out_valid), .out_idx(out_idx), .out_re(out_re), .out_im(out_im)
    );

    always #5 clk = ~clk;

    integer xr [0:7], xi [0:7];     // frame to send
    integer csv, errors = 0, frame = 0, max_err = 0;

    task run_frame;
        integer n, k, got;
        real ref_re, ref_im, ang, err_re, err_im;
        begin
            // Load 8 samples
            for (n = 0; n < 8; n = n + 1) begin
                @(negedge clk);
                while (!in_ready) @(negedge clk);
                in_re = xr[n]; in_im = xi[n]; in_valid = 1'b1;
            end
            @(negedge clk) in_valid = 1'b0;

            // Collect 8 results and compare with the DFT
            got = 0;
            while (got < 8) begin
                @(negedge clk);
                if (out_valid) begin
                    k = out_idx;
                    ref_re = 0.0; ref_im = 0.0;
                    for (n = 0; n < 8; n = n + 1) begin
                        ang = -2.0 * PI * n * k / 8.0;
                        ref_re = ref_re + xr[n] * $cos(ang) - xi[n] * $sin(ang);
                        ref_im = ref_im + xr[n] * $sin(ang) + xi[n] * $cos(ang);
                    end
                    ref_re = ref_re / 8.0;  ref_im = ref_im / 8.0;
                    err_re = out_re - ref_re;  if (err_re < 0) err_re = -err_re;
                    err_im = out_im - ref_im;  if (err_im < 0) err_im = -err_im;
                    if (err_re > max_err) max_err = $rtoi(err_re + 0.999);
                    if (err_im > max_err) max_err = $rtoi(err_im + 0.999);
                    if (err_re > TOL || err_im > TOL) begin
                        $display("ERROR frame %0d X[%0d] = %0d%+0dj, expected %.1f%+.1fj",
                                 frame, k, out_re, out_im, ref_re, ref_im);
                        errors = errors + 1;
                    end
                    $fwrite(csv, "%0d,%0d,%0d,%0d,%0d,%0d,%.2f,%.2f\n",
                            frame, k, xr[k], xi[k], out_re, out_im, ref_re, ref_im);
                    got = got + 1;
                end
            end
            frame = frame + 1;
        end
    endtask

    integer n, f;
    initial begin
        $dumpfile("build/fft8.vcd");
        $dumpvars(0, fft8_tb);
        csv = $fopen("build/fft8_out.csv", "w");
        $fwrite(csv, "frame,k,x_re,x_im,X_re,X_im,ref_re,ref_im\n");

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        // Impulse: flat spectrum, every X[k] = 16384/8 = 2048
        for (n = 0; n < 8; n = n + 1) begin xr[n] = (n == 0) ? 16384 : 0; xi[n] = 0; end
        run_frame;

        // DC: all energy in bin 0
        for (n = 0; n < 8; n = n + 1) begin xr[n] = 10000; xi[n] = 0; end
        run_frame;

        // Real cosine on bin 1: energy split between bins 1 and 7
        for (n = 0; n < 8; n = n + 1) begin
            xr[n] = $rtoi(20000 * $cos(2.0 * PI * n / 8.0)); xi[n] = 0;
        end
        run_frame;

        // Complex exponential on bin 3: all energy in bin 3
        for (n = 0; n < 8; n = n + 1) begin
            xr[n] = $rtoi(20000 * $cos(2.0 * PI * 3 * n / 8.0));
            xi[n] = $rtoi(20000 * $sin(2.0 * PI * 3 * n / 8.0));
        end
        run_frame;

        // Full-scale corners: largest positive and negative inputs
        for (n = 0; n < 8; n = n + 1) begin xr[n] = 32767; xi[n] = 32767; end
        run_frame;
        for (n = 0; n < 8; n = n + 1) begin xr[n] = (n % 2) ? 32767 : -32768; xi[n] = -32768; end
        run_frame;

        // Random frames
        for (f = 0; f < 20; f = f + 1) begin
            for (n = 0; n < 8; n = n + 1) begin xr[n] = $random % 32768; xi[n] = $random % 32768; end
            run_frame;
        end

        $fclose(csv);
        if (errors == 0)
            $display("PASS: %0d frames, max error %0d LSB (tolerance %0d)", frame, max_err, TOL);
        else
            $display("FAIL: %0d errors", errors);
        $finish;
    end

endmodule

`default_nettype wire
