module uart_synchronizer (
    input  logic clk,
    input  logic reset,
    input  logic serial_async,
    output logic serial_sync
);

    logic serial_meta;

    always_ff @(posedge clk) begin
        if (reset) begin
            serial_meta <= 1'b1;
            serial_sync <= 1'b1;
        end
        else begin
            serial_meta <= serial_async;
            serial_sync <= serial_meta;
        end
    end

endmodule