module bit_counter (
    input logic clk, rst,
    input logic [127:0]entry,
    output logic [7:0]count
);

//1st stage

logic [1:0] level_0 [0:63];
genvar i;
generate
    for ( i=0 ; i<64 ; i=i+1 ) begin
    assign level_0[i] = entry[2*i] + entry[(2*i)+1] ;
end
endgenerate

logic [1:0] level_0_r[0:63];
integer k;
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
            for ( k=0 ; k<64 ; k=k+1 ) begin
                level_0_r[k] <=0;
            end
    end
    else level_0_r<=level_0;
end

//2nd stage
logic [2:0] level_1 [0:31];
generate
    for ( i=0 ; i<32 ; i=i+1 ) begin
    assign level_1[i] = level_0_r[2*i] + level_0_r[(2*i)+1] ;
end
endgenerate

logic [2:0] level_1_r[0:31];
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
            for ( k=0 ; k<32 ; k=k+1 ) begin
                level_1_r[k] <=0;
            end
    end
    else level_1_r<=level_1;
end

//3rd stage
logic [3:0] level_2 [0:15];
generate
    for ( i=0 ; i<16 ; i=i+1 ) begin
    assign level_2[i] = level_1_r[2*i] + level_1_r[(2*i)+1] ;
end
endgenerate

logic [3:0] level_2_r[0:15];
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
            for ( k=0 ; k<16 ; k=k+1 ) begin
                level_2_r[k] <=0;
            end
    end
    else level_2_r<=level_2;
end

//4th stage
logic [4:0] level_3 [0:7];
generate
    for ( i=0 ; i<8 ; i=i+1 ) begin
    assign level_3[i] = level_2_r[2*i] + level_2_r[(2*i)+1] ;
end
endgenerate

logic [4:0] level_3_r[0:7];
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
            for ( k=0 ; k<8 ; k=k+1 ) begin
                level_3_r[k] <=0;
            end
    end
    else level_3_r<=level_3;
end


//5th stage
logic [5:0] level_4 [0:3];
generate
    for ( i=0 ; i<4 ; i=i+1 ) begin
    assign level_4[i] = level_3_r[2*i] + level_3_r[(2*i)+1] ;
end
endgenerate

logic [5:0] level_4_r[0:3];
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
            for ( k=0 ; k<4 ; k=k+1 ) begin
                level_4_r[k] <=0;
            end
    end
    else level_4_r<=level_4;
end

//6th stage
logic [6:0] level_5 [0:1];
generate
    for ( i=0 ; i<2 ; i=i+1 ) begin
    assign level_5[i] = level_4_r[2*i] + level_4_r[(2*i)+1] ;
end
endgenerate

logic [6:0] level_5_r[0:1];
always_ff @( posedge clk or posedge rst ) begin 
    if(rst) begin
            for ( k=0 ; k<2 ; k=k+1 ) begin
                level_5_r[k] <=0;
            end
    end
    else level_5_r<=level_5;
end

//7th stage (final)
logic [7:0] level_6;
assign level_6  = level_5_r[0] + level_5_r[1] ;

//always_ff @( posedge clk or posedge rst ) begin 
   //if(rst)  count<=8'd0;
   //else count<=  level_6;
//end

assign count = level_6;

endmodule