// pwm_tb.v -- self-checking testbench for pwm.v
//
// For several duty values, count how many cycles the output is high in one
// full PWM period and check it equals `duty`. Also low-pass filters the PWM
// output (a digital stand-in for an RC filter) and writes it to
// build/pwm_out.csv, so `make plot` shows the "analog" level stepping.

`timescale 1ns/1ps
`default_nettype none

module pwm_tb;

    localparam WIDTH  = 6;            // 64-cycle period keeps the sim short
    localparam PERIOD = 1 << WIDTH;

    reg              clk   = 1'b0;
    reg              rst_n = 1'b0;
    reg  [WIDTH-1:0] duty  = 0;
    wire             pwm_out;
    wire             period_start;

    pwm #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .duty(duty),
        .pwm_out(pwm_out), .period_start(period_start)
    );

    always #5 clk = ~clk;

    // First-order IIR low-pass "RC filter": v += (pwm - v) / 32
    real    v_rc = 0.0;
    integer csv;
    always @(posedge clk) if (rst_n) begin
        v_rc = v_rc + ((pwm_out ? 1.0 : 0.0) - v_rc) / 32.0;
        $fwrite(csv, "%0d,%0d\n", pwm_out, $rtoi(v_rc * 1000.0));
    end

    integer errors = 0;
    integer high, k, t;
    integer duties [0:6];

    initial begin
        $dumpfile("build/pwm.vcd");
        $dumpvars(0, pwm_tb);
        csv = $fopen("build/pwm_out.csv", "w");
        $fwrite(csv, "pwm,rc_filtered_x1000\n");

        duties[0] = 0;  duties[1] = 1;  duties[2] = 16; duties[3] = 32;
        duties[4] = 48; duties[5] = 63; duties[6] = 8;

        repeat (3) @(posedge clk);
        @(negedge clk) rst_n = 1'b1;

        for (k = 0; k < 7; k = k + 1) begin
            @(negedge clk) duty = duties[k];
            // Let the new value be latched and the output pipeline settle
            repeat (2 * PERIOD) @(posedge clk);
            // Count high cycles over exactly one period
            high = 0;
            for (t = 0; t < PERIOD; t = t + 1) begin
                @(posedge clk); #1;
                if (pwm_out) high = high + 1;
            end
            if (high != duties[k]) begin
                $display("ERROR: duty=%0d but output was high %0d/%0d cycles",
                         duties[k], high, PERIOD);
                errors = errors + 1;
            end else
                $display("duty=%2d -> high %2d/%0d cycles, avg %.3f",
                         duties[k], high, PERIOD, high * 1.0 / PERIOD);
        end

        $fclose(csv);
        if (errors == 0) $display("PASS: all duty cycles exact");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end

endmodule

`default_nettype wire
