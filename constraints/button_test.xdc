## Nexys 4 rev B - prueba de ocho botones externos en Pmod JB
## Reloj principal de 100 MHz
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]
## Botones externos activos en HIGH
## JB1, JB2, JB3, JB4, JB7, JB8, JB9 y JB10
set_property PACKAGE_PIN G14 [get_ports {buttons_async[0]}]
set_property PACKAGE_PIN P15 [get_ports {buttons_async[1]}]
set_property PACKAGE_PIN V11 [get_ports {buttons_async[2]}]
set_property PACKAGE_PIN V15 [get_ports {buttons_async[3]}]
set_property PACKAGE_PIN K16 [get_ports {buttons_async[4]}]
set_property PACKAGE_PIN R16 [get_ports {buttons_async[5]}]
set_property PACKAGE_PIN T9  [get_ports {buttons_async[6]}]
set_property PACKAGE_PIN U11 [get_ports {buttons_async[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {buttons_async[*]}]
## LEDs LD0 a LD7
set_property PACKAGE_PIN T8 [get_ports {led[0]}]
set_property PACKAGE_PIN V9 [get_ports {led[1]}]
set_property PACKAGE_PIN R8 [get_ports {led[2]}]
set_property PACKAGE_PIN T6 [get_ports {led[3]}]
set_property PACKAGE_PIN T5 [get_ports {led[4]}]
set_property PACKAGE_PIN T4 [get_ports {led[5]}]
set_property PACKAGE_PIN U7 [get_ports {led[6]}]
set_property PACKAGE_PIN U6 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
