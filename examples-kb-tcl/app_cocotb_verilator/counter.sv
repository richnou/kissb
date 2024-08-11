module counter(input wire clk,output reg [3:0] value);

    initial begin
        value = 0;
    end
    enum reg[1:0] { A, B ,C } state = A;

    always @(posedge clk) begin
        value <= value +1;
        if (value==4'd15) begin
            state <= B;
        end
    end

endmodule 