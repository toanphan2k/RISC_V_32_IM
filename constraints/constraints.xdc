# Example constraint file for find_min_top.
# Replace the clock period with the board clock period and fill in the
# package-pin assignments for your specific FPGA board before implementation.

# Example: 100 MHz input clock (10 ns period).
# create_clock -name sys_clk -period 10.00 [get_ports clk]

# Set I/O standards and package pins using your board's master XDC.
# Do not use guessed pin assignments; incorrect pins can prevent implementation
# or cause electrical conflicts on the board.
#
# Example syntax:
# set_property -dict { PACKAGE_PIN <clock_pin> IOSTANDARD <io_standard> } [get_ports clk]
# set_property -dict { PACKAGE_PIN <reset_pin> IOSTANDARD <io_standard> } [get_ports rst_n]
# set_property -dict { PACKAGE_PIN <start_pin> IOSTANDARD <io_standard> } [get_ports start]
# set_property -dict { PACKAGE_PIN <write_enable_pin> IOSTANDARD <io_standard> } [get_ports ram_we]
# set_property -dict { PACKAGE_PIN <done_pin> IOSTANDARD <io_standard> } [get_ports done]
# set_property -dict { PACKAGE_PIN <write_address_bit_0_pin> IOSTANDARD <io_standard> } [get_ports {ram_waddr[0]}]
# Repeat for ram_waddr[1] through ram_waddr[6].
# set_property -dict { PACKAGE_PIN <write_data_bit_0_pin> IOSTANDARD <io_standard> } [get_ports {ram_wdata[0]}]
# Repeat for ram_wdata[1] through ram_wdata[7].
# set_property -dict { PACKAGE_PIN <min_bit_0_pin> IOSTANDARD <io_standard> } [get_ports {min_value[0]}]
# set_property -dict { PACKAGE_PIN <min_bit_1_pin> IOSTANDARD <io_standard> } [get_ports {min_value[1]}]
# set_property -dict { PACKAGE_PIN <min_bit_2_pin> IOSTANDARD <io_standard> } [get_ports {min_value[2]}]
# set_property -dict { PACKAGE_PIN <min_bit_3_pin> IOSTANDARD <io_standard> } [get_ports {min_value[3]}]
# set_property -dict { PACKAGE_PIN <min_bit_4_pin> IOSTANDARD <io_standard> } [get_ports {min_value[4]}]
# set_property -dict { PACKAGE_PIN <min_bit_5_pin> IOSTANDARD <io_standard> } [get_ports {min_value[5]}]
# set_property -dict { PACKAGE_PIN <min_bit_6_pin> IOSTANDARD <io_standard> } [get_ports {min_value[6]}]
# set_property -dict { PACKAGE_PIN <min_bit_7_pin> IOSTANDARD <io_standard> } [get_ports {min_value[7]}]
#
# address is an output on this design, typically useful for debug. If you
# keep it as a top-level port, constrain each bit as well:
# set_property -dict { PACKAGE_PIN <address_bit_pin> IOSTANDARD <io_standard> } [get_ports {address[0]}]
# Repeat for address[1] through address[6].

create_clock -name sys_clk -period 3.00 [get_ports clk]
