// fft8.v -- 8-point complex FFT, radix-2 decimation in time.
//
//            7
//   X[k] = SUM x[n] * exp(-j*2*pi*n*k/8) / 8        k = 0..7
//           n=0
//
// (The 1/8 scaling keeps the output in the same range as the input.)
//
// Dataflow: the 8 inputs are reordered in bit-reversed order and pass through
// log2(8) = 3 stages of 4 butterflies each (fft_bfly.v):
//
//   x0 ─┐┌─ stage 1 ─┐┌─ stage 2 ─┐┌─ stage 3 ─┐
//   x4 ─┘│  span 1   ││  span 2   ││  span 4   │── X0..X7
//   x2 ─┐│  W^0      ││  W^0,W^2  ││  W^0..W^3 │   (natural order)
//   x6 ─┘│           ││           ││           │
//   ...
//
// Interface (streaming, one complex sample per clock):
//   1. LOAD:    while `in_ready`, give 8 samples x[0..7] with `in_valid`.
//   2. COMPUTE: one clock; the butterfly network is purely combinational.
//   3. UNLOAD:  8 cycles with `out_valid` high, `out_idx` = k, X[k] on out_*.
//
// Widths: inputs are W-bit Q1.(W-1). Internally IW = W+1 bits: a complex
// value with |re|,|im| < 1 can have magnitude up to sqrt(2), and the FFT
// preserves magnitude, so one extra integer bit is needed. Outputs are IW bits.

`timescale 1ns/1ps
`default_nettype none

module fft8 #(
    parameter W = 16
) (
    input  wire                clk,
    input  wire                rst_n,
    input  wire                in_valid,
    output wire                in_ready,
    input  wire signed [W-1:0] in_re,
    input  wire signed [W-1:0] in_im,
    output reg                 out_valid,
    output reg  [2:0]          out_idx,
    output reg  signed [W:0]   out_re,
    output reg  signed [W:0]   out_im
);

    localparam IW = W + 1;
    localparam [1:0] S_LOAD = 2'd0, S_COMPUTE = 2'd1, S_UNLOAD = 2'd2;

    reg [1:0] state;
    reg [2:0] cnt;

    // Sample buffer (natural order) and result buffer, as flat vectors:
    // element i lives at [i*IW +: IW].
    reg  [8*IW-1:0] x_re, x_im;
    reg  [8*IW-1:0] y_re, y_im;

    // Stage outputs. s0 is the input in bit-reversed order.
    wire [8*IW-1:0] s0_re, s0_im, s1_re, s1_im, s2_re, s2_im, s3_re, s3_im;

    genvar i, g, j;
    generate
        // Bit reversal of a 3-bit index: 1 (001) -> 4 (100), 3 (011) -> 6 (110)
        for (i = 0; i < 8; i = i + 1) begin : g_bitrev
            localparam integer R = ((i & 1) << 2) | (i & 2) | ((i >> 2) & 1);
            assign s0_re[i*IW +: IW] = x_re[R*IW +: IW];
            assign s0_im[i*IW +: IW] = x_im[R*IW +: IW];
        end

        // Stage 1: span 1, all twiddles W^0
        for (g = 0; g < 4; g = g + 1) begin : g_st1
            fft_bfly #(.IW(IW), .K(0)) bf (
                .a_re (s0_re[(2*g)*IW +: IW]),   .a_im (s0_im[(2*g)*IW +: IW]),
                .b_re (s0_re[(2*g+1)*IW +: IW]), .b_im (s0_im[(2*g+1)*IW +: IW]),
                .y0_re(s1_re[(2*g)*IW +: IW]),   .y0_im(s1_im[(2*g)*IW +: IW]),
                .y1_re(s1_re[(2*g+1)*IW +: IW]), .y1_im(s1_im[(2*g+1)*IW +: IW])
            );
        end

        // Stage 2: span 2, twiddles W^0 and W^2
        for (g = 0; g < 2; g = g + 1) begin : g_st2
            for (j = 0; j < 2; j = j + 1) begin : g_j
                fft_bfly #(.IW(IW), .K(2*j)) bf (
                    .a_re (s1_re[(4*g+j)*IW +: IW]),   .a_im (s1_im[(4*g+j)*IW +: IW]),
                    .b_re (s1_re[(4*g+j+2)*IW +: IW]), .b_im (s1_im[(4*g+j+2)*IW +: IW]),
                    .y0_re(s2_re[(4*g+j)*IW +: IW]),   .y0_im(s2_im[(4*g+j)*IW +: IW]),
                    .y1_re(s2_re[(4*g+j+2)*IW +: IW]), .y1_im(s2_im[(4*g+j+2)*IW +: IW])
                );
            end
        end

        // Stage 3: span 4, twiddles W^0..W^3
        for (j = 0; j < 4; j = j + 1) begin : g_st3
            fft_bfly #(.IW(IW), .K(j)) bf (
                .a_re (s2_re[j*IW +: IW]),     .a_im (s2_im[j*IW +: IW]),
                .b_re (s2_re[(j+4)*IW +: IW]), .b_im (s2_im[(j+4)*IW +: IW]),
                .y0_re(s3_re[j*IW +: IW]),     .y0_im(s3_im[j*IW +: IW]),
                .y1_re(s3_re[(j+4)*IW +: IW]), .y1_im(s3_im[(j+4)*IW +: IW])
            );
        end
    endgenerate

    assign in_ready = (state == S_LOAD);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_LOAD;
            cnt       <= 3'd0;
            x_re      <= 0;  x_im <= 0;
            y_re      <= 0;  y_im <= 0;
            out_valid <= 1'b0;
            out_idx   <= 3'd0;
            out_re    <= 0;  out_im <= 0;
        end else begin
            out_valid <= 1'b0;
            case (state)
                S_LOAD: if (in_valid) begin
                    // Sign-extend each W-bit input to IW bits
                    x_re[cnt*IW +: IW] <= {in_re[W-1], in_re};
                    x_im[cnt*IW +: IW] <= {in_im[W-1], in_im};
                    cnt <= cnt + 1'b1;
                    if (cnt == 3'd7) state <= S_COMPUTE;
                end
                S_COMPUTE: begin
                    y_re  <= s3_re;
                    y_im  <= s3_im;
                    state <= S_UNLOAD;
                end
                S_UNLOAD: begin
                    out_valid <= 1'b1;
                    out_idx   <= cnt;
                    out_re    <= y_re[cnt*IW +: IW];
                    out_im    <= y_im[cnt*IW +: IW];
                    cnt       <= cnt + 1'b1;
                    if (cnt == 3'd7) state <= S_LOAD;
                end
                default: state <= S_LOAD;
            endcase
        end
    end

endmodule

`default_nettype wire
