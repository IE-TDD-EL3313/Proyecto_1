`timescale 1ns/1ps

module tb_mole_request_generator;

    localparam integer TEST_PULSE_MS = 3;

    logic clk;
    logic reset;
    logic ce_1ms;
    logic start;
    logic solicitud_topo;
    logic busy;
    logic done;

    integer error_count;

    mole_request_generator #(
        .PULSE_MS(TEST_PULSE_MS)
    ) dut (
        .clk            (clk),
        .reset          (reset),
        .ce_1ms         (ce_1ms),
        .start          (start),
        .solicitud_topo (solicitud_topo),
        .busy           (busy),
        .done           (done)
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
        input logic expected_request,
        input logic expected_busy,
        input logic expected_done,
        input string test_name
    );
        begin
            #1;
            if ((solicitud_topo !== expected_request) ||
                (busy !== expected_busy) ||
                (done !== expected_done)) begin
                $error(
                    "FAIL: %s | solicitud=%b/%b busy=%b/%b done=%b/%b",
                    test_name,
                    solicitud_topo,
                    expected_request,
                    busy,
                    expected_busy,
                    done,
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
        expect_outputs(1'b0, 1'b0, 1'b0, "Reset limpia generador");

        @(negedge clk);
        reset = 1'b0;

        pulse_start();
        expect_outputs(1'b1, 1'b1, 1'b0, "Start inicia solicitud");

        sample_one_ms();
        expect_outputs(1'b1, 1'b1, 1'b0, "Solicitud activa tras 1 ms");

        // Un nuevo start durante busy debe conservarse para emitirlo despues.
        pulse_start();
        expect_outputs(1'b1, 1'b1, 1'b0, "Start durante busy queda pendiente");

        sample_one_ms();
        expect_outputs(1'b1, 1'b1, 1'b0, "Solicitud activa tras 2 ms");

        sample_one_ms();
        expect_outputs(1'b0, 1'b0, 1'b1, "Solicitud termina tras 3 ms");

        @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, 1'b0, "Done dura un solo ciclo");

        sample_one_ms();
        expect_outputs(1'b1, 1'b1, 1'b0,
                       "Solicitud pendiente inicia tras separacion de 1 ms");

        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_outputs(1'b0, 1'b0, 1'b1,
                       "Solicitud pendiente conserva duracion configurada");

        @(posedge clk);
        #1;

        // Reset debe cancelar una solicitud en progreso.
        pulse_start();
        expect_outputs(1'b1, 1'b1, 1'b0, "Segunda solicitud iniciada");
        @(negedge clk);
        reset = 1'b1;
        @(posedge clk);
        #1;
        expect_outputs(1'b0, 1'b0, 1'b0, "Reset cancela solicitud");

        if (error_count == 0)
            $display("PASS: tb_mole_request_generator completo sin errores");
        else
            $fatal(1, "FAIL: generador de solicitud detecto %0d errores", error_count);

        $finish;
    end

endmodule
