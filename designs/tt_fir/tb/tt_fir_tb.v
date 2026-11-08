// tt_fir_tb.v -- self-checking testbench for the Tiny Tapeout FIR project.
//
// It drives only the Tiny Tapeout pins, the way the microcontroller on the
// demo board will: put a sample on ui_in, raise STROBE (uio[0]), wait for
// TOGGLE (uio[3]) to flip, read uo_out.
//
// 1. Impulse:  x = 127 (just under 1.0), the output must be h[k] * 127/128.
// 2. Random:   every output is compared, bit for bit, with a reference
//              model of the same fixed-point arithmetic (8-bit samples,
//              Q1.15 coefficients, round to nearest, saturate).
// 3. Sines:    a 0.02*fs tone must come through at ~0 dB; a 0.3*fs tone
//              must be attenuated to the 8-bit noise floor (< -34 dB).
// 4. Handshake: STROBE pulses while the filter is busy are ignored, and
//              VALID pulses exactly once per sample.
//
// Every input/output pair is written to build/tt_um_chipcourse_fir_out.csv;
// `make plot` draws the waveforms and the measured frequency response.

`timescale 1ns/1ps
`default_nettype none

module tt_um_chipcourse_fir_tb;

    localparam TAPS = 16;
    localparam real PI = 3.14159265358979;

    reg        clk = 1'b0, rst_n = 1'b0, ena = 1'b1;
    reg  [7:0] ui_in  = 8'd0;
    reg  [7:0] uio_in = 8'd0;
    wire [7:0] uo_out, uio_out, uio_oe;

    tt_um_chipcourse_fir dut (
        .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(uio_in), .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    always #10 clk = ~clk;          // 50 MHz, the Tiny Tapeout default

    wire ready  = uio_out[1];
    wire valid  = uio_out[2];
    wire toggle = uio_out[3];

    // ---- Reference model ---------------------------------------------------
    integer h [0:TAPS-1];
    integer xh [0:TAPS-1];          // xh[k] = x[n-k]

    function integer model_push;    // push a sample, return expected output
        input integer x;
        integer k;
        reg signed [63:0] acc;
        begin
            for (k = TAPS - 1; k > 0; k = k - 1) xh[k] = xh[k-1];
            xh[0] = x;
            acc = 0;
            for (k = 0; k < TAPS; k = k + 1) acc = acc + h[k] * xh[k];
            acc = (acc + (1 <<< 14)) >>> 15;          // round, back to Q1.7
            if (acc >  127) acc =  127;               // saturate
            if (acc < -128) acc = -128;
            model_push = acc;
        end
    endfunction

    // ---- Driver: one sample in through the pins, one result out -----------
    integer csv, n = 0, errors = 0, expected, y, valid_count = 0;
    integer phase = 0;
    reg     last_toggle;

    always @(posedge clk) if (valid) valid_count = valid_count + 1;

    task send;
        input integer x;
        integer t;
        begin
            while (!ready) @(negedge clk);
            last_toggle = toggle;
            ui_in = x[7:0];
            #3 uio_in[0] = 1'b1;                    // STROBE, not aligned to clk
            repeat (4) @(negedge clk);
            uio_in[0] = 1'b0;
            t = 0;
            while (toggle == last_toggle && t < 100) begin
                @(negedge clk);
                t = t + 1;
            end
            y = $signed(uo_out);
            expected = model_push(x);
            if (t >= 100) begin
                $display("ERROR n=%0d: no output (TOGGLE did not flip)", n);
                errors = errors + 1;
            end else if (y !== expected) begin
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

    integer i, count0;
    real    g_pass, g_stop;

    initial begin
        $dumpfile("build/tt_fir.vcd");
        $dumpvars(0, tt_um_chipcourse_fir_tb);
        csv = $fopen("build/tt_um_chipcourse_fir_out.csv", "w");
        $fwrite(csv, "n,x,y,phase\n");

        h[0]=-114;  h[1]=-159;  h[2]=-139;  h[3]=291;   h[4]=1450;  h[5]=3284;
        h[6]=5246;  h[7]=6525;  h[8]=6525;  h[9]=5246;  h[10]=3284; h[11]=1450;
        h[12]=291;  h[13]=-139; h[14]=-159; h[15]=-114;
        for (i = 0; i < TAPS; i = i + 1) xh[i] = 0;

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);

        if (uio_oe !== 8'b0000_1110) begin
            $display("ERROR: uio_oe = %b, expected 00001110", uio_oe);
            errors = errors + 1;
        end

        phase = 1;
        // 1. Impulse response
        send(127);
        for (i = 1; i < TAPS + 4; i = i + 1) send(0);

        phase = 2;
        // 2. Random full-scale samples, compared with the model
        for (i = 0; i < 300; i = i + 1) send($random % 128);

        phase = 3;
        // 3. Frequency response at two points
        sine_gain(0.02, 100, g_pass);
        sine_gain(0.30, 100, g_stop);
        $display("gain at 0.02 fs = %.3f (%.1f dB), at 0.30 fs = %.3f (peak below %0s)",
                 g_pass, 20.0 * $log10(g_pass), g_stop, (g_stop < 0.01) ? "1 LSB" : "2 LSB");
        if (g_pass < 0.95 || g_pass > 1.02) begin
            $display("ERROR: pass-band gain out of range"); errors = errors + 1;
        end
        if (g_stop > 0.02) begin
            $display("ERROR: stop-band attenuation too small"); errors = errors + 1;
        end

        // 4. Handshake: a second STROBE while busy must be ignored
        count0 = valid_count;
        while (!ready) @(negedge clk);
        ui_in = 8'd50;
        uio_in[0] = 1'b1; repeat (4) @(negedge clk); uio_in[0] = 1'b0;
        repeat (2) @(negedge clk);
        if (ready) begin $display("ERROR: READY high while busy"); errors = errors + 1; end
        ui_in = 8'd99;                                   // must not be taken
        uio_in[0] = 1'b1; repeat (4) @(negedge clk); uio_in[0] = 1'b0;
        repeat (40) @(negedge clk);
        if (valid_count - count0 != 1) begin
            $display("ERROR: %0d VALID pulses for one accepted sample", valid_count - count0);
            errors = errors + 1;
        end
        expected = model_push(50);
        if ($signed(uo_out) !== expected) begin
            $display("ERROR: after ignored STROBE y=%0d expected=%0d", $signed(uo_out), expected);
            errors = errors + 1;
        end

        $fclose(csv);
        if (errors == 0) $display("PASS: %0d samples bit-exact vs. model through the Tiny Tapeout pins", n);
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end

endmodule

`default_nettype wire
