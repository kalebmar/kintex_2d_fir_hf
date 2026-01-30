`timescale 1ns / 1ps
`default_nettype none

//******************************************************************************
//* AXI4-Lite interfész.                                                       *
//******************************************************************************
module axi4_lite_if #(
    //A használt címbitek száma.
    parameter ADDR_BITS = 8
) (
    //Órajel és reset.
    input  wire                 clk,            //Rendszerórajel
    input  wire                 rst,            //Aktív magas szinkron reset
    
    //AXI4-Lite írási cím csatorna.
    input  wire [ADDR_BITS-1:0] s_axi_awaddr,
    input  wire                 s_axi_awvalid,
    output wire                 s_axi_awready,
    
    //AXI4-Lite írási adat csatorna.
    input  wire [31:0]          s_axi_wdata,
    input  wire [3:0]           s_axi_wstrb, //melyik bajt ervenyes az adatbol
    input  wire                 s_axi_wvalid,
    output wire                 s_axi_wready,
    
    //AXI4-Lite írási válasz csatorna.
    output wire [1:0]           s_axi_bresp, //2 bites statuszkod OKAY SLVERR DECERR
                                             // SLVERR slave hibát jelez
                                             // DECERR nem létezik slave a címen
    output wire                 s_axi_bvalid, 
    input  wire                 s_axi_bready,
    
    //AXI4-Lite olvasási cím csatorna.
    input  wire [ADDR_BITS-1:0] s_axi_araddr,
    input  wire                 s_axi_arvalid,
    output wire                 s_axi_arready,
    
    //AXI4-Lite olvasási adat csatorna.
    output reg  [31:0]          s_axi_rdata,
    output wire [1:0]           s_axi_rresp, //rdata ervenyes vagy hibas tranzakciobol szarmazik
                                             //bresphez hasonló kódok
    output wire                 s_axi_rvalid,
    input  wire                 s_axi_rready,
    
    //Regiszter írási interfész.
    //?? miért vannak az outputok regiszterezve?
    output reg  [ADDR_BITS-1:0] wr_addr,        //Írási cím
    output wire                 wr_en,          //Írás engedélyező jel
    output reg  [31:0]          wr_data,        //Írási adat
    output reg  [3:0]           wr_strb,        //Bájt engedélyező jelek
    input  wire                 wr_ack,         //Írás nyugtázó jel
    
    //Regiszter olvasási interfész.
    output reg  [ADDR_BITS-1:0] rd_addr,        //Olvasási cím
    output wire                 rd_en,          //Olvasás engedélyező jel
    input  wire [31:0]          rd_data,        //Olvasási adat
    input  wire                 rd_ack          //Olvasás nyugtázó jel
);

//******************************************************************************
//* Írási állapotgép.                                                          *
//******************************************************************************
localparam WR_ADDR_WAIT = 2'd0;
localparam WR_DATA_WAIT = 2'd1;
localparam WR_EXECUTE   = 2'd2;
localparam WR_RESPONSE  = 2'd3;

reg [1:0] wr_state;

always @(posedge clk)
begin
    if (rst)
        wr_state <= WR_ADDR_WAIT;
    else
        case (wr_state)
            //Váraozás az írási címre.
            WR_ADDR_WAIT:   if(s_axi_awvalid)
                                begin
                                wr_state <= WR_DATA_WAIT;
                                wr_addr <= s_axi_awaddr;
                                end
                            else
                              wr_state <= WR_ADDR_WAIT;         
            //Várakozás az írási adatra.                
            WR_DATA_WAIT:   if(s_axi_wvalid)
                                begin
                                wr_state <= WR_EXECUTE;
                                wr_data <= s_axi_wdata;
                                wr_strb <= s_axi_wstrb;
                                end
                            else
                              wr_state <= WR_DATA_WAIT;
            //Az írási művelet végrehajtása.
            WR_EXECUTE  :   if(wr_ack)
                                wr_state <= WR_RESPONSE;
                            else
                                wr_state <= WR_EXECUTE;
            
            //A nyugtázás elküldése.
            WR_RESPONSE :   if(s_axi_bready)
                                begin
                                wr_state <= WR_ADDR_WAIT;
                                end
                            else
                              wr_state <= WR_RESPONSE;
        endcase
end

//Az írási cím csatorna READY jelzésének előállítása.
assign s_axi_awready = (wr_state == WR_ADDR_WAIT);
//Az írási adat csatorna READY jelzésének előállítása.
assign s_axi_wready  = (wr_state == WR_DATA_WAIT);
//Az írési válasz csatorna VALID jelzésének előállítása.
assign s_axi_bvalid  = (wr_state == WR_EXECUTE);
//Mindog OKAY (00) nyugtát küldünk.
assign s_axi_bresp   = 2'b00;

//A regiszerek írás engedélyező jelének előállítása.
assign wr_en = (wr_state == WR_EXECUTE);


//******************************************************************************
//* Olvasási állapotgép.                                                       *
//******************************************************************************
localparam RD_ADDR_WAIT = 2'd0;
localparam RD_EXECUTE   = 2'd1;
localparam RD_SEND_DATA = 2'd2;

reg [1:0] rd_state;

always @(posedge clk)
begin
    if (rst)
        rd_state <= RD_ADDR_WAIT;
    else
        case (rd_state)
            //Váraozás az olvasási címre.
            RD_ADDR_WAIT: if(s_axi_arvalid)begin
                                rd_state <= RD_EXECUTE;
                                rd_addr <= s_axi_araddr;
                                end
                          else
                                rd_state <= RD_ADDR_WAIT;
            
            //Az olvasási művelet végrehajtása.
            RD_EXECUTE  : if(rd_ack)begin
                                rd_state <= RD_SEND_DATA;
                                s_axi_rdata <= rd_data;
                                end
                          else
                                rd_state <= RD_EXECUTE;
            
            //A beolvasott adat elküldése.
            RD_SEND_DATA: if(s_axi_rready)begin
                                rd_state <= RD_ADDR_WAIT;
                                s_axi_rdata <=  0;
                                end
                          else
                                rd_state <= RD_SEND_DATA;
            
            //Érvénytelen állapotok.
            default     : rd_state <= RD_ADDR_WAIT;
        endcase
end

//Az olvasási cím csatorna READY jelzésének előállítása.
assign s_axi_arready = (rd_state == RD_ADDR_WAIT);
//Az olvasási adat csatorna VALID jelzésének előállítása.
assign s_axi_rvalid  = (rd_state == RD_SEND_DATA);
//Mindog OKAY (00) nyugtát küldünk.
assign s_axi_rresp   = 2'b00;

//A regiszerek olvasás engedélyező jelének előállítása.
assign rd_en = (rd_state == RD_EXECUTE);

endmodule

`default_nettype wire
