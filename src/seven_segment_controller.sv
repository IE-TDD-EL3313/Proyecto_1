module seven_segment_controller (
    input  logic       clk,
    input  logic       reset,
    input  logic       ce_1ms,
    input  logic [6:0] hits,
    input  logic [6:0] misses,
    output logic [6:0] seg,
    output logic       dp,
    output logic [7:0] an
);

    logic [1:0] scan_index;
    logic [3:0] digit_value;

    always_ff @(posedge clk) begin
        if (reset)
            scan_index <= 2'd0;
        else if (ce_1ms)
            scan_index <= scan_index + 1'b1;
    end

    always_comb begin
        an          = 8'b1111_1111;
        digit_value = 4'd0;
        dp          = 1'b1;

        case (scan_index)
            2'd0: begin
                an[0]      = 1'b0;
                digit_value = hits % 10;
            end

            2'd1: begin
                an[1]      = 1'b0;
                digit_value = hits / 10;
            end

            2'd2: begin
                an[2]      = 1'b0;
                digit_value = misses % 10;
            end

            default: begin
                an[3]      = 1'b0;
                digit_value = misses / 10;
            end
        endcase
    end

    // Nexys 4: segmentos y anodos activos en bajo.
    // seg[0]=A, seg[1]=B, ..., seg[6]=G.
    always_comb begin
        case (digit_value)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end

endmodule
