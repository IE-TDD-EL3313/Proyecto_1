module test_botones (
    input  logic [7:0] botones,
    output logic [7:0] leds
);

    always_comb begin
        leds = botones;
    end

endmodule