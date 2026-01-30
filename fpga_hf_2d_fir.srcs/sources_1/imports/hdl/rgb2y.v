module rgb2y (
    input clk,

    input signed [17:0] kr_i,
    input signed [17:0] kb_i,

    input       dv_i,
    input       hs_i,
    input       vs_i,
    input [7:0] r_i,
    input [7:0] g_i,
    input [7:0] b_i,

    output       dv_o,
    output       hs_o,
    output       vs_o,
    output [7:0] y_o
);


  integer i;
  reg [7:0] g_dl[2:0];

  always @(posedge clk) 
    for (i = 0; i < 3; i = i + 1) g_dl[i] <= (i == 0) ? g_i : g_dl[i-1];

  wire signed [47:0] p_o[1:0];
  dsp_rgby dsp_0 (
      .clk_i(clk),
      .k_i  (kr_i),
      .pa0_i(r_i),
      .pa1_i(g_i),
      .pc_i ({23'b0, g_dl[2], 17'b0}),
      .p_o  (p_o[0])
  );

  dsp_rgby dsp_1 (
      .clk_i(clk),
      .k_i  (kb_i),
      .pa0_i(b_i),
      .pa1_i(g_i),
      .pc_i (p_o[0]),
      .p_o  (p_o[1])
  );

  reg [7:0] sat;
  always @(posedge clk)
    if (p_o[1][47]) 
        sat <= 8'b0;
    else
        sat <= p_o[1][24:17];

  assign y_o = sat;

  reg [5:0] hs_dl;
  reg [5:0] vs_dl;
  reg [5:0] dv_dl;

  always @(posedge clk)
    for (i = 0; i < 6; i = i + 1) begin
      hs_dl[i] <= (i == 0) ? hs_i : hs_dl[i-1];
      vs_dl[i] <= (i == 0) ? vs_i : vs_dl[i-1];
      dv_dl[i] <= (i == 0) ? dv_i : dv_dl[i-1];
    end

  assign hs_o = hs_dl[5];
  assign vs_o = vs_dl[5];
  assign dv_o = dv_dl[5];

endmodule
