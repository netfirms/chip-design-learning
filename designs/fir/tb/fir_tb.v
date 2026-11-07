// fir_tb.v -- self-checking testbench for fir.v
//
// 1. Impulse:  the output must reproduce the coefficients h[0..15].
// 2. Random:   every output is compared, bit for bit, with a reference
//              model of the same fixed-point arithmetic.
// 3. Sines:    a 0.02*fs tone (pass band) must come through at ~0 dB and a
//              0.3*fs tone (stop band) must be attenuated by > 40 dB.
//
// Every input/output pair is written to build/fir_out.csv; `make plot`
// draws the waveforms and spectra.

`timescale 1ns/1ps
`default_nettype none

module fir_tb;

    localparam W    = 16;
    localparam TAPS = 16;
    localparam real PI = 3.14159265358979;

    reg                clk = 1'b0, rst_n = 1'b0;
    reg                in_valid = 1'b0;
    wire               in_ready;
    reg  signed [W-1:0] in_sample = 0;
    wire               out_valid;
    wire signed [W-1:0] out_sample;

    fir #(.W(W)) dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .in_ready(in_ready), .in_sample(in_sample),
        .out_valid(out_valid), .out_sample(out_sample)
    );

    always #5 clk = ~clk;

    // ---- Reference model ---------------------------------------------------
    integer h [0:TAPS-1];
    integer xh [0:TAPS-1];       // xh[k] = x[n-k]

    function integer model_push;  // push a sample, return expected output
        input integer x;
        integer k;
        reg signed [63:0] acc;
        begin
            for (k = TAPS - 1; k > 0; k = k - 1) xh[k] = xh[k-1];
            xh[0] = x;
            acc = 0;
            for (k = 0; k < TAPS; k = k + 1) acc = acc + h[k] * xh[k];
            acc = (acc + (1 <<< 14)) >>> 15;          // round, Q1.15
            if (acc >  32767) acc =  32767;           // saturate
            if (acc < -32768) acc = -32768;
            model_push = acc;
        end
    endfunction

    // ---- Driver: send one sample, wait for its result ----------------------
    integer csv, n = 0, errors = 0, expected, y;
    integer phase = 0;   // test phase, written to the CSV for plotting

    task send;
        input integer x;
        begin
            @(negedge clk);
            while (!in_ready) @(negedge clk);
            in_sample = x;
            in_valid  = 1'b1;
            @(negedge clk);
            in_valid  = 1'b0;
            while (!out_valid) @(negedge clk);
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

    // Peak |y| over a burst of a sine at frequency f (fraction of fs)
    task sine_gain;
        input real f;
        input integer amp;
        output real gain;
        integer i, peak;
        begin
            peak = 0;
            for (i = 0; i < 200; i = i + 1) begin
                send($rtoi(amp * $sin(2.0 * PI * f * i)));
                if (i >= 2 * TAPS && (y > peak || -y > peak)) peak = (y > 0) ? y : -y;
            end
            gain = peak * 1.0 / amp;
        end
    endtask

    integer i;
    real    g_pass, g_stop;

    initial begin
        $dumpfile("build/fir.vcd");
        $dumpvars(0, fir_tb);
        csv = $fopen("build/fir_out.csv", "w");
        $fwrite(csv, "n,x,y,phase\n");

        h[0]=-114;  h[1]=-159;  h[2]=-139;  h[3]=291;   h[4]=1450;  h[5]=3284;
        h[6]=5246;  h[7]=6525;  h[8]=6525;  h[9]=5246;  h[10]=3284; h[11]=1450;
        h[12]=291;  h[13]=-139; h[14]=-159; h[15]=-114;
        for (i = 0; i < TAPS; i = i + 1) xh[i] = 0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        phase = 1;
        // 1. Impulse response (x = 32767, i.e. just under 1.0)
        send(32767);
        if (y < h[0] - 1 || y > h[0] + 1) errors = errors + 1;
        for (i = 1; i < TAPS + 4; i = i + 1) begin
            send(0);
            if (i < TAPS && (y < h[i] - 1 || y > h[i] + 1)) begin
                $display("ERROR: impulse response tap %0d = %0d, expected %0d", i, y, h[i]);
                errors = errors + 1;
            end
        end

        phase = 2;
        // 2. Random full-scale samples, compared with the model
        for (i = 0; i < 300; i = i + 1) send($random % 32768);

        phase = 3;
        // 3. Frequency response at two points
        sine_gain(0.02, 16000, g_pass);
        sine_gain(0.30, 16000, g_stop);
        $display("gain at 0.02 fs = %.4f (%.1f dB), at 0.30 fs = %.5f (%.1f dB)",
                 g_pass, 20.0 * $log10(g_pass), g_stop, 20.0 * $log10(g_stop + 1e-9));
        if (g_pass < 0.95 || g_pass > 1.01) begin
            $display("ERROR: pass-band gain out of range"); errors = errors + 1;
        end
        if (g_stop > 0.01) begin
            $display("ERROR: stop-band attenuation too small"); errors = errors + 1;
        end

        $fclose(csv);
        if (errors == 0) $display("PASS: %0d samples bit-exact vs. model, filter response OK", n);
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end

endmodule

`default_nettype wire
