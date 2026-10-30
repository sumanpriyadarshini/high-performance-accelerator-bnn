module RBG;
 
logic clk,rst,load;
logic [7:0] count;

top_RBG rbg(
    .clk(clk),
    .rst(rst),
    .load(load),
    .count(count)
);

always #5 clk = ~clk;

initial begin
    clk  = 0;
    rst  = 1;
    load = 0;
   
    @(posedge clk);
     rst  = 0;
    load = 1;          
    @(posedge clk);
    load = 0;

    repeat (50) begin
        @(posedge clk);
        $display("t=%0t  count=%0d", $time, count);
    end

    $finish;
end

endmodule