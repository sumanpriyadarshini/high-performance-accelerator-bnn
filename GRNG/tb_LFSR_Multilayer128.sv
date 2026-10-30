module tb_LFSR_Multilayer;
    logic clk = 0, rst, load;
    logic [127:0] entry;

    LFSR_Multilayered128 dut (.clk(clk), .rst(rst), .load(load), .entry(entry));

    always #5 clk = ~clk;

    initial begin
        rst = 1; load = 0;
        #10 rst = 0; load = 1;
        #10 load = 0;

        // run for some cycles, dump entry each cycle
        repeat (20) begin
            @(posedge clk);
            $display("time=%0t entry=%h", $time, entry);
        end
        $finish;
    end
endmodule