`timescale 1ns/1ps

module tb_hit_evaluator;

    logic       ventana_activa;
    logic [7:0] golpe_limpio;
    logic [7:0] topo_onehot;

    logic acierto;
    logic fallo;


    hit_evaluator dut (
        .ventana_activa (ventana_activa),
        .golpe_limpio   (golpe_limpio),
        .topo_onehot    (topo_onehot),
        .acierto         (acierto),
        .fallo           (fallo)
    );


    task automatic verificar(
        input logic       ventana,
        input logic [7:0] golpe,
        input logic [7:0] topo,
        input logic       acierto_esperado,
        input logic       fallo_esperado,
        input string      nombre_prueba
    );

        begin

            ventana_activa = ventana;
            golpe_limpio   = golpe;
            topo_onehot    = topo;

            #1;

            if ((acierto == acierto_esperado) &&
                (fallo   == fallo_esperado)) begin

                $display(
                    "PASS: %s | acierto=%0b fallo=%0b",
                    nombre_prueba,
                    acierto,
                    fallo
                );

            end
            else begin

                $error(
                    "FAIL: %s | esperado A=%0b F=%0b, recibido A=%0b F=%0b",
                    nombre_prueba,
                    acierto_esperado,
                    fallo_esperado,
                    acierto,
                    fallo
                );

            end

        end

    endtask


    initial begin

        // Valores iniciales
        ventana_activa = 1'b0;
        golpe_limpio   = 8'b00000000;
        topo_onehot    = 8'b00000001;

        #1;


        // --------------------------------------------------
        // Prueba 1
        // Sin golpe dentro de ventana
        // --------------------------------------------------

        verificar(
            1'b1,
            8'b00000000,
            8'b00100000,
            1'b0,
            1'b0,
            "Sin golpe dentro de ventana"
        );


        // --------------------------------------------------
        // Prueba 2
        // Golpe correcto: topo 5
        // --------------------------------------------------

        verificar(
            1'b1,
            8'b00100000,
            8'b00100000,
            1'b1,
            1'b0,
            "Golpe correcto al topo 5"
        );


        // --------------------------------------------------
        // Prueba 3
        // Golpe incorrecto
        // --------------------------------------------------

        verificar(
            1'b1,
            8'b00000100,
            8'b00100000,
            1'b0,
            1'b1,
            "Golpe incorrecto"
        );


        // --------------------------------------------------
        // Prueba 4
        // Golpe correcto pero fuera de ventana
        // --------------------------------------------------

        verificar(
            1'b0,
            8'b00100000,
            8'b00100000,
            1'b0,
            1'b0,
            "Golpe correcto fuera de ventana"
        );


        // --------------------------------------------------
        // Prueba 5
        // Golpe incorrecto fuera de ventana
        // --------------------------------------------------

        verificar(
            1'b0,
            8'b00000010,
            8'b00100000,
            1'b0,
            1'b0,
            "Golpe incorrecto fuera de ventana"
        );


        // --------------------------------------------------
        // Prueba 6
        // Dos botones simultáneos
        // --------------------------------------------------

        verificar(
            1'b1,
            8'b00100100,
            8'b00100000,
            1'b0,
            1'b1,
            "Dos botones presionados simultaneamente"
        );


        // --------------------------------------------------
        // Prueba 7
        // Otro acierto: topo 0
        // --------------------------------------------------

        verificar(
            1'b1,
            8'b00000001,
            8'b00000001,
            1'b1,
            1'b0,
            "Golpe correcto al topo 0"
        );


        // --------------------------------------------------
        // Prueba 8
        // Otro acierto: topo 7
        // --------------------------------------------------

        verificar(
            1'b1,
            8'b10000000,
            8'b10000000,
            1'b1,
            1'b0,
            "Golpe correcto al topo 7"
        );


        $display("-----------------------------------------");
        $display("Pruebas del evaluador de golpe finalizadas");
        $display("-----------------------------------------");

        $finish;

    end

endmodule