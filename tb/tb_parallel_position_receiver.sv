`timescale 1ns/1ps

module tb_parallel_position_receiver;

    localparam integer TEST_STABLE_MS = 3;

    logic       clk;
    logic       reset;
    logic       ce_1ms;
    logic [2:0] position_async;
    logic [2:0] position;
    logic       position_valid;

    integer error_count;
    integer valid_count;

    parallel_position_receiver #(
        .STABLE_MS(TEST_STABLE_MS)
    ) dut (
        .clk            (clk),
        .reset          (reset),
        .ce_1ms         (ce_1ms),
        .position_async (position_async),
        .position       (position),
        .position_valid (position_valid)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        #1;
        if (position_valid)
            valid_count = valid_count + 1;
    end

    task automatic set_position(input logic [2:0] value);
        begin
            @(negedge clk);
            position_async = value;
            repeat (3) @(posedge clk);
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

    task automatic expect_state(
        input logic [2:0] expected_position,
        input logic       expected_valid,
        input string      test_name
    );
        begin
            #1;
            if ((position !== expected_position) ||
                (position_valid !== expected_valid)) begin
                $error(
                    "FAIL: %s | position esperada=%0d recibida=%0d | valid esperado=%b recibido=%b",
                    test_name,
                    expected_position,
                    position,
                    expected_valid,
                    position_valid
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        reset          = 1'b1;
        ce_1ms         = 1'b0;
        position_async = 3'b000;
        error_count    = 0;
        valid_count    = 0;

        repeat (3) @(posedge clk);
        #1;
        expect_state(3'b000, 1'b0, "Reset limpia receptor");

        @(negedge clk);
        reset = 1'b0;

        // Primera posicion estable: debe validarse tras tres muestras.
        set_position(3'd1);
        sample_one_ms();
        sample_one_ms();
        expect_state(3'd0, 1'b0, "Posicion aun no estable");
        sample_one_ms();
        expect_state(3'd1, 1'b1, "Primera posicion estable aceptada");

        @(posedge clk);
        #1;
        expect_state(3'd1, 1'b0, "position_valid dura un ciclo");

        // Cambio transitorio de una sola muestra: debe rechazarse.
        set_position(3'd2);
        sample_one_ms();
        set_position(3'd1);
        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_state(3'd1, 1'b0, "Transitorio de posicion rechazado");

        // Cambio estable a topo 5.
        set_position(3'd5);
        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_state(3'd5, 1'b1, "Nueva posicion estable aceptada");

        @(posedge clk);
        #1;
        sample_one_ms();
        sample_one_ms();
        expect_state(3'd5, 1'b0, "Posicion repetida no genera otro valid");

        if (valid_count != 2) begin
            $error("Se esperaban 2 pulsos valid y se observaron %0d", valid_count);
            error_count = error_count + 1;
        end

        if (error_count == 0)
            $display("PASS: tb_parallel_position_receiver completo sin errores");
        else
            $fatal(1, "FAIL: receptor paralelo detecto %0d errores", error_count);

        $finish;
    end

endmodule
