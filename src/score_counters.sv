module score_counters #(
    parameter logic [6:0] MAX_SCORE = 7'd99
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       hit_pulse,
    input  logic       miss_pulse,
    output logic [6:0] hits,
    output logic [6:0] misses
);

    always_ff @(posedge clk) begin
        if (reset) begin
            hits   <= 7'd0;
            misses <= 7'd0;
        end else begin
            if (hit_pulse && (hits < MAX_SCORE))
                hits <= hits + 1'b1;

            if (miss_pulse && (misses < MAX_SCORE))
                misses <= misses + 1'b1;
        end
    end

endmodule
