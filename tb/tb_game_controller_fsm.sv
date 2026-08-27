`timescale 1ns/1ps

module tb_game_controller_fsm;

    logic       clk;
    logic       reset;
    logic       position_valid;
    logic       hit_pulse;
    logic       miss_pulse;
    logic       timeout_pulse;
    logic       third_miss_pulse;
    logic       game_over_done;
    logic       request_start;
    logic       turn_start;
    logic       turn_cancel;
    logic       game_over_start;
    logic       game_data_reset;
    logic       game_active;
    logic       game_over;
    logic [3:0] state_debug;

    integer error_count;

    localparam logic [3:0] ST_REQUEST_START   = 4'd0;
    localparam logic [3:0] ST_WAIT_POSITION   = 4'd1;
    localparam logic [3:0] ST_START_TURN      = 4'd2;
    localparam logic [3:0] ST_PLAY            = 4'd3;
    localparam logic [3:0] ST_RESOLVE_HIT     = 4'd4;
    localparam logic [3:0] ST_RESOLVE_MISS    = 4'd5;
    localparam logic [3:0] ST_GAME_OVER_START = 4'd6;
    localparam logic [3:0] ST_GAME_OVER_WAIT  = 4'd7;
    localparam logic [3:0] ST_AUTO_RESET      = 4'd8;

    game_controller_fsm dut (
        .clk             (clk),
        .reset           (reset),
        .position_valid  (position_valid),
        .hit_pulse       (hit_pulse),
        .miss_pulse      (miss_pulse),
        .timeout_pulse   (timeout_pulse),
        .third_miss_pulse(third_miss_pulse),
        .game_over_done  (game_over_done),
        .request_start   (request_start),
        .turn_start      (turn_start),
        .turn_cancel     (turn_cancel),
        .game_over_start (game_over_start),
        .game_data_reset (game_data_reset),
        .game_active     (game_active),
        .game_over       (game_over),
        .state_debug     (state_debug)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic pulse_input(
        ref logic signal_to_pulse
    );
        begin
            @(negedge clk);
            signal_to_pulse = 1'b1;
            @(posedge clk);
            #1;
            @(negedge clk);
            signal_to_pulse = 1'b0;
        end
    endtask

    task automatic step_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task automatic expect_state(
        input logic [3:0] expected_state,
        input string      test_name
    );
        begin
            #1;
            if (state_debug !== expected_state) begin
                $error(
                    "FAIL: %s | estado esperado=%0d recibido=%0d",
                    test_name,
                    expected_state,
                    state_debug
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        reset            = 1'b1;
        position_valid   = 1'b0;
        hit_pulse        = 1'b0;
        miss_pulse       = 1'b0;
        timeout_pulse    = 1'b0;
        third_miss_pulse = 1'b0;
        game_over_done   = 1'b0;
        error_count      = 0;

        repeat (2) @(posedge clk);
        #1;
        expect_state(ST_REQUEST_START, "Reset prepara solicitud");

        if (!request_start) begin
            $error("request_start no esta activo en ST_REQUEST_START");
            error_count = error_count + 1;
        end

        @(negedge clk);
        reset = 1'b0;
        step_clock();
        expect_state(ST_WAIT_POSITION, "Espera posicion");

        pulse_input(position_valid);
        expect_state(ST_START_TURN, "Posicion valida inicia turno");
        if (!turn_start) begin
            $error("turn_start no esta activo en ST_START_TURN");
            error_count = error_count + 1;
        end

        step_clock();
        expect_state(ST_PLAY, "Turno activo");

        // Camino de acierto.
        pulse_input(hit_pulse);
        expect_state(ST_RESOLVE_HIT, "Acierto resuelto");
        step_clock();
        expect_state(ST_REQUEST_START, "Acierto solicita siguiente topo");

        // Preparar un nuevo turno.
        step_clock();
        pulse_input(position_valid);
        step_clock();
        expect_state(ST_PLAY, "Segundo turno activo");

        // Fallo que no es el tercero.
        pulse_input(miss_pulse);
        expect_state(ST_RESOLVE_MISS, "Fallo entra en resolucion");
        step_clock();
        expect_state(ST_REQUEST_START, "Fallo no final solicita otro topo");

        // Preparar tercer turno y simular timeout como fallo.
        step_clock();
        pulse_input(position_valid);
        step_clock();
        expect_state(ST_PLAY, "Tercer turno activo");
        pulse_input(timeout_pulse);
        expect_state(ST_RESOLVE_MISS, "Timeout se trata como fallo");

        // En el ciclo de resolucion llega el pulso del tercer fallo.
        third_miss_pulse = 1'b1;
        step_clock();
        expect_state(ST_GAME_OVER_START, "Tercer fallo inicia game over");
        if (!game_over_start || !game_over) begin
            $error("Salidas de game over incorrectas al iniciar");
            error_count = error_count + 1;
        end
        @(negedge clk);
        third_miss_pulse = 1'b0;

        step_clock();
        expect_state(ST_GAME_OVER_WAIT, "Espera obligatoria de fin de partida");
        if (!game_over || game_active) begin
            $error("Indicadores de fin de partida incorrectos");
            error_count = error_count + 1;
        end

        pulse_input(game_over_done);
        expect_state(ST_AUTO_RESET, "Fin de 2 s produce auto reset");
        if (!game_data_reset) begin
            $error("game_data_reset no esta activo");
            error_count = error_count + 1;
        end

        step_clock();
        expect_state(ST_REQUEST_START, "Nueva partida solicita topo");

        // Reset manual desde cualquier estado.
        step_clock();
        reset = 1'b1;
        step_clock();
        expect_state(ST_REQUEST_START, "Reset manual vuelve al inicio");

        if (error_count == 0)
            $display("PASS: tb_game_controller_fsm completo sin errores");
        else
            $fatal(1, "FAIL: FSM detecto %0d errores", error_count);

        $finish;
    end

endmodule
