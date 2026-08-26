`timescale 1ns/1ps

module tb_time_enable;

    localparam int CLK_FREQ = 100_000_000;
    localparam time CLK_PERIOD = 10ns;

    logic clk;
    logic reset;
    logic ce_1ms;

    integer pulse_count;


    // --------------------------------------------------
    // DUT
    // --------------------------------------------------

    time_enable #(
        .CLK_FREQ(CLK_FREQ)
    ) dut (
        .clk    (clk),
        .reset  (reset),
        .ce_1ms (ce_1ms)
    );


    // --------------------------------------------------
    // Reloj de 100 MHz
    // --------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    // --------------------------------------------------
    // Contar pulsos de ce_1ms
    // --------------------------------------------------

    always @(posedge ce_1ms) begin
        pulse_count = pulse_count + 1;

        $display(
            "Pulso CE_1MS numero %0d en tiempo %0t",
            pulse_count,
            $time
        );
    end


    // --------------------------------------------------
    // Prueba
    // --------------------------------------------------

    initial begin

        reset       = 1'b1;
        pulse_count = 0;

        // Reset durante algunos ciclos
        repeat (5)
            @(posedge clk);

        reset = 1'b0;

        // Esperar 5 pulsos de 1 ms
        wait(pulse_count == 5);

        // Verificación
        if (pulse_count == 5)
            $display("PASS: se generaron correctamente 5 pulsos CE_1MS");
        else
            $error("FAIL: cantidad incorrecta de pulsos");

        $display("--------------------------------------");
        $display("Prueba del generador temporal terminada");
        $display("--------------------------------------");

        $finish;

    end

endmodule