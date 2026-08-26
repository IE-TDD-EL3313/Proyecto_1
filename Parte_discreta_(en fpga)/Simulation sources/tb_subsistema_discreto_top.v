`timescale 1ns/1ps

module tb_subsistema_discreto_top;

    // Para simular rápido usamos un baud alto (1 Mbaud) con clk de 100MHz.
    // Cambie estos parámetros a 9600 para la síntesis real en la Nexys4.
    localparam integer CLK_FREQ = 100_000_000;
    localparam integer BAUD     = 1_000_000;

    reg clk = 0;
    reg rst_n = 0;
    reg solicitud_topo = 0;

    wire uart_line;
    wire [7:0] led;
    wire tx_busy;
    wire [2:0] posicion_rx;
    wire dato_valido;

    // Reloj de 100 MHz -> periodo 10 ns
    always #5 clk = ~clk;

    subsistema_discreto_top #(
        .CLK_FREQ(CLK_FREQ), .BAUD(BAUD)
    ) u_discreto (
        .clk            (clk),
        .rst_n          (rst_n),
        .solicitud_topo (solicitud_topo),
        .uart_tx_line   (uart_line),
        .led            (led),
        .tx_busy        (tx_busy)
    );

    receptor_uart #(
        .CLK_FREQ(CLK_FREQ), .BAUD(BAUD)
    ) u_receptor (
        .clk           (clk),
        .rst_n         (rst_n),
        .serial_sync   (uart_line), // mismo dominio de reloj: sin sync extra
        .posicion_topo (posicion_rx),
        .dato_valido   (dato_valido)
    );

    integer i;

    task pedir_topo;
        begin
            solicitud_topo = 1;
            @(posedge clk);
            solicitud_topo = 0;
        end
    endtask

    initial begin
        $display("t\tLED\tPOS_RX\tDATO_VALIDO");
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (5) @(posedge clk);

        for (i = 0; i < 6; i = i + 1) begin
            pedir_topo();
            // esperar a que termine la transmisión (start+8+stop bits) + margen
            wait (dato_valido == 1'b1);
            $display("%0t\tLED=%b\tPOS_RX=%0d\tOK", $time, led, posicion_rx);
            repeat (20) @(posedge clk); // pequeña pausa entre solicitudes
        end

        $display("Prueba finalizada.");
        $finish;
    end

    // Monitor de error: verifica que LED activo coincida con posicion_rx
    always @(posedge dato_valido) begin
        if (led !== (8'b1 << posicion_rx))
            $display("ERROR: LED=%b no coincide con posicion_rx=%0d", led, posicion_rx);
    end

endmodule
