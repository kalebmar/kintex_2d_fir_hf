`timescale 1ns / 1ps

module hdmi_top(
   input  wire       clk100M,
   input  wire       rstbt,
   output wire [7:0] led_r,
   
   input  wire       hdmi_rx_d0_p,
   input  wire       hdmi_rx_d0_n,
   input  wire       hdmi_rx_d1_p,
   input  wire       hdmi_rx_d1_n,
   input  wire       hdmi_rx_d2_p,
   input  wire       hdmi_rx_d2_n,
   input  wire       hdmi_rx_clk_p,
   input  wire       hdmi_rx_clk_n,
   input  wire       hdmi_rx_cec,
   output wire       hdmi_rx_hpd,
   input  wire       hdmi_rx_scl,
   inout  wire       hdmi_rx_sda,
   
   output wire       hdmi_tx_d0_p,
   output wire       hdmi_tx_d0_n,
   output wire       hdmi_tx_d1_p,
   output wire       hdmi_tx_d1_n,
   output wire       hdmi_tx_d2_p,
   output wire       hdmi_tx_d2_n,
   output wire       hdmi_tx_clk_p,
   output wire       hdmi_tx_clk_n,
   input  wire       hdmi_tx_cec,
   input  wire       hdmi_tx_hpdn,
   input  wire       hdmi_tx_scl,
   input  wire       hdmi_tx_sda
);

//******************************************************************************
//* Generating the 200 MHz reference clock for the IDELAYCTRL.                 *
//******************************************************************************
wire clk200M;
wire pll_clkfb;
wire pll_locked;


PLLE2_BASE #(
   .BANDWIDTH("OPTIMIZED"),         // OPTIMIZED, HIGH, LOW
   .CLKFBOUT_MULT(10),              // Multiply value for all CLKOUT, (2-64)
   .CLKFBOUT_PHASE(0.0),            // Phase offset in degrees of CLKFB, (-360.000-360.000).
   .CLKIN1_PERIOD(1000.0 / 100.0),  // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
   .CLKOUT0_DIVIDE(5),              // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
   .CLKOUT1_DIVIDE(1),
   .CLKOUT2_DIVIDE(1),
   .CLKOUT3_DIVIDE(1),
   .CLKOUT4_DIVIDE(1),
   .CLKOUT5_DIVIDE(1),
   .CLKOUT0_DUTY_CYCLE(0.5),        // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
   .CLKOUT1_DUTY_CYCLE(0.5),
   .CLKOUT2_DUTY_CYCLE(0.5),
   .CLKOUT3_DUTY_CYCLE(0.5),
   .CLKOUT4_DUTY_CYCLE(0.5),
   .CLKOUT5_DUTY_CYCLE(0.5),
   .CLKOUT0_PHASE(0.0),             // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
   .CLKOUT1_PHASE(0.0),
   .CLKOUT2_PHASE(0.0),
   .CLKOUT3_PHASE(0.0),
   .CLKOUT4_PHASE(0.0),
   .CLKOUT5_PHASE(0.0),
   .DIVCLK_DIVIDE(1),               // Master division value, (1-56)
   .REF_JITTER1(0.0),               // Reference input jitter in UI, (0.000-0.999).
   .STARTUP_WAIT("FALSE")           // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
) clk_generator1 (
   .CLKOUT0(clk200M),               // 1-bit output: CLKOUT0
   .CLKOUT1(),                      // 1-bit output: CLKOUT1
   .CLKOUT2(),                      // 1-bit output: CLKOUT2
   .CLKOUT3(),                      // 1-bit output: CLKOUT3
   .CLKOUT4(),                      // 1-bit output: CLKOUT4
   .CLKOUT5(),                      // 1-bit output: CLKOUT5
   .CLKFBOUT(pll_clkfb),            // 1-bit output: Feedback clock
   .LOCKED(pll_locked),             // 1-bit output: LOCK
   .CLKIN1(clk100M),                // 1-bit input: Input clock
   .PWRDWN(1'b0),                   // 1-bit input: Power-down
   .RST(rstbt),                     // 1-bit input: Reset
   .CLKFBIN(pll_clkfb)              // 1-bit input: Feedback clock
);

wire rst;
assign rst = ~pll_locked;

wire clk_200M;
BUFG BUFG_200M (
   .O(clk_200M),
   .I(clk200M)
);



wire rx_clk, rx_clk_5x;
wire [7:0] rx_red, rx_green, rx_blue;
wire rx_dv, rx_hs, rx_vs;
wire [5:0] rx_status;
hdmi_rx hdmi_rx_0(
   .clk_200M(clk_200M),
   .rst(rst),
   .hdmi_rx_cec(hdmi_rx_cec),
   .hdmi_rx_hpd(hdmi_rx_hpd),
   .hdmi_rx_scl(hdmi_rx_scl),
   .hdmi_rx_sda(hdmi_rx_sda),
   .hdmi_rx_clk_p(hdmi_rx_clk_p),
   .hdmi_rx_clk_n(hdmi_rx_clk_n),
   .hdmi_rx_d0_p(hdmi_rx_d0_p),
   .hdmi_rx_d0_n(hdmi_rx_d0_n),
   .hdmi_rx_d1_p(hdmi_rx_d1_p),
   .hdmi_rx_d1_n(hdmi_rx_d1_n),
   .hdmi_rx_d2_p(hdmi_rx_d2_p),
   .hdmi_rx_d2_n(hdmi_rx_d2_n),
   .rx_clk(rx_clk),
   .rx_clk_5x(rx_clk_5x),
   .rx_red(rx_red),
   .rx_green(rx_green),
   .rx_blue(rx_blue),
   .rx_dv(rx_dv),
   .rx_hs(rx_hs),
   .rx_vs(rx_vs),
   .rx_status(rx_status)
);

wire tx_dv, tx_hs, tx_vs;
wire dv_to_fir, hs_to_fir, vs_to_fir;
wire [7:0]rgb2y_to_ram_block;

rgb2y rgb2y_i(
   .clk(rx_clk),
    
   .kr_i(27865),
   .kb_i(9463),
    
   .dv_i(rx_dv),
   .hs_i(rx_hs),
   .vs_i(rx_vs),
   .r_i(rx_red),
   .g_i(rx_green),
   .b_i(rx_blue),

   .dv_o(dv_to_fir),
   .hs_o(hs_to_fir),
   .vs_o(vs_to_fir),
   .y_o(rgb2y_to_ram_block)
);

wire [7:0] data_connect[4:0];

sp_ram_block ram_block_i(
   .clk(rx_clk),
   .rst(rst),

   .en(1'b1),
   .we(1'b1),

    .hsync_i(hs_to_fir),
    .vsync_i(vs_to_fir),
    .dv_i(dv_to_fir),

    .data_in(rgb2y_to_ram_block),

    .hsync_o(tx_hs),
    .vsync_o(tx_vs),
    .dv_o(tx_dv),

    .data_out_0(data_connect[0]),
    .data_out_1(data_connect[1]),
    .data_out_2(data_connect[2]),
    .data_out_3(data_connect[3]),
    .data_out_4(data_connect[4])
);

/**
 * 5x5 Laplacian Filter Coefficients:
 * Used for edge detection by calculating the discrete second derivative.
 * The sum of coefficients is 0 to ensure zero response in uniform areas.
 */
localparam [15:0]
    coeff_0_0 = 16'hFFFF, coeff_0_1 = 16'hFFFF, coeff_0_2 = 16'hFFFE, coeff_0_3 = 16'hFFFF, coeff_0_4 = 16'hFFFF, // -1, -1, -2, -1, -1
    coeff_1_0 = 16'hFFFF, coeff_1_1 = 16'hFFFC, coeff_1_2 = 16'hFFF8, coeff_1_3 = 16'hFFFC, coeff_1_4 = 16'hFFFF, // -1, -4, -8, -4, -1
    coeff_2_0 = 16'hFFFE, coeff_2_1 = 16'hFFF8, coeff_2_2 = 16'h0030, coeff_2_3 = 16'hFFF8, coeff_2_4 = 16'hFFFE, // -2, -8, 48, -8, -2
    coeff_3_0 = 16'hFFFF, coeff_3_1 = 16'hFFFC, coeff_3_2 = 16'hFFF8, coeff_3_3 = 16'hFFFC, coeff_3_4 = 16'hFFFF, // -1, -4, -8, -4, -1
    coeff_4_0 = 16'hFFFF, coeff_4_1 = 16'hFFFF, coeff_4_2 = 16'hFFFE, coeff_4_3 = 16'hFFFF, coeff_4_4 = 16'hFFFF; // -1, -1, -2, -1, -1

wire [7:0] fir_out;

two_d_fir fir_i(
   .clk(rx_clk),
   .rst(rst),

   .sample_0(data_connect[0]),
   .sample_1(data_connect[1]),
   .sample_2(data_connect[2]),
   .sample_3(data_connect[3]),
   .sample_4(data_connect[4]),

   .coeff_0_0(coeff_0_0),
   .coeff_0_1(coeff_0_1),
   .coeff_0_2(coeff_0_2),
   .coeff_0_3(coeff_0_3),
   .coeff_0_4(coeff_0_4),

   .coeff_1_0(coeff_1_0),
   .coeff_1_1(coeff_1_1),
   .coeff_1_2(coeff_1_2),
   .coeff_1_3(coeff_1_3),
   .coeff_1_4(coeff_1_4),

   .coeff_2_0(coeff_2_0),
   .coeff_2_1(coeff_2_1),
   .coeff_2_2(coeff_2_2),
   .coeff_2_3(coeff_2_3),
   .coeff_2_4(coeff_2_4),

   .coeff_3_0(coeff_3_0),
   .coeff_3_1(coeff_3_1),
   .coeff_3_2(coeff_3_2),
   .coeff_3_3(coeff_3_3),
   .coeff_3_4(coeff_3_4),

   .coeff_4_0(coeff_4_0),
   .coeff_4_1(coeff_4_1),
   .coeff_4_2(coeff_4_2),
   .coeff_4_3(coeff_4_3),
   .coeff_4_4(coeff_4_4),

   .fir_out(fir_out)
    );

    
wire [7:0] tx_red, tx_green, tx_blue;

assign tx_red = fir_out;
assign tx_green = fir_out;
assign tx_blue = fir_out;


hdmi_tx hdmi_tx_0(
   .tx_clk(rx_clk),
   .tx_clk_5x(rx_clk_5x),
   .rst(rst),
   .tx_red(tx_red),
   .tx_green(tx_green),
   .tx_blue(tx_blue),
   .tx_dv(tx_dv),
   .tx_hs(tx_hs),
   .tx_vs(tx_vs),
   .hdmi_tx_clk_p(hdmi_tx_clk_p),
   .hdmi_tx_clk_n(hdmi_tx_clk_n),
   .hdmi_tx_d0_p(hdmi_tx_d0_p),
   .hdmi_tx_d0_n(hdmi_tx_d0_n),
   .hdmi_tx_d1_p(hdmi_tx_d1_p),
   .hdmi_tx_d1_n(hdmi_tx_d1_n),
   .hdmi_tx_d2_p(hdmi_tx_d2_p),
   .hdmi_tx_d2_n(hdmi_tx_d2_n)
);

assign led_r = {pll_locked, 1'b1, rx_status};

endmodule
