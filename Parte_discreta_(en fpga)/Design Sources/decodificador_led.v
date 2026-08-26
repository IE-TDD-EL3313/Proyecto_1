`timescale 1ns/1ps
// ============================================================================
// decodificador_led.v
//
// Sustituye al 74HC138 físico. Decodificador 3 a 8 puramente combinacional:
// enciende un único LED según la posición de 3 bits recibida.
// ============================================================================
module decodificador_led (
    input  wire [2:0] posicion,
    output reg  [7:0] led
);
    always @(*) begin
        led = 8'b0000_0000;
        led[posicion] = 1'b1;
    end
endmodule
