// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
`include "pulp_soc_defines.sv"

module safe_domain #(
        parameter int unsigned FLL_DATA_WIDTH = 32,
        parameter int unsigned FLL_ADDR_WIDTH = 32,
        parameter int unsigned N_UART = 1,
        parameter int unsigned N_SPI = 1,
        parameter int unsigned N_I2C = 2
) (
        input  logic             ref_clk_i            ,
        output logic             slow_clk_o           ,
        input  logic             rst_ni               ,
        output logic             rst_no               ,

        output logic             test_clk_o           ,
        output logic             test_mode_o          ,
        output logic             mode_select_o        ,
        output logic             dft_cg_enable_o      ,

        //**********************************************************
        //*** PERIPHERALS SIGNALS **********************************
        //**********************************************************

        // PAD CONTROL REGISTER
        input  logic [127:0]     pad_mux_i            ,
        input  logic [383:0]     pad_cfg_i            ,

        output logic [47:0][5:0] pad_cfg_o            ,

        // GPIOS
        input  logic [31:0]      gpio_out_i           ,
        output logic [31:0]      gpio_in_o            ,
        input  logic [31:0]      gpio_dir_i           ,
        input  logic [191:0]     gpio_cfg_i           ,

        // UART
        input  logic             uart_tx_i            ,
        output logic             uart_rx_o            ,

        input  logic [N_I2C-1:0] i2c_scl_out_i,
        output logic [N_I2C-1:0] i2c_scl_in_o,
        input  logic [N_I2C-1:0] i2c_scl_oe_i,
        input  logic [N_I2C-1:0] i2c_sda_out_i,
        output logic [N_I2C-1:0] i2c_sda_in_o,
        input  logic [N_I2C-1:0] i2c_sda_oe_i,

        // I2S
        output logic             i2s_slave_sd0_o      ,
        output logic             i2s_slave_sd1_o      ,
        output logic             i2s_slave_ws_o       ,
        input  logic             i2s_slave_ws_i       ,
        input  logic             i2s_slave_ws_oe      ,
        output logic             i2s_slave_sck_o      ,
        input  logic             i2s_slave_sck_i      ,
        input  logic             i2s_slave_sck_oe     ,

        // SPI MASTER
        input  logic [N_SPI-1:0]      spi_clk_i,
        input  logic [N_SPI-1:0][3:0] spi_csn_i,
        input  logic [N_SPI-1:0][3:0] spi_oen_i,
        input  logic [N_SPI-1:0][3:0] spi_sdo_i,
        output logic [N_SPI-1:0][3:0] spi_sdi_o,

        // SDIO
        input  logic             sdio_clk_i,
        input  logic             sdio_cmd_i,
        output logic             sdio_cmd_o,
        input  logic             sdio_cmd_oen_i,
        input  logic [3:0]       sdio_data_i,
        output logic [3:0]       sdio_data_o,
        input  logic [3:0]       sdio_data_oen_i,

        // CAMERA INTERFACE
        output logic             cam_pclk_o           ,
        output logic [7:0]       cam_data_o           ,
        output logic             cam_hsync_o          ,
        output logic             cam_vsync_o          ,

        // DVSI INTERFACE
        input  logic             dvsi_asa_i           ,
        input  logic             dvsi_are_i           ,
        input  logic             dvsi_asy_i           ,
        input  logic             dvsi_ynrst_i         ,  
        input  logic             dvsi_yclk_i          , 
        input  logic             dvsi_sxy_i           ,
        input  logic             dvsi_xclk_i          , 
        input  logic             dvsi_xnrst_i         ,  
        input  logic             dvsi_cfg0_i          , 
        input  logic             dvsi_cfg1_i          , 
        input  logic             dvsi_cfg2_i          , 
        input  logic             dvsi_cfg3_i          , 
        input  logic             dvsi_cfg4_i          , 
        input  logic             dvsi_cfg5_i          , 
        input  logic             dvsi_cfg6_i          , 
        input  logic             dvsi_cfg7_i          ,
        output logic             dvsi_xydata0_o       ,
        output logic             dvsi_xydata1_o       ,
        output logic             dvsi_xydata2_o       ,
        output logic             dvsi_xydata3_o       ,
        output logic             dvsi_xydata4_o       ,
        output logic             dvsi_xydata5_o       ,
        output logic             dvsi_xydata6_o       ,
        output logic             dvsi_xydata7_o       ,
        output logic             dvsi_on0_o           ,
        output logic             dvsi_on1_o           ,
        output logic             dvsi_on2_o           ,
        output logic             dvsi_on3_o           ,
        output logic             dvsi_off0_o          ,
        output logic             dvsi_off1_o          ,
        output logic             dvsi_off2_o          ,
        output logic             dvsi_off3_o          ,

        // TIMER
        input  logic [3:0]       timer0_i             ,
        input  logic [3:0]       timer1_i             ,
        input  logic [3:0]       timer2_i             ,
        input  logic [3:0]       timer3_i             ,

        //**********************************************************
        //*** PAD FRAME SIGNALS ************************************
        //**********************************************************

        // PADS OUTPUTS
        output logic             out_spim_sdio0_o     ,
        output logic             out_spim_sdio1_o     ,
        output logic             out_spim_sdio2_o     ,
        output logic             out_spim_sdio3_o     ,
        output logic             out_spim_csn0_o      ,
        output logic             out_spim_csn1_o      ,
        output logic             out_spim_sck_o       ,
        output logic             out_sdio_clk_o       ,
        output logic             out_sdio_cmd_o       ,
        output logic             out_sdio_data0_o     ,
        output logic             out_sdio_data1_o     ,
        output logic             out_sdio_data2_o     ,
        output logic             out_sdio_data3_o     ,
        output logic             out_uart_rx_o        ,
        output logic             out_uart_tx_o        ,
        output logic             out_cam_pclk_o       ,
        output logic             out_cam_hsync_o      ,
        output logic             out_cam_data0_o      ,
        output logic             out_cam_data1_o      ,
        output logic             out_cam_data2_o      ,
        output logic             out_cam_data3_o      ,
        output logic             out_cam_data4_o      ,
        output logic             out_cam_data5_o      ,
        output logic             out_cam_data6_o      ,
        output logic             out_cam_data7_o      ,
        output logic             out_cam_vsync_o      ,
        output logic             out_i2c0_sda_o       ,
        output logic             out_i2c0_scl_o       ,
        output logic             out_i2s0_sck_o       ,
        output logic             out_i2s0_ws_o        ,
        output logic             out_i2s0_sdi_o       ,
        output logic             out_i2s1_sdi_o       ,
        /* DVSI */
        output logic             out_dvsi_asa_o       ,
        output logic             out_dvsi_are_o       ,
        output logic             out_dvsi_asy_o       ,
        output logic             out_dvsi_ynrst_o     ,
        output logic             out_dvsi_yclk_o      ,
        output logic             out_dvsi_sxy_o       ,
        output logic             out_dvsi_xclk_o      ,
        output logic             out_dvsi_xnrst_o     ,
        output logic             out_dvsi_cfg0_o      ,
        output logic             out_dvsi_cfg1_o      ,
        output logic             out_dvsi_cfg2_o      ,
        output logic             out_dvsi_cfg3_o      ,
        output logic             out_dvsi_cfg4_o      ,
        output logic             out_dvsi_cfg5_o      ,
        output logic             out_dvsi_cfg6_o      ,
        output logic             out_dvsi_cfg7_o      ,


        // PAD INPUTS
        input logic              in_spim_sdio0_i      ,
        input logic              in_spim_sdio1_i      ,
        input logic              in_spim_sdio2_i      ,
        input logic              in_spim_sdio3_i      ,
        input logic              in_spim_csn0_i       ,
        input logic              in_spim_csn1_i       ,
        input logic              in_spim_sck_i        ,
        input logic              in_sdio_clk_i        ,
        input logic              in_sdio_cmd_i        ,
        input logic              in_sdio_data0_i      ,
        input logic              in_sdio_data1_i      ,
        input logic              in_sdio_data2_i      ,
        input logic              in_sdio_data3_i      ,
        input logic              in_uart_rx_i         ,
        input logic              in_uart_tx_i         ,
        input logic              in_cam_pclk_i        ,
        input logic              in_cam_hsync_i       ,
        input logic              in_cam_data0_i       ,
        input logic              in_cam_data1_i       ,
        input logic              in_cam_data2_i       ,
        input logic              in_cam_data3_i       ,
        input logic              in_cam_data4_i       ,
        input logic              in_cam_data5_i       ,
        input logic              in_cam_data6_i       ,
        input logic              in_cam_data7_i       ,
        input logic              in_cam_vsync_i       ,
        input logic              in_i2c0_sda_i        ,
        input logic              in_i2c0_scl_i        ,
        input logic              in_i2s0_sck_i        ,
        input logic              in_i2s0_ws_i         ,
        input logic              in_i2s0_sdi_i        ,
        input logic              in_i2s1_sdi_i        ,
        /* DVSI */
        input logic              in_dvsi_xydata0_i    ,
        input logic              in_dvsi_xydata1_i    ,
        input logic              in_dvsi_xydata2_i    ,
        input logic              in_dvsi_xydata3_i    ,
        input logic              in_dvsi_xydata4_i    ,
        input logic              in_dvsi_xydata5_i    ,
        input logic              in_dvsi_xydata6_i    ,
        input logic              in_dvsi_xydata7_i    ,
        input logic              in_dvsi_on0_i        ,
        input logic              in_dvsi_on1_i        ,
        input logic              in_dvsi_on2_i        ,
        input logic              in_dvsi_on3_i        ,
        input logic              in_dvsi_off0_i       ,
        input logic              in_dvsi_off1_i       ,
        input logic              in_dvsi_off2_i       ,
        input logic              in_dvsi_off3_i       ,

        // OUTPUT ENABLE
        output logic             oe_spim_sdio0_o      ,
        output logic             oe_spim_sdio1_o      ,
        output logic             oe_spim_sdio2_o      ,
        output logic             oe_spim_sdio3_o      ,
        output logic             oe_spim_csn0_o       ,
        output logic             oe_spim_csn1_o       ,
        output logic             oe_spim_sck_o        ,
        output logic             oe_sdio_clk_o        ,
        output logic             oe_sdio_cmd_o        ,
        output logic             oe_sdio_data0_o      ,
        output logic             oe_sdio_data1_o      ,
        output logic             oe_sdio_data2_o      ,
        output logic             oe_sdio_data3_o      ,
        output logic             oe_uart_rx_o         ,
        output logic             oe_uart_tx_o         ,
        output logic             oe_cam_pclk_o        ,
        output logic             oe_cam_hsync_o       ,
        output logic             oe_cam_data0_o       ,
        output logic             oe_cam_data1_o       ,
        output logic             oe_cam_data2_o       ,
        output logic             oe_cam_data3_o       ,
        output logic             oe_cam_data4_o       ,
        output logic             oe_cam_data5_o       ,
        output logic             oe_cam_data6_o       ,
        output logic             oe_cam_data7_o       ,
        output logic             oe_cam_vsync_o       ,
        output logic             oe_i2c0_sda_o        ,
        output logic             oe_i2c0_scl_o        ,
        output logic             oe_i2s0_sck_o        ,
        output logic             oe_i2s0_ws_o         ,
        output logic             oe_i2s0_sdi_o        ,
        output logic             oe_i2s1_sdi_o        
        /* DVSI */
        /*
        output logic             oe_dvsi_asa_o        ,
        output logic             oe_dvsi_are_o        ,
        output logic             oe_dvsi_asy_o        ,
        output logic             oe_dvsi_ynrst_o      ,
        output logic             oe_dvsi_yclk_o       ,
        output logic             oe_dvsi_sxy_o        ,
        output logic             oe_dvsi_xclk_o       ,
        output logic             oe_dvsi_xnrst_o      ,
        output logic             oe_dvsi_cfg0_o       ,
        output logic             oe_dvsi_cfg1_o       ,
        output logic             oe_dvsi_cfg2_o       ,
        output logic             oe_dvsi_cfg3_o       ,
        output logic             oe_dvsi_cfg4_o       ,
        output logic             oe_dvsi_cfg5_o       ,
        output logic             oe_dvsi_cfg6_o       ,
        output logic             oe_dvsi_cfg7_o
        */       
    );

    logic        s_test_clk;

    logic        s_rtc_int;
    logic        s_gpio_wake;
    logic        s_rstn_sync;
    logic        s_rstn;


    //**********************************************************
    //*** GPIO CONFIGURATIONS **********************************
    //**********************************************************

   logic [31:0][5:0] s_gpio_cfg;

   genvar i,j;

    pad_control #(
        .N_UART ( N_UART ),
        .N_SPI  ( N_SPI  ),
        .N_I2C  ( N_I2C  )
    ) pad_control_i (

        //********************************************************************//
        //*** PERIPHERALS SIGNALS ********************************************//
        //********************************************************************//
        .pad_mux_i             ( pad_mux_i             ),
        .pad_cfg_i             ( pad_cfg_i             ),
        .pad_cfg_o             ( pad_cfg_o             ),

        .gpio_out_i            ( gpio_out_i            ),
        .gpio_in_o             ( gpio_in_o             ),
        .gpio_dir_i            ( gpio_dir_i            ),
        .gpio_cfg_i            ( s_gpio_cfg            ),

        .uart_tx_i             ( uart_tx_i             ),
        .uart_rx_o             ( uart_rx_o             ),

        .i2c_scl_out_i         ( i2c_scl_out_i         ),
        .i2c_scl_in_o          ( i2c_scl_in_o          ),
        .i2c_scl_oe_i          ( i2c_scl_oe_i          ),
        .i2c_sda_out_i         ( i2c_sda_out_i         ),
        .i2c_sda_in_o          ( i2c_sda_in_o          ),
        .i2c_sda_oe_i          ( i2c_sda_oe_i          ),

        .i2s_slave_sd0_o       ( i2s_slave_sd0_o       ),
        .i2s_slave_sd1_o       ( i2s_slave_sd1_o       ),
        .i2s_slave_ws_o        ( i2s_slave_ws_o        ),
        .i2s_slave_ws_i        ( i2s_slave_ws_i        ),
        .i2s_slave_ws_oe       ( i2s_slave_ws_oe       ),
        .i2s_slave_sck_o       ( i2s_slave_sck_o       ),
        .i2s_slave_sck_i       ( i2s_slave_sck_i       ),
        .i2s_slave_sck_oe      ( i2s_slave_sck_oe      ),

        .spi_clk_i             ( spi_clk_i             ),
        .spi_csn_i             ( spi_csn_i             ),
        .spi_oen_i             ( spi_oen_i             ),
        .spi_sdo_i             ( spi_sdo_i             ),
        .spi_sdi_o             ( spi_sdi_o             ),

        .sdio_clk_i            ( sdio_clk_i            ),
        .sdio_cmd_i            ( sdio_cmd_i            ),
        .sdio_cmd_o            ( sdio_cmd_o            ),
        .sdio_cmd_oen_i        ( sdio_cmd_oen_i        ),
        .sdio_data_i           ( sdio_data_i           ),
        .sdio_data_o           ( sdio_data_o           ),
        .sdio_data_oen_i       ( sdio_data_oen_i       ),

        .cam_pclk_o            ( cam_pclk_o            ),
        .cam_data_o            ( cam_data_o            ),
        .cam_hsync_o           ( cam_hsync_o           ),
        .cam_vsync_o           ( cam_vsync_o           ),

        /* DVSI */
        .dvsi_asa_i            ( dvsi_asa_i            ),
        .dvsi_are_i            ( dvsi_are_i            ),
        .dvsi_asy_i            ( dvsi_asy_i            ),
        .dvsi_ynrst_i          ( dvsi_ynrst_i          ),
        .dvsi_yclk_i           ( dvsi_yclk_i           ),
        .dvsi_sxy_i            ( dvsi_sxy_i            ),
        .dvsi_xclk_i           ( dvsi_xclk_i           ),
        .dvsi_xnrst_i          ( dvsi_xnrst_i          ),
        .dvsi_cfg0_i           ( dvsi_cfg0_i           ),
        .dvsi_cfg1_i           ( dvsi_cfg1_i           ),
        .dvsi_cfg2_i           ( dvsi_cfg2_i           ),
        .dvsi_cfg3_i           ( dvsi_cfg3_i           ),
        .dvsi_cfg4_i           ( dvsi_cfg4_i           ),
        .dvsi_cfg5_i           ( dvsi_cfg5_i           ),
        .dvsi_cfg6_i           ( dvsi_cfg6_i           ),
        .dvsi_cfg7_i           ( dvsi_cfg7_i           ),
        .dvsi_xydata0_o        ( dvsi_xydata0_o        ),
        .dvsi_xydata1_o        ( dvsi_xydata1_o        ),
        .dvsi_xydata2_o        ( dvsi_xydata2_o        ),
        .dvsi_xydata3_o        ( dvsi_xydata3_o        ),
        .dvsi_xydata4_o        ( dvsi_xydata4_o        ),
        .dvsi_xydata5_o        ( dvsi_xydata5_o        ),
        .dvsi_xydata6_o        ( dvsi_xydata6_o        ),
        .dvsi_xydata7_o        ( dvsi_xydata7_o        ),
        .dvsi_on0_o            ( dvsi_on0_o            ),
        .dvsi_on1_o            ( dvsi_on1_o            ),
        .dvsi_on2_o            ( dvsi_on2_o            ),
        .dvsi_on3_o            ( dvsi_on3_o            ),
        .dvsi_off0_o           ( dvsi_off0_o           ),
        .dvsi_off1_o           ( dvsi_off1_o           ),
        .dvsi_off2_o           ( dvsi_off2_o           ),
        .dvsi_off3_o           ( dvsi_off3_o           ),

        .timer0_i              ( timer0_i              ),
        .timer1_i              ( timer1_i              ),
        .timer2_i              ( timer2_i              ),
        .timer3_i              ( timer3_i              ),

        .out_spim_sdio0_o      ( out_spim_sdio0_o      ),
        .out_spim_sdio1_o      ( out_spim_sdio1_o      ),
        .out_spim_sdio2_o      ( out_spim_sdio2_o      ),
        .out_spim_sdio3_o      ( out_spim_sdio3_o      ),
        .out_spim_csn0_o       ( out_spim_csn0_o       ),
        .out_spim_csn1_o       ( out_spim_csn1_o       ),
        .out_spim_sck_o        ( out_spim_sck_o        ),
        .out_sdio_clk_o        ( out_sdio_clk_o        ),
        .out_sdio_cmd_o        ( out_sdio_cmd_o        ),
        .out_sdio_data0_o      ( out_sdio_data0_o      ),
        .out_sdio_data1_o      ( out_sdio_data1_o      ),
        .out_sdio_data2_o      ( out_sdio_data2_o      ),
        .out_sdio_data3_o      ( out_sdio_data3_o      ),
        .out_uart_rx_o         ( out_uart_rx_o         ),
        .out_uart_tx_o         ( out_uart_tx_o         ),
        .out_cam_pclk_o        ( out_cam_pclk_o        ),
        .out_cam_hsync_o       ( out_cam_hsync_o       ),
        .out_cam_data0_o       ( out_cam_data0_o       ),
        .out_cam_data1_o       ( out_cam_data1_o       ),
        .out_cam_data2_o       ( out_cam_data2_o       ),
        .out_cam_data3_o       ( out_cam_data3_o       ),
        .out_cam_data4_o       ( out_cam_data4_o       ),
        .out_cam_data5_o       ( out_cam_data5_o       ),
        .out_cam_data6_o       ( out_cam_data6_o       ),
        .out_cam_data7_o       ( out_cam_data7_o       ),
        .out_cam_vsync_o       ( out_cam_vsync_o       ),
        .out_i2c0_sda_o        ( out_i2c0_sda_o        ),
        .out_i2c0_scl_o        ( out_i2c0_scl_o        ),
        .out_i2s0_sck_o        ( out_i2s0_sck_o        ),
        .out_i2s0_ws_o         ( out_i2s0_ws_o         ),
        .out_i2s0_sdi_o        ( out_i2s0_sdi_o        ),
        .out_i2s1_sdi_o        ( out_i2s1_sdi_o        ),
        /* DVSI */
        .out_dvsi_asa_o        ( out_dvsi_asa_o        ),
        .out_dvsi_are_o        ( out_dvsi_are_o        ),
        .out_dvsi_asy_o        ( out_dvsi_asy_o        ),
        .out_dvsi_ynrst_o      ( out_dvsi_ynrst_o      ),
        .out_dvsi_yclk_o       ( out_dvsi_yclk_o       ),
        .out_dvsi_sxy_o        ( out_dvsi_sxy_o        ),
        .out_dvsi_xclk_o       ( out_dvsi_xclk_o       ),
        .out_dvsi_xnrst_o      ( out_dvsi_xnrst_o      ),
        .out_dvsi_cfg0_o       ( out_dvsi_cfg0_o       ),
        .out_dvsi_cfg1_o       ( out_dvsi_cfg1_o       ),
        .out_dvsi_cfg2_o       ( out_dvsi_cfg2_o       ),
        .out_dvsi_cfg3_o       ( out_dvsi_cfg3_o       ),
        .out_dvsi_cfg4_o       ( out_dvsi_cfg4_o       ),
        .out_dvsi_cfg5_o       ( out_dvsi_cfg5_o       ),
        .out_dvsi_cfg6_o       ( out_dvsi_cfg6_o       ),
        .out_dvsi_cfg7_o       ( out_dvsi_cfg7_o       ),

        .in_spim_sdio0_i       ( in_spim_sdio0_i       ),
        .in_spim_sdio1_i       ( in_spim_sdio1_i       ),
        .in_spim_sdio2_i       ( in_spim_sdio2_i       ),
        .in_spim_sdio3_i       ( in_spim_sdio3_i       ),
        .in_spim_csn0_i        ( in_spim_csn0_i        ),
        .in_spim_csn1_i        ( in_spim_csn1_i        ),
        .in_spim_sck_i         ( in_spim_sck_i         ),
        .in_sdio_clk_i         ( in_sdio_clk_i         ),
        .in_sdio_cmd_i         ( in_sdio_cmd_i         ),
        .in_sdio_data0_i       ( in_sdio_data0_i       ),
        .in_sdio_data1_i       ( in_sdio_data1_i       ),
        .in_sdio_data2_i       ( in_sdio_data2_i       ),
        .in_sdio_data3_i       ( in_sdio_data3_i       ),
        .in_uart_rx_i          ( in_uart_rx_i          ),
        .in_uart_tx_i          ( in_uart_tx_i          ),
        .in_cam_pclk_i         ( in_cam_pclk_i         ),
        .in_cam_hsync_i        ( in_cam_hsync_i        ),
        .in_cam_data0_i        ( in_cam_data0_i        ),
        .in_cam_data1_i        ( in_cam_data1_i        ),
        .in_cam_data2_i        ( in_cam_data2_i        ),
        .in_cam_data3_i        ( in_cam_data3_i        ),
        .in_cam_data4_i        ( in_cam_data4_i        ),
        .in_cam_data5_i        ( in_cam_data5_i        ),
        .in_cam_data6_i        ( in_cam_data6_i        ),
        .in_cam_data7_i        ( in_cam_data7_i        ),
        .in_cam_vsync_i        ( in_cam_vsync_i        ),
        .in_i2c0_sda_i         ( in_i2c0_sda_i         ),
        .in_i2c0_scl_i         ( in_i2c0_scl_i         ),
        .in_i2s0_sck_i         ( in_i2s0_sck_i         ),
        .in_i2s0_ws_i          ( in_i2s0_ws_i          ),
        .in_i2s0_sdi_i         ( in_i2s0_sdi_i         ),
        .in_i2s1_sdi_i         ( in_i2s1_sdi_i         ),
        /* DVSI */
        .in_dvsi_xydata0_i     ( in_dvsi_xydata0_i     ),
        .in_dvsi_xydata1_i     ( in_dvsi_xydata1_i     ),
        .in_dvsi_xydata2_i     ( in_dvsi_xydata2_i     ),
        .in_dvsi_xydata3_i     ( in_dvsi_xydata3_i     ),
        .in_dvsi_xydata4_i     ( in_dvsi_xydata4_i     ),
        .in_dvsi_xydata5_i     ( in_dvsi_xydata5_i     ),
        .in_dvsi_xydata6_i     ( in_dvsi_xydata6_i     ),
        .in_dvsi_xydata7_i     ( in_dvsi_xydata7_i     ),
        .in_dvsi_on0_i         ( in_dvsi_on0_i         ),
        .in_dvsi_on1_i         ( in_dvsi_on1_i         ),
        .in_dvsi_on2_i         ( in_dvsi_on2_i         ),
        .in_dvsi_on3_i         ( in_dvsi_on3_i         ),
        .in_dvsi_off0_i        ( in_dvsi_off0_i        ),
        .in_dvsi_off1_i        ( in_dvsi_off1_i        ),
        .in_dvsi_off2_i        ( in_dvsi_off2_i        ),
        .in_dvsi_off3_i        ( in_dvsi_off3_i        ),

        .oe_spim_sdio0_o       ( oe_spim_sdio0_o       ),
        .oe_spim_sdio1_o       ( oe_spim_sdio1_o       ),
        .oe_spim_sdio2_o       ( oe_spim_sdio2_o       ),
        .oe_spim_sdio3_o       ( oe_spim_sdio3_o       ),
        .oe_spim_csn0_o        ( oe_spim_csn0_o        ),
        .oe_spim_csn1_o        ( oe_spim_csn1_o        ),
        .oe_spim_sck_o         ( oe_spim_sck_o         ),
        .oe_sdio_clk_o         ( oe_sdio_clk_o         ),
        .oe_sdio_cmd_o         ( oe_sdio_cmd_o         ),
        .oe_sdio_data0_o       ( oe_sdio_data0_o       ),
        .oe_sdio_data1_o       ( oe_sdio_data1_o       ),
        .oe_sdio_data2_o       ( oe_sdio_data2_o       ),
        .oe_sdio_data3_o       ( oe_sdio_data3_o       ),
        .oe_uart_rx_o          ( oe_uart_rx_o          ),
        .oe_uart_tx_o          ( oe_uart_tx_o          ),
        .oe_cam_pclk_o         ( oe_cam_pclk_o         ),
        .oe_cam_hsync_o        ( oe_cam_hsync_o        ),
        .oe_cam_data0_o        ( oe_cam_data0_o        ),
        .oe_cam_data1_o        ( oe_cam_data1_o        ),
        .oe_cam_data2_o        ( oe_cam_data2_o        ),
        .oe_cam_data3_o        ( oe_cam_data3_o        ),
        .oe_cam_data4_o        ( oe_cam_data4_o        ),
        .oe_cam_data5_o        ( oe_cam_data5_o        ),
        .oe_cam_data6_o        ( oe_cam_data6_o        ),
        .oe_cam_data7_o        ( oe_cam_data7_o        ),
        .oe_cam_vsync_o        ( oe_cam_vsync_o        ),
        .oe_i2c0_sda_o         ( oe_i2c0_sda_o         ),
        .oe_i2c0_scl_o         ( oe_i2c0_scl_o         ),
        .oe_i2s0_sck_o         ( oe_i2s0_sck_o         ),
        .oe_i2s0_ws_o          ( oe_i2s0_ws_o          ),
        .oe_i2s0_sdi_o         ( oe_i2s0_sdi_o         ),
        .oe_i2s1_sdi_o         ( oe_i2s1_sdi_o         ),
        /* DVSI */
        /*
        .oe_dvsi_asa_o         ( oe_dvsi_asa_o         ),
        .oe_dvsi_are_o         ( oe_dvsi_are_o         ),
        .oe_dvsi_asy_o         ( oe_dvsi_asy_o         ),
        .oe_dvsi_ynrst_o       ( oe_dvsi_ynrst_o       ),
        .oe_dvsi_yclk_o        ( oe_dvsi_yclk_o        ),
        .oe_dvsi_sxy_o         ( oe_dvsi_sxy_o         ),
        .oe_dvsi_xclk_o        ( oe_dvsi_xclk_o        ),
        .oe_dvsi_xnrst_o       ( oe_dvsi_xnrst_o       ),
        .oe_dvsi_cfg0_o        ( oe_dvsi_cfg0_o        ),
        .oe_dvsi_cfg1_o        ( oe_dvsi_cfg1_o        ),
        .oe_dvsi_cfg2_o        ( oe_dvsi_cfg2_o        ),
        .oe_dvsi_cfg3_o        ( oe_dvsi_cfg3_o        ),
        .oe_dvsi_cfg4_o        ( oe_dvsi_cfg4_o        ),
        .oe_dvsi_cfg5_o        ( oe_dvsi_cfg5_o        ),
        .oe_dvsi_cfg6_o        ( oe_dvsi_cfg6_o        ),
        .oe_dvsi_cfg7_o        ( oe_dvsi_cfg7_o        ),
        */

        .*
    );


`ifndef PULP_FPGA_EMUL
    rstgen i_rstgen
    (
        .clk_i       ( ref_clk_i   ),
        .rst_ni      ( s_rstn      ),
        .test_mode_i ( test_mode_o ),
        .rst_no      ( s_rstn_sync ),  //to be used by logic clocked with ref clock in AO domain
        .init_no     (             )  //not used
    );

  assign slow_clk_o = ref_clk_i;

