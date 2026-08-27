module consecutive_misses (
    input  logic       clk,
    input  logic       reset,
    input  logic       hit_pulse,
    input  logic       miss_pulse,
    output logic [1:0] miss_count,
    output logic       three_misses,
    output logic       third_miss_pulse
);

    always_ff @(posedge clk) begin
        if (reset) begin
            miss_count       <= 2'd0;
            third_miss_pulse <= 1'b0;
        end else begin
            third_miss_pulse <= 1'b0;

            // Un acierto tiene prioridad y reinicia las vidas perdidas.
            if (hit_pulse) begin
                miss_count <= 2'd0;
            end else if (miss_pulse) begin
                if (miss_count < 2'd3)
                    miss_count <= miss_count + 1'b1;

                if (miss_count == 2'd2)
                    third_miss_pulse <= 1'b1;
            end
        end
    end

    assign three_misses = (miss_count == 2'd3);

endmodule
