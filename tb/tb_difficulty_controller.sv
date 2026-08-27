`timescale 1ns/1ps

module tb_difficulty_controller;

    logic        clk;
    logic        reset;
    logic        hit_pulse;
    logic        miss_pulse;
    logic [10:0] duration_ms;

    integer error_count;
    integer hit_index;
    integer expected_duration;

    difficulty_controller dut (
        .clk        (clk),
        .reset      (reset),
        .hit_pulse  (hit_pulse),
        .miss_pulse (miss_pulse),
        .duration_ms(duration_ms)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic send_result(input logic hit, input logic miss);
        begin
            @(negedge clk);
            hit_pulse  = hit;
            miss_pulse = miss;
            @(posedge clk);
            #1;
            @(negedge clk);
            hit_pulse  = 1'b0;
            miss_pulse = 1'b0;
        end
    endtask

    task automatic expect_duration(
        input integer expected,
        input string  test_name
    );
        begin
            #1;
            if (duration_ms !== expected[10:0]) begin
                $error(
                    "FAIL: %s | esperado=%0d recibido=%0d",
                    test_name,
                    expected,
                    duration_ms
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s -> %0d ms", test_name, duration_ms);
            end
        end
    endtask

    initial begin
        reset       = 1'b1;
        hit_pulse   = 1'b0;
        miss_pulse  = 1'b0;
        error_count = 0;

        repeat (3) @(posedge clk);
        #1;
        expect_duration(1500, "Duracion inicial");

        @(negedge clk);
        reset = 1'b0;

        for (hit_index = 1; hit_index <= 10; hit_index = hit_index + 1) begin
            send_result(1'b1, 1'b0);
            expected_duration = 1500 - (100 * hit_index);
            expect_duration(
                expected_duration,
                $sformatf("Reduccion por acierto %0d", hit_index)
            );
        end

        send_result(1'b1, 1'b0);
        expect_duration(500, "No baja del minimo");

        send_result(1'b0, 1'b1);
        expect_duration(500, "Fallo conserva dificultad");

        reset = 1'b1;
        @(posedge clk);
        #1;
        expect_duration(1500, "Reset restaura dificultad");

        if (error_count == 0)
            $display("PASS: tb_difficulty_controller completo sin errores");
        else
            $fatal(1, "FAIL: dificultad detecto %0d errores", error_count);

        $finish;
    end

endmodule
