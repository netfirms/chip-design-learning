// iir.v -- 2nd-order IIR low-pass filter ("biquad"), Direct Form I.
//
//   y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2] - a1*y[n-1] - a2*y[n-2]
//
//   H(z) = (b0 + b1 z^-1 + b2 z^-2) / (1 + a1 z^-1 + a2 z^-2)
//
// A 2nd-order Butterworth low-pass with cutoff 0.05*fs, designed by
// python/dsp_coeffs.py with the bilinear transform. Two poles give the same
// roll-off as a much longer FIR, for 5 multipliers instead of 16 -- the price
// is feedback: the output depends on previous outputs, so rounding errors
// recirculate, coefficients must keep the poles inside the unit circle, and
// the loop cannot simply be pipelined to raise the clock rate.
//
// Number formats (see docs/fixed-point.md):
//   x, y           : signed Q1.15
//   b0..b2, a1, a2 : signed Q2.14 (a1 = -1.561 needs an integer bit)
//   acc            : signed, 36 bits (five 32-bit products + guard bits)
//
// Architecture: fully parallel. All five products are computed in the same
// cycle, so the filter accepts a new sample every clock (compare with the
// time-shared MAC in designs/fir). Because the coefficients are constants,
// synthesis turns each "multiplier" into a few shifts and adds.
//
// Handshake: drive `in_sample` with `in_valid`; one cycle later `out_valid`
// is high and `out_sample` holds y[n].

`timescale 1ns/1ps
`default_nettype none

module iir #(
    parameter W = 16
) (
    input  wire                clk,
    input  wire                rst_n,
    input  wire                in_valid,
    input  wire signed [W-1:0] in_sample,
    output reg                 out_valid,
    output reg  signed [W-1:0] out_sample
);

    localparam FRAC = 14;          // coefficient fractional bits (Q2.14)
    localparam AW   = 2 * W + 4;   // accumulator width

    // Coefficients from python/dsp_coeffs.py (multiply by 2^-14 for real value)
    localparam signed [AW-1:0] B0 =    329;   //  0.020083
    localparam signed [AW-1:0] B1 =    658;   //  0.040167
    localparam signed [AW-1:0] B2 =    329;   //  0.020083
    localparam signed [AW-1:0] A1 = -25576;   // -1.561018
    localparam signed [AW-1:0] A2 =  10508;   //  0.641352

    // Filter state
    reg signed [W-1:0] x1, x2;   // x[n-1], x[n-2]
    reg signed [W-1:0] y1, y2;   // y[n-1], y[n-2]

    // Sign-extend a sample to accumulator width
    function signed [AW-1:0] sx;
        input signed [W-1:0] v;
        sx = {{(AW-W){v[W-1]}}, v};
    endfunction

    wire signed [AW-1:0] acc = B0 * sx(in_sample) + B1 * sx(x1) + B2 * sx(x2)
                             - A1 * sx(y1)        - A2 * sx(y2);

    // Round to nearest, drop the 14 fractional coefficient bits, saturate.
    // Saturation matters even more in an IIR than an FIR: a wrapped-around
    // output would be fed back and could make the filter oscillate.
    wire signed [AW-1:0] rounded = (acc + (1 <<< (FRAC - 1))) >>> FRAC;
    localparam signed [AW-1:0] YMAX =  (1 <<< (W - 1)) - 1;
    localparam signed [AW-1:0] YMIN = -(1 <<< (W - 1));
    wire signed [W-1:0] y = (rounded > YMAX) ? YMAX[W-1:0] :
                            (rounded < YMIN) ? YMIN[W-1:0] :
                                               rounded[W-1:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x1 <= 0; x2 <= 0; y1 <= 0; y2 <= 0;
            out_valid  <= 1'b0;
            out_sample <= 0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                x2 <= x1;  x1 <= in_sample;
                y2 <= y1;  y1 <= y;
                out_sample <= y;
            end
        end
    end

endmodule

`default_nettype wire
