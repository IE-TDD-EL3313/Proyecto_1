module position_register (
    input  logic       clk,
    input  logic       reset,
    input  logic       data_valid,
    input  logic [7:0] rx_data,

    output logic [2:0] posicion_topo
);

    always_ff @(posedge clk) begin

        if (reset) begin
            posicion_topo <= 3'b000;
        end
        else begin

            if (data_valid) begin
                posicion_topo <= rx_data[2:0];
            end

        end

    end

endmodule