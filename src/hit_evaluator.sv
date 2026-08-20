module hit_evaluator (
    input  logic       ventana_activa,
    input  logic [7:0] golpe_limpio,
    input  logic [7:0] topo_onehot,

    output logic       acierto,
    output logic       fallo
);

    logic hay_golpe;
    logic golpe_correcto;

    always_comb begin

        hay_golpe       = (golpe_limpio != 8'b00000000);
        golpe_correcto  = (golpe_limpio == topo_onehot);

        acierto = 1'b0;
        fallo   = 1'b0;

        if (ventana_activa && hay_golpe) begin

            if (golpe_correcto) begin
                acierto = 1'b1;
            end
            else begin
                fallo = 1'b1;
            end

        end

    end

endmodule