`timescale 1ns/1ps

module tb_game_over_timer;

    localparam integer TEST_GAME_OVER_MS = 4;

    logic clk;
    logic reset;
    logic ce_1ms;
    logic start;
    logic active;
    logic done_pulse;

    integer error_count;

    game_over_timer #(
        .GAME_OVER_MS(TEST_GAME_OVER_MS)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .ce_1ms    (ce_1ms),
        .start     (start),
        .active    (active),
        .done_pulse(done_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic pulse_start;
        begin
            @(negedge clk);
            start = 1'b1;
            @(posedge clk);
            #1;
            @(negedge clk);
            start = 1'b0;
        end
    endtask

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

    task automatic expect_outputs(
        input logic expected_active,
        input logic expected_done,
        input string test_name
    );
        begin
            #1;
            if ((active !== expected_active) ||
                (done_pulse !== expected_done)) begin
                $error(
                    "FAIL: %s | active=%b/%b done=%b/%b",
                    test_name,
                    active,
                    expected_active,
                    done_pulse,
                    expected_done
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
        start       = 1'b0;
        error_count = 0;

        repeat (3) @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, "Reset limpia temporizador");

        @(negedge clk);
        reset = 1'b0;

        pulse_start();
        expect_outputs(1'b1, 1'b0, "Start inicia fin de partida");

        repeat (3) begin
            sample_one_ms();
            expect_outputs(1'b1, 1'b0, "Fin de partida permanece activo");
        end

        sample_one_ms();
        expect_outputs(1'b0, 1'b1, "Finaliza tras tiempo configurado");

        @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, "Done dura un ciclo");

        pulse_start();
        sample_one_ms();
        reset = 1'b1;
        @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, "Reset cancela fin de partida");

        if (error_count == 0)
            $display("PASS: tb_game_over_timer completo sin errores");
        else
            $fatal(1, "FAIL: temporizador final detecto %0d errores", error_count);

        $finish;
    end

endmodule
