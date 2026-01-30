`timescale 1ns / 1ps
module tb_bram_row();

reg clk = 1;

always #50 clk <= ~clk;


reg [8:0]in = 0;
reg [2:0]address = -1;
wire [8:0]ram_dl;
wire [8:0]out_1;
reg [8:0]out_0;

always @(posedge clk) begin
    in <= in + 1;
    address <= address + 1;
end

sp_ram_row sp_ram_i_0(
    .clk(clk),

    .en(1'b1), 
    .we(1'b1),
    .addr(address), 
    .din(in),
    .dout(ram_dl)
    );

always @(posedge clk) begin
    out_0 <= ram_dl;
end
    
sp_ram_row sp_ram_i_1(
    .clk(clk),

    .en(1'b1), 
    .we(1'b1),
    .addr(address), 
    .din(ram_dl),
    .dout(out_1)
    );
    
initial
begin
#10000;
$display("Szimuláció vége");
$finish;   // Szimuláció leállítása
end

endmodule
