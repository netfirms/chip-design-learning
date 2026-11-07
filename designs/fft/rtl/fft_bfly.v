// fft_bfly.v -- one radix-2 decimation-in-time butterfly with a fixed twiddle.
//
//        a ----------(+)---- >>1 ---> y0 = (a + W*b) / 2
//                  \ /
//                   X
//                  / \
//   b -- (x W^k) --(-)---- >>1 ---> y1 = (a - W*b) / 2
//
// W^k = exp(-j*2*pi*k/8) for an 8-point FFT. Because N = 8 there are only
// four twiddles, and each is cheap:
//   k=0:  1               (no multiply)
//   k=2: -j               (swap re/im and negate: no multiply)
//   k=1:  c*(1 - j)       c = sqrt(2)/2, one constant multiply per component
//   k=3:  c*(-1 - j)
// Dividing by 2 in every stage (3 stages -> 1/8 overall) stops the values
// from growing, so the data width can stay fixed (see docs/fixed-point.md).

`timescale 1ns/1ps
`default_nettype none

module fft_bfly #(
    parameter IW = 17,     // internal data width
    parameter K  = 0       // twiddle index 0..3 (W8^K)
) (
    input  wire signed [IW-1:0] a_re, a_im,
    input  wire signed [IW-1:0] b_re, b_im,
    output wire signed [IW-1:0] y0_re, y0_im,
    output wire signed [IW-1:0] y1_re, y1_im
);

    // sqrt(2)/2 in Q1.15
    localparam signed [16:0] C = 17'sd23170;

    // Sign-extend b by one bit so b_re +/- b_im cannot overflow
    wire signed [IW:0] br = {b_re[IW-1], b_re};
    wire signed [IW:0] bi = {b_im[IW-1], b_im};
    wire signed [IW:0] sum  = br + bi;
    wire signed [IW:0] diff = bi - br;

    // Constant multiplies, scaled back down by 2^15 (truncation).
    // Only some bits of the products and sums are kept on purpose, so tell
    // the linter that the unused bits are intentional.
    /* verilator lint_off UNUSEDSIGNAL */
    wire signed [IW+17:0] c_sum  = sum  * C;
    wire signed [IW+17:0] c_diff = diff * C;
    wire signed [IW:0]    cs = c_sum[IW+15:15];
    wire signed [IW:0]    cd = c_diff[IW+15:15];

    // t = W^K * b
    wire signed [IW:0] t_re, t_im;
    generate
        if (K == 0) begin : g_w0
            assign t_re = br;
            assign t_im = bi;
        end else if (K == 1) begin : g_w1
            assign t_re = cs;      //  c*(re + im)
            assign t_im = cd;      //  c*(im - re)
        end else if (K == 2) begin : g_w2
            assign t_re = bi;      //  im
            assign t_im = -br;     // -re
        end else begin : g_w3
            assign t_re = cd;      //  c*(im - re)
            assign t_im = -cs;     // -c*(re + im)
        end
    endgenerate

    // Add/subtract with one extra bit, then halve (arithmetic shift right).
    // Bit 0 is the fraction lost by halving; the top bit is never needed
    // because |a + t| <= |a| + |b| and both have magnitude < 2^(IW-1).
    wire signed [IW+1:0] s0_re = {a_re[IW-1], a_re[IW-1], a_re} + {t_re[IW], t_re};
    wire signed [IW+1:0] s0_im = {a_im[IW-1], a_im[IW-1], a_im} + {t_im[IW], t_im};
    wire signed [IW+1:0] s1_re = {a_re[IW-1], a_re[IW-1], a_re} - {t_re[IW], t_re};
    wire signed [IW+1:0] s1_im = {a_im[IW-1], a_im[IW-1], a_im} - {t_im[IW], t_im};

    assign y0_re = s0_re[IW:1];
    assign y0_im = s0_im[IW:1];
    assign y1_re = s1_re[IW:1];
    assign y1_im = s1_im[IW:1];
    /* verilator lint_on UNUSEDSIGNAL */

endmodule

`default_nettype wire