`else
  assign s_rstn_sync = s_rstn;
  //Don't use the supplied clock directly for the FPGA target. On some boards
  //the reference clock is a very fast (e.g. 200MHz) clock that cannot be used
  //directly as the "slow_clk". Therefore we slow it down if a FPGA/board
  //dependent module fpga_slow_clk_gen. Dividing the fast reference clock
  //internally instead of doing so in the toplevel prevents unecessary clock
  //division just to generate a faster clock once again in the SoC and
  //Peripheral clock PLLs in soc_domain.sv. Instead all PLL use directly the
  //board reference clock as input.

  fpga_slow_clk_gen i_slow_clk_gen
    (
     .rst_ni(s_rstn_sync),
     .ref_clk_i(ref_clk_i),
     .slow_clk_o(slow_clk_o)
     );
`endif


    assign s_rstn          = rst_ni;
    assign rst_no          = s_rstn;

    assign test_clk_o      = 1'b0;
    assign dft_cg_enable_o = 1'b0;
    assign test_mode_o     = 1'b0;
    assign mode_select_o   = 1'b0;

    //********************************************************
    //*** PAD AND GPIO CONFIGURATION SIGNALS PACK ************
    //********************************************************

    generate
       for (i=0; i<32; i++)
     begin : GEN_GPIO_CFG_I
        for (j=0; j<6; j++)
          begin : GEN_GPIO_CFG_J
         assign s_gpio_cfg[i][j] = gpio_cfg_i[j+6*i];
          end
     end
    endgenerate

endmodule // safe_domain
