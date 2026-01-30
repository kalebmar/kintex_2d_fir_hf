`timescale 1ns / 1ps

module tb_2d_fir();

reg clk = 1;
reg rst;

always #50 clk <= ~clk;

initial
begin
    #0
    rst = 1;
    #150;
    rst = 0;
end

reg [7:0] sample_array[199:0];
reg [7:0] sample_current[4:0];

reg [15:0] coeff_array[24:0];
wire [7:0]out;


reg [28:0] accu = 29'b0;
reg [28:0] test_out = 29'd0;

integer i = 0;
integer y = 0;
integer x = 0;


initial $readmemh("samples_test.txt", sample_array);
initial $readmemh("coeff_test.txt", coeff_array);

two_d_fir UUT(
    .clk(clk),
    .rst(rst),

    .sample_0(sample_current[0]),
    .sample_1(sample_current[1]),
    .sample_2(sample_current[2]),
    .sample_3(sample_current[3]),
    .sample_4(sample_current[4]),

    .coeff_0_0(coeff_array[0]),
    .coeff_0_1(coeff_array[1]),
    .coeff_0_2(coeff_array[2]),
    .coeff_0_3(coeff_array[3]),
    .coeff_0_4(coeff_array[4]),
                    
    .coeff_1_0(coeff_array[5]),
    .coeff_1_1(coeff_array[6]),
    .coeff_1_2(coeff_array[7]),
    .coeff_1_3(coeff_array[8]),
    .coeff_1_4(coeff_array[9]),
                    
    .coeff_2_0(coeff_array[10]),
    .coeff_2_1(coeff_array[11]),
    .coeff_2_2(coeff_array[12]),
    .coeff_2_3(coeff_array[13]),
    .coeff_2_4(coeff_array[14]),
                    
    .coeff_3_0(coeff_array[15]),
    .coeff_3_1(coeff_array[16]),
    .coeff_3_2(coeff_array[17]),
    .coeff_3_3(coeff_array[18]),
    .coeff_3_4(coeff_array[19]),
                    
    .coeff_4_0(coeff_array[20]),
    .coeff_4_1(coeff_array[21]),
    .coeff_4_2(coeff_array[22]),
    .coeff_4_3(coeff_array[23]),
    .coeff_4_4(coeff_array[24]),

    .fir_out(out)
    );


initial
begin
    for(i=0; i<220; i=i+5)
    begin
    if(i<200)
        begin
        for(y=0; y<5; y=y+1)
            sample_current[y] = sample_array[i+y];
        end
    else
        begin
        for(y=0; y<5; y=y+1)
            sample_current[y] = 8'd60 + y;
        end
        if(i>60)
        begin
        accu = 29'b0;
        for(y=0; y<5;y=y+1)
            for(x=0; x<5; x=x+1)
            begin
                    test_out = coeff_array[5*y+x] * sample_array[i+20+y-(5*x)];
                    accu = accu + test_out;
            end
        end
        #100;
    end
 
    $display("Szimuláció vége");
    $finish;   // Szimuláció leállítása

end

endmodule
