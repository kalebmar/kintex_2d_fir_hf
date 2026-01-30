`timescale 1ns / 1ps

module tb_bram_block(    );


reg clk = 1;
reg rst;


always #50 clk <= ~clk;

initial
begin
    #0
    rst = 1;
    #150
    rst = 0;
end

wire [7:0] data_out[4:0];
reg [7:0] y;
reg hsync_i, vsync_i, dv_i;
wire hsync_o, vsync_o, dv_o;

reg [9:0]row; //max 1023
reg [9:0]col; //max 1023

always @(posedge clk) begin
    if(rst | (col == 10'd22))
        col <= 10'b0;
    else 
        col <= col + 1;
end

always @(posedge clk) begin
     if(rst | (row == 10'd22))
        row <= 10'b0;
    else if(col == 10'd22)
        row <= row + 1;    
end

always @(posedge clk) begin
    if(col == 10'd19 | col == 10'd20)
        hsync_i <= 1'b1;
    else 
        hsync_i <= 1'b0;
end


always @(posedge clk) begin
    if(row == 10'd18 | row == 10'd19)
        vsync_i <= 1'b1;
    else 
        vsync_i <= 1'b0;
end


always @(posedge clk) begin
    if(rst)
        dv_i <= 1'b0;
    else if((col < 10'd16) && (row < 10'd16))
    begin
        dv_i <= 1'b1;
        y <= col + 16 * row;
    end
    else
    begin
        dv_i <= 1'b0;
        y <= 8'b0;
    end
end

sp_ram_block ram_block_i(
    .clk(clk),
    .rst(rst),

    .en(1'b1),
    .we(1'b1),

    .hsync_i(hsync_i),
    .vsync_i(vsync_i),
    .dv_i(dv_i),

    .data_in(y),

    .hsync_o(hsync_o),
    .vsync_o(vsync_o),
    .dv_o(dv_o),

    .data_out_0(data_out[0]),
    .data_out_1(data_out[1]),
    .data_out_2(data_out[2]),
    .data_out_3(data_out[3]),
    .data_out_4(data_out[4])
);

initial
begin
#1000000;
$display("Szimuláció vége");
$finish;   // Szimuláció leállítása
end

endmodule
