#######################################
#  _______ _           _              #
# |__   __(_)         (_)             #
#    | |   _ _ __ ___  _ _ __   __ _  #
#    | |  | | '_ ` _ \| | '_ \ / _` | #
#    | |  | | | | | | | | | | | (_| | #
#    |_|  |_|_| |_| |_|_|_| |_|\__, | #
#                               __/ | #
#                              |___/  #
#######################################


#Create constraint for the clock input of the genesys2 board
create_clock -period 5.000 -name ref_clk [get_ports ref_clk_p]

#I2S and CAM interface are not used in this FPGA port. Set constraints to
#disable the clock
set_case_analysis 0 i_pulpissimo/safe_domain_i/cam_pclk_o
set_case_analysis 0 i_pulpissimo/safe_domain_i/i2s_slave_sck_o
#set_input_jitter tck 1.000

## JTAG
create_clock -period 100.000 -name tck -waveform {0.000 50.000} [get_ports pad_jtag_tck]
set_input_jitter tck 1.000


# minimize routing delay
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tdi]
set_input_delay -clock tck -clock_fall 5.000 [get_ports pad_jtag_tms]
set_output_delay -clock tck 5.000 [get_ports pad_jtag_tdo]
set_false_path -from [get_ports pad_jtag_trst]

set_max_delay -to [get_ports pad_jtag_tdo] 20.000
set_max_delay -from [get_ports pad_jtag_tms] 20.000
set_max_delay -from [get_ports pad_jtag_tdi] 20.000
set_max_delay -from [get_ports pad_jtag_trst] 20.000

set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
set_max_delay -datapath_only -from [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000


# reset signal
set_false_path -from [get_ports pad_reset_n]

# Set ASYNC_REG attribute for ff synchronizers to place them closer together and
# increase MTBF
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim0/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim1/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim2/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_adv_timer/u_tim3/u_in_stage/r_ls_clk_sync_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_apb_timer_unit/s_ref_clk*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/i_ref_clk_sync/i_pulp_sync/r_reg_reg*]
set_property ASYNC_REG true [get_cells i_pulpissimo/soc_domain_i/pulp_soc_i/soc_peripherals_i/u_evnt_gen/r_ls_sync_reg*]

# Create asynchronous clock group between slow-clk and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/safe_domain_i/i_slow_clk_gen/i_slow_clk_mngr/inst/mmcm_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/i_fpga_clk_gen/i_clk_manager/inst/mmcm_adv_inst/CLKOUT0]]

# Create asynchronous clock group between Per Clock  and SoC clock. Those clocks
# are considered asynchronously and proper synchronization regs are in place
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_per_o]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]

# Create asynchronous clock group between JTAG TCK and SoC clock.
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins i_pulpissimo/pad_jtag_tck]] -group [get_clocks -of_objects [get_pins i_pulpissimo/soc_domain_i/pulp_soc_i/i_clk_rst_gen/clk_soc_o]]

#############################################################
#  _____ ____         _____      _   _   _                  #
# |_   _/ __ \       / ____|    | | | | (_)                 #
#   | || |  | |_____| (___   ___| |_| |_ _ _ __   __ _ ___  #
#   | || |  | |______\___ \ / _ \ __| __| | '_ \ / _` / __| #
#  _| || |__| |      ____) |  __/ |_| |_| | | | | (_| \__ \ #
# |_____\____/      |_____/ \___|\__|\__|_|_| |_|\__, |___/ #
#                                                 __/ |     #
#                                                |___/      #
#############################################################

## Sys clock
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVDS} [get_ports ref_clk_n]
set_property -dict {PACKAGE_PIN AD12 IOSTANDARD LVDS} [get_ports ref_clk_p]


## Buttons
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports pad_reset_n]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS12} [get_ports btnc_i]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS12} [get_ports btnd_i]
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS12} [get_ports btnl_i]
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS12} [get_ports btnr_i]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS12} [get_ports btnu_i]

## To use FTDI FT2232 JTAG
set_property -dict {PACKAGE_PIN Y29 IOSTANDARD LVCMOS33} [get_ports pad_jtag_trst]
set_property -dict {PACKAGE_PIN AD27 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tck]
set_property -dict {PACKAGE_PIN W27 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdi]
set_property -dict {PACKAGE_PIN W28 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tdo]
set_property -dict {PACKAGE_PIN W29 IOSTANDARD LVCMOS33} [get_ports pad_jtag_tms]

## UART
set_property -dict {PACKAGE_PIN Y23 IOSTANDARD LVCMOS33} [get_ports pad_uart_tx]
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS33} [get_ports pad_uart_rx]

## LEDs
set_property -dict {PACKAGE_PIN T28 IOSTANDARD LVCMOS33} [get_ports led0_o]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports led1_o]
set_property -dict {PACKAGE_PIN U30 IOSTANDARD LVCMOS33} [get_ports led2_o]
set_property -dict {PACKAGE_PIN U29 IOSTANDARD LVCMOS33} [get_ports led3_o]
#set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports ]
#set_property -dict {PACKAGE_PIN V26 IOSTANDARD LVCMOS33} [get_ports ]
#set_property -dict {PACKAGE_PIN W24 IOSTANDARD LVCMOS33} [get_ports ]
#set_property -dict {PACKAGE_PIN W23 IOSTANDARD LVCMOS33} [get_ports ]

