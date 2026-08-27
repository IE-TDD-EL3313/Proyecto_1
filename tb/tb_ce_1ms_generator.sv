`timescale 1ns/1ps

module tb_ce_1ms_generator;

    // Frecuencia reducida para acelerar la simulacion:
    // 10 000 Hz / 1000 = 10 ciclos por cada pulso de 1 ms logico.
    localparam integer TEST_CLK_FREQ_HZ = 10_000;
    localparam integer EXPECTED_CYCLES  = 10;

    logic clk;
    logic reset;
    logic ce_1ms;

    integer pulse_number;
    integer cycle_number;
    integer error_count;

    ce_1ms_generator #(
        .CLK_FREQ_HZ(TEST_CLK_FREQ_HZ)
    ) dut (
        .clk    (clk),
        .reset  (reset),
        .ce_1ms (ce_1ms)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset       = 1'b1;
        error_count = 0;

        repeat (3) begin
            @(posedge clk);
            #1;
            if (ce_1ms !== 1'b0) begin
                $error("ce_1ms debe permanecer en 0 durante reset");
                error_count = error_count + 1;
            end
        end

        @(negedge clk);
        reset = 1'b0;

        // Comprobar tres periodos completos, ciclo por ciclo.
        for (pulse_number = 1; pulse_number <= 3; pulse_number = pulse_number + 1) begin
            for (cycle_number = 1;
                 cycle_number <= EXPECTED_CYCLES;
                 cycle_number = cycle_number + 1) begin

                @(posedge clk);
                #1;

                if (cycle_number < EXPECTED_CYCLES) begin
                    if (ce_1ms !== 1'b0) begin
                        $error(
                            "Pulso adelantado: periodo=%0d ciclo=%0d",
                            pulse_number,
                            cycle_number
                        );
                        error_count = error_count + 1;
                    end
                end else begin
                    if (ce_1ms !== 1'b1) begin
                        $error(
                            "Falta pulso: periodo=%0d ciclo=%0d",
                            pulse_number,
                            cycle_number
                        );
                        error_count = error_count + 1;
                    end else begin
                        $display(
                            "PASS: pulso %0d generado tras %0d ciclos",
                            pulse_number,
                            EXPECTED_CYCLES
                        );
                    end
                end
            end
        end

        // Comprobar que reset elimina inmediatamente el enable registrado.
        @(negedge clk);
        reset = 1'b1;
        @(posedge clk);
        #1;

        if (ce_1ms !== 1'b0) begin
            $error("Reset no desactivo ce_1ms");
            error_count = error_count + 1;
        end

        if (error_count == 0) begin
            $display("PASS: tb_ce_1ms_generator completo sin errores");
        end else begin
            $fatal(1, "FAIL: se detectaron %0d errores", error_count);
        end

        $finish;
    end

endmodule
