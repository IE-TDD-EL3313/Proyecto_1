module game_over_timer #(
    parameter integer GAME_OVER_MS = 2000
) (
    input  logic clk,
    input  logic reset,
    input  logic ce_1ms,
    input  logic start,
    output logic active,
    output logic done_pulse
);

    localparam integer COUNTER_WIDTH =
        (GAME_OVER_MS <= 1) ? 1 : $clog2(GAME_OVER_MS);

    logic [COUNTER_WIDTH-1:0] elapsed_ms;

    always_ff @(posedge clk) begin
        if (reset) begin
            elapsed_ms <= '0;
            active     <= 1'b0;
            done_pulse <= 1'b0;
        end else begin
            done_pulse <= 1'b0;

            if (start) begin
                elapsed_ms <= '0;
                active     <= 1'b1;
            end else if (active && ce_1ms) begin
                if ((GAME_OVER_MS <= 1) ||
                    (elapsed_ms == GAME_OVER_MS - 1)) begin
                    elapsed_ms <= '0;
                    active     <= 1'b0;
                    done_pulse <= 1'b1;
                end else begin
                    elapsed_ms <= elapsed_ms + 1'b1;
                end
            end
        end
    end

endmodule
