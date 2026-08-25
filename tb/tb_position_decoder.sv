`timescale 1ns/1ps

module tb_position_decoder;

    logic [2:0] posicion_topo;
    logic [7:0] topo_onehot;

    position_decoder dut (
        .posicion_topo (posicion_topo),
        .topo_onehot   (topo_onehot)
    );

    integer i;

    initial begin

        // Probar las 8 posiciones posibles
        for (i = 0; i < 8; i = i + 1) begin

            posicion_topo = i[2:0];

            #1;

            if (topo_onehot == (8'b00000001 << i)) begin
                $display(
                    "PASS: posicion %0d -> onehot %b",
                    i,
                    topo_onehot
                );
            end
            else begin
                $error(
                    "FAIL: posicion %0d -> esperado %b, recibido %b",
                    i,
                    (8'b00000001 << i),
                    topo_onehot
                );
            end

        end

        $display("-------------------------------------");
        $display("Pruebas del decodificador finalizadas");
        $display("-------------------------------------");

        $finish;

    end

endmodule