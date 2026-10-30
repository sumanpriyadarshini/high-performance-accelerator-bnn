module gaussian (
    input logic clk,
    input logic rst,
    input logic [7:0] count,
    output logic signed [15:0] z
);

   // Mean(u) = 64, Variance = 32, std.deviation = sqrt(32)
   // 1/sqrt(32) = 0.1767...
   // 0.1767... * 65536 = 11585 (mul 2^16 and rounded)
   localparam logic signed [15:0] k_const = 16'sd11585 ;

  //stage-1 : finding the diff(X-u)
   logic signed [7:0] diff; //extra bit for count to be read as unsigned not signed
   always_ff@ (posedge clk or posedge rst) begin
         if (rst) begin
              diff <= 0;
         end
        else diff <= $signed (count) - 8'sd64 ;
    end

    //stage 2 : finding the product part
    logic signed [23:0] prod;
    always_ff @( posedge clk or posedge rst ) begin 
        if (rst) begin
            prod <= 0 ;
         end
        else prod <= diff * k_const ;
    end

    //stage 3: 
    always_ff @( posedge clk or posedge rst ) begin 
        if (rst) begin
            z <= 0 ;
         end
        else z <= prod >>> 8 ; //arithmetic right shift
    end

endmodule