module turn_window_timer (
    input  logic        clk,
    input  logic        reset,
    input  logic        ce_1ms,
    input  logic        start,
    input  logic        cancel,
    input  logic [10:0] duration_ms,
    output logic        active,
    output logic        timeout_pulse
);

    logic [10:0] elapsed_ms;

    always_ff @(posedge clk) begin
        if (reset) begin
            elapsed_ms    <= 11'd0;
            active        <= 1'b0;
            timeout_pulse <= 1'b0;
        end else begin
            timeout_pulse <= 1'b0;

            // Cancel tiene prioridad para impedir un timeout posterior al golpe.
            if (cancel) begin
                elapsed_ms <= 11'd0;
                active     <= 1'b0;
            end else if (start) begin
                elapsed_ms <= 11'd0;
                active     <= 1'b1;
            end else if (active && ce_1ms) begin
                if ((duration_ms <= 11'd1) ||
                    (elapsed_ms == duration_ms - 1'b1)) begin
                    elapsed_ms    <= 11'd0;
                    active        <= 1'b0;
                    timeout_pulse <= 1'b1;
                end else begin
                    elapsed_ms <= elapsed_ms + 1'b1;
                end
            end
        end
    end

endmodule
