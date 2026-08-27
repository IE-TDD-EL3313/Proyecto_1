module status_indicator #(
    parameter integer BLINK_MS = 250
) (
    input  logic clk,
    input  logic reset,
    input  logic ce_1ms,
    input  logic game_active,
    input  logic game_over,
    output logic status_led
);

    localparam integer COUNTER_WIDTH =
        (BLINK_MS <= 1) ? 1 : $clog2(BLINK_MS);

    logic [COUNTER_WIDTH-1:0] blink_counter;
    logic blink_state;

    always_ff @(posedge clk) begin
        if (reset) begin
            blink_counter <= '0;
            blink_state   <= 1'b0;
        end else if (!game_over) begin
            blink_counter <= '0;
            blink_state   <= 1'b0;
        end else if (ce_1ms) begin
            if ((BLINK_MS <= 1) ||
                (blink_counter == BLINK_MS - 1)) begin
                blink_counter <= '0;
                blink_state   <= ~blink_state;
            end else begin
                blink_counter <= blink_counter + 1'b1;
            end
        end
    end

    always_comb begin
        if (game_over)
            status_led = blink_state;
        else if (game_active)
            status_led = 1'b1;
        else
            status_led = 1'b0;
    end

endmodule