## Switches
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS12} [get_ports switch0_i]
set_property -dict {PACKAGE_PIN G25 IOSTANDARD LVCMOS12} [get_ports switch1_i]
#set_property -dict {PACKAGE_PIN H24 IOSTANDARD LVCMOS12} [get_ports {}]
# set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS12} [get_ports {}]
# set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS12} [get_ports {}]
# set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS12} [get_ports {}]
# set_property -dict {PACKAGE_PIN P26 IOSTANDARD LVCMOS33} [get_ports {}]
# set_property -dict {PACKAGE_PIN P27 IOSTANDARD LVCMOS33} [get_ports {}]

## I2C Bus
set_property -dict {PACKAGE_PIN AE30 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_scl]
set_property -dict {PACKAGE_PIN AF30 IOSTANDARD LVCMOS33} [get_ports pad_i2c0_sda]

## QSPI Flash
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports pad_spim_csn0]
#set_property -dict { PACKAGE_PIN P24   IOSTANDARD LVCMOS33 } [get_ports { pad_spim_sdio0 }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_d[0]
set_property -dict {PACKAGE_PIN R25 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio1]
set_property -dict {PACKAGE_PIN R20 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio2]
set_property -dict {PACKAGE_PIN R21 IOSTANDARD LVCMOS33} [get_ports pad_spim_sdio3]


## OLED Display
set_property -dict {PACKAGE_PIN AC17 IOSTANDARD LVCMOS18} [get_ports oled_dc_o]
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS18} [get_ports oled_rst_o]
set_property -dict {PACKAGE_PIN AF17 IOSTANDARD LVCMOS18} [get_ports oled_spim_sck_o]
set_property -dict {PACKAGE_PIN Y15 IOSTANDARD LVCMOS18} [get_ports oled_spim_mosi_o]
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports oled_vbat_o]
set_property -dict {PACKAGE_PIN AG17 IOSTANDARD LVCMOS18} [get_ports oled_vdd_o]


#############################################
## SD Card
#############################################
#set_property -dict { PACKAGE_PIN P28   IOSTANDARD LVCMOS33 } [get_ports { sd_cd }]; #IO_L8N_T1_D12_14 Sch=sd_cd
set_property -dict {PACKAGE_PIN R29 IOSTANDARD LVCMOS33} [get_ports pad_sdio_cmd]
set_property -dict {PACKAGE_PIN R26 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data0]
set_property -dict {PACKAGE_PIN R30 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data1]
set_property -dict {PACKAGE_PIN P29 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data2]
set_property -dict {PACKAGE_PIN T30 IOSTANDARD LVCMOS33} [get_ports pad_sdio_data3]
set_property -dict {PACKAGE_PIN AE24 IOSTANDARD LVCMOS33} [get_ports sdio_reset_o]
set_property -dict {PACKAGE_PIN R28 IOSTANDARD LVCMOS33} [get_ports pad_sdio_clk]



# set_property -dict {PACKAGE_PIN R28 IOSTANDARD LVCMOS33} [get_ports spi_clk_o]
# set_property -dict {PACKAGE_PIN T30 IOSTANDARD LVCMOS33} [get_ports spi_ss]
# set_property -dict {PACKAGE_PIN R26 IOSTANDARD LVCMOS33} [get_ports spi_miso]
# set_property -dict {PACKAGE_PIN R29 IOSTANDARD LVCMOS33} [get_ports spi_mosi]
# set_property -dict { PACKAGE_PIN P28   IOSTANDARD LVCMOS33 } [get_ports { sd_cd }]; #IO_L8N_T1_D12_14 Sch=sd_cd
# set_property -dict { PACKAGE_PIN R29   IOSTANDARD LVCMOS33 } [get_ports { sd_cmd }]; #IO_L7N_T1_D10_14 Sch=sd_cmd
# set_property -dict { PACKAGE_PIN R26   IOSTANDARD LVCMOS33 } [get_ports { sd_dat[0] }]; #IO_L10N_T1_D15_14 Sch=sd_dat[0]
# set_property -dict { PACKAGE_PIN R30   IOSTANDARD LVCMOS33 } [get_ports { sd_dat[1] }]; #IO_L9P_T1_DQS_14 Sch=sd_dat[1]
# set_property -dict { PACKAGE_PIN P29   IOSTANDARD LVCMOS33 } [get_ports { sd_dat[2] }]; #IO_L7P_T1_D09_14 Sch=sd_dat[2]
# set_property -dict { PACKAGE_PIN T30   IOSTANDARD LVCMOS33 } [get_ports { sd_dat[3] }]; #IO_L9N_T1_DQS_D13_14 Sch=sd_dat[3]
# set_property -dict { PACKAGE_PIN AE24  IOSTANDARD LVCMOS33 } [get_ports { sd_reset }]; #IO_L12N_T1_MRCC_12 Sch=sd_reset
# set_property -dict { PACKAGE_PIN R28   IOSTANDARD LVCMOS33 } [get_ports { sd_clk }]; #IO_L11P_T1_SRCC_14 Sch=sd_sclk

