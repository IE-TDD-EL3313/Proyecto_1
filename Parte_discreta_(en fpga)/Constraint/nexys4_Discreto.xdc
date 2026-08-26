## ============================================================================
## nexys4_discreto.xdc
## Restricciones para subsistema_discreto_top en la Nexys 4.
## Todos los pines, bancos y nombres de señal fueron tomados EXACTAMENTE del
## archivo maestro Nexys-4-Master.xdc proporcionado (mismos PACKAGE_PIN,
## mismo IOSTANDARD, mismos comentarios de banco/nombre de esquemático).
## ============================================================================

## ----------------------------------------------------------------------------
## Reloj de 100 MHz
## Bank = 35, Pin name = IO_L12P_T1_MRCC_35, Sch name = CLK100MHZ
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ----------------------------------------------------------------------------
## Reset
## Bank = 15, Pin name = IO_L3P_T0_DQS_AD1P_15, Sch name = CPU_RESET
## CORRECCIÓN: btnCpuReset es ACTIVO EN BAJO (en reposo entrega '1', al
## presionarlo entrega '0') -- es la convención de Xilinx para reset de
## "soft cores" en los diseños de referencia de Digilent. Nuestro puerto
## rst_n también es activo en bajo, así que se conecta DIRECTO, sin invertir:
##   wire rst_n = btnCpuReset;   // (ya lo hace así rtl/nexys4_top.v)
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN C12 [get_ports btnCpuReset]
set_property IOSTANDARD LVCMOS33 [get_ports btnCpuReset]

## ----------------------------------------------------------------------------
## Botón central (BTNC) — solicitud_topo para pruebas manuales.
## Bank = 15, Pin name = IO_L11N_T1_SRCC_15, Sch name = BTNC
## En el diseño final esta señal la genera la FSM del juego, no un botón
## físico; se deja aquí solo para poder probar el subsistema discreto de
## forma aislada presionando un botón.
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN E16 [get_ports solicitud_topo]
set_property IOSTANDARD LVCMOS33 [get_ports solicitud_topo]

## ----------------------------------------------------------------------------
## LEDs LD0-LD7 (posición activa del topo)
## Bank = 34
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN T8 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN V9 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN R8 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN T6 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN T5 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN T4 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U7 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN U6 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

## ----------------------------------------------------------------------------
## OPCIÓN A (recomendada para pruebas): puente USB-UART integrado de la
## Nexys4 (chip FTDI). Con esto se puede ver la trama transmitida directo en
## un terminal serial del PC (PuTTY, RealTerm, screen, etc.) sin cableado
## externo. RsTx es la señal que la FPGA transmite HACIA el PC.
## Bank = 35, Pin name = IO_L11N_T1_SRCC_35, Sch name = UART_RXD_OUT
## ----------------------------------------------------------------------------
set_property PACKAGE_PIN D4 [get_ports uart_tx_line]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_line]

## ----------------------------------------------------------------------------
## OPCIÓN B (alternativa): sacar la señal por el PMOD JA, pin 1, para
## conectarla a un dispositivo externo real (osciloscopio, otro chip, etc).
## Bank = 15, Pin name = IO_L1N_T0_AD0N_15, Sch name = JA1
## Si usa esta opción, comente el bloque "OPCIÓN A" de arriba y descomente
## las dos líneas siguientes (y cambie el nombre del puerto si hace falta).
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN B13 [get_ports uart_tx_line]
#set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_line]

## ----------------------------------------------------------------------------
## NOTA IMPORTANTE sobre integración con el subsistema FPGA (receptor_uart):
## Si subsistema_discreto_top y receptor_uart conviven en el MISMO bitstream,
## NO conecte uart_tx_line a un pin físico: conéctela por wire interno
## directamente al puerto serial_sync de receptor_uart (tal como hace
## tb/tb_whackamole.v). Las opciones A y B de arriba solo tienen sentido si
## quiere observar o exportar la señal físicamente.
## ----------------------------------------------------------------------------
