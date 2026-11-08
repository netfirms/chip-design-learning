// minirv.v -- a small multi-cycle RISC-V CPU (RV32I).
//
// This is a complete 32-bit RISC-V processor: it runs code compiled by an
// ordinary C compiler (riscv64-unknown-elf-gcc -march=rv32i). It implements
// all 37 user-level RV32I instructions that a C program needs; FENCE is a
// no-op, and ECALL, EBREAK, unknown opcodes and misaligned accesses stop the
// CPU with `trap` high. There are no CSRs, interrupts or caches.
//
// The CPU is multi-cycle: one instruction moves through a small state
// machine, and only one thing happens at a time, so every signal is easy to
// follow in a waveform:
//
//   FETCH  read the instruction at pc from memory      (waits for mem_ready)
//   EXEC   decode, read rs1/rs2, run the ALU, write rd and the next pc;
//          loads and stores set up the memory access instead
//   MEM    do the load or store, write rd for a load    (waits for mem_ready)
//   TRAP   stopped
//
// With memory that answers in one cycle, ALU and branch instructions take 3
// clocks, loads and stores take 5.
//
// Memory interface (one port for instructions and data, valid/ready):
//   mem_valid  the CPU wants an access; mem_addr, mem_wdata, mem_wstrb are valid
//   mem_addr   word-aligned byte address
//   mem_wstrb  byte write enables; 0000 means a read
//   mem_ready  the memory has done the access; for a read, mem_rdata is valid
// All four outputs come straight from flip-flops, so the chip's output
// timing does not depend on the logic inside.
//
// Ports
//   clk    rising-edge clock
//   rst_n  asynchronous, active-low reset; execution starts at RESET_PC
//   trap   high once the CPU has stopped

`timescale 1ns/1ps
`default_nettype none

