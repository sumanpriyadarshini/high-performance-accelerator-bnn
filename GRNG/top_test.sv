module top_RBG (
    input logic clk, rst, load,
    output logic [7:0] count
);
   logic [127:0] entry;
   
   LFSR_Multilayered128 lfs(
        .clk(clk),
        .rst(rst),
        .load(load),
        .entry(entry)
    );
    
    bit_counter bn(
     .clk(clk), 
     .rst(rst),
     .entry(entry),
     .count(count)
    );
endmodule