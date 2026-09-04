
create_clock -name PS_GCLK -period 20ns [get_ports clk]
          
set_property PACKAGE_PIN Y14 [get_ports clk]
          
set_property PACKAGE_PIN Y17 [get_ports rst_n]
set_property PACKAGE_PIN U14 [get_ports i_t_start]          

set_property PACKAGE_PIN M2 [get_ports o_car_ns_red]
set_property PACKAGE_PIN Y12 [get_ports o_car_ns_yellow]
set_property PACKAGE_PIN P3 [get_ports o_car_ns_green]
set_property PACKAGE_PIN M4 [get_ports o_car_ns_left]
set_property PACKAGE_PIN R5 [get_ports o_car_ew_red]
set_property PACKAGE_PIN M8 [get_ports o_car_ew_yellow]
set_property PACKAGE_PIN P7 [get_ports o_car_ew_green]
set_property PACKAGE_PIN U13 [get_ports o_car_ew_left]

set_property PACKAGE_PIN N8 [get_ports o_ped_ns_green]
set_property PACKAGE_PIN R3 [get_ports o_ped_ns_red]
set_property PACKAGE_PIN AB13 [get_ports o_ped_ew_green]
set_property PACKAGE_PIN V15 [get_ports o_ped_ew_red]



# Example: set_property IOSTANDARD LVDS_25 [get_ports [list data_p* data_n*]]

set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports i_t_start]

set_property IOSTANDARD LVCMOS33 [get_ports o_car_ns_red]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ns_yellow]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ns_green]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ns_left]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ew_red]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ew_yellow]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ew_green]
set_property IOSTANDARD LVCMOS33 [get_ports o_car_ew_left]

set_property IOSTANDARD LVCMOS33 [get_ports o_ped_ns_green]
set_property IOSTANDARD LVCMOS33 [get_ports o_ped_ns_red]
set_property IOSTANDARD LVCMOS33 [get_ports o_ped_ew_green]
set_property IOSTANDARD LVCMOS33 [get_ports o_ped_ew_red]






      
      