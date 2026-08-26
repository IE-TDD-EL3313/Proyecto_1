`timescale 1ns/1ps
// ============================================================================
// receptor_uart.v
//
// Implementación del bloque "Receptor UART" descrito en la sección 5.1.1 del
// documento de diseño. Recibe la trama 8N1 enviada por subsistema_discreto_top
// y recupera POSICION_TOPO[2:0] a partir de los 3 bits menos significativos.
//
// FSM: ESPERA -> START -> DATOS -> STOP -> ESPERA
// Muestreo en la mitad de cada bit para máxima robustez frente al jitter.
// ============================================================================
module receptor_uart #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD     = 9600
) (
    input  wire clk,
    input  wire rst_n,
    input  wire serial_sync,          // UART_TX ya sincronizado con clk
    output reg  [2:0] posicion_topo,  // posición recibida
    output reg  dato_valido           // pulso: nueva posición disponible
);

    localparam integer BIT_PERIOD  = CLK_FREQ / BAUD;
    localparam integer HALF_PERIOD = BIT_PERIOD / 2;

    localparam ESPERA = 2'd0;
    localparam START  = 2'd1;
    localparam DATOS  = 2'd2;
    localparam STOP   = 2'd3;

    reg [1:0]  estado;
    reg [15:0] cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  dato_rx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            estado        <= ESPERA;
            cnt           <= 0;
            bit_idx       <= 0;
            dato_rx       <= 8'h00;
            posicion_topo <= 3'b000;
            dato_valido   <= 1'b0;
        end else begin
            dato_valido <= 1'b0; // pulso de 1 ciclo por defecto

            case (estado)
                ESPERA: begin
                    if (serial_sync == 1'b0) begin // flanco de bajada = START
                        estado <= START;
                        cnt    <= 0;
                    end
                end

                START: begin
                    // Espera medio periodo para muestrear en el centro del bit START
                    if (cnt == HALF_PERIOD[15:0]) begin
                        if (serial_sync == 1'b0) begin // confirma bit de start
                            estado  <= DATOS;
                            cnt     <= 0;
                            bit_idx <= 0;
                        end else begin
                            estado <= ESPERA; // falso start (ruido)
                        end
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                DATOS: begin
                    if (cnt == BIT_PERIOD[15:0] - 1) begin
                        cnt            <= 0;
                        dato_rx[bit_idx] <= serial_sync; // LSB primero
                        if (bit_idx == 3'd7)
                            estado <= STOP;
                        else
                            bit_idx <= bit_idx + 1'b1;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                STOP: begin
                    if (cnt == BIT_PERIOD[15:0] - 1) begin
                        cnt <= 0;
                        if (serial_sync == 1'b1) begin // bit de stop válido
                            posicion_topo <= dato_rx[2:0];
                            dato_valido   <= 1'b1;
                        end
                        estado <= ESPERA;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end

                default: estado <= ESPERA;
            endcase
        end
    end

endmodule
