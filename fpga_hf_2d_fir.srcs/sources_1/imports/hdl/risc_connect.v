`timescale 1ns / 1ps
`default_nettype none

//******************************************************************************
//* Saját periféria.                                                      *
//******************************************************************************
module risc_connect #(
    //AXI interfész paraméterek.
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 5,
    //GPIO paraméterek.
    parameter C_WIDTH       = 8
) (
    //AXI órajel és reset jel.
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s_axi_aclk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 100000000" *)
    input  wire                              s_axi_aclk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s_axi_aresetn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input  wire                              s_axi_aresetn,
    
    //AXI4-Lite írási cím csatorna.
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *)
    (* X_INTERFACE_PARAMETER = "PROTOCOL AXI4LITE" *)
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *)
    input  wire                              s_axi_awvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *)
    output wire                              s_axi_awready,
    
    //AXI4-Lite írási adat csatorna.
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *)
    input  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *)
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *)
    input  wire                              s_axi_wvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *)
    output wire                              s_axi_wready,
    
    //AXI4-Lite írási válasz csatorna.
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *)
    output wire [1:0]                        s_axi_bresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *)
    output wire                              s_axi_bvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *)
    input  wire                              s_axi_bready,
    
    //AXI4-Lite olvasási cím csatorna.
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARADDR" *)
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARVALID" *)
    input  wire                              s_axi_arvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREADY" *)
    output wire                              s_axi_arready,
    
    //AXI4-Lite olvasási adat csatorna.
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RDATA" *)
    output wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RRESP" *)
    output wire [1:0]                        s_axi_rresp,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RVALID" *)
    output wire                              s_axi_rvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RREADY" *)
    input  wire                              s_axi_rready,
    
    //Interfész
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 GPIO TRI_T" *)
    output wire [C_GPIO_WIDTH-1:0]           gpio_tri_t,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 GPIO TRI_O" *)
    output wire [C_GPIO_WIDTH-1:0]           gpio_tri_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 GPIO TRI_I" *)
    input  wire [C_GPIO_WIDTH-1:0]           gpio_tri_i
        

);

//******************************************************************************
//* Órajel és reset.                                                           *
//******************************************************************************
wire clk =  s_axi_aclk;
wire rst = ~s_axi_aresetn;


//******************************************************************************
//* AXI4-Lite interfész.                                                       *
//******************************************************************************
wire [6:0]  wr_addr;
wire        wr_en;
wire [31:0] wr_data;
wire [3:0]  wr_strb;

wire [6:0]  rd_addr;
wire        rd_en;
reg  [31:0] rd_data;

axi4_lite_if #(
    //A használt címbitek száma.
    .ADDR_BITS(C_S_AXI_ADDR_WIDTH)
) axi4_lite_if_i (
    //Órajel és reset.
    .clk(clk),                          //Rendszerórajel
    .rst(rst),                          //Aktív magas szinkron reset
    
    //AXI4-Lite írási cím csatorna.
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    
    //AXI4-Lite írási adat csatorna.
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    
    //AXI4-Lite írási válasz csatorna.
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    
    //AXI4-Lite olvasási cím csatorna.
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    
    //AXI4-Lite olvasási adat csatorna.
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    
    //Regiszter írási interfész.
    .wr_addr(wr_addr),                  //Írási cím
    .wr_en(wr_en),                      //Írás engedélyező jel
    .wr_data(wr_data),                  //Írási adat
    .wr_strb(wr_strb),                  //Bájt engedelyező jelek
    .wr_ack(1'b1),                      //Írás nyugtázó jel
    
    //Regiszter olvasási interfész.
    .rd_addr(rd_addr),                  //Olvasási cím
    .rd_en(rd_en),                      //Olvasás engedélyező jel
    .rd_data(rd_data),                  //Olvasási adat
    .rd_ack(1'b1)                       //Olvasás nyugtázó jel
);


//******************************************************************************
//* A regiszterek írási és olvasási engedélyező jeleinek előállítása.          *
//******************************************************************************
//Regiszter írás engedélyező jelek. Az adott regisztert akkor írjuk, ha a wr_en
//jel aktív, a wr_addr megfelelő része az adott regisztert választja ki, illetve
//32 bites írás kerül végrehajtásra.
wire dout_reg_wr = wr_en & (wr_addr[4:2] == 3'd0) & (wr_strb == 4'b1111);
wire dir_reg_wr  = wr_en & (wr_addr[4:2] == 3'd2) & (wr_strb == 4'b1111);
wire ie_reg_wr   = wr_en & (wr_addr[4:2] == 3'd3) & (wr_strb == 4'b1111);
wire if_reg_wr   = wr_en & (wr_addr[4:2] == 3'd4) & (wr_strb == 4'b1111);

//Írási módok és az írási mód kiválasztó jel (az írási cím 5. és 6. bitjei).
localparam WR_NORM = 2'd0;              //Normál írás
localparam WR_SET  = 2'd1;              //Bit beállítás (set)
localparam WR_CLR  = 2'd2;              //Bit törlés (clear)
localparam WR_TGL  = 2'd3;              //Bit invertálás (toggle)
  
wire [1:0] wr_mode = wr_addr[6:5];


//******************************************************************************
//* GPIO kimeneti adatregiszter.                     BÁZIS+0x00, 32 bit, R/W4  *
//******************************************************************************
reg [C_GPIO_WIDTH-1:0] dout_reg;

//Reset hatására töröljük a kimeneti adatregisztert. Ha az írás engedélyezés
//aktív, akkor végezzük el az írási módnak megfelelő műveletet.
always @(posedge clk)
begin
    if (rst)
        dout_reg <= 0;
    else
        if (dout_reg_wr)
            case (wr_mode)
                WR_NORM: dout_reg <= wr_data[C_GPIO_WIDTH-1:0];
                WR_SET : dout_reg <= dout_reg |  wr_data[C_GPIO_WIDTH-1:0];
                WR_CLR : dout_reg <= dout_reg & ~wr_data[C_GPIO_WIDTH-1:0];
                WR_TGL : dout_reg <= dout_reg ^  wr_data[C_GPIO_WIDTH-1:0];
            endcase
end

//A GPIO kimenet meghajtása.
assign gpio_tri_o = dout_reg;


endmodule

`default_nettype wire
