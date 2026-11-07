// counter_tb.v -- self-checking testbench for counter.v
//
// A good testbench does not just make waveforms for you to eyeball: it
// computes the expected result itself and stops with an error on mismatch.
// Run it with `make sim`, then open build/counter.vcd in GTKWave or Surfer.

`timescale 1ns/1ps
`default_nettype none

module counter_tb;

    localparam WIDTH  = 4;   // small width so we see a wrap-around quickly
    localparam CYCLES = 100;

    reg              clk   = 1'b0;
    reg              rst_n = 1'b0;
    reg              en    = 1'b0;
    wire [WIDTH-1:0] count;
    wire             wrap;

    // Device under test
    counter #(.WIDTH(WIDTH)) dut (
        .clk  (clk),
        .rst_n(rst_n),
        .en   (en),
        .count(count),
        .wrap (wrap)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Reference model: what we *expect* the hardware to do.
    reg [WIDTH-1:0] expected;
    integer         errors = 0;
    integer         wraps  = 0;
    integer         i;

    task check;
        begin
            if (count !== expected) begin
                $display("ERROR t=%0t: count=%0d expected=%0d", $time, count, expected);
                errors = errors + 1;
            end
            if (wrap !== (en && expected == {WIDTH{1'b1}})) begin
                $display("ERROR t=%0t: wrap=%b unexpected (count=%0d en=%b)", $time, wrap, count, en);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("build/counter.vcd");
        $dumpvars(0, counter_tb);

        // Hold reset for a few cycles
        expected = 0;
        repeat (3) @(posedge clk);
        #1 check;

        // Release reset away from the clock edge
        @(negedge clk) rst_n = 1'b1;

        // Randomly toggle enable and compare against the model every cycle
        for (i = 0; i < CYCLES; i = i + 1) begin
            @(negedge clk) en = ($random % 4) != 0;   // enabled ~75% of the time
            #1 check;
            if (wrap) wraps = wraps + 1;
            @(posedge clk);
            if (en) expected = expected + 1'b1;
            #1 check;
        end

        // Asynchronous reset in the middle of a cycle
        @(negedge clk) #2 rst_n = 1'b0;
        expected = 0;
        #1 check;

        if (wraps == 0) begin
            $display("ERROR: counter never wrapped, test is too short");
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: %0d cycles, %0d wrap-arounds, 0 errors", CYCLES, wraps);
        else
            $display("FAIL: %0d errors", errors);

        $finish;
    end

endmodule

`default_nettype wire
