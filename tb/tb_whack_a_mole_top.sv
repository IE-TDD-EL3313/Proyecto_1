`timescale 1ns/1ps

module tb_whack_a_mole_top;

    logic clk = 1'b0;
    logic reset_button = 1'b0;
    logic [2:0] position_async = 3'd0;
    logic [7:0] buttons_async = 8'd0;
    logic solicitud_topo;
    logic [7:0] mole_leds;
    logic status_led;
    logic [6:0] seg;
    logic dp;
    logic [7:0] an;
    integer errors = 0;

    always #5 clk = ~clk;

    whack_a_mole_top #(
        .CLK_FREQ_HZ        (10_000),
        .BUTTON_DEBOUNCE_MS (1),
        .POSITION_STABLE_MS (1),
        .REQUEST_PULSE_MS   (1),
        .INITIAL_MS         (11'd5),
        .MINIMUM_MS         (11'd2),
        .STEP_MS            (11'd1),
        .GAME_OVER_MS       (4),
        .STATUS_BLINK_MS    (2)
    ) dut (.*);
      
    task automatic wait_request_and_send(input logic [2:0] new_position);
        begin
            wait (dut.state_debug == 4'd1);
            position_async = new_position;
            wait (dut.turn_active === 1'b1);
            @(negedge clk);
        end
    endtask

    task automatic press_button(input integer index);
        begin
            buttons_async = 8'b0000_0001 << index;
            repeat (15) @(posedge clk);
            buttons_async = 8'b0000_0000;
            repeat (15) @(posedge clk);
        end
    endtask

    task automatic check(input logic condition, input string message_text);
        begin
            if (condition)
                $display("PASS: %s", message_text);
            else begin
                $error("FAIL: %s", message_text);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        reset_button = 1'b1;
        repeat (5) @(posedge clk);
        reset_button = 1'b0;

        wait_request_and_send(3'd2);
        check(mole_leds == 8'b0000_0100,
              "La posicion 2 enciende LED2");
        press_button(2);
        wait (dut.hits == 7'd1);
        check((dut.hits == 1) && (dut.misses == 0),
              "Boton correcto incrementa aciertos");
        check(dut.duration_ms == 4,
              "Acierto reduce la duracion del turno");

        wait_request_and_send(3'd5);
        press_button(1);
        wait (dut.misses == 7'd1);
        check((dut.misses == 1) && (dut.consecutive_miss_count == 1),
              "Boton incorrecto cuenta fallo consecutivo");

        wait_request_and_send(3'd3);
        press_button(3);
        wait (dut.hits == 7'd2);
        check(dut.consecutive_miss_count == 0,
              "Acierto reinicia fallos consecutivos");

        wait_request_and_send(3'd4);
        wait (dut.misses == 7'd2);
        check(dut.consecutive_miss_count == 1,
              "Timeout cuenta como fallo");

        wait_request_and_send(3'd6);
        press_button(0);
        wait (dut.misses == 7'd3);

        wait_request_and_send(3'd7);
        press_button(0);
        wait (dut.game_over === 1'b1);
        check((dut.misses == 4) && (dut.consecutive_miss_count == 3),
              "Tres fallos consecutivos producen game over");
        check(status_led === 1'b0 || status_led === 1'b1,
              "Indicador de estado permanece definido");

        wait (dut.game_data_reset === 1'b1);
        // El siguiente flanco positivo aplica data_reset a los registros;
        // el flanco negativo permite observarlos despues de la region NBA.
        @(posedge clk);
        @(negedge clk);
        check((dut.hits == 0) && (dut.misses == 0),
              "Auto reset limpia ambos puntajes");
        check(dut.duration_ms == 5,
              "Auto reset restaura dificultad inicial");

        if (errors == 0)
            $display("PASS: tb_whack_a_mole_top completo sin errores");
        else
            $fatal(1, "FAIL: integracion detecto %0d errores", errors);

        $finish;
    end

    initial begin
        #2000000;
        $fatal(1, "FAIL: timeout global de la prueba integral");
    end

endmodule
