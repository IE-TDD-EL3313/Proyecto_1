`timescale 1ns/1ps
// ============================================================================
// control_solicitud.v
//
// Sustituye al bloque discreto "Control de solicitud" (antes implementado con
// un flip-flop D + compuertas NOT/AND). Aquí se agrega además un sincronizador
// de 2 etapas, útil si SOLICITUD_TOPO llega desde un dominio de reloj distinto
// (por ejemplo, si el "subsistema discreto" se ubica en otra región del mismo
// FPGA o en otro chip). Si ambos subsistemas comparten el mismo reloj, el
// sincronizador es opcional, pero no estorba y es buena práctica dejarlo.
//
// Función: generar un único PULSO_AVANCE de 1 ciclo de reloj por cada
// transición 0->1 de SOLICITUD_TOPO, evitando que una solicitud sostenida
// provoque múltiples avances del LFSR.
// ============================================================================
module control_solicitud (
    input  wire clk,
    input  wire rst_n,           // reset asíncrono, activo en bajo
    input  wire solicitud_topo,  // señal externa proveniente de la FSM del juego
    output wire pulso_avance     // pulso de un ciclo -> avanza LFSR y dispara TX
);

    // sync_reg[0] = 1ra etapa sync, sync_reg[1] = 2da etapa (señal ya estable),
    // sync_reg[2] = valor anterior de la 2da etapa (para detectar flanco)
    reg [2:0] sync_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sync_reg <= 3'b000;
        else
            sync_reg <= {sync_reg[1:0], solicitud_topo};
    end

    // Detector de flanco de subida 0 -> 1 sobre la señal sincronizada
    assign pulso_avance = sync_reg[1] & ~sync_reg[2];

endmodule
