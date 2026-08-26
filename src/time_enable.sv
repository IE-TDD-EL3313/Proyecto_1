module time_enable #(
    parameter int CLK_FREQ = 100_000_000
)(
    input  logic clk,
    input  logic reset,

    output logic ce_1ms
);

    // Número de ciclos del reloj de 100 MHz que hay en 1 ms
    localparam int CYCLES_PER_MS = CLK_FREQ / 1000;

    // Contador interno
    logic [$clog2(CYCLES_PER_MS)-1:0] counter;


    always_ff @(posedge clk) begin

        if (reset) begin

            counter <= 0;
            ce_1ms  <= 1'b0;

        end
        else begin

            // Por defecto no hay habilitación
            ce_1ms <= 1'b0;

            // ¿Transcurrió 1 ms?
            if (counter == CYCLES_PER_MS - 1) begin

                counter <= 0;
                ce_1ms  <= 1'b1;

            end
            else begin

                counter <= counter + 1;

            end

        end

    end

endmodule