module button_debounce #(
    parameter integer STABLE_CYCLES = 100_000
) (
    input  logic clk,
    input  logic button_async,
    output logic button_clean
);

    localparam integer COUNTER_WIDTH = $clog2(STABLE_CYCLES + 1);

    logic button_meta = 1'b0;
    logic button_sync = 1'b0;
    logic [COUNTER_WIDTH-1:0] stable_counter = '0;
    logic button_clean_reg = 1'b0;

    always_ff @(posedge clk) begin
        button_meta <= button_async;
        button_sync <= button_meta;

        if (button_sync == button_clean_reg) begin
            stable_counter <= '0;
        end else if (stable_counter == STABLE_CYCLES - 1) begin
            button_clean_reg <= button_sync;
            stable_counter   <= '0;
        end else begin
            stable_counter <= stable_counter + 1'b1;
        end
    end

    assign button_clean = button_clean_reg;

endmodule


module button_test_top (
    input  logic       clk,
    input  logic [7:0] buttons_async,
    output logic [7:0] led
);

    logic [7:0] buttons_clean;

    genvar index;
    generate
        for (index = 0; index < 8; index = index + 1) begin : generate_debouncers
            button_debounce #(
                .STABLE_CYCLES(100_000) // 1 ms con reloj de 100 MHz
            ) debounce_instance (
                .clk          (clk),
                .button_async (buttons_async[index]),
                .button_clean (buttons_clean[index])
            );
        end
    endgenerate

    // Durante esta prueba, cada boton controla directamente su LED.
    assign led = buttons_clean;

endmodule