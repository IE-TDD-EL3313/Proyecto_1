`timescale 1ns/1ps

module tb_button_bank;

    localparam integer TEST_DEBOUNCE_MS = 3;

    logic       clk;
    logic       reset;
    logic       ce_1ms;
    logic [7:0] buttons_async;
    logic [7:0] buttons_level;
    logic [7:0] buttons_pulse;

    integer error_count;
    integer pulse_count;

    button_bank #(
        .BUTTON_COUNT(8),
        .DEBOUNCE_MS(TEST_DEBOUNCE_MS)
    ) dut (
        .clk           (clk),
        .reset         (reset),
        .ce_1ms        (ce_1ms),
        .buttons_async (buttons_async),
        .buttons_level (buttons_level),
        .buttons_pulse (buttons_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        #1;
        if (buttons_pulse != 8'b0)
            pulse_count = pulse_count + 1;
    end

    task automatic settle_synchronizer(input logic [7:0] value);
        begin
            @(negedge clk);
            buttons_async = value;
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

    task automatic expect_vectors(
        input logic [7:0] expected_level,
        input logic [7:0] expected_pulse,
        input string      test_name
    );
        begin
            #1;
            if ((buttons_level !== expected_level) ||
                (buttons_pulse !== expected_pulse)) begin
                $error(
                    "FAIL: %s | level esperado=%b recibido=%b | pulse esperado=%b recibido=%b",
                    test_name,
                    expected_level,
                    buttons_level,
                    expected_pulse,
                    buttons_pulse
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        reset         = 1'b1;
        ce_1ms        = 1'b0;
        buttons_async = 8'b0;
        error_count   = 0;
        pulse_count   = 0;

        repeat (3) @(posedge clk);
        #1;
        expect_vectors(8'b0, 8'b0, "Reset limpia niveles y pulsos");

        @(negedge clk);
        reset = 1'b0;

        // Rebote corto en BTN0: no completa tres muestras consecutivas.
        settle_synchronizer(8'b0000_0001);
        sample_one_ms();
        settle_synchronizer(8'b0000_0000);
        sample_one_ms();
        settle_synchronizer(8'b0000_0001);
        sample_one_ms();
        settle_synchronizer(8'b0000_0000);
        sample_one_ms();
        expect_vectors(8'b0, 8'b0, "Rebote corto rechazado");

        // Pulsacion valida en BTN0 durante tres muestras.
        settle_synchronizer(8'b0000_0001);
        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_vectors(8'b0000_0001, 8'b0000_0001,
                       "BTN0 genera un pulso al validarse");

        @(posedge clk);
        #1;
        expect_vectors(8'b0000_0001, 8'b0,
                       "Pulso de BTN0 dura un solo ciclo");

        // Mantener BTN0 no debe producir pulsos adicionales.
        sample_one_ms();
        sample_one_ms();
        expect_vectors(8'b0000_0001, 8'b0,
                       "Boton sostenido no repite pulsos");

        // Liberacion valida: cambia level a cero, sin pulso de subida.
        settle_synchronizer(8'b0);
        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_vectors(8'b0, 8'b0, "Liberacion filtrada sin pulso");

        // Dos botones simultaneos deben conservar ambos bits.
        settle_synchronizer(8'b0010_0100); // BTN5 y BTN2
        sample_one_ms();
        sample_one_ms();
        sample_one_ms();
        expect_vectors(8'b0010_0100, 8'b0010_0100,
                       "Botones simultaneos generan vector correcto");

        @(posedge clk);
        #1;
        expect_vectors(8'b0010_0100, 8'b0,
                       "Pulso simultaneo dura un solo ciclo");

        if (pulse_count != 2) begin
            $error("Se esperaban 2 eventos de pulso y se observaron %0d", pulse_count);
            error_count = error_count + 1;
        end

        if (error_count == 0)
            $display("PASS: tb_button_bank completo sin errores");
        else
            $fatal(1, "FAIL: tb_button_bank detecto %0d errores", error_count);

        $finish;
    end

endmodule
