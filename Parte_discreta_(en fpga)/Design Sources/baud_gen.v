`timescale 1ns/1ps
// ============================================================================
// baud_gen.v
//
// Sustituye al bloque discreto "Generador de referencia temporal" (oscilador
// astable NE555 + divisor de frecuencia). En la Nexys 4 ya se dispone de un
// reloj estable de 100 MHz, así que basta con un contador/divisor digital
// para obtener BAUD_TICK a la tasa de baudios deseada.
//
// BAUD_TICK se genera como un pulso de 1 ciclo de clk cada (CLK_FREQ/BAUD)
// ciclos, sin importar si la transmisión está activa o no (tick libre,
// continuo). El bloque de transmisión UART decide cuándo usarlo.
// ============================================================================
module baud_gen #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD     = 9600
) (
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick
);
    localparam integer DIV_MAX = (CLK_FREQ / BAUD) - 1;
    localparam integer CNT_W   = $clog2(DIV_MAX + 1);

    reg [CNT_W-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt       <= 0;
            baud_tick <= 1'b0;
        end else if (cnt == DIV_MAX[CNT_W-1:0]) begin
            cnt       <= 0;
            baud_tick <= 1'b1;
        end else begin
            cnt       <= cnt + 1'b1;
            baud_tick <= 1'b0;
        end
    end
endmodule
