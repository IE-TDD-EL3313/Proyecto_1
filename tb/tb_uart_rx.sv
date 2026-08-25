`timescale 1ns/1ps

module tb_uart_rx;

    localparam int CLK_FREQ  = 100_000_000;
    localparam int BAUD_RATE = 2400;

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam time CLK_PERIOD  = 10ns;

    logic clk;
    logic reset;
    logic serial_sync;

    logic [7:0] rx_data;
    logic       data_valid;


    // --------------------------------------------------
    // DUT
    // --------------------------------------------------

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut (
        .clk         (clk),
        .reset       (reset),
        .serial_sync (serial_sync),
        .rx_data     (rx_data),
        .data_valid  (data_valid)
    );


    // --------------------------------------------------
    // Reloj FPGA: 100 MHz
    // --------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    // --------------------------------------------------
    // Esperar un periodo UART
    // --------------------------------------------------

    task automatic wait_uart_bit;
        repeat (CLKS_PER_BIT)
            @(posedge clk);
    endtask


    // --------------------------------------------------
    // Transmitir un byte UART 8N1
    // --------------------------------------------------

    task automatic send_uart_byte(
        input logic [7:0] data
    );

        integer i;

        begin

            // Línea en reposo
            serial_sync = 1'b1;
            @(posedge clk);

            // START
            serial_sync = 1'b0;
            wait_uart_bit();

            // DATA: LSB primero
            for (i = 0; i < 8; i = i + 1) begin
                serial_sync = data[i];
                wait_uart_bit();
            end

            // STOP
            serial_sync = 1'b1;
            wait_uart_bit();

            // Regreso a reposo
            serial_sync = 1'b1;

        end

    endtask


    // --------------------------------------------------
    // Enviar y verificar una trama
    // --------------------------------------------------

    task automatic test_uart_byte(
        input logic [7:0] expected
    );

        begin

            fork

                // Transmisor
                begin
                    send_uart_byte(expected);
                end

                // Receptor / verificador
                begin

                    // Esperar el pulso generado por el DUT
                    @(posedge data_valid);

                    if (rx_data == expected) begin
                        $display(
                            "PASS: esperado 0x%02h, recibido 0x%02h",
                            expected,
                            rx_data
                        );
                    end
                    else begin
                        $error(
                            "FAIL: esperado 0x%02h, recibido 0x%02h",
                            expected,
                            rx_data
                        );
                    end

                end

            join

        end

    endtask


    // --------------------------------------------------
    // Secuencia principal
    // --------------------------------------------------

    initial begin

        reset       = 1'b1;
        serial_sync = 1'b1;

        repeat (5)
            @(posedge clk);

        reset = 1'b0;

        repeat (5)
            @(posedge clk);


        // --------------------------
        // Topo 5
        // --------------------------

        $display("Prueba 1: enviando 0x05");
        test_uart_byte(8'h05);

        repeat (20)
            @(posedge clk);


        // --------------------------
        // Topo 3
        // --------------------------

        $display("Prueba 2: enviando 0x03");
        test_uart_byte(8'h03);

        repeat (20)
            @(posedge clk);


        // --------------------------
        // Topo 7
        // --------------------------

        $display("Prueba 3: enviando 0x07");
        test_uart_byte(8'h07);

        repeat (20)
            @(posedge clk);


        $display("-----------------------------------");
        $display("Todas las pruebas UART finalizaron.");
        $display("-----------------------------------");

        $finish;

    end

endmodule