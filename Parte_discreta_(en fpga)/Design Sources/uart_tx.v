`timescale 1ns/1ps
// ============================================================================
// uart_tx.v
//
// Sustituye al bloque discreto "Registro / Transmisión UART" (74HC165 +
// 74HC164 + latch SR con 74HC00). En Verilog no hace falta separar contador
// de anillo / registro de desplazamiento / latch en componentes distintos:
// una sola FSM síncrona resuelve la trama completa START -> 8 datos -> STOP.
//
// Trama 8N1: 1 bit START ('0'), 8 bits de datos (LSB primero), 1 bit STOP
// ('1'). DATA_IN[2:0] = POSICION_TOPO[2:0], los bits restantes se envían en 0.
// ============================================================================
module uart_tx #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD     = 9600
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start_tx,   // = INICIAR_TX (pulso de 1 ciclo)
    input  wire [7:0] data_in,    // = DATO_TX[7:0]
    output reg        tx,         // = UART_TX (línea serial hacia la FPGA)
    output wire       tx_busy,    // = TX_BUSY  (equivalente a E)
    output wire       tx_listo    // = TX_LISTO (equivalente a E_negado)
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATOS = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] estado;
    reg [7:0] shift_reg;
    reg [2:0] bit_cnt;

    wire baud_tick;
    baud_gen #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) u_baud (
        .clk(clk), .rst_n(rst_n), .baud_tick(baud_tick)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            estado    <= IDLE;
            tx        <= 1'b1;   // línea en reposo = '1'
            shift_reg <= 8'h00;
            bit_cnt   <= 3'd0;
        end else begin
            case (estado)
                IDLE: begin
                    tx <= 1'b1;
                    if (start_tx) begin
                        shift_reg <= data_in;   // = LOAD_TX
                        estado    <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;              // bit de start
                    if (baud_tick) begin
                        estado  <= DATOS;
                        bit_cnt <= 3'd0;
                    end
                end

                DATOS: begin
                    tx <= shift_reg[0];      // se envía LSB primero
                    if (baud_tick) begin
                        shift_reg <= {1'b0, shift_reg[7:1]}; // = SHIFT_EN
                        if (bit_cnt == 3'd7)
                            estado <= STOP;
                        else
                            bit_cnt <= bit_cnt + 1'b1;
                    end
                end

                STOP: begin
                    tx <= 1'b1;              // bit de stop
                    if (baud_tick)
                        estado <= IDLE;
                end

                default: estado <= IDLE;
            endcase
        end
    end

    assign tx_busy  = (estado != IDLE);
    assign tx_listo = (estado == IDLE);

endmodule
