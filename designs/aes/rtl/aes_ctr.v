// aes_ctr.v -- a private-link chip: AES-128 in counter (CTR) mode on a byte stream.
//
// Two of these chips, one at each end of a wire, with the same key and the
// same starting counter, give a private link: what goes over the wire looks
// like random bytes to anyone without the key.
//
//   sender:    wire_byte  = plain_byte  ^ keystream_byte
//   receiver:  plain_byte = wire_byte   ^ keystream_byte    (the same chip)
//   keystream: AES_K(counter), AES_K(counter + 1), ...      16 bytes a block
//
// In CTR mode the same encryption core both encrypts and decrypts, so the
// chip needs no AES decryption logic at all.
//
// Interface: one 8-bit input bus and three write strobes.
//   key_we   shift in_data into the key, most significant byte first (16 writes)
//   iv_we    shift in_data into the counter block, the same way (16 writes)
//   in_valid a data byte: out_data = in_data ^ keystream byte, one clock later,
//            with out_valid. Only accepted while in_ready is high.
// Writing the key or the counter throws away the keystream block in
// hand and starts a new one. in_ready is low for 11 clocks at the start and
// after every 16 data bytes, while the core makes the net keystream block.
//
// The low 32 bits of the counter block count up by one per block, as in
// NIST SP 800-38A appendix B.1, so the standard CTR test vectors apply.
`timescale 1ns/1ps
`default_nettype none

module aes_ctr (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] in_data,
    input  wire       key_we,
    input  wire       iv_we,
    input  wire       in_valid,
    output wire       in_ready,
    output reg  [7:0] out_data,
    output reg        out_valid
);
    reg  [127:0] key;        // secret key, shared by both ends of the link
    reg  [127:0] ctr;        // counter block for the next keystream block
    reg  [127:0] ks;         // keystream block in hand
    reg          ks_valid;   // ks holds unused bytes
    reg  [3:0]   idx;        // next keystream byte to use, 0..15
    reg          stale;      // key or counter changed while the core ran

    wire         cfg = key_we | iv_we;
    wire         core_busy, core_done;
    wire [127:0] core_out;
    wire         core_start = !ks_valid && !core_busy && !core_done && !cfg;

    aes128 u_core (
        .clk(clk), .rst_n(rst_n), .start(core_start),
        .key(key), .block(ctr),
        .result(core_out), .done(core_done), .busy(core_busy)
    );

    assign in_ready = ks_valid && !cfg;
    wire take = in_valid && in_ready;

    // keystream byte idx: byte 0 is the most significant, as in FIPS-197
    wire [7:0] ks_byte = ks[127 - 8*idx -: 8];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key       <= 128'h0;
            ctr       <= 128'h0;
            ks        <= 128'h0;
            ks_valid  <= 1'b0;
            idx       <= 4'd0;
            stale     <= 1'b0;
            out_data  <= 8'h00;
            out_valid <= 1'b0;
        end else begin
            out_valid <= take;
            if (take) out_data <= in_data ^ ks_byte;

            if (cfg) begin
                // A new key or counter: start the keystream again
                if (key_we) key <= {key[119:0], in_data};
                if (iv_we)  ctr <= {ctr[119:0], in_data};
                ks_valid <= 1'b0;
                idx      <= 4'd0;
                stale    <= core_busy && !core_done;
            end else begin
                if (core_done) begin
                    // Keep the block unless the key or counter changed meanwhile
                    if (!stale) begin
                        ks       <= core_out;
                        ks_valid <= 1'b1;
                        ctr[31:0] <= ctr[31:0] + 32'd1;
                    end
                    stale <= 1'b0;
                end
                if (take) begin
                    idx <= idx + 4'd1;
                    if (idx == 4'd15) ks_valid <= 1'b0;   // block used up
                end
            end
        end
    end
endmodule

`default_nettype wire
