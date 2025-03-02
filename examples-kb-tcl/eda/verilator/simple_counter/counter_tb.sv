module counter_tb;

    logic resn;
    logic clk;
    
    always begin
        #10 clk <= ! clk;
    end

    initial begin
        $dumpfile("waves.fst");
        $dumpvars();
        resn = 0;
        clk = 0;
        #500 @(posedge clk);
        resn=1;

        #5000 $finish();
    end

    counter dut(
        .clk(clk),
        .resn(resn),
        .value()
    );
endmodule 