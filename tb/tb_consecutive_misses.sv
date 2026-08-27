`timescale 1ns/1ps

module tb_consecutive_misses;

    logic       clk;
    logic       reset;
    logic       hit_pulse;
    logic       miss_pulse;
    logic [1:0] miss_count;
    logic       three_misses;
    logic       third_miss_pulse;

    integer error_count;

    consecutive_misses dut (
        .clk             (clk),
        .reset           (reset),
        .hit_pulse       (hit_pulse),
        .miss_pulse      (miss_pulse),
        .miss_count      (miss_count),
        .three_misses    (three_misses),
        .third_miss_pulse(third_miss_pulse)
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

    task automatic expect_state(
        input logic [1:0] expected_count,
        input logic       expected_three,
        input logic       expected_pulse,
        input string      test_name
    );
        begin
            #1;
            if ((miss_count !== expected_count) ||
                (three_misses !== expected_three) ||
                (third_miss_pulse !== expected_pulse)) begin
                $error(
                    "FAIL: %s | count=%0d/%0d three=%b/%b pulse=%b/%b",
                    test_name,
                    miss_count,
                    expected_count,
                    three_misses,
                    expected_three,
                    third_miss_pulse,
                    expected_pulse
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
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
        expect_state(2'd0, 1'b0, 1'b0, "Reset limpia fallos consecutivos");

        @(negedge clk);
        reset = 1'b0;

        send_result(1'b0, 1'b1);
        expect_state(2'd1, 1'b0, 1'b0, "Primer fallo");
        send_result(1'b0, 1'b1);
        expect_state(2'd2, 1'b0, 1'b0, "Segundo fallo");

        send_result(1'b1, 1'b0);
        expect_state(2'd0, 1'b0, 1'b0, "Acierto reinicia secuencia");

        send_result(1'b0, 1'b1);
        send_result(1'b0, 1'b1);
        send_result(1'b0, 1'b1);
        expect_state(2'd3, 1'b1, 1'b1, "Tercer fallo termina partida");

        @(posedge clk);
        #1;
        expect_state(2'd3, 1'b1, 1'b0, "Pulso de tercer fallo dura un ciclo");

        send_result(1'b0, 1'b1);
        expect_state(2'd3, 1'b1, 1'b0, "Conteo satura en tres");

        send_result(1'b1, 1'b1);
        expect_state(2'd0, 1'b0, 1'b0, "Acierto tiene prioridad");

        if (error_count == 0)
            $display("PASS: tb_consecutive_misses completo sin errores");
        else
            $fatal(1, "FAIL: fallos consecutivos detectaron %0d errores", error_count);

        $finish;
    end

endmodule
