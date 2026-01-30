`timescale 1ns / 1ps

module dsp_rgby(
input  clk_i,
input  signed [17:0] k_i,
input  [7:0] pa0_i,
input  [7:0] pa1_i,

input signed [47:0] pc_i,

output signed [47:0] p_o
    );

reg signed [17:0] k_reg[1:0];
reg [7:0] pa0_reg, pa1_reg;
reg signed [8:0] pa_res;
reg signed [26:0] m_reg;
reg signed [47:0] p_reg;

always @ (posedge clk_i)
begin
 k_reg [0] <= k_i;
 k_reg [1] <= k_reg[0];
 
 pa0_reg <= pa0_i;
 pa1_reg <= pa1_i;
 pa_res <= pa0_reg - pa1_reg;
 
 m_reg <= k_reg[1] * pa_res; 
 p_reg <= m_reg + pc_i;
end

assign p_o = p_reg;
    
endmodule
