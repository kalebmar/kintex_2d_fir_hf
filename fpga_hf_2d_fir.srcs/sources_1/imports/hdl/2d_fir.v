`timescale 1ns / 1ps

/**
 * Latency Breakdown:
 * DSP Chain: 11 cycles
 * Saturation: 1 cycle
 * Total: 12 cycles
 */

module two_d_fir (
    input clk,
    input rst,

    input [7:0] sample_0,
    input [7:0] sample_1,
    input [7:0] sample_2,
    input [7:0] sample_3,
    input [7:0] sample_4,

    input signed [15:0] coeff_0_0,
    input signed [15:0] coeff_0_1,
    input signed [15:0] coeff_0_2,
    input signed [15:0] coeff_0_3,
    input signed [15:0] coeff_0_4,

    input signed [15:0] coeff_1_0,
    input signed [15:0] coeff_1_1,
    input signed [15:0] coeff_1_2,
    input signed [15:0] coeff_1_3,
    input signed [15:0] coeff_1_4,

    input signed [15:0] coeff_2_0,
    input signed [15:0] coeff_2_1,
    input signed [15:0] coeff_2_2,
    input signed [15:0] coeff_2_3,
    input signed [15:0] coeff_2_4,

    input signed [15:0] coeff_3_0,
    input signed [15:0] coeff_3_1,
    input signed [15:0] coeff_3_2,
    input signed [15:0] coeff_3_3,
    input signed [15:0] coeff_3_4,

    input signed [15:0] coeff_4_0,
    input signed [15:0] coeff_4_1,
    input signed [15:0] coeff_4_2,
    input signed [15:0] coeff_4_3,
    input signed [15:0] coeff_4_4,

    output [7:0] fir_out
);

  wire signed [28:0] dsp_chain_out_connect[4:0];


  dsp_chain chain_0 (
      .clk(clk),
      .rst(rst),
      .sample(sample_0),
      .coeff_0(coeff_0_0),
      .coeff_1(coeff_0_1),
      .coeff_2(coeff_0_2),
      .coeff_3(coeff_0_3),
      .coeff_4(coeff_0_4),
      .dsp_chain_out(dsp_chain_out_connect[0])
  );

  dsp_chain chain_1 (
      .clk(clk),
      .rst(rst),
      .sample(sample_1),
      .coeff_0(coeff_1_0),
      .coeff_1(coeff_1_1),
      .coeff_2(coeff_1_2),
      .coeff_3(coeff_1_3),
      .coeff_4(coeff_1_4),
      .dsp_chain_out(dsp_chain_out_connect[1])
  );

  dsp_chain chain_2 (
      .clk(clk),
      .rst(rst),
      .sample(sample_2),
      .coeff_0(coeff_2_0),
      .coeff_1(coeff_2_1),
      .coeff_2(coeff_2_2),
      .coeff_3(coeff_2_3),
      .coeff_4(coeff_2_4),
      .dsp_chain_out(dsp_chain_out_connect[2])
  );

  dsp_chain chain_3 (
      .clk(clk),
      .rst(rst),
      .sample(sample_3),
      .coeff_0(coeff_3_0),
      .coeff_1(coeff_3_1),
      .coeff_2(coeff_3_2),
      .coeff_3(coeff_3_3),
      .coeff_4(coeff_3_4),
      .dsp_chain_out(dsp_chain_out_connect[3])
  );

  dsp_chain chain_4 (
      .clk(clk),
      .rst(rst),
      .sample(sample_4),
      .coeff_0(coeff_4_0),
      .coeff_1(coeff_4_1),
      .coeff_2(coeff_4_2),
      .coeff_3(coeff_4_3),
      .coeff_4(coeff_4_4),
      .dsp_chain_out(dsp_chain_out_connect[4])
  );


  wire signed [28:0] dsp_chain_sum;

  assign dsp_chain_sum =  dsp_chain_out_connect[0] +
                          dsp_chain_out_connect[1] +
                          dsp_chain_out_connect[2] +
                          dsp_chain_out_connect[3] +
                          dsp_chain_out_connect[4];


  reg [7:0] sat;

  always @(posedge clk)
    if (dsp_chain_sum[28]) 
      sat <= 8'b0;
    else 
      sat <= dsp_chain_sum[15:8];

  assign fir_out = sat;

endmodule
