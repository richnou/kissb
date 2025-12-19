// A very simple counter to demonstrate simulator usage
module counter(
    input wire clk,
    input wire resn,
    output reg [3:0] value
);

    always @(posedge clk) begin
        if (!resn) begin
            value <= 4'h0;
        end
        else begin
            value <= value + 4'd1;
        end

    end

endmodule
