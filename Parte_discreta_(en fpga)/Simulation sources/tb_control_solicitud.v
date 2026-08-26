`timescale 1ns/1ps
// ============================================================================
// tb_control_solicitud.v
// Verifica que control_solicitud.v genere EXACTAMENTE un pulso de 1 ciclo
// por cada flanco de subida de solicitud_topo, incluso si la señal se
// mantiene en alto varios ciclos (no debe generar pulsos repetidos).
// ============================================================================
module tb_control_solicitud;

    reg clk = 0;
    reg rst_n = 0;
    reg solicitud_topo = 0;
    wire pulso_avance;

    integer pulsos_contados = 0;
    integer errores = 0;

    always #5 clk = ~clk; // 100 MHz

    control_solicitud dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .solicitud_topo (solicitud_topo),
        .pulso_avance   (pulso_avance)
    );

    always @(posedge clk) if (pulso_avance) pulsos_contados = pulsos_contados + 1;

    task verificar(input integer esperados, input [79*8-1:0] nombre);
        begin
            if (pulsos_contados == esperados)
                $display("PASS: %0s (pulsos=%0d)", nombre, pulsos_contados);
            else begin
                $display("FAIL: %0s (esperados=%0d, obtenidos=%0d)", nombre, esperados, pulsos_contados);
                errores = errores + 1;
            end
            pulsos_contados = 0;
        end
    endtask

    initial begin
        rst_n = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (4) @(posedge clk);

        // Caso 1: un solo pulso de 1 ciclo -> debe generar exactamente 1 pulso
        solicitud_topo = 1; @(posedge clk); solicitud_topo = 0;
        repeat (10) @(posedge clk);
        verificar(1, "pulso corto de 1 ciclo");

        // Caso 2: señal sostenida en alto por 20 ciclos -> debe generar SOLO 1 pulso
        solicitud_topo = 1;
        repeat (20) @(posedge clk);
        solicitud_topo = 0;
        repeat (10) @(posedge clk);
        verificar(1, "senal sostenida (sin repetir pulsos)");

        // Caso 3: dos flancos separados -> deben generar 2 pulsos
        solicitud_topo = 1; @(posedge clk); solicitud_topo = 0;
        repeat (10) @(posedge clk);
        solicitud_topo = 1; @(posedge clk); solicitud_topo = 0;
        repeat (10) @(posedge clk);
        verificar(2, "dos flancos separados");

        // Caso 4: nunca se activa solicitud -> 0 pulsos
        repeat (30) @(posedge clk);
        verificar(0, "sin actividad");

        if (errores == 0)
            $display(">>> tb_control_solicitud: TODAS LAS PRUEBAS PASARON");
        else
            $display(">>> tb_control_solicitud: %0d PRUEBA(S) FALLARON", errores);

        $finish;
    end

endmodule
