`timescale 1ns/1ps
// ============================================================================
// lfsr_4bit.v
//
// Sustituye al bloque discreto "Registro LFSR" (4 flip-flops D + XOR de
// realimentación). Genera la secuencia pseudoaleatoria que determina la
// posición del topo.
//
// Polinomio usado: x^4 + x^3 + 1  (realimentación = state[3] ^ state[2])
// Es un LFSR de Galois/Fibonacci de 4 bits con periodo máximo 15
// (recorre todos los valores de 1 a 15, nunca pasa por 0000).
//
// La semilla inicial se fija por RESET y debe ser distinta de 0000, tal como
// indica el documento de diseño.
//
// POSICION_TOPO[2:0] se arma igual que en el diseño original:
//   posicion_topo[2:0] = {Q1, Q2, Q4}
// Ajuste el mapeo de bits si su etiquetado de flip-flops (Q1..Q4) difiere.
// ============================================================================
module lfsr_4bit (
    input  wire clk,
    input  wire rst_n,
    input  wire en,                  // = PULSO_AVANCE: hace avanzar el LFSR
    output wire [3:0] estado_lfsr,   // {Q1,Q2,Q3,Q4}
    output wire [2:0] posicion_topo  // {Q1,Q2,Q4}
);

    localparam [3:0] SEMILLA = 4'b1011; // cualquier valor != 0000

    reg [3:0] q; // q[3]=Q1 (MSB, primero en entrar), q[0]=Q4 (LSB, último)

    wire feedback = q[3] ^ q[2]; // x^4 + x^3 + 1

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= SEMILLA;
        else if (en)
            q <= {q[2:0], feedback}; // desplazamiento con realimentación
    end

    assign estado_lfsr   = q;
    // Q1 = q[3], Q2 = q[2], Q3 = q[1], Q4 = q[0]
    assign posicion_topo = {q[3], q[2], q[0]}; // {Q1,Q2,Q4}

endmodule
