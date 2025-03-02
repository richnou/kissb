// That's a very bad counter to demonstrate cocotb
module counter(input wire clk,output reg [3:0] value);

    initial begin
        value = 0;
    end

    always @(posedge clk) begin
        value <= value +1;
    end

endmodule 