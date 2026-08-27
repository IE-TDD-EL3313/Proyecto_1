`timescale 1ns/1ps

module tb_turn_window_timer;

    logic        clk;
    logic        reset;
    logic        ce_1ms;
    logic        start;
    logic        cancel;
    logic [10:0] duration_ms;
    logic        active;
    logic        timeout_pulse;

    integer error_count;

    turn_window_timer dut (
        .clk          (clk),
        .reset        (reset),
        .ce_1ms       (ce_1ms),
        .start        (start),
        .cancel       (cancel),
        .duration_ms  (duration_ms),
        .active       (active),
        .timeout_pulse(timeout_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic pulse_control(
        input logic start_value,
        input logic cancel_value
    );
        begin
            @(negedge clk);
            start  = start_value;
            cancel = cancel_value;
            @(posedge clk);
            #1;
            @(negedge clk);
            start  = 1'b0;
            cancel = 1'b0;
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
        input logic expected_timeout,
        input string test_name
    );
        begin
            #1;
            if ((active !== expected_active) ||
                (timeout_pulse !== expected_timeout)) begin
                $error(
                    "FAIL: %s | active=%b/%b timeout=%b/%b",
                    test_name,
                    active,
                    expected_active,
                    timeout_pulse,
                    expected_timeout
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
        cancel      = 1'b0;
        duration_ms = 11'd5;
        error_count = 0;

        repeat (3) @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, "Reset cierra ventana");

        @(negedge clk);
        reset = 1'b0;

        pulse_control(1'b1, 1'b0);
        expect_outputs(1'b1, 1'b0, "Start abre ventana");

        repeat (4) begin
            sample_one_ms();
            expect_outputs(1'b1, 1'b0, "Ventana permanece activa");
        end

        sample_one_ms();
        expect_outputs(1'b0, 1'b1, "Timeout exacto a 5 ms");

        @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, "Timeout dura un ciclo");

        // Cancelar una ventana antes de tiempo.
        duration_ms = 11'd5;
        pulse_control(1'b1, 1'b0);
        sample_one_ms();
        sample_one_ms();
        pulse_control(1'b0, 1'b1);
        expect_outputs(1'b0, 1'b0, "Cancel cierra ventana sin timeout");

        repeat (5) sample_one_ms();
        expect_outputs(1'b0, 1'b0, "Ventana cancelada no expira despues");

        // Una nueva ventana puede iniciarse despues de cancelar.
        duration_ms = 11'd3;
        pulse_control(1'b1, 1'b0);
        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_outputs(1'b0, 1'b1, "Reinicio y timeout exacto a 3 ms");

        @(posedge clk);
        #1;

        // Caso de borde: duracion de 1 ms.
        duration_ms = 11'd1;
        pulse_control(1'b1, 1'b0);
        sample_one_ms();
        expect_outputs(1'b0, 1'b1, "Duracion minima de 1 ms");

        if (error_count == 0)
            $display("PASS: tb_turn_window_timer completo sin errores");
        else
            $fatal(1, "FAIL: temporizador detecto %0d errores", error_count);

        $finish;
    end

endmodule
