module top_RBG (
    input logic clk, rst, load,
    output logic signed [15:0] z
);
   logic [127:0] entry;
   logic [7:0] count;
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

    gaussian gauss(
        .clk(clk),
        .rst(rst),
        .count(count),
        .z(z)
    );
endmodule