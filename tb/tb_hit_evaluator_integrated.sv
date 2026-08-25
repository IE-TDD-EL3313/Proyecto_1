`timescale 1ns/1ps

module tb_hit_evaluator_integrated;

    logic [2:0] posicion_topo;
    logic [7:0] golpe_limpio;
    logic       ventana_activa;

    logic [7:0] topo_onehot;
    logic       acierto;
    logic       fallo;


    position_decoder u_decoder (
        .posicion_topo (posicion_topo),
        .topo_onehot   (topo_onehot)
    );


    hit_evaluator u_evaluator (
        .ventana_activa (ventana_activa),
        .golpe_limpio   (golpe_limpio),
        .topo_onehot    (topo_onehot),
        .acierto         (acierto),
        .fallo           (fallo)
    );


    task automatic verificar(
        input logic [2:0] posicion,
        input logic [7:0] golpe,
        input logic       ventana,
        input logic       acierto_esperado,
        input logic       fallo_esperado,
        input string      nombre
    );

        begin

            posicion_topo  = posicion;
            golpe_limpio   = golpe;
            ventana_activa = ventana;

            #1;

            if ((acierto == acierto_esperado) &&
                (fallo   == fallo_esperado)) begin

                $display(
                    "PASS: %s | topo=%0d golpe=%b A=%0b F=%0b",
                    nombre,
                    posicion_topo,
                    golpe_limpio,
                    acierto,
                    fallo
                );

            end
            else begin

                $error(
                    "FAIL: %s | esperado A=%0b F=%0b, recibido A=%0b F=%0b",
                    nombre,
                    acierto_esperado,
                    fallo_esperado,
                    acierto,
                    fallo
                );

            end

        end

    endtask


    initial begin

        posicion_topo  = 3'd0;
        golpe_limpio   = 8'b0;
        ventana_activa = 1'b0;

        #1;


        // Topo 5, golpe correcto
        verificar(
            3'd5,
            8'b00100000,
            1'b1,
            1'b1,
            1'b0,
            "Topo 5 - golpe correcto"
        );


        // Topo 5, golpe incorrecto
        verificar(
            3'd5,
            8'b00000100,
            1'b1,
            1'b0,
            1'b1,
            "Topo 5 - golpe incorrecto"
        );


        // Topo 3, golpe correcto
        verificar(
            3'd3,
            8'b00001000,
            1'b1,
            1'b1,
            1'b0,
            "Topo 3 - golpe correcto"
        );


        // Topo 7, golpe correcto
        verificar(
            3'd7,
            8'b10000000,
            1'b1,
            1'b1,
            1'b0,
            "Topo 7 - golpe correcto"
        );


        // Topo 0, golpe correcto
        verificar(
            3'd0,
            8'b00000001,
            1'b1,
            1'b1,
            1'b0,
            "Topo 0 - golpe correcto"
        );


        // Sin golpe
        verificar(
            3'd4,
            8'b00000000,
            1'b1,
            1'b0,
            1'b0,
            "Sin golpe"
        );


        // Golpe correcto pero fuera de ventana
        verificar(
            3'd2,
            8'b00000100,
            1'b0,
            1'b0,
            1'b0,
            "Golpe fuera de ventana"
        );


        // Dos botones
        verificar(
            3'd6,
            8'b01000010,
            1'b1,
            1'b0,
            1'b1,
            "Dos botones simultaneos"
        );


        $display("---------------------------------------------");
        $display("Prueba integrada del evaluador finalizada");
        $display("---------------------------------------------");

        $finish;

    end

endmodule