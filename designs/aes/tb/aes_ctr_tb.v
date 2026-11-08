// aes_ctr_tb.v -- self-checking testbench for the AES-128 core and the CTR link chip.
//
// 1. The core alone (aes128) against the known answers of FIPS-197
//    (appendix B and C.1) and NIST SP 800-38A F.1.1 (ECB-AES128).
// 2. One link chip (aes_ctr) against SP 800-38A F.5.1 (CTR-AES128).
// 3. A private link: Alice's chip encrypts a message, the ciphertext goes
//    over the "wire", Bob's chip (same key) decrypts it, and Eve's chip
//    (wrong key) gets nothing readable.
//
// Writes build/aes_link.csv (the message, the wire and what each side reads)
// for the plots, and prints PASS or FAIL.

`timescale 1ns/1ps
`default_nettype none

module aes_ctr_tb;

    reg clk   = 1'b0;
    reg rst_n = 1'b0;
    always #5 clk = ~clk;

    integer errors = 0;

    // ---------------------------------------------------------------------
    // 1. The core on its own
    // ---------------------------------------------------------------------
    reg          c_start = 1'b0;
    reg  [127:0] c_key = 0, c_block = 0;
    wire [127:0] c_result;
    wire         c_done, c_busy;

    aes128 core (
        .clk(clk), .rst_n(rst_n), .start(c_start), .key(c_key), .block(c_block),
        .result(c_result), .done(c_done), .busy(c_busy)
    );

    integer cycles;
    task core_check(input [127:0] k, input [127:0] p, input [127:0] expect_ct, input [8*24-1:0] name);
        begin
            @(negedge clk);
            c_key = k; c_block = p; c_start = 1'b1;
            @(negedge clk);
            c_start = 1'b0;
            cycles = 0;
            while (!c_done) begin @(negedge clk); cycles = cycles + 1; end
            if (c_result !== expect_ct || cycles != 10) begin
                $display("ERROR %0s: got %h after %0d clocks, expected %h after 10",
                         name, c_result, cycles, expect_ct);
                errors = errors + 1;
            end else
                $display("  ok    %-22s %h  (%0d clocks)", name, c_result, cycles);
        end
    endtask

    // ---------------------------------------------------------------------
    // 2 and 3. Three link chips: Alice (0), Bob (1) and Eve (2)
    // ---------------------------------------------------------------------
    reg  [7:0] d   [0:2];
    reg        kwe [0:2];
    reg        ivwe[0:2];
    reg        val [0:2];
    wire       rdy [0:2];
    wire [7:0] q   [0:2];
    wire       qv  [0:2];

    genvar g;
    generate
        for (g = 0; g < 3; g = g + 1) begin : chip
            aes_ctr u (
                .clk(clk), .rst_n(rst_n), .in_data(d[g]), .key_we(kwe[g]), .iv_we(ivwe[g]),
                .in_valid(val[g]), .in_ready(rdy[g]), .out_data(q[g]), .out_valid(qv[g])
            );
        end
    endgenerate

    integer n;
    initial for (n = 0; n < 3; n = n + 1) begin
        d[n] = 0; kwe[n] = 0; ivwe[n] = 0; val[n] = 0;
    end

    // Capture every output byte of each chip, in order
    reg [7:0] outbuf [0:2][0:255];
    integer   outcnt [0:2];
    initial for (n = 0; n < 3; n = n + 1) outcnt[n] = 0;
    generate
        for (g = 0; g < 3; g = g + 1) begin : cap
            always @(posedge clk) if (qv[g]) begin
                outbuf[g][outcnt[g]] <= q[g];
                outcnt[g] <= outcnt[g] + 1;
            end
        end
    endgenerate

    // Load a 128-bit key or counter block, most significant byte first
    task load(input integer ch, input [127:0] value, input is_key);
        integer b;
        begin
            for (b = 15; b >= 0; b = b - 1) begin
                @(negedge clk);
                d[ch] = value[8*b +: 8];
                if (is_key) kwe[ch] = 1'b1; else ivwe[ch] = 1'b1;
            end
            @(negedge clk);
            kwe[ch] = 1'b0; ivwe[ch] = 1'b0;
        end
    endtask

    // Send one data byte, waiting while the chip makes a keystream block
    integer stall [0:2];
    initial for (n = 0; n < 3; n = n + 1) stall[n] = 0;
    task send(input integer ch, input [7:0] b);
        begin
            d[ch] = b; val[ch] = 1'b1;
            @(posedge clk);
            while (!rdy[ch]) begin stall[ch] = stall[ch] + 1; @(posedge clk); end
            @(negedge clk);
            val[ch] = 1'b0;
        end
    endtask

    // ---------------------------------------------------------------------
    // Test data
    // ---------------------------------------------------------------------
    localparam [127:0] SP_KEY = 128'h2b7e151628aed2a6abf7158809cf4f3c;
    localparam [127:0] SP_IV  = 128'hf0f1f2f3f4f5f6f7f8f9fafbfcfdfeff;
    localparam [4*128-1:0] SP_PT = {
        128'h6bc1bee22e409f96e93d7e117393172a, 128'hae2d8a571e03ac9c9eb76fac45af8e51,
        128'h30c81c46a35ce411e5fbc1191a0a52ef, 128'hf69f2445df4f9b17ad2b417be66c3710};
    localparam [4*128-1:0] SP_CTR = {
        128'h874d6191b620e3261bef6864990db6ce, 128'h9806f66b7970fdff8617187bb9fffdff,
        128'h5ae4df3edbd5d35e5b4f09020db03eab, 128'h1e031dda2fbe03d1792170a0f3009cee};

    // The secret message: 64 characters, 4 AES blocks
    localparam integer MLEN = 64;
    localparam [8*MLEN-1:0] MSG =
        "Meet me in the lab at 9. Hardware is the new Software. Bring GDS";
    localparam [127:0] LINK_KEY = 128'h436869702d636f757273652d6b657921;  // "Chip-course-key!"
    localparam [127:0] EVE_KEY  = 128'h00000000000000000000000000000001;
    localparam [127:0] LINK_IV  = 128'h6c696e6b2d6e6f6e63652d0000000000;  // "link-nonce-" + counter

    function [7:0] msg_byte(input integer i);   // character i of MSG, from the left
        msg_byte = MSG[8*(MLEN-1-i) +: 8];
    endfunction

    integer i, csv, base, ctr_err;
    reg [7:0] wire_b;

    initial begin
        $dumpfile("build/aes_ctr.vcd");
        $dumpvars(0, aes_ctr_tb);
        repeat (3) @(posedge clk);
        @(negedge clk) rst_n = 1'b1;

        // ---- 1. Core known answers ---------------------------------------
        $display("AES-128 core, known answers:");
        core_check(128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3243f6a8885a308d313198a2e0370734,
                   128'h3925841d02dc09fbdc118597196a0b32, "FIPS-197 appendix B");
        core_check(128'h000102030405060708090a0b0c0d0e0f, 128'h00112233445566778899aabbccddeeff,
                   128'h69c4e0d86a7b0430d8cdb78070b4c55a, "FIPS-197 C.1");
        core_check(SP_KEY, 128'h6bc1bee22e409f96e93d7e117393172a, 128'h3ad77bb40d7a3660a89ecaf32466ef97, "SP 800-38A ECB #1");
        core_check(SP_KEY, 128'hae2d8a571e03ac9c9eb76fac45af8e51, 128'hf5d3d58503b9699de785895a96fdbaaf, "SP 800-38A ECB #2");
        core_check(SP_KEY, 128'h30c81c46a35ce411e5fbc1191a0a52ef, 128'h43b1cd7f598ece23881b00e3ed030688, "SP 800-38A ECB #3");
        core_check(SP_KEY, 128'hf69f2445df4f9b17ad2b417be66c3710, 128'h7b0c785e27e8ad3f8223207104725dd4, "SP 800-38A ECB #4");

        // ---- 2. CTR known answers through the link chip -------------------
        ctr_err = errors;
        load(0, SP_KEY, 1);
        load(0, SP_IV, 0);
        for (i = 0; i < 64; i = i + 1) send(0, SP_PT[8*(63-i) +: 8]);
        repeat (2) @(posedge clk);
        for (i = 0; i < 64; i = i + 1)
            if (outbuf[0][i] !== SP_CTR[8*(63-i) +: 8]) begin
                if (errors < 20) $display("ERROR CTR byte %0d: got %h, expected %h",
                                          i, outbuf[0][i], SP_CTR[8*(63-i) +: 8]);
                errors = errors + 1;
            end
        if (outcnt[0] != 64) begin
            $display("ERROR CTR: %0d output bytes, expected 64", outcnt[0]);
            errors = errors + 1;
        end
        $display("  %0s    SP 800-38A F.5.1 CTR-AES128, 64 bytes, %0d stall clocks",
                 (errors != ctr_err) ? "FAIL" : "ok", stall[0]);

        // ---- 3. A private link: Alice -> wire -> Bob, and Eve listening ----
        base = outcnt[0];
        load(0, LINK_KEY, 1);  load(0, LINK_IV, 0);    // Alice
        load(1, LINK_KEY, 1);  load(1, LINK_IV, 0);    // Bob: the same key and counter
        load(2, EVE_KEY, 1);   load(2, LINK_IV, 0);    // Eve: knows the counter, not the key
        for (i = 0; i < MLEN; i = i + 1) send(0, msg_byte(i));
        repeat (2) @(posedge clk);
        for (i = 0; i < MLEN; i = i + 1) begin
            wire_b = outbuf[0][base + i];
            send(1, wire_b);
            send(2, wire_b);
        end
        repeat (2) @(posedge clk);

        csv = $fopen("build/aes_link.csv", "w");
        $fwrite(csv, "i,plain,wire,bob,eve\n");
        $write("\nAlice sends: ");
        for (i = 0; i < MLEN; i = i + 1) $write("%c", msg_byte(i));
        $write("\nOn the wire: ");
        for (i = 0; i < 24; i = i + 1) $write("%h ", outbuf[0][base + i]);
        $write("...\nBob reads:   ");
        for (i = 0; i < MLEN; i = i + 1) $write("%c", outbuf[1][i]);
        $write("\nEve reads:   ");
        for (i = 0; i < MLEN; i = i + 1)
            $write("%c", (outbuf[2][i] >= 8'h20 && outbuf[2][i] < 8'h7f) ? outbuf[2][i] : 8'h2e);
        $write("\n\n");
        for (i = 0; i < MLEN; i = i + 1) begin
            $fwrite(csv, "%0d,%0d,%0d,%0d,%0d\n", i, msg_byte(i), outbuf[0][base + i],
                    outbuf[1][i], outbuf[2][i]);
            if (outbuf[1][i] !== msg_byte(i)) errors = errors + 1;
            if (outbuf[0][base + i] === msg_byte(i) && i < 16) begin
                $display("ERROR: byte %0d went over the wire in clear", i);
                errors = errors + 1;
            end
        end
        $fclose(csv);
        if (outbuf[2][0] === msg_byte(0) && outbuf[2][1] === msg_byte(1) && outbuf[2][2] === msg_byte(2)) begin
            $display("ERROR: Eve read the message without the key");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: 6 core known answers, SP 800-38A CTR, Alice -> Bob over a private link, 0 errors");
        else
            $display("FAIL: %0d errors", errors);
        $finish;
    end

    initial begin
        #2_000_000;
        $display("FAIL: timeout");
        $finish;
    end
endmodule

`default_nettype wire
