module parallel_position_receiver #(
    parameter integer STABLE_MS = 2
) (
    input  logic       clk,
    input  logic       reset,
    input  logic       ce_1ms,
    input  logic [2:0] position_async,
    output logic [2:0] position,
    output logic       position_valid
);

    localparam integer COUNTER_WIDTH =
        (STABLE_MS <= 1) ? 1 : $clog2(STABLE_MS + 1);

    logic [2:0] position_sync;
    logic [2:0] candidate;
    logic [COUNTER_WIDTH-1:0] stable_counter;
    logic initialized;

    sync_2ff #(
        .WIDTH(3)
    ) position_synchronizer (
        .clk      (clk),
        .reset    (reset),
        .async_in (position_async),
        .sync_out (position_sync)
    );

    always_ff @(posedge clk) begin
        if (reset) begin
            position       <= 3'b000;
            candidate      <= 3'b000;
            stable_counter <= '0;
            initialized    <= 1'b0;
            position_valid <= 1'b0;
        end else begin
            position_valid <= 1'b0;

            if (ce_1ms) begin
                if (position_sync != candidate) begin
                    candidate <= position_sync;

                    if (STABLE_MS <= 1) begin
                        stable_counter <= '0;

                        if (!initialized || (position != position_sync)) begin
                            position       <= position_sync;
                            initialized    <= 1'b1;
                            position_valid <= 1'b1;
                        end
                    end else begin
                        stable_counter <= 1;
                    end
                end else if (stable_counter < STABLE_MS) begin
                    if (stable_counter == STABLE_MS - 1) begin
                        stable_counter <= STABLE_MS;

                        if (!initialized || (position != candidate)) begin
                            position       <= candidate;
                            initialized    <= 1'b1;
                            position_valid <= 1'b1;
                        end
                    end else begin
                        stable_counter <= stable_counter + 1'b1;
                    end
                end
            end
        end
    end

endmodule
