`timescale 1ns/1ps

module tb_turn_timer;

    logic        clk;
    logic        reset;
    logic        iniciar_turno;
    logic        ce_1ms;
    logic [10:0] duracion_turno;

    logic ventana_activa;
    logic tiempo_agotado;


    // --------------------------------------------------
    // DUT
    // --------------------------------------------------

    turn_timer dut (
        .clk            (clk),
        .reset          (reset),
        .iniciar_turno  (iniciar_turno),
        .ce_1ms         (ce_1ms),
        .duracion_turno (duracion_turno),
        .ventana_activa (ventana_activa),
        .tiempo_agotado (tiempo_agotado)
    );


    // --------------------------------------------------
    // Reloj de 100 MHz
    // --------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // --------------------------------------------------
    // Generar manualmente un pulso CE_1MS
    //
    // En este testbench no necesitamos esperar 1 ms real.
    // Solo verificamos que turn_timer cuente correctamente
    // los pulsos recibidos.
    // --------------------------------------------------

    task automatic generar_ce_1ms;
        begin

            @(negedge clk);
            ce_1ms = 1'b1;

            @(negedge clk);
            ce_1ms = 1'b0;

        end
    endtask


    // --------------------------------------------------
    // Generar pulso INICIAR_TURNO
    // --------------------------------------------------

    task automatic iniciar;
        begin

            @(negedge clk);
            iniciar_turno = 1'b1;

            @(negedge clk);
            iniciar_turno = 1'b0;

        end
    endtask


    // --------------------------------------------------
    // Secuencia principal
    // --------------------------------------------------

    initial begin

        reset          = 1'b1;
        iniciar_turno  = 1'b0;
        ce_1ms         = 1'b0;
        duracion_turno = 11'd0;

        repeat (3)
            @(posedge clk);

        reset = 1'b0;


        // ==================================================
        // PRUEBA 1
        // Duración = 5 ms
        // ==================================================

        duracion_turno = 11'd5;

        iniciar();

        #1;

        if (ventana_activa == 1'b1)
            $display("PASS: ventana activada para turno de 5 ms");
        else
            $error("FAIL: ventana no se activo");


        // Primeros 4 ms:
        // la ventana debe permanecer activa.
        repeat (4) begin

            generar_ce_1ms();

            #1;

            if (ventana_activa != 1'b1)
                $error("FAIL: ventana termino antes de tiempo");

            if (tiempo_agotado != 1'b0)
                $error("FAIL: tiempo_agotado se activo antes de tiempo");

        end


        // Quinto milisegundo
        generar_ce_1ms();

        #1;

        if ((ventana_activa == 1'b0) &&
            (tiempo_agotado == 1'b1)) begin

            $display(
                "PASS: turno de 5 ms finalizado correctamente"
            );

        end
        else begin

            $error(
                "FAIL: final incorrecto del turno de 5 ms"
            );

        end


        // Esperar un ciclo para comprobar que
        // tiempo_agotado vuelve a cero.
        @(posedge clk);
        #1;

        if (tiempo_agotado == 1'b0)
            $display("PASS: tiempo_agotado dura un solo ciclo");
        else
            $error("FAIL: tiempo_agotado permanece activo");


        // ==================================================
        // PRUEBA 2
        // Duración = 3 ms
        // ==================================================

        duracion_turno = 11'd3;

        iniciar();

        #1;

        if (ventana_activa == 1'b1)
            $display("PASS: ventana activada para turno de 3 ms");
        else
            $error("FAIL: segunda ventana no se activo");


        // Primeros 2 ms
        repeat (2) begin

            generar_ce_1ms();

            #1;

            if (ventana_activa != 1'b1)
                $error("FAIL: turno de 3 ms termino antes de tiempo");

        end


        // Tercer milisegundo
        generar_ce_1ms();

        #1;

        if ((ventana_activa == 1'b0) &&
            (tiempo_agotado == 1'b1)) begin

            $display(
                "PASS: turno de 3 ms finalizado correctamente"
            );

        end
        else begin

            $error(
                "FAIL: final incorrecto del turno de 3 ms"
            );

        end


        // ==================================================
        // FIN
        // ==================================================

        $display("--------------------------------------");
        $display("Pruebas del temporizador finalizadas");
        $display("--------------------------------------");

        $finish;

    end

endmodule