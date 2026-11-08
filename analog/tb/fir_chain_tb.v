// fir_chain_tb.v -- run real ADC samples through the course's FIR filter.
//
// The samples come from the ngspice simulation of the 8-bit flash ADC
// (analog/analog.py writes them as hex, already converted to Q1.15). This
// testbench feeds them to designs/fir/rtl/fir.v exactly as the FIR's own
// testbench does, one sample per handshake, and writes every output sample
// as a signed decimal number, one per line, for the DAC simulation.
//
//   iverilog -g2012 -o build/chain_sim tb/fir_chain_tb.v ../designs/fir/rtl/fir.v
//   vvp -n build/chain_sim +in=build/adc_q15.hex +out=build/fir_out.txt +n=288

`timescale 1ns/1ps
`default_nettype none

module fir_chain_tb;
    localparam MAXN = 4096;

    reg                clk = 1'b0;
    reg                rst_n = 1'b0;
    reg                in_valid = 1'b0;
    wire               in_ready;
    reg  signed [15:0] in_sample = 16'sd0;
    wire               out_valid;
    wire signed [15:0] out_sample;

    fir dut (
        .clk(clk), .rst_n(rst_n),
        .in_valid(in_valid), .in_ready(in_ready), .in_sample(in_sample),
        .out_valid(out_valid), .out_sample(out_sample)
    );

    always #5 clk = ~clk;   // 100 MHz, the clock the FIR is signed off at

    reg [15:0] samples [0:MAXN-1];
    reg [1023:0] in_file, out_file;
    integer n, i, fd;

    initial begin
        if (!$value$plusargs("in=%s", in_file))   in_file  = "build/adc_q15.hex";
        if (!$value$plusargs("out=%s", out_file)) out_file = "build/fir_out.txt";
        if (!$value$plusargs("n=%d", n))          n        = 288;
        $readmemh(in_file, samples, 0, n - 1);
        fd = $fopen(out_file, "w");

        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        for (i = 0; i < n; i = i + 1) begin
            while (!in_ready) @(negedge clk);
            in_sample = samples[i];
            in_valid  = 1'b1;
            @(negedge clk);
            in_valid  = 1'b0;
            while (!out_valid) @(negedge clk);
            $fdisplay(fd, "%0d", out_sample);
        end
        $fclose(fd);
        $display("fir_chain_tb: filtered %0d ADC samples", n);
        $finish;
    end
endmodule

`default_nettype wire