module minirv #(
    parameter [31:0] RESET_PC = 32'h0000_0000
) (
    input  wire        clk,
    input  wire        rst_n,

    output reg         mem_valid,
    output reg  [31:0] mem_addr,
    output reg  [31:0] mem_wdata,
    output reg  [3:0]  mem_wstrb,
    input  wire        mem_ready,
    input  wire [31:0] mem_rdata,

    output wire        trap
);

    // ---- State machine -------------------------------------------------------
    localparam [1:0] S_FETCH = 2'd0,
                     S_EXEC  = 2'd1,
                     S_MEM   = 2'd2,
                     S_TRAP  = 2'd3;

    reg [1:0]  state;
    reg [31:0] pc;
    reg [31:0] instr;     // the instruction being executed

    assign trap = (state == S_TRAP);

    // ---- Decode: fields and immediates (the RISC-V instruction formats) ---------
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire       alt    = instr[30];          // funct7[5]: SUB vs ADD, SRA vs SRL

    wire [31:0] imm_i = {{21{instr[31]}}, instr[30:20]};
    wire [31:0] imm_s = {{21{instr[31]}}, instr[30:25], instr[11:7]};
    wire [31:0] imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_u = {instr[31:12], 12'b0};
    wire [31:0] imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    localparam [6:0] OP_LUI    = 7'b0110111,
                     OP_AUIPC  = 7'b0010111,
                     OP_JAL    = 7'b1101111,
                     OP_JALR   = 7'b1100111,
                     OP_BRANCH = 7'b1100011,
                     OP_LOAD   = 7'b0000011,
                     OP_STORE  = 7'b0100011,
                     OP_IMM    = 7'b0010011,
                     OP_REG    = 7'b0110011,
                     OP_FENCE  = 7'b0001111;

    wire is_lui    = (opcode == OP_LUI);
    wire is_auipc  = (opcode == OP_AUIPC);
    wire is_jal    = (opcode == OP_JAL);
    wire is_jalr   = (opcode == OP_JALR);
    wire is_branch = (opcode == OP_BRANCH);
    wire is_load   = (opcode == OP_LOAD);
    wire is_store  = (opcode == OP_STORE);
    wire is_imm    = (opcode == OP_IMM);
    wire is_reg    = (opcode == OP_REG);
    wire is_fence  = (opcode == OP_FENCE);
    // Anything else (ECALL, EBREAK, CSRs, unknown opcodes) is not supported.
    wire is_known  = is_lui | is_auipc | is_jal | is_jalr | is_branch |
                     is_load | is_store | is_imm | is_reg | is_fence;

    // ---- Register file: x1..x31, x0 is always zero -------------------------------
    // 31 x 32 = 992 flip-flops: by far the biggest part of this CPU.
    reg  [31:0] regs [1:31];
    wire [31:0] rs1_val = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    wire [31:0] rs2_val = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

    reg         rd_we;      // write rd this cycle
    reg  [31:0] rd_val;     // with this value

    always @(posedge clk)
        if (rd_we && rd != 5'd0)
            regs[rd] <= rd_val;

    // ---- ALU: register-register and register-immediate operations ---------------
    wire [31:0] alu_b   = is_reg ? rs2_val : imm_i;
    wire [4:0]  shamt   = alu_b[4:0];
    wire        lt_s    = $signed(rs1_val) < $signed(alu_b);
    wire        lt_u    = rs1_val < alu_b;
    reg  [31:0] alu_out;

    always @* begin
        case (funct3)
            3'b000:  alu_out = (is_reg && alt) ? rs1_val - alu_b : rs1_val + alu_b; // ADD/SUB
            3'b001:  alu_out = rs1_val << shamt;                                     // SLL
            3'b010:  alu_out = {31'd0, lt_s};                                        // SLT
            3'b011:  alu_out = {31'd0, lt_u};                                        // SLTU
            3'b100:  alu_out = rs1_val ^ alu_b;                                      // XOR
            3'b101:  alu_out = alt ? $unsigned($signed(rs1_val) >>> shamt)           // SRA
                                   : rs1_val >> shamt;                               // SRL
            3'b110:  alu_out = rs1_val | alu_b;                                      // OR
            default: alu_out = rs1_val & alu_b;                                      // AND
        endcase
    end

    // ---- Branches and jumps ------------------------------------------------------
    reg take_branch;
    always @* begin
        case (funct3)
            3'b000:  take_branch = (rs1_val == rs2_val);                    // BEQ
            3'b001:  take_branch = (rs1_val != rs2_val);                    // BNE
            3'b100:  take_branch = ($signed(rs1_val) <  $signed(rs2_val));  // BLT
            3'b101:  take_branch = ($signed(rs1_val) >= $signed(rs2_val));  // BGE
            3'b110:  take_branch = (rs1_val <  rs2_val);                    // BLTU
            3'b111:  take_branch = (rs1_val >= rs2_val);                    // BGEU
            default: take_branch = 1'b0;
        endcase
    end

    wire [31:0] pc_plus4  = pc + 32'd4;
    wire [31:0] jalr_dest = (rs1_val + imm_i) & ~32'd1;
    wire [31:0] next_pc   = is_jal                    ? pc + imm_j :
                            is_jalr                   ? jalr_dest  :
                            (is_branch && take_branch) ? pc + imm_b :
                                                        pc_plus4;

    // ---- Loads and stores --------------------------------------------------------
    wire [31:0] ls_addr = rs1_val + (is_store ? imm_s : imm_i);
    wire [1:0]  ls_byte = ls_addr[1:0];        // byte offset inside the word

    // funct3[1:0]: 00 byte, 01 halfword, 10 word. Halfwords must be 2-byte
    // aligned and words 4-byte aligned.
    wire ls_misaligned = (funct3[1:0] == 2'b01 && ls_byte[0]) ||
                         (funct3[1:0] == 2'b10 && ls_byte != 2'b00) ||
                         (funct3[1:0] == 2'b11);
    wire pc_misaligned = (next_pc[1:0] != 2'b00);

    // Stores: move the data to its byte lane and enable only those bytes.
    wire [31:0] st_data = (funct3[1:0] == 2'b00) ? {4{rs2_val[7:0]}}  :
                          (funct3[1:0] == 2'b01) ? {2{rs2_val[15:0]}} : rs2_val;
    wire [3:0]  st_strb = (funct3[1:0] == 2'b00) ? (4'b0001 << ls_byte) :
                          (funct3[1:0] == 2'b01) ? (4'b0011 << ls_byte) : 4'b1111;

    // Loads: shift the addressed bytes down, then sign- or zero-extend.
    // funct3[2] is 1 for the unsigned loads LBU and LHU.
    wire [31:0] ld_shift = mem_rdata >> {ls_byte, 3'b000};
    wire [31:0] ld_data  = (funct3[1:0] == 2'b00) ? {{24{~funct3[2] & ld_shift[7]}},  ld_shift[7:0]}  :
                           (funct3[1:0] == 2'b01) ? {{16{~funct3[2] & ld_shift[15]}}, ld_shift[15:0]} :
                                                    ld_shift;

    // ---- What to write to rd -------------------------------------------------------
    always @* begin
        rd_we  = 1'b0;
        rd_val = alu_out;
        if (state == S_EXEC) begin
            rd_we = is_lui | is_auipc | is_jal | is_jalr | is_imm | is_reg;
            if      (is_lui)             rd_val = imm_u;
            else if (is_auipc)           rd_val = pc + imm_u;
            else if (is_jal || is_jalr)  rd_val = pc_plus4;
        end else if (state == S_MEM) begin
            rd_we  = is_load & mem_ready;
            rd_val = ld_data;
        end
    end

    // ---- Sequencer -------------------------------------------------------------------
    wire exec_trap = !is_known ||
                     ((is_load || is_store) && ls_misaligned) ||
                     ((is_jal || is_jalr || is_branch) && pc_misaligned);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_FETCH;
            pc        <= RESET_PC;
            instr     <= 32'h0000_0013;     // NOP (addi x0, x0, 0)
            mem_valid <= 1'b1;              // fetch the first instruction
            mem_addr  <= RESET_PC;
            mem_wdata <= 32'd0;
            mem_wstrb <= 4'b0000;
        end else begin
            case (state)
                S_FETCH:
                    if (mem_ready) begin
                        instr     <= mem_rdata;
                        mem_valid <= 1'b0;
                        state     <= S_EXEC;
                    end

                S_EXEC:
                    if (exec_trap) begin
                        state <= S_TRAP;
                    end else if (is_load || is_store) begin
                        mem_valid <= 1'b1;
                        mem_addr  <= {ls_addr[31:2], 2'b00};
                        mem_wdata <= st_data;
                        mem_wstrb <= is_store ? st_strb : 4'b0000;
                        state     <= S_MEM;
                    end else begin
                        pc        <= next_pc;
                        mem_valid <= 1'b1;          // fetch the next instruction
                        mem_addr  <= next_pc;
                        state     <= S_FETCH;
                    end

                S_MEM:
                    if (mem_ready) begin
                        pc        <= pc_plus4;
                        mem_addr  <= pc_plus4;      // mem_valid stays high: fetch
                        mem_wstrb <= 4'b0000;
                        state     <= S_FETCH;
                    end

                default: ;                          // S_TRAP: stay stopped
            endcase
        end
    end

endmodule

`default_nettype wire
