// iir_tb.v -- self-checking testbench for iir.v
//
// 1. Step:    a constant input must settle to the same value (DC gain = 1).
// 2. Random:  every output is compared, bit for bit, with a reference model.
// 3. Sines:   0.01*fs passes at ~0 dB; 0.2*fs is attenuated by ~26 dB.
//
// Inputs and outputs go to build/iir_out.csv for `make plot`.

`timescale 1ns/1ps
`default_nettype none

module iir_tb;

    localparam W = 16;
    localparam real PI = 3.14159265358979;

    reg                 clk = 1'b0, rst_n = 1'b0;
    reg                 in_valid = 1'b0;
    reg  signed [W-1:0] in_sample = 0;
    wire                out_valid;
    wire signed [W-1:0] out_sample;

    iir #(.W(W)) dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .in_sample(in_sample),
        .out_valid(out_valid), .out_sample(out_sample)
    );

    always #5 clk = ~clk;

    // ---- Reference model (same integer arithmetic) -------------------------
    integer mx1 = 0, mx2 = 0, my1 = 0, my2 = 0;

    function integer model_push;
        input integer x;
        reg signed [63:0] acc;
        begin
            acc = 329 * x + 658 * mx1 + 329 * mx2 + 25576 * my1 - 10508 * my2;
            acc = (acc + (1 <<< 13)) >>> 14;
            if (acc >  32767) acc =  32767;
            if (acc < -32768) acc = -32768;
            mx2 = mx1; mx1 = x;
            my2 = my1; my1 = acc;
            model_push = acc;
        end
    endfunction

    integer csv, n = 0, errors = 0, expected, y;
    integer phase = 0;   // test phase, written to the CSV for plotting

    // Send one sample per clock (this filter never stalls)
    task send;
        input integer x;
        begin
            @(negedge clk);
            in_sample = x;
            in_valid  = 1'b1;
            @(negedge clk);
            in_valid  = 1'b0;
            if (!out_valid) begin
                $display("ERROR n=%0d: out_valid not asserted", n);
                errors = errors + 1;
            end
            y = out_sample;
            expected = model_push(x);
            if (y !== expected) begin
                $display("ERROR n=%0d: x=%0d y=%0d expected=%0d", n, x, y, expected);
                errors = errors + 1;
            end
            $fwrite(csv, "%0d,%0d,%0d,%0d\n", n, x, y, phase);
            n = n + 1;
        end
    endtask

    task sine_gain;
        input real f;
        input integer amp;
        output real gain;
        integer i, peak;
        begin
            peak = 0;
            for (i = 0; i < 400; i = i + 1) begin
                send($rtoi(amp * $sin(2.0 * PI * f * i)));
                if (i >= 200 && (y > peak || -y > peak)) peak = (y > 0) ? y : -y;
            end
            gain = peak * 1.0 / amp;
        end
    endtask

    integer i;
    real    g_pass, g_stop;

    initial begin
        $dumpfile("build/iir.vcd");
        $dumpvars(0, iir_tb);
        csv = $fopen("build/iir_out.csv", "w");
        $fwrite(csv, "n,x,y,phase\n");

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        phase = 1;
        // 1. Step response: should settle at the input level
        for (i = 0; i < 150; i = i + 1) send(16384);
        if (y < 16384 - 2 || y > 16384 + 2) begin
            $display("ERROR: step settled at %0d, expected 16384", y);
            errors = errors + 1;
        end
        for (i = 0; i < 150; i = i + 1) send(0);

        phase = 2;
        // 2. Random input, including full-scale values
        for (i = 0; i < 300; i = i + 1) send($random % 32768);

        phase = 3;
        // 3. Frequency response
        sine_gain(0.01, 16000, g_pass);
        sine_gain(0.20, 16000, g_stop);
        $display("gain at 0.01 fs = %.4f (%.1f dB), at 0.20 fs = %.4f (%.1f dB)",
                 g_pass, 20.0 * $log10(g_pass), g_stop, 20.0 * $log10(g_stop));
        if (g_pass < 0.97 || g_pass > 1.02) begin
            $display("ERROR: pass-band gain out of range"); errors = errors + 1;
        end
        if (g_stop > 0.06) begin
            $display("ERROR: stop-band attenuation too small"); errors = errors + 1;
        end

        $fclose(csv);
        if (errors == 0) $display("PASS: %0d samples bit-exact vs. model, filter response OK", n);
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end

endmodule

`default_nettype wire
