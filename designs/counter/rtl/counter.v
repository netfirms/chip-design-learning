// counter.v -- a parameterised up-counter.
//
// This is the "hello world" of digital design. It is small enough to read in
// one sitting, but it still exercises every stage of the RTL-to-GDS flow:
// simulation, linting, synthesis, static timing analysis and place & route.
//
// Ports
//   clk    : rising-edge clock
//   rst_n  : asynchronous, active-low reset (count goes to 0)
//   en     : count enable; when low the counter holds its value
//   count  : current count value
//   wrap   : high for one cycle when the counter rolls over from max to 0

`timescale 1ns/1ps
`default_nettype none

module counter #(
    parameter WIDTH = 8
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output reg  [WIDTH-1:0] count,
    output wire             wrap
);

    // The counter is at its maximum value when every bit is 1.
    wire at_max = &count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (en)
            count <= count + 1'b1;
    end

    // Combinational output: "the next clock edge will wrap".
    assign wrap = en & at_max;

endmodule

`default_nettype wire
