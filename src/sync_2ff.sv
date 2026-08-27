module sync_2ff #(
    parameter integer WIDTH = 1
) (
    input  logic             clk,
    input  logic             reset,
    input  logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);

    logic [WIDTH-1:0] meta_stage;

    always_ff @(posedge clk) begin
        if (reset) begin
            meta_stage <= '0;
            sync_out   <= '0;
        end else begin
            meta_stage <= async_in;
            sync_out   <= meta_stage;
        end
    end

endmodule
