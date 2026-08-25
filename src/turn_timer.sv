module turn_timer (
    input  logic        clk,
    input  logic        reset,
    input  logic        iniciar_turno,
    input  logic        ce_1ms,
    input  logic [10:0] duracion_turno,

    output logic        ventana_activa,
    output logic        tiempo_agotado
);

    logic [10:0] contador_ms;


    always_ff @(posedge clk) begin

        if (reset) begin

            contador_ms     <= 11'd0;
            ventana_activa  <= 1'b0;
            tiempo_agotado  <= 1'b0;

        end
        else begin

            // Por defecto, TIEMPO_AGOTADO solo dura un ciclo
            tiempo_agotado <= 1'b0;


            // --------------------------------------------------
            // Iniciar un nuevo turno
            // --------------------------------------------------

            if (iniciar_turno) begin

                contador_ms    <= 11'd0;
                ventana_activa <= 1'b1;

            end


            // --------------------------------------------------
            // Contar mientras la ventana esté activa
            // --------------------------------------------------

            else if (ventana_activa && ce_1ms) begin

                if (contador_ms == duracion_turno - 1) begin

                    contador_ms    <= 11'd0;
                    ventana_activa <= 1'b0;
                    tiempo_agotado <= 1'b1;

                end
                else begin

                    contador_ms <= contador_ms + 1'b1;

                end

            end

        end

    end

endmodule