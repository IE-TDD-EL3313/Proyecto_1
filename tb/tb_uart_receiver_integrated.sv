`timescale 1ns/1ps

module tb_uart_receiver_integrated;

    // --------------------------------------------------
    // Parámetros
    // --------------------------------------------------

    localparam int CLK_FREQ  = 100_000_000;
    localparam int BAUD_RATE = 2400;

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam time CLK_PERIOD  = 10ns;


    // --------------------------------------------------
    // Señales
    // --------------------------------------------------

    logic clk;
    logic reset;

    logic serial_async;
    logic serial_sync;

    logic [7:0] rx_data;
    logic       data_valid;

    logic [2:0] posicion_topo;


    // --------------------------------------------------
    // Sincronizador UART
    // --------------------------------------------------

    uart_synchronizer u_sync (
        .clk          (clk),
        .reset        (reset),
        .serial_async (serial_async),
        .serial_sync  (serial_sync)
    );


    // --------------------------------------------------
    // Receptor UART
    // --------------------------------------------------

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_uart_rx (
        .clk         (clk),
        .reset       (reset),
        .serial_sync (serial_sync),
        .rx_data     (rx_data),
        .data_valid  (data_valid)
    );


    // --------------------------------------------------
    // Registro de posición
    // --------------------------------------------------

    position_register u_position (
        .clk           (clk),
        .reset         (reset),
        .data_valid    (data_valid),
        .rx_data       (rx_data),
        .posicion_topo (posicion_topo)
    );


    // --------------------------------------------------
    // Reloj FPGA: 100 MHz
    // --------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    // --------------------------------------------------
    // Esperar un bit UART completo
    // --------------------------------------------------

    task automatic wait_uart_bit;
        repeat (CLKS_PER_BIT)
            @(posedge clk);
    endtask


    // --------------------------------------------------
    // Transmitir byte UART 8N1
    // --------------------------------------------------

    task automatic send_uart_byte(
        input logic [7:0] data
    );

        integer i;

        begin

            // Línea en reposo
            serial_async = 1'b1;

            @(posedge clk);

            // START
            serial_async = 1'b0;
            wait_uart_bit();

            // DATA
            // UART envía primero D0
            for (i = 0; i < 8; i = i + 1) begin

                serial_async = data[i];
                wait_uart_bit();

            end

            // STOP
            serial_async = 1'b1;
            wait_uart_bit();

            // Mantener reposo
            serial_async = 1'b1;

        end

    endtask


    // --------------------------------------------------
    // Enviar byte y comprobar posición
    // --------------------------------------------------

    task automatic test_position(
        input logic [7:0] uart_byte,
        input logic [2:0] expected_position
    );

        begin

            fork

                // Enviar trama UART
                begin
                    send_uart_byte(uart_byte);
                end


                // Esperar dato válido
                begin

                    @(posedge data_valid);

                    // El registro de posición captura en
                    // el siguiente flanco de clk.
                    @(posedge clk);
                    #1;

                    if (posicion_topo == expected_position) begin

                        $display(
                            "PASS: byte 0x%02h -> topo %0d",
                            uart_byte,
                            posicion_topo
                        );

                    end
                    else begin

                        $error(
                            "FAIL: byte 0x%02h -> esperado topo %0d, recibido %0d",
                            uart_byte,
                            expected_position,
                            posicion_topo
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

        reset        = 1'b1;
        serial_async = 1'b1;

        // Mantener reset algunos ciclos
        repeat (5)
            @(posedge clk);

        reset = 1'b0;

        repeat (5)
            @(posedge clk);


        // --------------------------------------------------
        // Topo 5
        // --------------------------------------------------

        $display("Prueba integrada 1: enviando topo 5");

        test_position(
            8'h05,
            3'd5
        );


        repeat (20)
            @(posedge clk);


        // --------------------------------------------------
        // Topo 3
        // --------------------------------------------------

        $display("Prueba integrada 2: enviando topo 3");

        test_position(
            8'h03,
            3'd3
        );


        repeat (20)
            @(posedge clk);


        // --------------------------------------------------
        // Topo 7
        // --------------------------------------------------

        $display("Prueba integrada 3: enviando topo 7");

        test_position(
            8'h07,
            3'd7
        );


        repeat (20)
            @(posedge clk);


        // --------------------------------------------------
        // Topo 0
        // --------------------------------------------------

        $display("Prueba integrada 4: enviando topo 0");

        test_position(
            8'h00,
            3'd0
        );


        repeat (20)
            @(posedge clk);


        $display("-------------------------------------------");
        $display("Pruebas integradas del receptor finalizadas");
        $display("-------------------------------------------");

        $finish;

    end

endmodule