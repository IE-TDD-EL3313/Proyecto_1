module position_decoder (
    input  logic [2:0] posicion_topo,
    output logic [7:0] topo_onehot
);

    always_comb begin
        topo_onehot = 8'b00000001 << posicion_topo;
    end

endmodule