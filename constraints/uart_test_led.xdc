## ============================================================
## UART TEST - Nexys 4 Rev. B
## Recibe UART por JB1 y muestra la posición en LED[7:0]
## ============================================================


## ------------------------------------------------------------
## CLOCK 100 MHz
## ------------------------------------------------------------

set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -add -name sys_clk_pin \
-period 10.000 \
-waveform {0.000 5.000} \
[get_ports clk]


## ------------------------------------------------------------
## RESET
## Usamos botón central BTNC
## ------------------------------------------------------------

set_property PACKAGE_PIN E16 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]


## ------------------------------------------------------------
## UART RX DESDE CIRCUITO DISCRETO
## Pmod JB1
## ------------------------------------------------------------

set_property PACKAGE_PIN G14 [get_ports uart_rx_in]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_in]


## ------------------------------------------------------------
## LEDS DE LA NEXYS 4
## ------------------------------------------------------------

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