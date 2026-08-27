`timescale 1ns/1ps

module tb_game_hit_evaluator;

    logic       turn_active;
    logic [2:0] active_position;
    logic [7:0] buttons_pulse;
    logic [7:0] active_mole_onehot;
    logic       any_press;
    logic       hit_pulse;
    logic       miss_pulse;

    integer position_index;
    integer error_count;
    logic [7:0] expected_onehot;
    logic [7:0] wrong_button;

    game_hit_evaluator dut (
        .turn_active       (turn_active),
        .active_position   (active_position),
        .buttons_pulse     (buttons_pulse),
        .active_mole_onehot(active_mole_onehot),
        .any_press         (any_press),
        .hit_pulse         (hit_pulse),
        .miss_pulse        (miss_pulse)
    );

    task automatic verify_case(
        input logic       test_turn_active,
        input logic [2:0] test_position,
        input logic [7:0] test_buttons,
        input logic       expected_any,
        input logic       expected_hit,
        input logic       expected_miss,
        input string      test_name
    );
        begin
            turn_active     = test_turn_active;
            active_position = test_position;
            buttons_pulse   = test_buttons;
            #1;

            if ((active_mole_onehot !== (8'b1 << test_position)) ||
                (any_press !== expected_any) ||
                (hit_pulse !== expected_hit) ||
                (miss_pulse !== expected_miss)) begin
                $error(
                    "FAIL: %s | onehot=%b any=%b hit=%b miss=%b",
                    test_name,
                    active_mole_onehot,
                    any_press,
                    hit_pulse,
                    miss_pulse
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        turn_active     = 1'b0;
        active_position = 3'b0;
        buttons_pulse   = 8'b0;
        error_count     = 0;

        // Probar las ocho posiciones con golpe correcto e incorrecto.
        for (position_index = 0;
             position_index < 8;
             position_index = position_index + 1) begin

            expected_onehot = 8'b1 << position_index;
            wrong_button    = 8'b1 << ((position_index + 1) % 8);

            verify_case(
                1'b1,
                position_index[2:0],
                expected_onehot,
                1'b1,
                1'b1,
                1'b0,
                $sformatf("Acierto en posicion %0d", position_index)
            );

            verify_case(
                1'b1,
                position_index[2:0],
                wrong_button,
                1'b1,
                1'b0,
                1'b1,
                $sformatf("Fallo en posicion %0d", position_index)
            );
        end

        verify_case(1'b1, 3'd4, 8'b0, 1'b0, 1'b0, 1'b0,
                    "Sin pulsacion durante turno");
        verify_case(1'b0, 3'd4, 8'b0001_0000, 1'b1, 1'b0, 1'b0,
                    "Pulsacion correcta fuera de ventana");
        verify_case(1'b1, 3'd4, 8'b0011_0000, 1'b1, 1'b0, 1'b1,
                    "Dos botones simultaneos cuentan como fallo");

        if (error_count == 0)
            $display("PASS: tb_game_hit_evaluator completo sin errores");
        else
            $fatal(1, "FAIL: evaluador detecto %0d errores", error_count);

        $finish;
    end

endmodule
