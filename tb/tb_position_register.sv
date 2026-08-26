`timescale 1ns/1ps

module tb_position_register;

    logic       clk;
    logic       reset;
    logic       data_valid;
    logic [7:0] rx_data;
    logic [2:0] posicion_topo;

    position_register dut (
        .clk           (clk),
        .reset         (reset),
        .data_valid    (data_valid),
        .rx_data       (rx_data),
        .posicion_topo (posicion_topo)
    );

    // Reloj de 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset      = 1'b1;
        data_valid = 1'b0;
        rx_data    = 8'h00;

        #20;

        reset = 1'b0;

        // Prueba 1: topo 5
        rx_data    = 8'h05;
        data_valid = 1'b1;

        @(posedge clk);
        #1;
        data_valid = 1'b0;

        if (posicion_topo == 3'b101)
            $display("PASS: topo 5 almacenado correctamente");
        else
            $error("FAIL: esperado 5, recibido %0d", posicion_topo);

        // Cambiar rx_data sin data_valid
        rx_data = 8'h03;

        repeat (3)
            @(posedge clk);

        if (posicion_topo == 3'b101)
            $display("PASS: posicion se mantiene sin data_valid");
        else
            $error("FAIL: posicion cambio sin data_valid");

        // Prueba 2: topo 3
        data_valid = 1'b1;

        @(posedge clk);
        #1;
        data_valid = 1'b0;

        if (posicion_topo == 3'b011)
            $display("PASS: topo 3 almacenado correctamente");
        else
            $error("FAIL: esperado 3, recibido %0d", posicion_topo);

        // Prueba 3: topo 7
        rx_data    = 8'h07;
        data_valid = 1'b1;

        @(posedge clk);
        #1;
        data_valid = 1'b0;

        if (posicion_topo == 3'b111)
            $display("PASS: topo 7 almacenado correctamente");
        else
            $error("FAIL: esperado 7, recibido %0d", posicion_topo);

        $display("------------------------------------------");
        $display("Pruebas del registro de posicion completas");
        $display("------------------------------------------");

        $finish;

    end

endmodule