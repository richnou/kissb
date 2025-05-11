// That's a very bad counter to demonstrate cocotb
module counter(
    input wire clk,
    input wire enable,
    output reg [15:0] value);

    initial begin
        value = 0;
    end

    always @(posedge clk) begin
        if (enable) begin
            value <= value +1;
        end 
        
    end

endmodule 