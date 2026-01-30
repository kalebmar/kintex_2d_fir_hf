module sp_ram_row (
    input clk,

    input en,
    input we,

    input [10:0] addr,
    input [ 8:0] din,

    output [8:0] dout
);

  localparam ADDR_W = 11;
  (* ram_style = "block" *) reg [8:0] memory[2047:0];
  integer y;
  
  initial 
    for (y = 0; y < (2 ** ADDR_W); y = y + 1) 
        memory[y] = 9'b0;

  reg [8:0] dout_reg;

  always @(posedge clk) begin
    if (en) begin
      if (we) memory[addr] <= din;
      dout_reg <= memory[addr];
    end
  end


  assign dout = dout_reg;

endmodule