# create_generated_clock -name sd_fast_clk -source [get_pins clk_mmcm/sd_sys_clk] -divide_by 2 [get_pins chipset_impl/piton_sd_top/sdc_controller/clock_divider0/fast_clk_reg/Q]
# create_generated_clock -name sd_slow_clk -source [get_pins clk_mmcm/sd_sys_clk] -divide_by 200 [get_pins chipset_impl/piton_sd_top/sdc_controller/clock_divider0/slow_clk_reg/Q]
# create_generated_clock -name sd_clk_out -source [get_pins sd_clk_oddr/C] -divide_by 1 -add -master_clock sd_fast_clk [get_ports sd_clk_out]
# create_generated_clock -name sd_clk_out_1 -source [get_pins sd_clk_oddr/C] -divide_by 1 -add -master_clock sd_slow_clk [get_ports sd_clk_out]

# create_clock -period 40.000 -name VIRTUAL_sd_fast_clk -waveform {0.000 20.000}
# create_clock -period 4000.000 -name VIRTUAL_sd_slow_clk -waveform {0.000 2000.000}

# set_output_delay -clock [get_clocks sd_clk_out] -min -add_delay 5.000 [get_ports {sd_dat[*]}]
# set_output_delay -clock [get_clocks sd_clk_out] -max -add_delay 15.000 [get_ports {sd_dat[*]}]
# set_output_delay -clock [get_clocks sd_clk_out_1] -min -add_delay 5.000 [get_ports {sd_dat[*]}]
# set_output_delay -clock [get_clocks sd_clk_out_1] -max -add_delay 1500.000 [get_ports {sd_dat[*]}]
# set_output_delay -clock [get_clocks sd_clk_out] -min -add_delay 5.000 [get_ports sd_cmd]
# set_output_delay -clock [get_clocks sd_clk_out] -max -add_delay 15.000 [get_ports sd_cmd]
# set_output_delay -clock [get_clocks sd_clk_out_1] -min -add_delay 5.000 [get_ports sd_cmd]
# set_output_delay -clock [get_clocks sd_clk_out_1] -max -add_delay 1500.000 [get_ports sd_cmd]
# set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk] -min -add_delay 20.000 [get_ports {sd_dat[*]}]
# set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk] -max -add_delay 35.000 [get_ports {sd_dat[*]}]
# set_input_delay -clock [get_clocks VIRTUAL_sd_slow_clk] -min -add_delay 2000.000 [get_ports {sd_dat[*]}]
# set_input_delay -clock [get_clocks VIRTUAL_sd_slow_clk] -max -add_delay 3500.000 [get_ports {sd_dat[*]}]
# set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk] -min -add_delay 20.000 [get_ports sd_cmd]
# set_input_delay -clock [get_clocks VIRTUAL_sd_fast_clk] -max -add_delay 35.000 [get_ports sd_cmd]
# set_input_delay -clock [get_clocks VIRTUAL_sd_slow_clk] -min -add_delay 2000.000 [get_ports sd_cmd]
# set_input_delay -clock [get_clocks VIRTUAL_sd_slow_clk] -max -add_delay 3500.000 [get_ports sd_cmd]
# set_clock_groups -physically_exclusive -group [get_clocks -include_generated_clocks sd_clk_out] -group [get_clocks -include_generated_clocks sd_clk_out_1]
# set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks {VIRTUAL_sd_fast_clk sd_fast_clk}] -group [get_clocks -include_generated_clocks {sd_slow_clk VIRTUAL_sd_slow_clk}]
# set_clock_groups -asynchronous -group [get_clocks [list [get_clocks -of_objects [get_pins clk_mmcm/chipset_clk]]]] -group [get_clocks -filter { NAME =~  "*sd*" }]

