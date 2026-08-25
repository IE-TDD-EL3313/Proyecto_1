## ============================================================
## Nexys 4
## Prueba de 8 botones externos conectados al Pmod JA
##
## BTN0 -> LED0
## BTN1 -> LED1
## BTN2 -> LED2
## BTN3 -> LED3
## BTN4 -> LED4
## BTN5 -> LED5
## BTN6 -> LED6
## BTN7 -> LED7
## ============================================================


## ============================================================
## BOTONES EXTERNOS - PMOD JA
## ============================================================

## BTN0 -> JA1
set_property PACKAGE_PIN B13 [get_ports {botones[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[0]}]

## BTN1 -> JA2
set_property PACKAGE_PIN F14 [get_ports {botones[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[1]}]

## BTN2 -> JA3
set_property PACKAGE_PIN D17 [get_ports {botones[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[2]}]

## BTN3 -> JA4
set_property PACKAGE_PIN E17 [get_ports {botones[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[3]}]

## BTN4 -> JA7
set_property PACKAGE_PIN G13 [get_ports {botones[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[4]}]

## BTN5 -> JA8
set_property PACKAGE_PIN C17 [get_ports {botones[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[5]}]

## BTN6 -> JA9
set_property PACKAGE_PIN D18 [get_ports {botones[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[6]}]

## BTN7 -> JA10
set_property PACKAGE_PIN E18 [get_ports {botones[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {botones[7]}]


## ============================================================
## LED0 - LED7 DE LA NEXYS 4
## ============================================================

## LED0
set_property PACKAGE_PIN T8 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

## LED1
set_property PACKAGE_PIN V9 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

## LED2
set_property PACKAGE_PIN R8 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

## LED3
set_property PACKAGE_PIN T6 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

## LED4
set_property PACKAGE_PIN T5 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

## LED5
set_property PACKAGE_PIN T4 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

## LED6
set_property PACKAGE_PIN U7 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

## LED7
set_property PACKAGE_PIN U6 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]