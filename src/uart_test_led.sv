module uart_test_led (
    input  logic       clk,        // 100 MHz de la Nexys 4
    input  logic       reset,
    input  logic       uart_rx_in, // UART desde el circuito discreto
    output logic [7:0] led
);

    logic rx_sync1;
    logic rx_sync2;

    always_ff @(posedge clk) begin
        if (reset) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end
        else begin
            rx_sync1 <= uart_rx_in;
            rx_sync2 <= rx_sync1;
        end
    end

    logic [7:0] rx_data;
    logic       data_valid;

    uart_rx #(
        .CLK_FREQ  (100_000_000),
        .BAUD_RATE (9600)
    ) uart_rx_inst (
        .clk         (clk),
        .reset       (reset),
        .serial_sync (rx_sync2),
        .rx_data     (rx_data),
        .data_valid  (data_valid)
    );

    always_ff @(posedge clk) begin

        if (reset) begin
            led <= 8'b00000000;
        end
        else if (data_valid) begin
            case (rx_data[2:0])
                3'd0: led <= 8'b00000001;
                3'd1: led <= 8'b00000010;
                3'd2: led <= 8'b00000100;
                3'd3: led <= 8'b00001000;
                3'd4: led <= 8'b00010000;
                3'd5: led <= 8'b00100000;
                3'd6: led <= 8'b01000000;
                3'd7: led <= 8'b10000000;
                default: led <= 8'b00000000;
            endcase
        end

    end

endmodule