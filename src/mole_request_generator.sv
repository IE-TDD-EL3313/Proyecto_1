module mole_request_generator #(
    parameter integer PULSE_MS = 1
) (
    input  logic clk,
    input  logic reset,
    input  logic ce_1ms,
    input  logic start,
    output logic solicitud_topo,
    output logic busy,
    output logic done
);

    localparam integer COUNTER_WIDTH =
        (PULSE_MS <= 1) ? 1 : $clog2(PULSE_MS);

    logic [COUNTER_WIDTH-1:0] pulse_counter;
    logic pending_request;

    always_ff @(posedge clk) begin
        if (reset) begin
            solicitud_topo <= 1'b0;
            busy           <= 1'b0;
            done           <= 1'b0;
            pulse_counter  <= '0;
            pending_request<= 1'b0;
        end else begin
            done <= 1'b0;

            if (busy) begin
                // No perder una jugada resuelta antes de acabar un pulso
                // largo: se conserva una unica solicitud pendiente.
                if (start)
                    pending_request <= 1'b1;

                if (ce_1ms) begin
                    if (pulse_counter == PULSE_MS - 1) begin
                        solicitud_topo <= 1'b0;
                        busy           <= 1'b0;
                        done           <= 1'b1;
                        pulse_counter  <= '0;
                    end else begin
                        pulse_counter <= pulse_counter + 1'b1;
                    end
                end
            end else if (pending_request && ce_1ms) begin
                // Deja al menos 1 ms en bajo entre pulsos para producir un
                // nuevo flanco reconocible en el circuito discreto.
                solicitud_topo <= 1'b1;
                busy           <= 1'b1;
                pulse_counter  <= '0;
                pending_request<= 1'b0;
            end else if (start) begin
                solicitud_topo <= 1'b1;
                busy           <= 1'b1;
                pulse_counter  <= '0;
            end
        end
    end

endmodule
