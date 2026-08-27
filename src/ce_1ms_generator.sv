module ce_1ms_generator #(
    parameter integer CLK_FREQ_HZ = 100_000_000
) (
    input  logic clk,
    input  logic reset,
    output logic ce_1ms
);

    localparam integer CYCLES_PER_MS = CLK_FREQ_HZ / 1000;
    localparam integer COUNTER_WIDTH =
        (CYCLES_PER_MS <= 1) ? 1 : $clog2(CYCLES_PER_MS);

    logic [COUNTER_WIDTH-1:0] cycle_counter;

    always_ff @(posedge clk) begin
        if (reset) begin
            cycle_counter <= '0;
            ce_1ms        <= 1'b0;
        end else if (cycle_counter == CYCLES_PER_MS - 1) begin
            cycle_counter <= '0;
            ce_1ms        <= 1'b1;
        end else begin
            cycle_counter <= cycle_counter + 1'b1;
            ce_1ms        <= 1'b0;
        end
    end

endmodule
