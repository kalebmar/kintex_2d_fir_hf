`timescale 1ns / 1ps

module tb_dsp_block();

reg clk = 1;
reg rst;

reg [7:0] sample_array[9:0];
reg [15:0] coeff = 16'd16;

reg [7:0]sample;
wire [7:0]sample_out_test;
wire [28:0]out;


initial $readmemh("samples.txt", sample_array);

always #50 clk <= ~clk;


initial
begin
    #50
    rst = 1;
    #150
    rst = 0;
end

dsp#(.SAMPLE_DELAY(1)) dsp_t(
    .clk(clk),
    .rst(rst),

  .sample_in(sample),
  .coeff(coeff),
  .pci(29'd0),
  .sample_out(sample_out_test),
  .out(out)
);
integer i;

initial
begin
    for(i=0; i<13; i=i+1)
    begin
    if(i<10)
        sample <= sample_array[i];
    else
        sample <= 8'd60;

    #100;
    end
 
    $display("Szimuláció vége időegység után.");
    $finish;   // Szimuláció leállítása

end
endmodule