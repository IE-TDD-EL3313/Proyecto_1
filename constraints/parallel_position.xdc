## Nexys 4 rev B - receptor paralelo de posicion desde protoboard
## Este archivo usa JA1, JA2 y JA3 como entradas Q0, Q1 y Q2.
## IMPORTANTE: los pines Pmod son de 3.3 V. No aplicar 5 V directamente.
## Reloj principal de 100 MHz
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]
## Posicion desde el LFSR discreto
## JA1 <- Q0 (bit menos significativo)
set_property PACKAGE_PIN B13 [get_ports {position_async[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {position_async[0]}]
## JA2 <- Q1
set_property PACKAGE_PIN F14 [get_ports {position_async[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {position_async[1]}]
## JA3 <- Q2 (bit mas significativo)
set_property PACKAGE_PIN D17 [get_ports {position_async[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {position_async[2]}]
## LEDs LD0 a LD7; exactamente uno se enciende segun Q2:Q1:Q0
set_property PACKAGE_PIN T8 [get_ports {led[0]}]
set_property PACKAGE_PIN V9 [get_ports {led[1]}]
set_property PACKAGE_PIN R8 [get_ports {led[2]}]
set_property PACKAGE_PIN T6 [get_ports {led[3]}]
set_property PACKAGE_PIN T5 [get_ports {led[4]}]
set_property PACKAGE_PIN T4 [get_ports {led[5]}]
set_property PACKAGE_PIN U7 [get_ports {led[6]}]
set_property PACKAGE_PIN U6 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]