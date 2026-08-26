`timescale 1ns/1ps
// ============================================================================
// tb_decodificador_led.v
// Barre las 8 posiciones posibles y verifica que se encienda únicamente el
// LED correspondiente (codificación one-hot).
// ============================================================================
module tb_decodificador_led;

    reg  [2:0] posicion;
    wire [7:0] led;
    integer errores = 0;
    integer i;

    decodificador_led dut (
        .posicion (posicion),
        .led      (led)
    );

    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            posicion = i[2:0];
            #10;
            if (led == (8'b1 << i))
                $display("PASS: posicion=%0d -> led=%b", i, led);
            else begin
                $display("FAIL: posicion=%0d -> led=%b (esperado %b)", i, led, (8'b1 << i));
                errores = errores + 1;
            end
        end

        if (errores == 0)
            $display(">>> tb_decodificador_led: TODAS LAS PRUEBAS PASARON");
        else
            $display(">>> tb_decodificador_led: %0d PRUEBA(S) FALLARON", errores);

        $finish;
    end

endmodule
