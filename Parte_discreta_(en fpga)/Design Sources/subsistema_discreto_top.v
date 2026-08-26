`timescale 1ns/1ps
// ============================================================================
// subsistema_discreto_top.v
//
// Integra en un solo módulo la versión digital (Verilog) de todo lo que en
// el diseño original se planteaba como circuitería discreta:
//
//   SOLICITUD_TOPO --> control_solicitud --> PULSO_AVANCE
//                                                 |
//                                                 v
//                                     lfsr_4bit (avanza estado)
//                                                 |
//                          +----------------------+----------------------+
//                          v                                             v
//                 decodificador_led (LED[7:0])                 uart_tx (UART_TX)
//
// Secuencia:
//   1) Llega un pulso en SOLICITUD_TOPO (proveniente de la FSM del juego en
//      la FPGA).
//   2) control_solicitud genera PULSO_AVANCE de 1 ciclo.
//   3) El LFSR avanza de estado en ese mismo flanco -> nueva POSICION_TOPO.
//   4) El decodificador muestra la posición nueva en los LEDs de inmediato
//      (es combinacional).
//   5) Un ciclo después (para que POSICION_TOPO ya sea estable), se dispara
//      la transmisión UART con el byte {5'b0, POSICION_TOPO[2:0]}.
// ============================================================================
module subsistema_discreto_top #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD     = 9600
) (
    input  wire clk,             // reloj de la Nexys4 (100 MHz, pin E3)
    input  wire rst_n,           // reset activo en bajo
    input  wire solicitud_topo,  // entrada: pedido de nueva posición
    output wire uart_tx_line,    // salida serie hacia el receptor UART (FPGA)
    output wire [7:0] led,       // salida: LED de la posición activa
    output wire tx_busy          // opcional: útil para depuración
);

    wire pulso_avance;
    reg  pulso_avance_d;         // versión retrasada 1 ciclo (arma el dato)
    reg  pendiente;              // solicitud de TX en espera de que UART esté libre
    reg  start_tx;               // pulso de 1 ciclo -> arranca uart_tx
    wire [3:0] estado_lfsr;
    wire [2:0] posicion_topo;
    wire tx_listo;

    control_solicitud u_ctrl (
        .clk            (clk),
        .rst_n          (rst_n),
        .solicitud_topo (solicitud_topo),
        .pulso_avance   (pulso_avance)
    );

    lfsr_4bit u_lfsr (
        .clk           (clk),
        .rst_n         (rst_n),
        .en            (pulso_avance),
        .estado_lfsr   (estado_lfsr),
        .posicion_topo (posicion_topo)
    );

    decodificador_led u_dec (
        .posicion (posicion_topo),
        .led      (led)
    );

    // Se retrasa un ciclo la marca de "dato listo" para asegurar que
    // posicion_topo ya refleje el nuevo estado del LFSR (que se actualiza
    // de forma síncrona en el mismo flanco en que se genera pulso_avance).
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pulso_avance_d <= 1'b0;
        else        pulso_avance_d <= pulso_avance;
    end

    // Se retiene la solicitud de transmisión (PENDIENTE) hasta que el UART
    // quede libre (TX_LISTO), evitando perder una solicitud si llegara
    // mientras aún se está transmitiendo la posición anterior. En el uso
    // real esto no debería ocurrir (una partida solicita un topo nuevo cada
    // cientos de ms, mucho más lento que una trama UART), pero se deja como
    // margen de seguridad.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pendiente <= 1'b0;
            start_tx  <= 1'b0;
        end else begin
            start_tx <= 1'b0; // pulso por defecto en 0
            if (pulso_avance_d)
                pendiente <= 1'b1;
            if (pendiente && tx_listo) begin
                start_tx  <= 1'b1;
                pendiente <= 1'b0;
            end
        end
    end

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD     (BAUD)
    ) u_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .start_tx (start_tx),
        .data_in  ({5'b00000, posicion_topo}),
        .tx       (uart_tx_line),
        .tx_busy  (tx_busy),
        .tx_listo (tx_listo)
    );

endmodule
