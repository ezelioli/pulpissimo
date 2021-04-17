//-----------------------------------------------------------------------------
// Title         : PULPissimo Verilog Wrapper
//-----------------------------------------------------------------------------
// File          : xilinx_pulpissimo.v
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 21.05.2019
//-----------------------------------------------------------------------------
// Description :
// Verilog Wrapper of PULPissimo to use the module within Xilinx IP integrator.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

module xilinx_pulpissimo
  (
   input wire  ref_clk_p,
   input wire  ref_clk_n,

//   inout wire  pad_spim_sdio0,
   inout wire  pad_spim_sdio1,
   inout wire  pad_spim_sdio2,
   inout wire  pad_spim_sdio3,
   inout wire  pad_spim_csn0,
   inout wire  pad_spim_sck,

   inout wire  pad_uart_rx,
   inout wire  pad_uart_tx,

   inout wire  led0_o, //Mapped to spim_csn1
   inout wire  led1_o, //Mapped to cam_pclk
   inout wire  led2_o, //Mapped to cam_hsync
   inout wire  led3_o, //Mapped to cam_data0

   inout wire  switch0_i, //Mapped to cam_data1
   inout wire  switch1_i, //Mapped to cam_data2

   inout wire  btnc_i, //Mapped to cam_data3
   inout wire  btnd_i, //Mapped to cam_data4
   inout wire  btnl_i, //Mapped to cam_data5
   inout wire  btnr_i, //Mapped to cam_data6
   inout wire  btnu_i, //Mapped to cam_data7

   inout wire  oled_spim_sck_o, //Mapped to spim_sck
   inout wire  oled_spim_mosi_o, //Mapped to spim_sdio0
   inout wire  oled_rst_o, //Mapped to i2s0_sck
   inout wire  oled_dc_o, //Mapped to i2s0_ws
   inout wire  oled_vbat_o, // Mapped to i2s0_sdi
   inout wire  oled_vdd_o, // Mapped to i2s1_sdi

   inout wire  sdio_reset_o, //Reset signal for SD card need to be driven low to
                             //power the onboard sd-card. Mapped to cam_vsync.
   inout wire  pad_sdio_clk,
   inout wire  pad_sdio_cmd,
   inout wire  pad_sdio_data0,
   inout wire  pad_sdio_data1,
   inout wire  pad_sdio_data2,
   inout wire  pad_sdio_data3,

   inout wire  pad_i2c0_sda,
   inout wire  pad_i2c0_scl,

   /* DVSI */
   inout wire  pad_dvsi_asa    , //fmc_la_p[0] , //pad_dvsi_asa    ,
   inout wire  pad_dvsi_are    , //fmc_la_p[1] , //pad_dvsi_are    ,
   inout wire  pad_dvsi_asy    , //fmc_la_p[2] , //pad_dvsi_asy    ,
   inout wire  pad_dvsi_ynrst  , //fmc_la_p[3] , //pad_dvsi_ynrst  ,
   inout wire  pad_dvsi_yclk   , //fmc_la_p[4] , //pad_dvsi_yclk   ,
   inout wire  pad_dvsi_sxy    , //fmc_la_p[5] , //pad_dvsi_sxy    ,
   inout wire  pad_dvsi_xclk   , //fmc_la_p[6] , //pad_dvsi_xclk   ,
   inout wire  pad_dvsi_xnrst  , //fmc_la_p[7] , //pad_dvsi_xnrst  ,
   inout wire  pad_dvsi_cfg0   , //fmc_la_p[8] , //pad_dvsi_cfg0   ,
   inout wire  pad_dvsi_cfg1   , //fmc_la_p[9] , //pad_dvsi_cfg1   ,
   inout wire  pad_dvsi_cfg2   , //fmc_la_p[10], //pad_dvsi_cfg2   ,
   inout wire  pad_dvsi_cfg3   , //fmc_la_p[11], //pad_dvsi_cfg3   ,
   inout wire  pad_dvsi_cfg4   , //fmc_la_p[12], //pad_dvsi_cfg4   ,
   inout wire  pad_dvsi_cfg5   , //fmc_la_p[13], //pad_dvsi_cfg5   ,
   inout wire  pad_dvsi_cfg6   , //fmc_la_p[14], //pad_dvsi_cfg6   ,
   inout wire  pad_dvsi_cfg7   , //fmc_la_p[15], //pad_dvsi_cfg7   ,
   inout wire  pad_dvsi_xydata0, //fmc_la_p[16], //pad_dvsi_xydata0,
   inout wire  pad_dvsi_xydata1, //fmc_la_p[17], //pad_dvsi_xydata1,
   inout wire  pad_dvsi_xydata2, //fmc_la_p[18], //pad_dvsi_xydata2,
   inout wire  pad_dvsi_xydata3, //fmc_la_p[19], //pad_dvsi_xydata3,
   inout wire  pad_dvsi_xydata4, //fmc_la_p[20], //pad_dvsi_xydata4,
   inout wire  pad_dvsi_xydata5, //fmc_la_p[21], //pad_dvsi_xydata5,
   inout wire  pad_dvsi_xydata6, //fmc_la_p[22], //pad_dvsi_xydata6,
   inout wire  pad_dvsi_xydata7, //fmc_la_p[23], //pad_dvsi_xydata7,
   inout wire  pad_dvsi_on0    , //fmc_la_p[24], //pad_dvsi_on0    ,
   inout wire  pad_dvsi_on1    , //fmc_la_p[25], //pad_dvsi_on1    ,
   inout wire  pad_dvsi_on2    , //fmc_la_p[26], //pad_dvsi_on2    ,
   inout wire  pad_dvsi_on3    , //fmc_la_p[27], //pad_dvsi_on3    ,
   inout wire  pad_dvsi_off0   , //fmc_la_p[28], //pad_dvsi_off0   ,
   inout wire  pad_dvsi_off1   , //fmc_la_p[29], //pad_dvsi_off1   ,
   inout wire  pad_dvsi_off2   , //fmc_la_p[30], //pad_dvsi_off2   ,
   inout wire  pad_dvsi_off3   , //fmc_la_p[31], //pad_dvsi_off3   ,

   input wire  pad_reset_n,
   inout wire  pad_bootsel,

   input wire  pad_jtag_tck,
   input wire  pad_jtag_tdi,
   output wire pad_jtag_tdo,
   input wire  pad_jtag_tms,
   input wire  pad_jtag_trst
 );

  localparam CORE_TYPE = 0; // 0 for RISCY, 1 for IBEX RV32IMC (formerly ZERORISCY), 2 for IBEX RV32EC (formerly MICRORISCY)
  localparam USE_FPU   = 1;
  localparam USE_HWPE = 0;

  wire        ref_clk;

  //wire pad_dvsi_asa     ;
  //wire pad_dvsi_are     ;
  //wire pad_dvsi_asy     ;
  //wire pad_dvsi_ynrst   ;
  //wire pad_dvsi_yclk    ;
  //wire pad_dvsi_sxy     ;
  //wire pad_dvsi_xclk    ;
  //wire pad_dvsi_xnrst   ;
  //wire pad_dvsi_cfg0    ;
  //wire pad_dvsi_cfg1    ;
  //wire pad_dvsi_cfg2    ;
  //wire pad_dvsi_cfg3    ;
  //wire pad_dvsi_cfg4    ;
  //wire pad_dvsi_cfg5    ;
  //wire pad_dvsi_cfg6    ;
  //wire pad_dvsi_cfg7    ;
  //wire pad_dvsi_xydata0 ;
  //wire pad_dvsi_xydata1 ;
  //wire pad_dvsi_xydata2 ;
  //wire pad_dvsi_xydata3 ;
  //wire pad_dvsi_xydata4 ;
  //wire pad_dvsi_xydata5 ;
  //wire pad_dvsi_xydata6 ;
  //wire pad_dvsi_xydata7 ;
  //wire pad_dvsi_on0     ;
  //wire pad_dvsi_on1     ;
  //wire pad_dvsi_on2     ;
  //wire pad_dvsi_on3     ;
  //wire pad_dvsi_off0    ;
  //wire pad_dvsi_off1    ;
  //wire pad_dvsi_off2    ;
  //wire pad_dvsi_off3    ;

  //assign fmc_la_p[0]     = pad_dvsi_asa     ;
  //assign fmc_la_p[1]     = pad_dvsi_are     ;
  //assign fmc_la_p[2]     = pad_dvsi_asy     ;
  //assign fmc_la_p[3]     = pad_dvsi_ynrst   ;
  //assign fmc_la_p[4]     = pad_dvsi_yclk    ;
  //assign fmc_la_p[5]     = pad_dvsi_sxy     ;
  //assign fmc_la_p[6]     = pad_dvsi_xclk    ;
  //assign fmc_la_p[7]     = pad_dvsi_xnrst   ;
  //assign fmc_la_p[8]     = pad_dvsi_cfg0    ;
  //assign fmc_la_p[9]     = pad_dvsi_cfg1    ;
  //assign fmc_la_p[10]    = pad_dvsi_cfg2    ;
  //assign fmc_la_p[11]    = pad_dvsi_cfg3    ;
  //assign fmc_la_p[12]    = pad_dvsi_cfg4    ;
  //assign fmc_la_p[13]    = pad_dvsi_cfg5    ;
  //assign fmc_la_p[14]    = pad_dvsi_cfg6    ;
  //assign fmc_la_p[15]    = pad_dvsi_cfg7    ;
  //assign fmc_la_p[16]    = pad_dvsi_xydata0 ;
  //assign fmc_la_p[17]    = pad_dvsi_xydata1 ;
  //assign fmc_la_p[18]    = pad_dvsi_xydata2 ;
  //assign fmc_la_p[19]    = pad_dvsi_xydata3 ;
  //assign fmc_la_p[20]    = pad_dvsi_xydata4 ;
  //assign fmc_la_p[21]    = pad_dvsi_xydata5 ;
  //assign fmc_la_p[22]    = pad_dvsi_xydata6 ;
  //assign fmc_la_p[23]    = pad_dvsi_xydata7 ;
  //assign fmc_la_p[24]    = pad_dvsi_on0     ;
  //assign fmc_la_p[25]    = pad_dvsi_on1     ;
  //assign fmc_la_p[26]    = pad_dvsi_on2     ;
  //assign fmc_la_p[27]    = pad_dvsi_on3     ;
  //assign fmc_la_p[28]    = pad_dvsi_off0    ;
  //assign fmc_la_p[29]    = pad_dvsi_off1    ;
  //assign fmc_la_p[30]    = pad_dvsi_off2    ;
  //assign fmc_la_p[31]    = pad_dvsi_off3    ;



  //Differential to single ended clock conversion
  IBUFGDS
    #(
      .IOSTANDARD("LVDS"),
      .DIFF_TERM("FALSE"),
      .IBUF_LOW_PWR("FALSE"))
  i_sysclk_iobuf
    (
     .I(ref_clk_p),
     .IB(ref_clk_n),
     .O(ref_clk)
     );

  pulpissimo
    #(.CORE_TYPE(CORE_TYPE),
      .USE_FPU(USE_FPU),
      .USE_HWPE(USE_HWPE)
      ) i_pulpissimo
      (
       .pad_spim_sdio0(oled_spim_mosi_o),
       .pad_spim_sdio1(pad_spim_sdio1),
       .pad_spim_sdio2(pad_spim_sdio2),
       .pad_spim_sdio3(pad_spim_sdio3),
       .pad_spim_csn0(pad_spim_csn0),
       .pad_spim_csn1(led0_o),
       .pad_spim_sck(oled_spim_sck_o),
       .pad_uart_rx(pad_uart_rx),
       .pad_uart_tx(pad_uart_tx),
       .pad_cam_pclk(led1_o),
       .pad_cam_hsync(led2_o),
       .pad_cam_data0(led3_o),
       .pad_cam_data1(switch0_i),
       .pad_cam_data2(switch1_i),
       .pad_cam_data3(btnc_i),
       .pad_cam_data4(btnd_i),
       .pad_cam_data5(btnl_i),
       .pad_cam_data6(btnr_i),
       .pad_cam_data7(btnu_i),
       .pad_cam_vsync(sdio_reset_o),
       .pad_sdio_clk(pad_sdio_clk),
       .pad_sdio_cmd(pad_sdio_cmd),
       .pad_sdio_data0(pad_sdio_data0),
       .pad_sdio_data1(pad_sdio_data1),
       .pad_sdio_data2(pad_sdio_data2),
       .pad_sdio_data3(pad_sdio_data3),
       .pad_i2c0_sda(pad_i2c0_sda),
       .pad_i2c0_scl(pad_i2c0_scl),
       .pad_i2s0_sck(oled_rst_o),
       .pad_i2s0_ws(oled_dc_o),
       .pad_i2s0_sdi(oled_vbat_o),
       .pad_i2s1_sdi(oled_vdd_o),
       /* DVSI */
       .pad_dvsi_asa(pad_dvsi_asa),
       .pad_dvsi_are(pad_dvsi_are),
       .pad_dvsi_asy(pad_dvsi_asy),
       .pad_dvsi_ynrst(pad_dvsi_ynrst),
       .pad_dvsi_yclk(pad_dvsi_yclk),
       .pad_dvsi_sxy(pad_dvsi_sxy),
       .pad_dvsi_xclk(pad_dvsi_xclk),
       .pad_dvsi_xnrst(pad_dvsi_xnrst),
       .pad_dvsi_cfg0(pad_dvsi_cfg0),
       .pad_dvsi_cfg1(pad_dvsi_cfg1),
       .pad_dvsi_cfg2(pad_dvsi_cfg2),
       .pad_dvsi_cfg3(pad_dvsi_cfg3),
       .pad_dvsi_cfg4(pad_dvsi_cfg4),
       .pad_dvsi_cfg5(pad_dvsi_cfg5),
       .pad_dvsi_cfg6(pad_dvsi_cfg6),
       .pad_dvsi_cfg7(pad_dvsi_cfg7),
       .pad_dvsi_xydata0(pad_dvsi_xydata0),
       .pad_dvsi_xydata1(pad_dvsi_xydata1),
       .pad_dvsi_xydata2(pad_dvsi_xydata2),
       .pad_dvsi_xydata3(pad_dvsi_xydata3),
       .pad_dvsi_xydata4(pad_dvsi_xydata4),
       .pad_dvsi_xydata5(pad_dvsi_xydata5),
       .pad_dvsi_xydata6(pad_dvsi_xydata6),
       .pad_dvsi_xydata7(pad_dvsi_xydata7),
       .pad_dvsi_on0(pad_dvsi_on0),
       .pad_dvsi_on1(pad_dvsi_on1),
       .pad_dvsi_on2(pad_dvsi_on2),
       .pad_dvsi_on3(pad_dvsi_on3),
       .pad_dvsi_off0(pad_dvsi_off0),
       .pad_dvsi_off1(pad_dvsi_off1),
       .pad_dvsi_off2(pad_dvsi_off2),
       .pad_dvsi_off3(pad_dvsi_off3),

       .pad_reset_n(pad_reset_n),
       .pad_jtag_tck(pad_jtag_tck),
       .pad_jtag_tdi(pad_jtag_tdi),
       .pad_jtag_tdo(pad_jtag_tdo),
       .pad_jtag_tms(pad_jtag_tms),
       .pad_jtag_trst(pad_jtag_trst),
       .pad_xtal_in(ref_clk),
       .pad_bootsel()
       );

endmodule
