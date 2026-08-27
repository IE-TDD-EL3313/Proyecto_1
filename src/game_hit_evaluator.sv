module game_hit_evaluator (
    input  logic       turn_active,
    input  logic [2:0] active_position,
    input  logic [7:0] buttons_pulse,
    output logic [7:0] active_mole_onehot,
    output logic       any_press,
    output logic       hit_pulse,
    output logic       miss_pulse
);

    always_comb begin
        active_mole_onehot = 8'b0000_0001 << active_position;
        any_press          = (buttons_pulse != 8'b0000_0000);
        hit_pulse          = 1'b0;
        miss_pulse         = 1'b0;

        if (turn_active && any_press) begin
            if (buttons_pulse == active_mole_onehot)
                hit_pulse = 1'b1;
            else
                miss_pulse = 1'b1;
        end
    end

endmodule
