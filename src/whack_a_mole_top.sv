module whack_a_mole_top #(
    parameter integer CLK_FREQ_HZ       = 100_000_000,
    parameter integer BUTTON_DEBOUNCE_MS= 10,
    parameter integer POSITION_STABLE_MS= 2,
    parameter integer REQUEST_PULSE_MS  = 500,
    parameter logic [10:0] INITIAL_MS   = 11'd1500,
    parameter logic [10:0] MINIMUM_MS   = 11'd500,
    parameter logic [10:0] STEP_MS      = 11'd100,
    parameter integer GAME_OVER_MS      = 2000,
    parameter integer STATUS_BLINK_MS   = 250
) (
    input  logic       clk,
    input  logic       reset_button,
    input  logic [2:0] position_async,
    input  logic [7:0] buttons_async,
    output logic       solicitud_topo,
    output logic [7:0] mole_leds,
    output logic       status_led,
    output logic [6:0] seg,
    output logic       dp,
    output logic [7:0] an
);

    logic reset_meta = 1'b0;
    logic reset      = 1'b0;
    logic ce_1ms;
    logic [7:0] buttons_level;
    logic [7:0] buttons_pulse;
    logic [2:0] active_position;
    logic position_valid;
    logic request_start;
    logic request_busy;
    logic request_done;
    logic turn_start;
    logic turn_cancel;
    logic turn_active;
    logic timeout_pulse;
    logic any_press;
    logic hit_pulse;
    logic button_miss_pulse;
    logic effective_miss_pulse;
    logic [10:0] duration_ms;
    logic [6:0] hits;
    logic [6:0] misses;
    logic [1:0] consecutive_miss_count;
    logic three_misses;
    logic third_miss_pulse;
    logic game_over_start;
    logic game_over_timer_active;
    logic game_over_done;
    logic game_data_reset;
    logic game_active;
    logic game_over;
    logic [3:0] state_debug;
    logic data_reset;

    // El pulsador central es asincrono respecto al reloj de 100 MHz.
    always_ff @(posedge clk) begin
        reset_meta <= reset_button;
        reset      <= reset_meta;
    end

    assign data_reset          = reset | game_data_reset;
    assign effective_miss_pulse= button_miss_pulse | timeout_pulse;

    ce_1ms_generator #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    ) timebase (
        .clk   (clk),
        .reset (reset),
        .ce_1ms(ce_1ms)
    );

    button_bank #(
        .BUTTON_COUNT(8),
        .DEBOUNCE_MS (BUTTON_DEBOUNCE_MS)
    ) buttons (
        .clk          (clk),
        .reset        (reset),
        .ce_1ms       (ce_1ms),
        .buttons_async(buttons_async),
        .buttons_level(buttons_level),
        .buttons_pulse(buttons_pulse)
    );

    parallel_position_receiver #(
        .STABLE_MS(POSITION_STABLE_MS)
    ) position_receiver (
        .clk           (clk),
        .reset         (reset),
        .ce_1ms        (ce_1ms),
        .position_async(position_async),
        .position      (active_position),
        .position_valid(position_valid)
    );

    mole_request_generator #(
        .PULSE_MS(REQUEST_PULSE_MS)
    ) request_generator (
        .clk           (clk),
        .reset         (reset),
        .ce_1ms        (ce_1ms),
        .start         (request_start),
        .solicitud_topo(solicitud_topo),
        .busy          (request_busy),
        .done          (request_done)
    );

    game_hit_evaluator hit_evaluator (
        .turn_active       (turn_active),
        .active_position   (active_position),
        .buttons_pulse     (buttons_pulse),
        .active_mole_onehot(mole_leds),
        .any_press         (any_press),
        .hit_pulse         (hit_pulse),
        .miss_pulse        (button_miss_pulse)
    );

    turn_window_timer turn_timer (
        .clk          (clk),
        .reset        (data_reset),
        .ce_1ms       (ce_1ms),
        .start        (turn_start),
        .cancel       (turn_cancel),
        .duration_ms  (duration_ms),
        .active       (turn_active),
        .timeout_pulse(timeout_pulse)
    );

    difficulty_controller #(
        .INITIAL_MS(INITIAL_MS),
        .MINIMUM_MS(MINIMUM_MS),
        .STEP_MS   (STEP_MS)
    ) difficulty (
        .clk        (clk),
        .reset      (data_reset),
        .hit_pulse  (hit_pulse),
        .miss_pulse (effective_miss_pulse),
        .duration_ms(duration_ms)
    );

    score_counters scores (
        .clk       (clk),
        .reset     (data_reset),
        .hit_pulse (hit_pulse),
        .miss_pulse(effective_miss_pulse),
        .hits      (hits),
        .misses    (misses)
    );

    consecutive_misses lives (
        .clk             (clk),
        .reset           (data_reset),
        .hit_pulse       (hit_pulse),
        .miss_pulse      (effective_miss_pulse),
        .miss_count      (consecutive_miss_count),
        .three_misses    (three_misses),
        .third_miss_pulse(third_miss_pulse)
    );

    game_over_timer #(
        .GAME_OVER_MS(GAME_OVER_MS)
    ) end_timer (
        .clk       (clk),
        .reset     (reset),
        .ce_1ms    (ce_1ms),
        .start     (game_over_start),
        .active    (game_over_timer_active),
        .done_pulse(game_over_done)
    );

    game_controller_fsm controller (
        .clk              (clk),
        .reset            (reset),
        .position_valid   (position_valid),
        .hit_pulse        (hit_pulse),
        .miss_pulse       (button_miss_pulse),
        .timeout_pulse    (timeout_pulse),
        .third_miss_pulse (third_miss_pulse),
        .game_over_done   (game_over_done),
        .request_start    (request_start),
        .turn_start       (turn_start),
        .turn_cancel      (turn_cancel),
        .game_over_start  (game_over_start),
        .game_data_reset  (game_data_reset),
        .game_active      (game_active),
        .game_over        (game_over),
        .state_debug      (state_debug)
    );

    seven_segment_controller display (
        .clk  (clk),
        .reset(reset),
        .ce_1ms(ce_1ms),
        .hits (hits),
        .misses(misses),
        .seg  (seg),
        .dp   (dp),
        .an   (an)
    );

    status_indicator #(
        .BLINK_MS(STATUS_BLINK_MS)
    ) status (
        .clk        (clk),
        .reset      (reset),
        .ce_1ms     (ce_1ms),
        .game_active(game_active),
        .game_over  (game_over),
        .status_led (status_led)
    );

endmodule
