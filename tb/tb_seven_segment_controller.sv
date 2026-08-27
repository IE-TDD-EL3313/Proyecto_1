`timescale 1ns/1ps

module tb_seven_segment_controller;

    logic       clk;
    logic       reset;
    logic       ce_1ms;
    logic [6:0] hits;
    logic [6:0] misses;
    logic [6:0] seg;
    logic       dp;
    logic [7:0] an;

    integer error_count;

    seven_segment_controller dut (
        .clk   (clk),
        .reset (reset),
        .ce_1ms(ce_1ms),
        .hits  (hits),
        .misses(misses),
        .seg   (seg),
        .dp    (dp),
        .an    (an)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    function automatic logic [6:0] expected_segments(input integer digit);
        begin
            case (digit)
                0: expected_segments = 7'b1000000;
                1: expected_segments = 7'b1111001;
                2: expected_segments = 7'b0100100;
                3: expected_segments = 7'b0110000;
                4: expected_segments = 7'b0011001;
                5: expected_segments = 7'b0010010;
                6: expected_segments = 7'b0000010;
                7: expected_segments = 7'b1111000;
                8: expected_segments = 7'b0000000;
                9: expected_segments = 7'b0010000;
                default: expected_segments = 7'b1111111;
            endcase
        end
    endfunction

    task automatic advance_digit;
        begin
            @(negedge clk);
            ce_1ms = 1'b1;
            @(posedge clk);
            #1;
            @(negedge clk);
            ce_1ms = 1'b0;
        end
    endtask

    task automatic expect_digit(
        input logic [7:0] expected_an,
        input integer     expected_digit,
        input string      test_name
    );
        begin
            #1;
            if ((an !== expected_an) ||
                (seg !== expected_segments(expected_digit)) ||
                (dp !== 1'b1)) begin
                $error(
                    "FAIL: %s | an=%b/%b seg=%b/%b dp=%b",
                    test_name,
                    an,
                    expected_an,
                    seg,
                    expected_segments(expected_digit),
                    dp
                );
                error_count = error_count + 1;
            end else begin
                $display("PASS: %s", test_name);
            end
        end
    endtask

    initial begin
        reset       = 1'b1;
        ce_1ms      = 1'b0;
        hits        = 7'd42;
        misses      = 7'd17;
        error_count = 0;

        repeat (3) @(posedge clk);
        #1;

        // Formato visual AN3..AN0 = 17 42.
        expect_digit(8'b1111_1110, 2, "AN0 muestra unidades de aciertos");

        @(negedge clk);
        reset = 1'b0;

        advance_digit();
        expect_digit(8'b1111_1101, 4, "AN1 muestra decenas de aciertos");
        advance_digit();
        expect_digit(8'b1111_1011, 7, "AN2 muestra unidades de fallos");
        advance_digit();
        expect_digit(8'b1111_0111, 1, "AN3 muestra decenas de fallos");
        advance_digit();
        expect_digit(8'b1111_1110, 2, "Barrido regresa a AN0");

        hits   = 7'd0;
        misses = 7'd99;
        #1;
        expect_digit(8'b1111_1110, 0, "Aciertos 00 muestran cero inicial");
        advance_digit();
        expect_digit(8'b1111_1101, 0, "Decenas de aciertos en cero");
        advance_digit();
        expect_digit(8'b1111_1011, 9, "Unidades de fallos en 99");
        advance_digit();
        expect_digit(8'b1111_0111, 9, "Decenas de fallos en 99");

        if (error_count == 0)
            $display("PASS: tb_seven_segment_controller completo sin errores");
        else
            $fatal(1, "FAIL: display detecto %0d errores", error_count);

        $finish;
    end

endmodule
