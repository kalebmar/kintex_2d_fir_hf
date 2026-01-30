`timescale 1ns / 1ps

/**
 * Latency Breakdown:
 * - Initial Latency (7 cycles): The first response appears at 'dsp_chain_out' 7 cycles 
 * after reset. This represents the shortest path through the cascade (PCI) chain.
 * - Full Settling Time (11 cycles): The output is mathematically fully valid after 
 * 11 cycles, once the cumulative sample delay line (sum of all SAMPLE_DELAY + 
 * final stage registers) is completely filled.
 */

module dsp_chain (
    input clk,
    input rst, // Synchronous reset: clears all internal delay lines and registers


    input [7:0] sample,
    input signed [15:0] coeff_0,
    input signed [15:0] coeff_1,
    input signed [15:0] coeff_2,
    input signed [15:0] coeff_3,
    input signed [15:0] coeff_4,
    output signed [28:0] dsp_chain_out
);

  wire [7:0] dsp_sample_connect[3:0];
  wire signed [28:0] dsp_out_connect[4:0];

  dsp #(
      .SAMPLE_DELAY(1)
  ) dsp_0 (
      .clk(clk),
      .rst(rst),

      .sample_in(sample),
      .coeff(coeff_0),
      .pci(29'b0),
      .sample_out(dsp_sample_connect[0]),
      .out(dsp_out_connect[0])
  );

  dsp #(
      .SAMPLE_DELAY(2)
  ) dsp_1 (
      .clk(clk),
      .rst(rst),

      .sample_in(dsp_sample_connect[0]),
      .coeff(coeff_1),
      .pci(dsp_out_connect[0]),
      .sample_out(dsp_sample_connect[1]),
      .out(dsp_out_connect[1])
  );

  dsp #(
      .SAMPLE_DELAY(2)
  ) dsp_2 (
      .clk(clk),
      .rst(rst),

      .sample_in(dsp_sample_connect[1]),
      .coeff(coeff_2),
      .pci(dsp_out_connect[1]),
      .sample_out(dsp_sample_connect[2]),
      .out(dsp_out_connect[2])
  );

  dsp #(
      .SAMPLE_DELAY(2)
  ) dsp_3 (
      .clk(clk),
      .rst(rst),

      .sample_in(dsp_sample_connect[2]),
      .coeff(coeff_3),
      .pci(dsp_out_connect[2]),
      .sample_out(dsp_sample_connect[3]),
      .out(dsp_out_connect[3])
  );

  dsp #(
      .SAMPLE_DELAY(2)
  ) dsp_4 (
      .clk(clk),
      .rst(rst),

      .sample_in(dsp_sample_connect[3]),
      .coeff(coeff_4),
      .pci(dsp_out_connect[3]),
      .sample_out(),
      .out(dsp_out_connect[4])
  );

  assign dsp_chain_out = dsp_out_connect[4];

endmodule
