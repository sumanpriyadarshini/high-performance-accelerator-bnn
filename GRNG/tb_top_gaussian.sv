module tb_gaussian;
    logic clk, rst;
    logic signed [15:0] z;
    logic load;

    top_RBG dut(
        .clk(clk), .rst(rst), .load(load),
.z(z)
);
   
    // clock gen
    initial clk = 0;
    always #5 clk = ~clk;
   
    initial begin
        rst = 1;
        load = 0;
        
        repeat(3) @(posedge clk);
        rst = 0;
        @(posedge clk)
        load = 1;
        @(posedge clk);
        load = 0;
        
        // total pipeline latency ≈ 6 (bit_counter) + 3 (gaussian) = ~9 clocks
        // before the first real z shows up - so run plenty of cycles
        repeat (2) @(posedge clk);

        $finish;
    end
    
    // ---- dump z to a file, for your later python histogram / K-S test ----
    integer fout;
    initial fout = $fopen("z_dump.txt", "w");

    always @(posedge clk) begin
        if (!rst)
            $fwrite(fout, "%0d\n", z);
    end

    final $fclose(fout);
endmodule