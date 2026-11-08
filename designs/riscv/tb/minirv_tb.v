// minirv_tb.v -- testbench for minirv: a small "SoC" around the CPU that
// runs real programs.
//
// The testbench is the rest of the computer: 64 KB of RAM holding the
// program, and three memory-mapped registers (see firmware/link.ld):
//
//   0x1000_0000  console   a byte written here is printed
//   0x1000_0004  exit      writing here ends the program with that exit code
//   0x1000_0008  cycles    reads the clock count since reset
//
// It runs three programs and checks each one:
//   1. firmware/isa_test.hex  every RV32I instruction against the spec (assembly)
//   2. firmware/hello.hex     a C program (prints, multiplies, divides, sorts, CRC)
//   3. a one-word program     EBREAK must stop the CPU with `trap` high
//
// Options: `vvp build/sim +trace` prints every instruction as it executes.

`timescale 1ns/1ps
`default_nettype none

module minirv_tb;

    localparam RAM_WORDS = 16384;               // 64 KB
    localparam [31:0] CONSOLE = 32'h1000_0000,
                      EXIT    = 32'h1000_0004,
                      CYCLES  = 32'h1000_0008;

    reg         clk   = 1'b0;
    reg         rst_n = 1'b0;
    wire        mem_valid;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg         mem_ready = 1'b0;
    reg  [31:0] mem_rdata = 32'd0;
    wire        trap;

    minirv dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .mem_valid(mem_valid),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .trap     (trap)
    );

    always #10 clk = ~clk;                      // 50 MHz, the clock used for the layout

    // ---- Memory and I/O: answers every access one cycle later ------------------
    reg  [31:0] ram [0:RAM_WORDS-1];
    reg  [31:0] cycle = 0;
    integer     exits = 0;                      // counts writes to EXIT
    reg  [31:0] exit_code = 0;
    integer     bad_access = 0;
    integer     console_fd;
    wire [31:0] word = mem_addr >> 2;
    integer     b;

    always @(posedge clk) begin
        cycle     <= rst_n ? cycle + 1 : 0;
        mem_ready <= 1'b0;
        if (rst_n && mem_valid && !mem_ready) begin
            mem_ready <= 1'b1;
            mem_rdata <= 32'hxxxx_xxxx;
            if (word < RAM_WORDS) begin
                mem_rdata <= ram[word];
                for (b = 0; b < 4; b = b + 1)
                    if (mem_wstrb[b]) ram[word][8*b +: 8] <= mem_wdata[8*b +: 8];
            end else if (mem_addr == CONSOLE && mem_wstrb != 0) begin
                $write("%c", mem_wdata[7:0]);
                $fwrite(console_fd, "%c", mem_wdata[7:0]);
            end else if (mem_addr == EXIT && mem_wstrb != 0) begin
                exits     <= exits + 1;
                exit_code <= mem_wdata;
            end else if (mem_addr == CYCLES && mem_wstrb == 0) begin
                mem_rdata <= cycle;
            end else begin
                $display("ERROR: access to unmapped address %h (wstrb %b)", mem_addr, mem_wstrb);
                bad_access = bad_access + 1;
            end
        end
    end

    // ---- Instruction counter and optional trace --------------------------------
    // The CPU is in EXEC (state 1) for exactly one cycle per instruction.
    // It also sorts instructions into classes: the program's instruction mix.
    integer retired = 0;
    integer n_alu, n_load, n_store, n_branch, n_jump, n_upper;
    reg     trace   = 1'b0;
    always @(posedge clk)
        if (rst_n && dut.state == 2'd1) begin
            retired = retired + 1;
            case (dut.instr[6:0])
                7'b0010011, 7'b0110011: n_alu    = n_alu + 1;
                7'b0000011:             n_load   = n_load + 1;
                7'b0100011:             n_store  = n_store + 1;
                7'b1100011:             n_branch = n_branch + 1;
                7'b1101111, 7'b1100111: n_jump   = n_jump + 1;
                default:                n_upper  = n_upper + 1;   // LUI, AUIPC, others
            endcase
            if (trace) $display("  pc=%h  instr=%h", dut.pc, dut.instr);
        end

    // ---- Run one program -------------------------------------------------------
    integer errors = 0;
    integer i;

    integer exits_before;
    wire    exited = (exits != exits_before);

    task run(input [8*32-1:0] name, input integer max_cycles, input integer want_trap);
        begin
            @(negedge clk) rst_n = 1'b0;
            exits_before = exits;
            repeat (2) @(negedge clk);
            retired = 0;
            n_alu = 0; n_load = 0; n_store = 0; n_branch = 0; n_jump = 0; n_upper = 0;
            rst_n = 1'b1;
            while (!exited && !trap && cycle < max_cycles) @(negedge clk);

            if (want_trap != 0) begin
                if (!trap) begin
                    $display("ERROR %0s: the CPU did not trap", name);
                    errors = errors + 1;
                end else
                    $display("%0s: trap after %0d instructions, as expected", name, retired);
            end else if (!exited) begin
                $display("ERROR %0s: %0s at pc=%h after %0d cycles", name,
                         trap ? "trapped" : "timed out", dut.pc, cycle);
                errors = errors + 1;
            end else if (exit_code != 0) begin
                $display("ERROR %0s: exit code %0d", name, exit_code);
                errors = errors + 1;
            end else begin
                $display("%0s: exit 0 after %0d instructions, %0d cycles (CPI %0d.%02d)",
                         name, retired, cycle, cycle / retired, (100 * cycle / retired) % 100);
                $display("  mix: alu %0d, load %0d, store %0d, branch %0d, jump %0d, lui/auipc %0d",
                         n_alu, n_load, n_store, n_branch, n_jump, n_upper);
            end
        end
    endtask

    task load(input [8*64-1:0] hexfile);
        begin
            for (i = 0; i < RAM_WORDS; i = i + 1) ram[i] = 32'd0;
            $readmemh(hexfile, ram);
        end
    endtask

    initial begin
        if ($test$plusargs("trace")) trace = 1'b1;
        console_fd = $fopen("build/console.txt", "w");
        $dumpfile("build/minirv.vcd");
        $dumpvars(0, minirv_tb);

        load("firmware/isa_test.hex");
        run("isa_test", 20000, 0);

        $dumpoff;                               // keep the VCD small: only isa_test
        load("firmware/hello.hex");
        run("hello", 2000000, 0);

        for (i = 0; i < RAM_WORDS; i = i + 1) ram[i] = 32'd0;
        ram[0] = 32'h0010_0073;                 // EBREAK
        run("ebreak", 100, 1);

        errors = errors + bad_access;
        if (errors == 0)
            $display("PASS: isa_test, hello.c and ebreak, 0 errors");
        else
            $display("FAIL: %0d errors", errors);
        $fclose(console_fd);
        $finish;
    end

endmodule

`default_nettype wire
