module button_bank #(
    parameter integer BUTTON_COUNT = 8,
    parameter integer DEBOUNCE_MS  = 10
) (
    input  logic                    clk,
    input  logic                    reset,
    input  logic                    ce_1ms,
    input  logic [BUTTON_COUNT-1:0] buttons_async,
    output logic [BUTTON_COUNT-1:0] buttons_level,
    output logic [BUTTON_COUNT-1:0] buttons_pulse
);

    logic [BUTTON_COUNT-1:0] buttons_sync;
    logic [BUTTON_COUNT-1:0] previous_level;

    sync_2ff #(
        .WIDTH(BUTTON_COUNT)
    ) input_synchronizer (
        .clk      (clk),
        .reset    (reset),
        .async_in (buttons_async),
        .sync_out (buttons_sync)
    );

    genvar button_index;
    generate
        for (button_index = 0;
             button_index < BUTTON_COUNT;
             button_index = button_index + 1) begin : generate_debouncers

            button_debouncer #(
                .DEBOUNCE_MS(DEBOUNCE_MS)
            ) debouncer (
                .clk          (clk),
                .reset        (reset),
                .ce_1ms       (ce_1ms),
                .button_sync  (buttons_sync[button_index]),
                .button_level (buttons_level[button_index])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (reset) begin
            previous_level <= '0;
        end else begin
            previous_level <= buttons_level;
        end
    end

    assign buttons_pulse = buttons_level & ~previous_level;

endmodule
