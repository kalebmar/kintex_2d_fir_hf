`timescale 1ns / 1ps

module dsp #(
    parameter SAMPLE_DELAY = 2
) (
    input clk,
    input rst,

    input [7:0] sample_in,
    input signed [15:0] coeff,
    input signed [28:0] pci,
    output [7:0] sample_out,
    output signed [28:0] out
);

  integer i;
  reg [7:0] sample_dl[SAMPLE_DELAY-1 : 0];
  reg signed [15:0] coeff_reg;
  reg signed [23:0] mul_reg;
  reg signed [28:0] out_reg;

  always @(posedge clk) begin
    if (rst) 
      for (i = 0; i < SAMPLE_DELAY; i = i + 1)
        sample_dl[i] <= 8'b0;
    else
      for (i = 0; i < SAMPLE_DELAY; i = i + 1)
        sample_dl[i] <= (i == 0) ? sample_in : sample_dl[i-1];
  end

  always @(posedge clk) begin
    coeff_reg <= coeff;
  end

  always @(posedge clk) begin
    if (rst) 
      mul_reg <= 24'b0;
    else 
      mul_reg <= coeff_reg * sample_dl[SAMPLE_DELAY-1];
  end

  always @(posedge clk) begin
    if (rst) 
      out_reg <= 29'b0;
    else 
      out_reg <= mul_reg + pci;
  end

  assign sample_out = sample_dl[SAMPLE_DELAY-1];
  assign out = out_reg;

endmodule
