module game_controller_fsm (
    input  logic       clk,
    input  logic       reset,
    input  logic       position_valid,
    input  logic       hit_pulse,
    input  logic       miss_pulse,
    input  logic       timeout_pulse,
    input  logic       third_miss_pulse,
    input  logic       game_over_done,
    output logic       request_start,
    output logic       turn_start,
    output logic       turn_cancel,
    output logic       game_over_start,
    output logic       game_data_reset,
    output logic       game_active,
    output logic       game_over,
    output logic [3:0] state_debug
);

    typedef enum logic [3:0] {
        ST_REQUEST_START  = 4'd0,
        ST_WAIT_POSITION  = 4'd1,
        ST_START_TURN     = 4'd2,
        ST_PLAY           = 4'd3,
        ST_RESOLVE_HIT    = 4'd4,
        ST_RESOLVE_MISS   = 4'd5,
        ST_GAME_OVER_START= 4'd6,
        ST_GAME_OVER_WAIT = 4'd7,
        ST_AUTO_RESET     = 4'd8
    } state_t;

    state_t current_state;
    state_t next_state;

    always_ff @(posedge clk) begin
        if (reset)
            current_state <= ST_REQUEST_START;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;

        case (current_state)
            ST_REQUEST_START: begin
                next_state = ST_WAIT_POSITION;
            end

            ST_WAIT_POSITION: begin
                if (position_valid)
                    next_state = ST_START_TURN;
            end

            ST_START_TURN: begin
                next_state = ST_PLAY;
            end

            ST_PLAY: begin
                if (hit_pulse)
                    next_state = ST_RESOLVE_HIT;
                else if (miss_pulse || timeout_pulse)
                    next_state = ST_RESOLVE_MISS;
            end

            ST_RESOLVE_HIT: begin
                next_state = ST_REQUEST_START;
            end

            ST_RESOLVE_MISS: begin
                if (third_miss_pulse)
                    next_state = ST_GAME_OVER_START;
                else
                    next_state = ST_REQUEST_START;
            end

            ST_GAME_OVER_START: begin
                next_state = ST_GAME_OVER_WAIT;
            end

            ST_GAME_OVER_WAIT: begin
                if (game_over_done)
                    next_state = ST_AUTO_RESET;
            end

            ST_AUTO_RESET: begin
                next_state = ST_REQUEST_START;
            end

            default: begin
                next_state = ST_REQUEST_START;
            end
        endcase
    end

    always_comb begin
        request_start   = 1'b0;
        turn_start      = 1'b0;
        turn_cancel     = 1'b0;
        game_over_start = 1'b0;
        game_data_reset = 1'b0;
        game_active     = 1'b1;
        game_over       = 1'b0;

        case (current_state)
            ST_REQUEST_START: begin
                request_start = 1'b1;
            end

            ST_START_TURN: begin
                turn_start = 1'b1;
            end

            ST_RESOLVE_HIT,
            ST_RESOLVE_MISS: begin
                turn_cancel = 1'b1;
            end

            ST_GAME_OVER_START: begin
                turn_cancel     = 1'b1;
                game_over_start = 1'b1;
                game_active     = 1'b0;
                game_over       = 1'b1;
            end

            ST_GAME_OVER_WAIT: begin
                game_active = 1'b0;
                game_over   = 1'b1;
            end

            ST_AUTO_RESET: begin
                turn_cancel     = 1'b1;
                game_data_reset = 1'b1;
                game_active     = 1'b0;
            end

            default: begin
                // Valores predeterminados.
            end
        endcase
    end

    assign state_debug = current_state;

endmodule
