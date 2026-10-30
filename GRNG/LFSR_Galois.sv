module LFSR_galois (  
    input logic clk, rst, load,
    input logic [31:0]scq,
    output logic y
);

 //right to left shift

 logic fb ;
 assign fb = s[31];
 logic [31:0]s;
 logic [5:0]i;                                         //bit change variable for shifting
 always_ff @( posedge clk, posedge rst ) begin 
        if (rst) begin 
          s <= 32'd0 ;
        end

        else if (load) s <= scq;

        else
           for (i = 0 ; i < 32'd32 ; i = i+1 ) begin
              if(i==0) s[i] <= fb; 
              else if (i==32'd1 | i==32'd2 | i==32'd22 )  s[i] <= ( s[i-1] ^ fb );
              else s[i] <= s[i-1] ;
           end
    
 end 

 assign y = s[31];

endmodule