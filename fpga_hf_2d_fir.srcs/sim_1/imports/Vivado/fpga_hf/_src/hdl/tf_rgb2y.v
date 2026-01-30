`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 11:13:08 AM
// Design Name: 
// Module Name: tf_rgb2y
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tf_rgb2y();

reg                 clk = 0;
    
reg   signed [17:0] kr_i = 27865;
reg   signed [17:0] kb_i = 9463;
    
wire                dv_i;
wire                hs_i;
wire                vs_i;
wire          [7:0] r_i;
wire          [7:0] g_i;
wire          [7:0] b_i;

wire                dv_o;
wire                hs_o;
wire                vs_o;
wire          [7:0] y_o;


rgb2y UUT(
    .clk    (clk ),

    .kr_i   (kr_i),
    .kb_i   (kb_i),

    .dv_i   (dv_i),
    .hs_i   (hs_i),
    .vs_i   (vs_i),
    .r_i    (r_i ),
    .g_i    (g_i ),
    .b_i    (b_i ),

    .dv_o   (dv_o),
    .hs_o   (hs_o),
    .vs_o   (vs_o),
    .y_o    (y_o )
);


localparam RES = 512;

always #5 clk <= ~clk;

integer file_in, file_out;
initial
begin
    //file_in  = $fopen("check.raw", "rb");
    file_in  = $fopen("lena.raw", "rb");
    file_out = $fopen("img_out.raw", "wb");
end


reg [7:0] mem_in[RES*RES*3-1:0];

initial
begin
    $fread(mem_in, file_in);
    $fclose(file_in);
    
    @(posedge vs_o);
    @(negedge vs_o);
    $fclose(file_out);
    $stop;
end

always @(negedge clk)
if (dv_o)
    $fwrite(file_out, "%c", y_o);


reg [15:0] col = -1;
reg [15:0] row = -1;

always @ (negedge clk)
begin
    if (col==(RES+50))
    begin    
        col <= 'h0;
    end
    else
    begin
        col <= col + 1;
    end

    if (col==(RES+50))
    begin
        if (row==(RES+50))
        begin
            row <= 'h0;
        end
        else
        begin
            row <= row + 1;
        end
    end
end

assign dv_i = (col<RES) & (row<RES);
assign hs_i = (col>(RES+10)) & (col<(RES+20));
assign vs_i = (row>(RES+10)) & (row<(RES+20));
assign r_i  = mem_in[row*RES*3 + col*3 + 0];
assign g_i  = mem_in[row*RES*3 + col*3 + 1];
assign b_i  = mem_in[row*RES*3 + col*3 + 2];


endmodule

