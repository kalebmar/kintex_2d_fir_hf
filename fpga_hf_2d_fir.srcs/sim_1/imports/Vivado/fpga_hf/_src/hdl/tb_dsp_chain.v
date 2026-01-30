`timescale 1ns / 1ps

module tb_dsp_chain();

reg clk = 1;
reg rst;

reg [7:0] sample_array[10:0];
reg [15:0] coeff_array[4:0];

reg [7:0]sample;
wire [28:0]out;

reg [28:0] test_out;

always #50 clk <= ~clk;


initial
begin
    #0
    rst = 1;
    #150
    rst = 0;
end

initial $readmemh("samples.txt", sample_array);
initial $readmemh("coeffs.txt", coeff_array);


dsp_chain UUT(
  .clk(clk),
  .rst(rst),

  .sample(sample),
  .coeff_0(coeff_array[0]),
  .coeff_1(coeff_array[1]),
  .coeff_2(coeff_array[2]),
  .coeff_3(coeff_array[3]),
  .coeff_4(coeff_array[4]),
  .dsp_chain_out(out)
);



integer i;

initial
begin
    for(i=0; i<22; i=i+1)
    begin
    if(i<11)
        sample <= sample_array[i];
    else
        sample <= 8'd60;

    #100;
        if(i>10)
        begin
            test_out <= coeff_array[0] * sample_array[i-5] + 
            coeff_array[1] * sample_array[i-6] +
            coeff_array[2] * sample_array[i-7] +
            coeff_array[3] * sample_array[i-8] +
            coeff_array[4] * sample_array[i-9];
        end
    end
 
    $display("Szimuláció vége időegység után.");
    $finish;   // Szimuláció leállítása

end

endmodule
