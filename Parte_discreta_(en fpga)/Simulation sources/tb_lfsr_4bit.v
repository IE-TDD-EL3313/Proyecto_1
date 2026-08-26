`timescale 1ns/1ps
// ============================================================================
// tb_lfsr_4bit.v
// Verifica: (1) la semilla inicial tras reset es distinta de 0000,
// (2) el LFSR nunca cae en el estado 0000, y (3) recorre los 15 estados
// posibles antes de repetir (periodo máximo).
// ============================================================================
module tb_lfsr_4bit;

    reg clk = 0;
    reg rst_n = 0;
    reg en = 0;
    wire [3:0] estado_lfsr;
    wire [2:0] posicion_topo;

    integer errores = 0;
    integer i;
    reg [3:0] primer_estado;
    reg [15:0] vistos; // bitmap de estados 0..15 vistos en el primer ciclo

    always #5 clk = ~clk;

    lfsr_4bit dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .en            (en),
        .estado_lfsr   (estado_lfsr),
        .posicion_topo (posicion_topo)
    );

    initial begin
        vistos = 16'b0;
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        if (estado_lfsr == 4'b0000) begin
            $display("FAIL: la semilla inicial es 0000");
            errores = errores + 1;
        end else begin
            $display("PASS: semilla inicial = %b (distinta de 0000)", estado_lfsr);
        end
        primer_estado = estado_lfsr;
        vistos[estado_lfsr] = 1'b1;

        // Avanza 20 veces (más que el periodo máximo de 15) y verifica
        // que nunca aparezca 0000 y que se recorran los 15 estados posibles
        // antes de repetir el primer_estado.
        for (i = 0; i < 20; i = i + 1) begin
            en = 1; @(posedge clk); en = 0; @(posedge clk);
            if (estado_lfsr == 4'b0000) begin
                $display("FAIL: el LFSR cayo en el estado prohibido 0000 en el paso %0d", i);
                errores = errores + 1;
            end
            vistos[estado_lfsr] = 1'b1;
            if (i < 14 && estado_lfsr == primer_estado) begin
                $display("FAIL: el LFSR repitio el estado inicial antes de 15 pasos (paso %0d)", i);
                errores = errores + 1;
            end
        end

        if (vistos == 16'b1111_1111_1111_1110) // todos los bits 1..15 en 1, bit0 (=0000) en 0
            $display("PASS: se recorrieron los 15 estados distintos de 0000 (periodo maximo)");
        else begin
            $display("FAIL: no se recorrieron los 15 estados esperados (vistos=%b)", vistos);
            errores = errores + 1;
        end

        if (errores == 0)
            $display(">>> tb_lfsr_4bit: TODAS LAS PRUEBAS PASARON");
        else
            $display(">>> tb_lfsr_4bit: %0d PRUEBA(S) FALLARON", errores);

        $finish;
    end

endmodule
