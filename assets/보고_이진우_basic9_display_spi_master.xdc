create_clock -name PL_GCLK -period 20 [get_ports clk]


set_property PACKAGE_PIN Y14 [get_ports clk]

set_property PACKAGE_PIN Y17 [get_ports rst_n]
set_property PACKAGE_PIN U14 [get_ports i_start]   

set_property PACKAGE_PIN Y13 [get_ports o_sclk]
set_property PACKAGE_PIN P2 [get_ports o_mosi]   
set_property PACKAGE_PIN P8 [get_ports o_cs_n]
set_property PACKAGE_PIN M3 [get_ports o_dc_n]   
set_property PACKAGE_PIN M7 [get_ports o_rst_n]









set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports i_start]

set_property IOSTANDARD LVCMOS33 [get_ports o_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports o_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports o_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports o_dc_n]
set_property IOSTANDARD LVCMOS33 [get_ports o_rst_n]

