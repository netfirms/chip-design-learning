// pwm.v -- pulse-width modulator.
//
// The digital way to make an "analog" level: switch an output on for `duty`
// out of every 2^WIDTH clock cycles. After an RC low-pass filter (or the
// inertia of a motor, or your eye looking at an LED) the average voltage is
//
//     V_avg = VDD * duty / 2^WIDTH
//
// so this is also the simplest possible DAC. With a 100 MHz clock and
// WIDTH = 8 the PWM frequency is 100 MHz / 256 = 390.6 kHz.
//
// `duty` is sampled once per period (when the counter wraps), so changing
// it mid-period never produces a glitch -- the same "double buffering"
// idea used in every microcontroller timer peripheral.

`timescale 1ns/1ps
`default_nettype none

module pwm #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] duty,     // 0 = always off, 2^WIDTH-1 = on 255/256
    output reg              pwm_out,
    output wire             period_start  // one-cycle pulse at the start of each period
);

    reg [WIDTH-1:0] cnt;
    reg [WIDTH-1:0] duty_q;   // duty value latched for the current period

    assign period_start = (cnt == {WIDTH{1'b0}});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= {WIDTH{1'b0}};
            duty_q  <= {WIDTH{1'b0}};
            pwm_out <= 1'b0;
        end else begin
            cnt <= cnt + 1'b1;
            // Latch a new duty cycle at the end of the period so it takes
            // effect cleanly from the next period_start.
            if (cnt == {WIDTH{1'b1}})
                duty_q <= duty;
            // Registered output: one cycle of latency, but the pin is driven
            // straight from a flip-flop, so it cannot glitch.
            pwm_out <= (cnt < duty_q);
        end
    end

endmodule

`default_nettype wire
