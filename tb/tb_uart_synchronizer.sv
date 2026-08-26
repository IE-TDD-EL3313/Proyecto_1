`timescale 1ns/1ps

module tb_uart_synchronizer;

    logic clk;
    logic reset;
    logic serial_async;
    logic serial_sync;

    uart_synchronizer dut (
        .clk(clk),
        .reset(reset),
        .serial_async(serial_async),
        .serial_sync(serial_sync)
    );

    // Reloj de 100 MHz -> periodo de 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Condiciones iniciales
        reset = 1;
        serial_async = 1;

        #20;
        reset = 0;

        // Simular llegada de un 0 asíncrono
        #7;
        serial_async = 0;

        #30;

        // Volver a 1
        serial_async = 1;

        #30;

        $finish;
    end

endmodule