## PMOD Header JD
#set_property -dict {PACKAGE_PIN V27 IOSTANDARD LVCMOS33}     [get_ports { jd[0]}]
#set_property -dict {PACKAGE_PIN Y30 IOSTANDARD LVCMOS33}     [get_ports { jd[1]}]
#set_property -dict { PACKAGE_PIN V24   IOSTANDARD LVCMOS33 } [get_ports { jd[2] }]; #IO_L23N_T3_A02_D18_14 Sch=jd[3]
#set_property -dict { PACKAGE_PIN W22   IOSTANDARD LVCMOS33 } [get_ports { jd[3] }]; #IO_L24N_T3_A00_D16_14 Sch=jd[4]
#set_property -dict { PACKAGE_PIN U24   IOSTANDARD LVCMOS33 } [get_ports { jd[4] }]; #IO_L23P_T3_A03_D19_14 Sch=jd[7]
#set_property -dict { PACKAGE_PIN Y26   IOSTANDARD LVCMOS33 } [get_ports { jd[5] }]; #IO_L1P_T0_13 Sch=jd[8]
#set_property -dict { PACKAGE_PIN V22   IOSTANDARD LVCMOS33 } [get_ports { jd[6] }]; #IO_L22N_T3_A04_D20_14 Sch=jd[9]
#set_property -dict { PACKAGE_PIN W21   IOSTANDARD LVCMOS33 } [get_ports { jd[7] }]; #IO_L24P_T3_A01_D17_14 Sch=jd[10]## PMOD Header JD
#set_property -dict { PACKAGE_PIN V27   IOSTANDARD LVCMOS33 } [get_ports { jd[0] }]; #IO_L16N_T2_A15_D31_14 Sch=jd[1]
#set_property -dict { PACKAGE_PIN Y30   IOSTANDARD LVCMOS33 } [get_ports { jd[1] }]; #IO_L8P_T1_13 Sch=jd[2]
#set_property -dict { PACKAGE_PIN V24   IOSTANDARD LVCMOS33 } [get_ports { jd[2] }]; #IO_L23N_T3_A02_D18_14 Sch=jd[3]
#set_property -dict { PACKAGE_PIN W22   IOSTANDARD LVCMOS33 } [get_ports { jd[3] }]; #IO_L24N_T3_A00_D16_14 Sch=jd[4]
#set_property -dict { PACKAGE_PIN U24   IOSTANDARD LVCMOS33 } [get_ports { jd[4] }]; #IO_L23P_T3_A03_D19_14 Sch=jd[7]
#set_property -dict { PACKAGE_PIN Y26   IOSTANDARD LVCMOS33 } [get_ports { jd[5] }]; #IO_L1P_T0_13 Sch=jd[8]
#set_property -dict { PACKAGE_PIN V22   IOSTANDARD LVCMOS33 } [get_ports { jd[6] }]; #IO_L22N_T3_A04_D20_14 Sch=jd[9]
#set_property -dict { PACKAGE_PIN W21   IOSTANDARD LVCMOS33 } [get_ports { jd[7] }]; #IO_L24P_T3_A01_D17_14 Sch=jd[10]


# Genesys 2 has a quad SPI flash
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]


