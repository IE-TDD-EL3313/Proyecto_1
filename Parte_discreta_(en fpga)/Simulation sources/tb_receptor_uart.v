`timescale 1ns/1ps
// ============================================================================
// tb_receptor_uart.v
// Genera manualmente (bit a bit) varias tramas UART 8N1 sobre serial_sync y
// verifica que receptor_uart.v recupere correctamente posicion_topo[2:0] y
// levante dato_valido.
// ============================================================================
module tb_receptor_uart;

    localparam integer CLK_FREQ = 100_000_000;
    localparam integer BAUD     = 1_000_000;
    localparam integer BIT_PERIOD_CYCLES = CLK_FREQ / BAUD;

    reg clk = 0;
    reg rst_n = 0;
    reg serial_sync = 1'b1; // línea en reposo = '1'
    wire [2:0] posicion_topo;
    wire dato_valido;

    integer errores = 0;

    always #5 clk = ~clk;

    receptor_uart #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .serial_sync   (serial_sync),
        .posicion_topo (posicion_topo),
        .dato_valido   (dato_valido)
    );

    // Envía manualmente una trama 8N1 completa con el byte dado
    task enviar_trama(input [7:0] byte_dato);
        integer b;
        begin
            serial_sync = 1'b0; // START
            repeat (BIT_PERIOD_CYCLES) @(posedge clk);
            for (b = 0; b < 8; b = b + 1) begin
                serial_sync = byte_dato[b]; // LSB primero
                repeat (BIT_PERIOD_CYCLES) @(posedge clk);
            end
            serial_sync = 1'b1; // STOP
            repeat (BIT_PERIOD_CYCLES) @(posedge clk);
        end
    endtask

    task verificar_recepcion(input [7:0] byte_enviado);
        reg [2:0] esperado;
        begin
            esperado = byte_enviado[2:0];
            wait (dato_valido == 1'b1);
            if (posicion_topo == esperado)
                $display("PASS: byte 0x%02h -> posicion_topo=%0d", byte_enviado, posicion_topo);
            else begin
                $display("FAIL: byte 0x%02h -> posicion_topo=%0d (esperado %0d)", byte_enviado, posicion_topo, esperado);
                errores = errores + 1;
            end
        end
    endtask

    initial begin
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (3) @(posedge clk);

        fork
            enviar_trama(8'h05); // posicion 5
            verificar_recepcion(8'h05);
        join
        repeat (5) @(posedge clk);

        fork
            enviar_trama(8'hF8); // bits altos en 1, posicion = 000 -> 0
            verificar_recepcion(8'hF8);
        join
        repeat (5) @(posedge clk);

        fork
            enviar_trama(8'h07); // posicion 7 (todos los bits bajos en 1)
            verificar_recepcion(8'h07);
        join
        repeat (5) @(posedge clk);

        if (errores == 0)
            $display(">>> tb_receptor_uart: TODAS LAS PRUEBAS PASARON");
        else
            $display(">>> tb_receptor_uart: %0d PRUEBA(S) FALLARON", errores);

        $finish;
    end

endmodule
