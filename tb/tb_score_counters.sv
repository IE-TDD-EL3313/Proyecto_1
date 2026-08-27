`timescale 1ns/1ps

module tb_score_counters;

    logic       clk;
    logic       reset;
    logic       hit_pulse;
    logic       miss_pulse;
    logic [6:0] hits;
    logic [6:0] misses;

    integer error_count;
    integer pulse_index;

    score_counters dut (
        .clk       (clk),
        .reset     (reset),
        .hit_pulse (hit_pulse),
        .miss_pulse(miss_pulse),
        .hits      (hits),
        .misses    (misses)
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

    task automatic expect_scores(
        input integer expected_hits,
        input integer expected_misses,
        input string  test_name
    );
        begin
            #1;
            if ((hits !== expected_hits[6:0]) ||
                (misses !== expected_misses[6:0])) begin
                $error(
                    "FAIL: %s | hits=%0d/%0d misses=%0d/%0d",
                    test_name,
                    hits,
                    expected_hits,
                    misses,
                    expected_misses
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
        expect_scores(0, 0, "Reset limpia puntajes");

        @(negedge clk);
        reset = 1'b0;

        send_result(1'b1, 1'b0);
        send_result(1'b1, 1'b0);
        send_result(1'b0, 1'b1);
        expect_scores(2, 1, "Conteo independiente");

        // Completar hasta saturacion en 99.
        for (pulse_index = 2; pulse_index <= 105; pulse_index = pulse_index + 1)
            send_result(1'b0, 1'b1);

        expect_scores(2, 99, "Fallos saturan en 99");

        for (pulse_index = 3; pulse_index <= 105; pulse_index = pulse_index + 1)
            send_result(1'b1, 1'b0);

        expect_scores(99, 99, "Aciertos saturan en 99");

        reset = 1'b1;
        @(posedge clk);
        #1;
        expect_scores(0, 0, "Reset posterior limpia ambos");

        if (error_count == 0)
            $display("PASS: tb_score_counters completo sin errores");
        else
            $fatal(1, "FAIL: puntajes detectaron %0d errores", error_count);

        $finish;
    end

endmodule
