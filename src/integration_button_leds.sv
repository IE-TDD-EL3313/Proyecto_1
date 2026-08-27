module input_debounce #(
    parameter integer STABLE_CYCLES = 100_000
) (
    input  logic clk,
    input  logic input_async,
    output logic input_clean
);
    localparam integer COUNTER_WIDTH = $clog2(STABLE_CYCLES + 1);

    logic input_meta = 1'b0;
    logic input_sync = 1'b0;
    logic [COUNTER_WIDTH-1:0] counter = '0;
    logic clean_reg = 1'b0;

    always_ff @(posedge clk) begin
        input_meta <= input_async;
        input_sync <= input_meta;

        if (input_sync == clean_reg) begin
            counter <= '0;
        end else if (counter == STABLE_CYCLES - 1) begin
            clean_reg <= input_sync;
            counter   <= '0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    assign input_clean = clean_reg;
endmodule


module whack_a_mole_integration_top (
    input  logic       clk,
    input  logic       btnC,
    input  logic [2:0] position_async,
    input  logic [7:0] buttons_async,
    output logic [7:0] led,
    output logic [6:0] seg,
    output logic       dp,
    output logic [7:0] an
);
    localparam integer POSITION_STABLE_CYCLES = 100_000; // 1 ms

    logic [7:0] buttons_clean;
    logic [7:0] buttons_previous = '0;
    logic [7:0] button_rise;

    logic [2:0] position_meta = '0;
    logic [2:0] position_sync = '0;
    logic [2:0] position_candidate = '0;
    logic [2:0] active_position = '0;
    logic [16:0] position_counter = '0;

    logic [6:0] hits = '0;
    logic [6:0] misses = '0;
    logic round_active = 1'b0;
    logic position_initialized = 1'b0;

    logic [16:0] refresh_counter = '0;
    logic [1:0] selected_digit;
    logic [3:0] digit_value;

    genvar button_index;
    generate
        for (button_index = 0; button_index < 8; button_index = button_index + 1) begin : debounce_buttons
            input_debounce #(
                .STABLE_CYCLES(100_000)
            ) button_debounce_instance (
                .clk         (clk),
                .input_async (buttons_async[button_index]),
                .input_clean (buttons_clean[button_index])
            );
        end
    endgenerate

    assign button_rise = buttons_clean & ~buttons_previous;
    assign led = 8'b0000_0001 << active_position;
    assign dp = 1'b1;

    always_ff @(posedge clk) begin
        position_meta <= position_async;
        position_sync <= position_meta;
        buttons_previous <= buttons_clean;
        refresh_counter <= refresh_counter + 1'b1;

        if (btnC) begin
            position_candidate <= position_sync;
            active_position    <= position_sync;
            position_counter   <= '0;
            hits               <= '0;
            misses             <= '0;
            round_active       <= 1'b0;
            position_initialized <= 1'b0;
        end else begin
            // Solo aceptar una posicion cuando permanecio estable durante 1 ms.
            if (position_sync != position_candidate) begin
                position_candidate <= position_sync;
                position_counter   <= '0;
            end else if (position_counter < POSITION_STABLE_CYCLES - 1) begin
                position_counter <= position_counter + 1'b1;
            end else if (!position_initialized ||
                         (active_position != position_candidate)) begin
                // La primera posicion estable o un cambio inicia una jugada.
                active_position     <= position_candidate;
                round_active        <= 1'b1;
                position_initialized <= 1'b1;
            end

            // Se evalua solamente la primera pulsacion de cada jugada.
            if (round_active && (button_rise != 8'b0)) begin
                if (button_rise == (8'b0000_0001 << active_position)) begin
                    if (hits < 99)
                        hits <= hits + 1'b1;
                end else begin
                    if (misses < 99)
                        misses <= misses + 1'b1;
                end
                round_active <= 1'b0;
            end
        end
    end

    // Multiplexado de cuatro digitos. Visualmente: MMHH.
    // AN3-AN2 = fallos; AN1-AN0 = aciertos.
    assign selected_digit = refresh_counter[16:15];

    always_comb begin
        an = 8'b1111_1111;
        digit_value = 4'd0;

        case (selected_digit)
            2'd0: begin
                an[0] = 1'b0;
                digit_value = hits % 10;
            end
            2'd1: begin
                an[1] = 1'b0;
                digit_value = hits / 10;
            end
            2'd2: begin
                an[2] = 1'b0;
                digit_value = misses % 10;
            end
            default: begin
                an[3] = 1'b0;
                digit_value = misses / 10;
            end
        endcase
    end

    // Segmentos activos en LOW: seg[0]=A ... seg[6]=G.
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