## FMC
#set_property -dict { PACKAGE_PIN AB30  IOSTANDARD LVCMOS33 } [get_ports { FMC_CLK_DIR }]; #IO_L10N_T1_13 Sch=fmc_clk_dir
#set_property -dict { PACKAGE_PIN E20   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk0_m2c_n }]; #IO_L12N_T1_MRCC_17 Sch=fmc_clk0_m2c_n
#set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk0_m2c_p }]; #IO_L12P_T1_MRCC_17 Sch=fmc_clk0_m2c_p
#set_property -dict { PACKAGE_PIN D28   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk1_m2c_n }]; #IO_L14N_T2_SRCC_16 Sch=fmc_clk1_m2c_n
#set_property -dict { PACKAGE_PIN E28   IOSTANDARD LVCMOS12 } [get_ports { fmc_clk1_m2c_p }]; #IO_L14P_T2_SRCC_16 Sch=fmc_clk1_m2c_p
#set_property -dict { PACKAGE_PIN K25   IOSTANDARD LVCMOS12 } [get_ports { FMC_CLK_N[2] }]; #IO_L12N_T1_MRCC_AD5N_15 Sch=fmc_clk_n[2]
#set_property -dict { PACKAGE_PIN L25   IOSTANDARD LVCMOS12 } [get_ports { FMC_CLK_P[2] }]; #IO_L12P_T1_MRCC_AD5P_15 Sch=fmc_clk_p[2]
#set_property -dict { PACKAGE_PIN K29   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[00] }]; #IO_L13N_T2_MRCC_15 Sch=fmc_ha_n[00]
#set_property -dict { PACKAGE_PIN K28   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[00] }]; #IO_L13P_T2_MRCC_15 Sch=fmc_ha_p[00]
#set_property -dict { PACKAGE_PIN L28   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[01] }]; #IO_L14N_T2_SRCC_15 Sch=fmc_ha_n[01]
#set_property -dict { PACKAGE_PIN M28   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[01] }]; #IO_L14P_T2_SRCC_15 Sch=fmc_ha_p[01]
#set_property -dict { PACKAGE_PIN P22   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[02] }]; #IO_L22N_T3_A16_15 Sch=fmc_ha_n[02]
#set_property -dict { PACKAGE_PIN P21   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[02] }]; #IO_L22P_T3_A17_15 Sch=fmc_ha_p[02]
#set_property -dict { PACKAGE_PIN N26   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[03] }]; #IO_L18N_T2_A23_15 Sch=fmc_ha_n[03]
#set_property -dict { PACKAGE_PIN N25   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[03] }]; #IO_L18P_T2_A24_15 Sch=fmc_ha_p[03]
#set_property -dict { PACKAGE_PIN M25   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[04] }]; #IO_L23N_T3_FWE_B_15 Sch=fmc_ha_n[04]
#set_property -dict { PACKAGE_PIN M24   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[04] }]; #IO_L23P_T3_FOE_B_15 Sch=fmc_ha_p[04]
#set_property -dict { PACKAGE_PIN H29   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[05] }]; #IO_L7N_T1_AD10N_15 Sch=fmc_ha_n[05]
#set_property -dict { PACKAGE_PIN J29   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[05] }]; #IO_L7P_T1_AD10P_15 Sch=fmc_ha_p[05]
#set_property -dict { PACKAGE_PIN N30   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[06] }]; #IO_L17N_T2_A25_15 Sch=fmc_ha_n[06]
#set_property -dict { PACKAGE_PIN N29   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[06] }]; #IO_L17P_T2_A26_15 Sch=fmc_ha_p[06]
#set_property -dict { PACKAGE_PIN M30   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[07] }]; #IO_L15N_T2_DQS_ADV_B_15 Sch=fmc_ha_n[07]
#set_property -dict { PACKAGE_PIN M29   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[07] }]; #IO_L15P_T2_DQS_15 Sch=fmc_ha_p[07]
#set_property -dict { PACKAGE_PIN J28   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[08] }]; #IO_L8N_T1_AD3N_15 Sch=fmc_ha_n[08]
#set_property -dict { PACKAGE_PIN J27   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[08] }]; #IO_L8P_T1_AD3P_15 Sch=fmc_ha_p[08]
#set_property -dict { PACKAGE_PIN K30   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[09] }]; #IO_L9N_T1_DQS_AD11N_15 Sch=fmc_ha_n[09]
#set_property -dict { PACKAGE_PIN L30   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[09] }]; #IO_L9P_T1_DQS_AD11P_15 Sch=fmc_ha_p[09]
#set_property -dict { PACKAGE_PIN N22   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[10] }]; #IO_L20N_T3_A19_15 Sch=fmc_ha_n[10]
#set_property -dict { PACKAGE_PIN N21   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[10] }]; #IO_L20P_T3_A20_15 Sch=fmc_ha_p[10]
#set_property -dict { PACKAGE_PIN N24   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[11] }]; #IO_L21N_T3_DQS_A18_15 Sch=fmc_ha_n[11]
#set_property -dict { PACKAGE_PIN P23   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[11] }]; #IO_L21P_T3_DQS_15 Sch=fmc_ha_p[11]
#set_property -dict { PACKAGE_PIN L27   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[12] }]; #IO_L11N_T1_SRCC_AD12N_15 Sch=fmc_ha_n[12]
#set_property -dict { PACKAGE_PIN L26   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[12] }]; #IO_L11P_T1_SRCC_AD12P_15 Sch=fmc_ha_p[12]
#set_property -dict { PACKAGE_PIN J26   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[13] }]; #IO_L10N_T1_AD4N_15 Sch=fmc_ha_n[13]
#set_property -dict { PACKAGE_PIN K26   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[13] }]; #IO_L10P_T1_AD4P_15 Sch=fmc_ha_p[13]
#set_property -dict { PACKAGE_PIN M27   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[14] }]; #IO_L16N_T2_A27_15 Sch=fmc_ha_n[14]
#set_property -dict { PACKAGE_PIN N27   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[14] }]; #IO_L16P_T2_A28_15 Sch=fmc_ha_p[14]
#set_property -dict { PACKAGE_PIN J22   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[15] }]; #IO_L5N_T0_AD2N_15 Sch=fmc_ha_n[15]
#set_property -dict { PACKAGE_PIN J21   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[15] }]; #IO_L5P_T0_AD2P_15 Sch=fmc_ha_p[15]
#set_property -dict { PACKAGE_PIN M23   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[16] }]; #IO_L24N_T3_RS0_15 Sch=fmc_ha_n[16]
#set_property -dict { PACKAGE_PIN M22   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[16] }]; #IO_L24P_T3_RS1_15 Sch=fmc_ha_p[16]
#set_property -dict { PACKAGE_PIN B25   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[17] }]; #IO_L12N_T1_MRCC_16 Sch=fmc_ha_n[17]
#set_property -dict { PACKAGE_PIN C25   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[17] }]; #IO_L12P_T1_MRCC_16 Sch=fmc_ha_p[17]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[18] }]; #IO_L14N_T2_SRCC_17 Sch=fmc_ha_n[18]
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[18] }]; #IO_L14P_T2_SRCC_17 Sch=fmc_ha_p[18]
#set_property -dict { PACKAGE_PIN F30   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[19] }]; #IO_L22N_T3_16 Sch=fmc_ha_n[19]
#set_property -dict { PACKAGE_PIN G29   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[19] }]; #IO_L22P_T3_16 Sch=fmc_ha_p[19]
#set_property -dict { PACKAGE_PIN F27   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[20] }]; #IO_L21N_T3_DQS_16 Sch=fmc_ha_n[20]
#set_property -dict { PACKAGE_PIN G27   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[20] }]; #IO_L21P_T3_DQS_16 Sch=fmc_ha_p[20]
#set_property -dict { PACKAGE_PIN F28   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[21] }]; #IO_L20N_T3_16 Sch=fmc_ha_n[21]
#set_property -dict { PACKAGE_PIN G28   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[21] }]; #IO_L20P_T3_16 Sch=fmc_ha_p[21]
#set_property -dict { PACKAGE_PIN C21   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[22] }]; #IO_L8N_T1_17 Sch=fmc_ha_n[22]
#set_property -dict { PACKAGE_PIN D21   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[22] }]; #IO_L8P_T1_17 Sch=fmc_ha_p[22]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_N[23] }]; #IO_L16N_T2_17 Sch=fmc_ha_n[23]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS12 } [get_ports { FMC_HA_P[23] }]; #IO_L16P_T2_17 Sch=fmc_ha_p[23]
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[00] }]; #IO_L12N_T1_MRCC_18 Sch=fmc_hb_n[00]
#set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[00] }]; #IO_L12P_T1_MRCC_18 Sch=fmc_hb_p[00]
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[01] }]; #IO_L7N_T1_18 Sch=fmc_hb_n[01]
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[01] }]; #IO_L7P_T1_18 Sch=fmc_hb_p[01]
#set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[02] }]; #IO_L2N_T0_18 Sch=fmc_hb_n[02]
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[02] }]; #IO_L2P_T0_18 Sch=fmc_hb_p[02]
#set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[03] }]; #IO_L11N_T1_SRCC_18 Sch=fmc_hb_n[03]
#set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[03] }]; #IO_L11P_T1_SRCC_18 Sch=fmc_hb_p[03]
#set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[04] }]; #IO_L9N_T1_DQS_18 Sch=fmc_hb_n[04]
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[04] }]; #IO_L9P_T1_DQS_18 Sch=fmc_hb_p[04]
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[05] }]; #IO_L1N_T0_18 Sch=fmc_hb_n[05]
#set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[05] }]; #IO_L1P_T0_18 Sch=fmc_hb_p[05]
#set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[06] }]; #IO_L14N_T2_SRCC_18 Sch=fmc_hb_n[06]
#set_property -dict { PACKAGE_PIN F12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[06] }]; #IO_L14P_T2_SRCC_18 Sch=fmc_hb_p[06]
#set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[07] }]; #IO_L22N_T3_18 Sch=fmc_hb_n[07]
#set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[07] }]; #IO_L22P_T3_18 Sch=fmc_hb_p[07]
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[08] }]; #IO_L5N_T0_18 Sch=fmc_hb_n[08]
#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[08] }]; #IO_L5P_T0_18 Sch=fmc_hb_p[08]
#set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[09] }]; #IO_L23N_T3_18 Sch=fmc_hb_n[09]
#set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[09] }]; #IO_L23P_T3_18 Sch=fmc_hb_p[09]
#set_property -dict { PACKAGE_PIN J12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[10] }]; #IO_L8N_T1_18 Sch=fmc_hb_n[10]
#set_property -dict { PACKAGE_PIN J11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[10] }]; #IO_L8P_T1_18 Sch=fmc_hb_p[10]
#set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[11] }]; #IO_L18N_T2_18 Sch=fmc_hb_n[11]
#set_property -dict { PACKAGE_PIN D11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[11] }]; #IO_L18P_T2_18 Sch=fmc_hb_p[11]
#set_property -dict { PACKAGE_PIN A12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[12] }]; #IO_L17N_T2_18 Sch=fmc_hb_n[12]
#set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[12] }]; #IO_L17P_T2_18 Sch=fmc_hb_p[12]
#set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[13] }]; #IO_L15N_T2_DQS_18 Sch=fmc_hb_n[13]
#set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[13] }]; #IO_L15P_T2_DQS_18 Sch=fmc_hb_p[13]
#set_property -dict { PACKAGE_PIN H12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[14] }]; #IO_L10N_T1_18 Sch=fmc_hb_n[14]
#set_property -dict { PACKAGE_PIN H11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[14] }]; #IO_L10P_T1_18 Sch=fmc_hb_p[14]
#set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[15] }]; #IO_L3N_T0_DQS_18 Sch=fmc_hb_n[15]
#set_property -dict { PACKAGE_PIN L12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[15] }]; #IO_L3P_T0_DQS_18 Sch=fmc_hb_p[15]
#set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[16] }]; #IO_L4N_T0_18 Sch=fmc_hb_n[16]
#set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[16] }]; #IO_L4P_T0_18 Sch=fmc_hb_p[16]
#set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[17] }]; #IO_L13N_T2_MRCC_18 Sch=fmc_hb_n[17]
#set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[17] }]; #IO_L13P_T2_MRCC_18 Sch=fmc_hb_p[17]
#set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[18] }]; #IO_L20N_T3_18 Sch=fmc_hb_n[18]
#set_property -dict { PACKAGE_PIN E14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[18] }]; #IO_L20P_T3_18 Sch=fmc_hb_p[18]
#set_property -dict { PACKAGE_PIN E11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[19] }]; #IO_L16N_T2_18 Sch=fmc_hb_n[19]
#set_property -dict { PACKAGE_PIN F11   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[19] }]; #IO_L16P_T2_18 Sch=fmc_hb_p[19]
#set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[20] }]; #IO_L24N_T3_18 Sch=fmc_hb_n[20]
#set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[20] }]; #IO_L24P_T3_18 Sch=fmc_hb_p[20]
#set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_N[21] }]; #IO_L21N_T3_DQS_18 Sch=fmc_hb_n[21]
#set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS12 } [get_ports { FMC_HB_P[21] }]; #IO_L21P_T3_DQS_18 Sch=fmc_hb_p[21]
#set_property -dict { PACKAGE_PIN C27   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[00] }]; #IO_L13N_T2_MRCC_16 Sch=fmc_la_n[00]
#set_property -dict { PACKAGE_PIN C26   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[01] }]; #IO_L11N_T1_SRCC_16 Sch=fmc_la_n[01]
#set_property -dict { PACKAGE_PIN G30   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[02] }]; #IO_L24N_T3_16 Sch=fmc_la_n[02]
#set_property -dict { PACKAGE_PIN E30   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[03] }]; #IO_L18N_T2_16 Sch=fmc_la_n[03]
#set_property -dict { PACKAGE_PIN H27   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[04] }]; #IO_L23N_T3_16 Sch=fmc_la_n[04]
#set_property -dict { PACKAGE_PIN A30   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[05] }]; #IO_L17N_T2_16 Sch=fmc_la_n[05]
#set_property -dict { PACKAGE_PIN C30   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[06] }]; #IO_L16N_T2_16 Sch=fmc_la_n[06]
#set_property -dict { PACKAGE_PIN E25   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[07] }]; #IO_L3N_T0_DQS_16 Sch=fmc_la_n[07]
#set_property -dict { PACKAGE_PIN B29   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[08] }]; #IO_L15N_T2_DQS_16 Sch=fmc_la_n[08]
#set_property -dict { PACKAGE_PIN A28   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[09] }]; #IO_L9N_T1_DQS_16 Sch=fmc_la_n[09]
#set_property -dict { PACKAGE_PIN A27   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[10] }]; #IO_L7N_T1_16 Sch=fmc_la_n[10]
#set_property -dict { PACKAGE_PIN A26   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[11] }]; #IO_L10N_T1_16 Sch=fmc_la_n[11]
#set_property -dict { PACKAGE_PIN E26   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[12] }]; #IO_L5N_T0_16 Sch=fmc_la_n[12]
#set_property -dict { PACKAGE_PIN D24   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[13] }]; #IO_L4N_T0_16 Sch=fmc_la_n[13]
#set_property -dict { PACKAGE_PIN B24   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[14] }]; #IO_L8N_T1_16 Sch=fmc_la_n[14]
#set_property -dict { PACKAGE_PIN A23   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[15] }]; #IO_L1N_T0_16 Sch=fmc_la_n[15]
#set_property -dict { PACKAGE_PIN D23   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[16] }]; #IO_L2N_T0_16 Sch=fmc_la_n[16]
#set_property -dict { PACKAGE_PIN E21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[17] }]; #IO_L11N_T1_SRCC_17 Sch=fmc_la_n[17]
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[18] }]; #IO_L13N_T2_MRCC_17 Sch=fmc_la_n[18]
#set_property -dict { PACKAGE_PIN H22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[19] }]; #IO_L7N_T1_17 Sch=fmc_la_n[19]
#set_property -dict { PACKAGE_PIN F22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[20] }]; #IO_L9N_T1_DQS_17 Sch=fmc_la_n[20]
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[21] }]; #IO_L5N_T0_17 Sch=fmc_la_n[21]
#set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[22] }]; #IO_L3N_T0_DQS_17 Sch=fmc_la_n[22]
#set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[23] }]; #IO_L18N_T2_17 Sch=fmc_la_n[23]
#set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[24] }]; #IO_L2N_T0_17 Sch=fmc_la_n[24]
#set_property -dict { PACKAGE_PIN C22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[25] }]; #IO_L10N_T1_17 Sch=fmc_la_n[25]
#set_property -dict { PACKAGE_PIN A22   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[26] }]; #IO_L23N_T3_17 Sch=fmc_la_n[26]
#set_property -dict { PACKAGE_PIN A21   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[27] }]; #IO_L21N_T3_DQS_17 Sch=fmc_la_n[27]
#set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[28] }]; #IO_L4N_T0_17 Sch=fmc_la_n[28]
#set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[29] }]; #IO_L22N_T3_17 Sch=fmc_la_n[29]
#set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[30] }]; #IO_L20N_T3_17 Sch=fmc_la_n[30]
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[31] }]; #IO_L17N_T2_17 Sch=fmc_la_n[31]
set_property -dict { PACKAGE_PIN D27   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_asa     }]; #IO_L13P_T2_MRCC_16 Sch=fmc_la_p[00]
set_property -dict { PACKAGE_PIN D26   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_are     }]; #IO_L11P_T1_SRCC_16 Sch=fmc_la_p[01]
set_property -dict { PACKAGE_PIN H30   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_asy     }]; #IO_L24P_T3_16 Sch=fmc_la_p[02]
set_property -dict { PACKAGE_PIN E29   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_ynrst   }]; #IO_L18P_T2_16 Sch=fmc_la_p[03]
set_property -dict { PACKAGE_PIN H26   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_yclk    }]; #IO_L23P_T3_16 Sch=fmc_la_p[04]
set_property -dict { PACKAGE_PIN B30   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_sxy     }]; #IO_L17P_T2_16 Sch=fmc_la_p[05]
set_property -dict { PACKAGE_PIN D29   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xclk    }]; #IO_L16P_T2_16 Sch=fmc_la_p[06]
set_property -dict { PACKAGE_PIN F25   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xnrst   }]; #IO_L3P_T0_DQS_16 Sch=fmc_la_p[07]
set_property -dict { PACKAGE_PIN C29   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg0    }]; #IO_L15P_T2_DQS_16 Sch=fmc_la_p[08]
set_property -dict { PACKAGE_PIN B28   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg1    }]; #IO_L9P_T1_DQS_16 Sch=fmc_la_p[09]
set_property -dict { PACKAGE_PIN B27   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg2    }]; #IO_L7P_T1_16 Sch=fmc_la_p[10]
set_property -dict { PACKAGE_PIN A25   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg3    }]; #IO_L10P_T1_16 Sch=fmc_la_p[11]
set_property -dict { PACKAGE_PIN F26   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg4    }]; #IO_L5P_T0_16 Sch=fmc_la_p[12]
set_property -dict { PACKAGE_PIN E24   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg5    }]; #IO_L4P_T0_16 Sch=fmc_la_p[13]
set_property -dict { PACKAGE_PIN C24   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg6    }]; #IO_L8P_T1_16 Sch=fmc_la_p[14]
set_property -dict { PACKAGE_PIN B23   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_cfg7    }]; #IO_L1P_T0_16 Sch=fmc_la_p[15]
set_property -dict { PACKAGE_PIN E23   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata0 }]; #IO_L2P_T0_16 Sch=fmc_la_p[16]
set_property -dict { PACKAGE_PIN F21   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata1 }]; #IO_L11P_T1_SRCC_17 Sch=fmc_la_p[17]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata2 }]; #IO_L13P_T2_MRCC_17 Sch=fmc_la_p[18]
set_property -dict { PACKAGE_PIN H21   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata3 }]; #IO_L7P_T1_17 Sch=fmc_la_p[19]
set_property -dict { PACKAGE_PIN G22   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata4 }]; #IO_L9P_T1_DQS_17 Sch=fmc_la_p[20]
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata5 }]; #IO_L5P_T0_17 Sch=fmc_la_p[21]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata6 }]; #IO_L3P_T0_DQS_17 Sch=fmc_la_p[22]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_xydata7 }]; #IO_L18P_T2_17 Sch=fmc_la_p[23]
set_property -dict { PACKAGE_PIN H20   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_on0     }]; #IO_L2P_T0_17 Sch=fmc_la_p[24]
set_property -dict { PACKAGE_PIN D22   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_on1     }]; #IO_L10P_T1_17 Sch=fmc_la_p[25]
set_property -dict { PACKAGE_PIN B22   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_on2     }]; #IO_L23P_T3_17 Sch=fmc_la_p[26]
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_on3     }]; #IO_L21P_T3_DQS_17 Sch=fmc_la_p[27]
set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_off0    }]; #IO_L4P_T0_17 Sch=fmc_la_p[28]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_off1    }]; #IO_L22P_T3_17 Sch=fmc_la_p[29]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_off2    }]; #IO_L20P_T3_17 Sch=fmc_la_p[30]
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS12 } [get_ports { pad_dvsi_off3    }]; #IO_L17P_T2_17 Sch=fmc_la_p[31]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[32] }]; #IO_L1N_T0_17 Sch=fmc_la_n[32]
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[32] }]; #IO_L1P_T0_17 Sch=fmc_la_p[32]
#set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_n[33] }]; #IO_L15N_T2_DQS_17 Sch=fmc_la_n[33]
#set_property -dict { PACKAGE_PIN D16   IOSTANDARD LVCMOS12 } [get_ports { fmc_la_p[33] }]; #IO_L15P_T2_DQS_17 Sch=fmc_la_p[33]
#set_property -dict { PACKAGE_PIN AC24  IOSTANDARD LVCMOS33 } [get_ports { FMC_SCL }]; #IO_L9P_T1_DQS_12 Sch=fmc_scl
#set_property -dict { PACKAGE_PIN AD24  IOSTANDARD LVCMOS33 } [get_ports { FMC_SDA }]; #IO_L9N_T1_DQS_12 Sch=fmc_sda

