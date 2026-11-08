// aes128.v -- iterative AES-128 encryption core (FIPS-197), one round per clock.
//
//   start  -> state = block ^ key                    (the first AddRoundKey)
//   10 clocks of: SubBytes, ShiftRows, MiColumns, AddRoundKey
//              (round 10 skips MixColumns)
//   done   -> result holds the ciphertext            (a one-clock pulse,
//             10 clocks after start)
//
// The round keys are computed on the fly, one per clock, next to the
// round: no key schedule memory. Round logic is used ten times, so the core
// has 16 S-boxes for the state and 4 for the key, 20 in all.
//
// Byte order is the one of FIPS-197: byte 0 is bits [127:120], and the state
// is filled column by column, so column c is bits [127-32c -: 32] and the
// byte in row r of that column is bits [127-32c-8r -: 8].
`timescale 1ns/1ps
`default_nettype none

module aes128 (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,     // one clock: latch key and block, begin
    input  wire [127:0] key,
    input  wire [127:0] block,     // plaintext
    output wire [127:0] result,    // ciphertext: valid from done until the next start
    output reg          done,      // one-clock pulse, 10 clocks after start
    output wire         busy
);
    // ---- GF(2^8) helpers: multiply by 2 and by 3 -------------------------
    function automatic [7:0] xtime(input [7:0] b);
        xtime = {b[6:0], 1'b0} ^ (b[7] ? 8'h1b : 8'h00);
    endfunction

    // MixColumns on one column: a matrix multiply in GF(2^8), only XORs
    function automatic [31:0] mix_col(input [31:0] c);
        reg [7:0] a0, a1, a2, a3;
        begin
            {a0, a1, a2, a3} = c;
            mix_col = {xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3,
                       a0 ^ xtime(a1) ^ xtime(a2) ^ a2 ^ a3,
                       a0 ^ a1 ^ xtime(a2) ^ xtime(a3) ^ a3,
                       xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3)};
        end
    endfunction

    // ---- Registers -------------------------------------------------------
    reg [127:0] state;      // the block being encrypted
    reg [127:0] rkey;       // the current round key
    reg [7:0]   rcon;       // round constant: 01, 02, 04, ... 1b, 36
    reg [3:0]   round;      // 1..10 while busy, 0 when idle

    assign busy   = (round != 4'd0);
    assign result = state;          // after round 10 the state is the ciphertext
    wire last = (round == 4'd10);

    // ---- SubBytes: 16 S-boxes, one per byte of the state ----------------
    wire [127:0] sb;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_sub
            aes_sbox u_sbox (.a(state[8*i +: 8]), .y(sb[8*i +: 8]));
        end
    endgenerate

    // ---- ShiftRows: row r moves left by r columns. Only wires. -----------
    // byte index (FIPS order) k = r + 4c lives at bits [127-8k -: 8]
    wire [127:0] sr;
    genvar r, c;
    generate
        for (c = 0; c < 4; c = c + 1) begin : g_col
            for (r = 0; r < 4; r = r + 1) begin : g_row
                assign sr[127 - 8*(r + 4*c) -: 8] = sb[127 - 8*(r + 4*((c + r) % 4)) -: 8];
            end
        end
    endgenerate

    // ---- MixColumns, skipped in the last round ---------------------------
    wire [127:0] mc = {mix_col(sr[127:96]), mix_col(sr[95:64]),
                       mix_col(sr[63:32]),  mix_col(sr[31:0])};

    // ---- Key expansion: the next round key from the current one ----------
    // t = SubWord(RotWord(w3)) ^ {rcon, 0, 0, 0}; then a chain of XORs
    wire [31:0] w0 = rkey[127:96], w1 = rkey[95:64], w2 = rkey[63:32], w3 = rkey[31:0];
    wire [31:0] sw;
    aes_sbox u_ks0 (.a(w3[23:16]), .y(sw[31:24]));   // RotWord: bytes 1,2,3,0
    aes_sbox u_ks1 (.a(w3[15:8]),  .y(sw[23:16]));
    aes_sbox u_ks2 (.a(w3[7:0]),   .y(sw[15:8]));
    aes_sbox u_ks3 (.a(w3[31:24]), .y(sw[7:0]));
    wire [31:0] n0 = w0 ^ sw ^ {rcon, 24'h0};
    wire [31:0] n1 = w1 ^ n0;
    wire [31:0] n2 = w2 ^ n1;
    wire [31:0] n3 = w3 ^ n2;
    wire [127:0] next_key = {n0, n1, n2, n3};

    // ---- AddRoundKey: one XOR per bit ------------------------------------
    wire [127:0] round_out = (last ? sr : mc) ^ next_key;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= 128'h0;
            rkey   <= 128'h0;
            rcon   <= 8'h01;
            round  <= 4'd0;
            done   <= 1'b0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                state <= block ^ key;           // round 0: AddRoundKey only
                rkey  <= key;
                rcon  <= 8'h01;
                round <= 4'd1;
            end else if (busy) begin
                state <= round_out;
                rkey  <= next_key;
                rcon  <= xtime(rcon);
                if (last) begin
                    done   <= 1'b1;
                    round  <= 4'd0;
                end else begin
                    round <= round + 4'd1;
                end
            end
        end
    end
endmodule

`default_nettype wire
