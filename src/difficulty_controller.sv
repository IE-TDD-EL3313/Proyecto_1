module difficulty_controller #(
    parameter logic [10:0] INITIAL_MS = 11'd1500,
    parameter logic [10:0] MINIMUM_MS = 11'd500,
    parameter logic [10:0] STEP_MS    = 11'd100
) (
    input  logic        clk,
    input  logic        reset,
    input  logic        hit_pulse,
    input  logic        miss_pulse,
    output logic [10:0] duration_ms
);

    always_ff @(posedge clk) begin
        if (reset) begin
            duration_ms <= INITIAL_MS;
        end else if (hit_pulse) begin
            if (duration_ms > MINIMUM_MS + STEP_MS)
                duration_ms <= duration_ms - STEP_MS;
            else
                duration_ms <= MINIMUM_MS;
        end else if (miss_pulse) begin
            // La dificultad alcanzada se conserva despues de un fallo.
            duration_ms <= duration_ms;
        end
    end

endmodule
