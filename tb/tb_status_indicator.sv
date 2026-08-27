`timescale 1ns/1ps

module tb_status_indicator;

    localparam integer TEST_BLINK_MS = 3;

    logic clk;
    logic reset;
    logic ce_1ms;
    logic game_active;
    logic game_over;
    logic status_led;

    integer error_count;

    status_indicator #(
        .BLINK_MS(TEST_BLINK_MS)
    ) dut (
        .clk        (clk),
        .reset      (reset),
        .ce_1ms     (ce_1ms),
        .game_active(game_active),
        .game_over  (game_over),
        .status_led (status_led)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic sample_one_ms;
        begin
            @(negedge clk);
            ce_1ms = 1'b1;
            @(posedge clk);
            #1;
            @(negedge clk);
            ce_1ms = 1'b0;
        end
    endtask

    task automatic expect_led(
        input logic  expected,
        input string test_name
    );
        begin
            #1;
            if (status_led !== expected) begin
                $error(
                    "FAIL: %s | LED esperado=%b recibido=%b",
                    test_name,
                    expected,
                    status_led
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        reset       = 1'b1;
        ce_1ms      = 1'b0;
        game_active = 1'b0;
        game_over   = 1'b0;
        error_count = 0;

        repeat (3) @(posedge clk);
        #1;
        expect_led(1'b0, "Reset apaga indicador");

        @(negedge clk);
        reset       = 1'b0;
        game_active = 1'b1;
        expect_led(1'b1, "Partida activa enciende LED fijo");

        game_active = 1'b0;
        game_over   = 1'b1;
        expect_led(1'b0, "Game over inicia LED apagado");

        sample_one_ms();
        sample_one_ms();
        expect_led(1'b0, "LED conserva fase antes del periodo");
        sample_one_ms();
        expect_led(1'b1, "LED conmuta tras periodo de parpadeo");

        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_led(1'b0, "LED completa segundo medio periodo");

        game_over   = 1'b0;
        game_active = 1'b1;
        @(posedge clk);
        #1;
        expect_led(1'b1, "Regreso a partida activa restaura LED fijo");

        game_active = 1'b0;
        #1;
        expect_led(1'b0, "Estado inactivo apaga LED");

        if (error_count == 0)
            $display("PASS: tb_status_indicator completo sin errores");
        else
            $fatal(1, "FAIL: indicador detecto %0d errores", error_count);

        $finish;
    end

endmodule
