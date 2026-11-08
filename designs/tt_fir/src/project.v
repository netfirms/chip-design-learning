/*
 * project.v -- the course FIR filter as a Tiny Tapeout project.
 *
 * Copyright (c) 2026 chip-design-learning contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * The 16-tap low-pass FIR from designs/fir (fir.v, unchanged) with its
 * sample width set to 8 bits, so one sample fits the 8 dedicated input pins
 * and one result fits the 8 dedicated output pins.
 *
 *   ui_in[7:0]   x, the input sample, signed Q1.7
 *   uo_out[7:0]  y, the latest filtered output, signed Q1.7 (held until the next one)
 *   uio[0]  in   STROBE: a rising edge loads ui_in as the next sample
 *   uio[1]  out  READY:  high when the filter can take a new sample
 *   uio[2]  out  VALID:  one-clock pulse when uo_out changes
 *   uio[3]  out  TOGGLE: flips on every new output (easy to poll from a microcontroller)
 *   uio[7:4]     unused, inputs
 *
 * STROBE comes from outside the chip (a microcontroller or a button), so it
 * is not synchronous to clk. Two flip-flops synchronise it before its
 * rising edge is detected; set ui_in up before raising STROBE and hold it
 * for at least 4 clock cycles. A sample takes 17 clock cycles, so at 50 MHz
 * the filter runs at up to ~2.9 Msample/s.
 *
 * Rename the module to tt_um_<your GitHub name>_fir before you submit: top
 * module names must be unique on the shuttle.
 */

`timescale 1ns/1ps
`default_nettype none

// TT requires the file name project.v, so the name differs from the module's
/* verilator lint_off DECLFILENAME */
module tt_um_chipcourse_fir (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // ---- STROBE: synchronise, then detect the rising edge ------------------
    reg [2:0] strobe_sync;      // [0],[1] synchroniser, [2] previous value
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) strobe_sync <= 3'b000;
        else        strobe_sync <= {strobe_sync[1:0], uio_in[0]};
    end
    wire strobe_rise = strobe_sync[1] & ~strobe_sync[2];

    // ---- The filter: designs/fir/rtl/fir.v with 8-bit samples --------------
    wire              in_ready;
    wire              out_valid;
    wire signed [7:0] out_sample;

    fir #(.W(8)) u_fir (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (strobe_rise),
        .in_ready  (in_ready),
        .in_sample (ui_in),
        .out_valid (out_valid),
        .out_sample(out_sample)
    );

    // ---- TOGGLE: a level a slow reader cannot miss ---------------------------
    reg toggle;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)         toggle <= 1'b0;
        else if (out_valid) toggle <= ~toggle;
    end

    // ---- Pins -----------------------------------------------------------------
    assign uo_out  = out_sample;
    assign uio_out = {4'b0000, toggle, out_valid, in_ready, 1'b0};
    assign uio_oe  = 8'b0000_1110;          // uio[3:1] outputs, the rest inputs

    // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
/* verilator lint_on DECLFILENAME */

`default_nettype wire
