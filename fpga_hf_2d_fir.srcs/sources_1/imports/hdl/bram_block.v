`define FIR_DELAY 12

module sp_ram_block(
    input clk,
    input rst,

    input en, // Can be removed
    input we, // Can be removed

    input hsync_i,
    input vsync_i,
    input dv_i,
   
    input [7:0] data_in,

    output hsync_o,
    output vsync_o,
    output dv_o,

    output [7:0] data_out_0,
    output [7:0] data_out_1,
    output [7:0] data_out_2,
    output [7:0] data_out_3,
    output [7:0] data_out_4
);


wire [8:0] data_out_connect[3:0];

// hsync counter for circular buffering
// hsync edge detection (polarity independent)

reg hsync_dl[1:0];
wire hsync_rising;
reg [10:0] px_counter;

always @(posedge clk)
begin
    hsync_dl[0] <= hsync_i;
    hsync_dl[1] <= hsync_dl[0];
end

assign hsync_rising  = (hsync_dl[0] & ~hsync_dl[1]);

// hsync_rising is delayed by 2 clock cycles -> addresses are shifted
// This is negligible as there is no valid data at the edges,
// so the exact placement of zeros in the buffer does not matter.

always @(posedge clk)
begin
    if(hsync_rising | rst)
        px_counter <= 11'b0;
    else
        px_counter <= px_counter + 1;    
end

// Force input to 0 if data_valid is low
// Added Latency: 1 cycle

reg [8:0] corrected_data;

always @(posedge clk)
begin
    if(rst)
        corrected_data <= 9'b0;
    else if(~dv_i) // Blanking interval
        corrected_data <= {dv_i,8'b0};
    else
        corrected_data <= {dv_i,data_in};
end

/**
 * Sync Signal Latency Calculation:
 * Match the delay of the entire design path.
 * - FIR Latency: 12 cycles (11 chain + 1 saturation)
 * - Input Correction: 1 cycle
 * - RAM & Alignment: 4 cycles
 * Total Latency: 1 + 4 + 12 = 17 cycles
 * Note: dv_i needs to be delayed by an additional 2 lines (handled via BRAM chain)
 */

reg [16:0] delay_hsync;
reg [14:0] delay_vsync;
reg [13:0] delay_dv;

always @(posedge clk) begin
    if(rst)
        begin
                delay_hsync <= 17'b0;
                delay_vsync <= 15'b0;
                delay_dv <= 14'b0;
        end
    else
        begin
                delay_hsync <= {delay_hsync[15:0], hsync_i};
                delay_vsync <= {delay_vsync[13:0], data_out_connect[3][8]};
                delay_dv <= {delay_dv[12:0], data_out_connect[1][8]};
        end
end

assign hsync_o = delay_hsync[16];
assign vsync_o = delay_vsync[14];
assign dv_o = delay_dv[13]; // Offset by 1 vs vsync due to corrected_data latency


// Registering data_out_0 to match pipeline depth (at least 1 cycle for BRAM)

reg [7:0] data_out_0_dl[3:0];

always @(posedge clk)
begin
    data_out_0_dl[0] <= corrected_data[7:0];
    data_out_0_dl[1] <= data_out_0_dl[0];    
    data_out_0_dl[2] <= data_out_0_dl[1];
    data_out_0_dl[3] <= data_out_0_dl[2];        
end

assign data_out_0 = data_out_0_dl[3];


sp_ram_row row_0(
    .clk(clk),

    .en(en), 
    .we(we),

    .addr(px_counter), 
    .din(corrected_data),

    .dout(data_out_connect[0])
    );

reg [7:0] data_out_1_dl[2:0];

always @(posedge clk)
begin
    data_out_1_dl[0] <= data_out_connect[0][7:0];
    data_out_1_dl[1] <= data_out_1_dl[0];    
    data_out_1_dl[2] <= data_out_1_dl[1];      
end

assign data_out_1 = data_out_1_dl[2];

sp_ram_row row_1(
    .clk(clk),

    .en(en), 
    .we(we),

    .addr(px_counter), 
    .din(data_out_connect[0]),

    .dout(data_out_connect[1])
    );

reg [7:0] data_out_2_dl[1:0];

always @(posedge clk)
begin
    data_out_2_dl[0] <= data_out_connect[1][7:0];
    data_out_2_dl[1] <= data_out_2_dl[0];      
end

assign data_out_2 = data_out_2_dl[1];

// Replace the data valid (dv) bit with vsync_i
// This allows vsync to be delayed by exactly 2 lines as it travels through 
// the BRAM cascade alongside the pixel data

wire [8:0]dv_swap_to_vsync;

assign dv_swap_to_vsync = {vsync_i ,data_out_connect[1][7:0]};

sp_ram_row row_2(
    .clk(clk),

    .en(en), 
    .we(we),

    .addr(px_counter), 
    .din(dv_swap_to_vsync),

    .dout(data_out_connect[2])
    );

reg [7:0] data_out_3_dl;

always @(posedge clk)
begin
    data_out_3_dl <= data_out_connect[2][7:0];     
end

assign data_out_3 = data_out_3_dl;

sp_ram_row row_3(
    .clk(clk),

    .en(en), 
    .we(we),

    .addr(px_counter), 
    .din(data_out_connect[2]),

    .dout(data_out_connect[3])
    );

assign data_out_4 = data_out_connect[3][7:0];

endmodule