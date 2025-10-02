/**
A very simple testbenck to demonstrate simulating the counter
*/
module counter_tb;

    logic resn;
    logic clk;

    always begin
        #10ns clk <= ! clk;
    end

    initial begin
        $dumpfile("waves.fst");
        $dumpvars();
        resn = 0;
        clk = 0;
        @(posedge clk);
        @(posedge clk);
        resn=1;

        repeat(10) begin
            @(posedge clk);
        end

        #5000 $finish();
    end

    counter dut(
        .clk(clk),
        .resn(resn),
        .value()
    );
endmodule
