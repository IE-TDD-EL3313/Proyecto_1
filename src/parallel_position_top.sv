module parallel_position_top (
    input  logic       clk,
    input  logic [2:0] position_async,
    output logic [7:0] led
);

    // Sincronizador de dos etapas para las senales externas.
    logic [2:0] position_meta = 3'b000;
    logic [2:0] position_sync = 3'b000;

    always_ff @(posedge clk) begin
        position_meta <= position_async;
        position_sync <= position_meta;
    end

    // Decodificador binario a one-hot: posicion N enciende solamente LED N.
    always_comb begin
        led = 8'b0000_0001 << position_sync;
    end

endmodule