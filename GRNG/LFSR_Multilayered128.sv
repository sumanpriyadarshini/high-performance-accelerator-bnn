module LFSR_Multilayered128(
    input  logic        clk,
    input  logic        rst,
    input  logic        load,
    output logic [127:0]  entry
);

 logic [31:0] scq [0:127] ;
 logic y [0:127];

 initial begin
        $readmemh("/home/suman/Documents/btech project/GRNG/seeds.hex", scq);
    end


 genvar i;               //genvar is used to define a variable to access instanciates (like int, float)
 generate
    for ( i = 0 ; i < 128 ; i=i+1 ) begin
        LFSR_galois lfsr( 
            .clk(clk), 
            .rst(rst), 
            .load(load),
            .scq(scq[i]),
            .y(y[i])
        );
    end
 endgenerate

genvar k;
generate
    for ( k = 0 ; k < 128 ; k=k+1 ) begin : bit_assign
       assign entry[127-k] = y[k]; 
    end
endgenerate
endmodule