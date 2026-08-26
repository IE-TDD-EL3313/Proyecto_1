`timescale 1ns/1ps
// ============================================================================
// nexys4_top.v
//
// Wrapper de nivel superior pensado para probar el subsistema discreto de
// forma AISLADA en la placa física Nexys 4, usando los nombres de puerto que
// coinciden exactamente con constraints/nexys4_discreto.xdc.
//
// - btnCpuReset: reset físico del botón "CPU RESET" de la Nexys4. Según el
//   manual de referencia de Digilent, este botón es ACTIVO EN BAJO (en
//   reposo entrega '1', al presionarlo entrega '0') -- es la convención
//   estándar de Xilinx para el reset de "soft cores", pensada para
//   conectarse DIRECTO a una entrada de reset activa en bajo, sin invertir.
// - solicitud_topo: botón BTNC, para simular manualmente el pedido de un
//   nuevo topo (en el diseño final esta señal la genera la FSM del juego).
//   A diferencia de CPU_RESET, los botones BTNU/BTNC/BTNL/BTNR/BTND SI son
//   activos en alto (en reposo '0', al presionarlos '1').
// - led[7:0]: LEDs de la Nexys4, muestran la posición activa.
// - uart_tx_line: trama serie, conectada por defecto al puente USB-UART
//   integrado de la placa (ver constraints), visible en un terminal serial.
//
// NOTA: este wrapper es solo para pruebas aisladas del subsistema discreto.
// Para el proyecto completo (subsistema discreto + subsistema FPGA en el
// mismo bitstream), no use este wrapper: instancie subsistema_discreto_top y
// receptor_uart directamente en su top-level del juego, conectados por wire
// interno como se muestra en tb/tb_whackamole.v.
// ============================================================================
module nexys4_top (
    input  wire clk,            // CLK100MHZ (pin E3)
    input  wire btnCpuReset,    // CPU_RESET (pin C12), ACTIVO EN BAJO
    input  wire solicitud_topo, // BTNC (pin E16), activo en alto
    output wire [7:0] led,      // LD0-LD7
    output wire uart_tx_line    // hacia el puente USB-UART (o PMOD JA1)
);

    // btnCpuReset ya es activo en bajo (1=no presionado, 0=presionado),
    // exactamente la polaridad que nuestro rst_n necesita. NO se invierte.
    wire rst_n = btnCpuReset;

    subsistema_discreto_top #(
        .CLK_FREQ(100_000_000),
        .BAUD(9600)
    ) u_discreto (
        .clk            (clk),
        .rst_n          (rst_n),
        .solicitud_topo (solicitud_topo),
        .uart_tx_line   (uart_tx_line),
        .led            (led),
        .tx_busy        ()
    );

endmodule
