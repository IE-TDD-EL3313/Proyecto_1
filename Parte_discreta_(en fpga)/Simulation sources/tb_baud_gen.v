`timescale 1ns/1ps
// ============================================================================
// tb_baud_gen.v
// Mide el número de ciclos de reloj entre pulsos de baud_tick consecutivos y
// verifica que coincida con CLK_FREQ/BAUD.
// ============================================================================
module tb_baud_gen;

    localparam integer CLK_FREQ = 100_000_000;
    localparam integer BAUD     = 115200;
    localparam integer ESPERADO = CLK_FREQ / BAUD; // ciclos entre ticks

    reg clk = 0;
    reg rst_n = 0;
    wire baud_tick;

    integer errores = 0;
    integer ciclos_ultimo_tick = -1;
    integer ciclo_actual = 0;
    integer periodo_medido;
    integer mediciones = 0;

    always #5 clk = ~clk;

    baud_gen #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .baud_tick (baud_tick)
    );

    always @(posedge clk) begin
        ciclo_actual = ciclo_actual + 1;
        if (baud_tick) begin
            if (ciclos_ultimo_tick != -1) begin
                periodo_medido = ciclo_actual - ciclos_ultimo_tick;
                mediciones = mediciones + 1;
                if (periodo_medido == ESPERADO)
                    $display("PASS: periodo entre ticks = %0d ciclos (esperado %0d)", periodo_medido, ESPERADO);
                else begin
                    $display("FAIL: periodo entre ticks = %0d ciclos (esperado %0d)", periodo_medido, ESPERADO);
                    errores = errores + 1;
                end
            end
            ciclos_ultimo_tick = ciclo_actual;
        end
    end

    initial begin
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;

        // Espera suficientes ciclos para capturar ~5 periodos de baud_tick
        repeat (ESPERADO * 6) @(posedge clk);

        if (mediciones < 4) begin
            $display("FAIL: se esperaban al menos 4 mediciones de periodo, se obtuvieron %0d", mediciones);
            errores = errores + 1;
        end

        if (errores == 0)
            $display(">>> tb_baud_gen: TODAS LAS PRUEBAS PASARON (%0d mediciones)", mediciones);
        else
            $display(">>> tb_baud_gen: %0d PRUEBA(S) FALLARON", errores);

        $finish;
    end

endmodule
