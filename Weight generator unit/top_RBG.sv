module top_RBG 
(
    input  logic               clk, rst, load,
    output logic signed [15:0] z,        // epsilon, Q8.8  (z_real = z / 256)
    output logic               z_valid   // high once the 9-stage pipeline has filled after 'load'
);
    logic [127:0] entry;
    logic [7:0]   count;

    LFSR_Multilayered128 lfsr(.clk(clk), .rst(rst), .load(load), .entry(entry));
    bit_counter bn (.clk(clk), .rst(rst), .entry(entry), .count(count));
    gaussian gauss (.clk(clk), .rst(rst), .count(count), .z(z));

    // pipeline latency = 6 (bit_counter) + 3 (gaussian) = 9 clocks after the load edge
    localparam int LAT = 9;
    logic [3:0] wcnt;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin wcnt <= 0; z_valid <= 1'b0; end
        else if (load) begin wcnt <= 0; z_valid <= 1'b0; end
        else if (!z_valid) begin
            if (wcnt == LAT-1) z_valid <= 1'b1;
            else               wcnt <= wcnt + 1'b1;
        end
    end
endmodule
