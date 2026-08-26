`timescale 1ns/1ps
// ============================================================================
// tb_uart_tx.v
// Transmite varios bytes conocidos y decodifica manualmente la trama serie
// (muestreando a mitad de cada bit) para verificar que uart_tx.v arme
// correctamente la trama 8N1 (start, 8 datos LSB-primero, stop).
// ============================================================================
module tb_uart_tx;

    localparam integer CLK_FREQ = 100_000_000;
    localparam integer BAUD     = 1_000_000; // rápido para simular en poco tiempo
    localparam integer BIT_PERIOD_CYCLES = CLK_FREQ / BAUD;

    reg clk = 0;
    reg rst_n = 0;
    reg start_tx = 0;
    reg [7:0] data_in = 8'h00;
    wire tx, tx_busy, tx_listo;

    integer errores = 0;

    always #5 clk = ~clk;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start_tx (start_tx),
        .data_in  (data_in),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_listo (tx_listo)
    );

    // Decodifica manualmente la trama muestreando a mitad de cada periodo de bit
    task decodificar_y_verificar(input [7:0] esperado);
        reg [7:0] recibido;
        integer b;
        begin
            // Espera a que empiece la transmisión (tx cae a 0 = bit start)
            wait (tx == 1'b0);
            // Muestrea a mitad del bit start para confirmarlo
            repeat (BIT_PERIOD_CYCLES/2) @(posedge clk);
            if (tx !== 1'b0) begin
                $display("FAIL: bit de START invalido");
                errores = errores + 1;
            end
            // Recorre los 8 bits de datos, LSB primero
            for (b = 0; b < 8; b = b + 1) begin
                repeat (BIT_PERIOD_CYCLES) @(posedge clk);
                recibido[b] = tx;
            end
            // Verifica el bit de STOP
            repeat (BIT_PERIOD_CYCLES) @(posedge clk);
            if (tx !== 1'b1) begin
                $display("FAIL: bit de STOP invalido");
                errores = errores + 1;
            end

            if (recibido == esperado)
                $display("PASS: byte transmitido = 0x%02h", recibido);
            else begin
                $display("FAIL: byte transmitido = 0x%02h (esperado 0x%02h)", recibido, esperado);
                errores = errores + 1;
            end
        end
    endtask

    task enviar(input [7:0] byte_a_enviar);
        begin
            wait (tx_listo == 1'b1);
            @(posedge clk);
            data_in  = byte_a_enviar;
            start_tx = 1'b1;
            @(posedge clk);
            start_tx = 1'b0;
        end
    endtask

    initial begin
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (3) @(posedge clk);

        // Prueba con varias posiciones de topo típicas (0..7) y un par de
        // valores adicionales para cubrir todos los bits del byte.
        enviar(8'h00); decodificar_y_verificar(8'h00); // posicion 0
        enviar(8'h03); decodificar_y_verificar(8'h03); // posicion 3
        enviar(8'h07); decodificar_y_verificar(8'h07); // posicion 7
        enviar(8'hFF); decodificar_y_verificar(8'hFF); // todos los bits en 1
        enviar(8'hA5); decodificar_y_verificar(8'hA5); // patron alternado

        if (errores == 0)
            $display(">>> tb_uart_tx: TODAS LAS PRUEBAS PASARON");
        else
            $display(">>> tb_uart_tx: %0d PRUEBA(S) FALLARON", errores);

        $finish;
    end

endmodule
