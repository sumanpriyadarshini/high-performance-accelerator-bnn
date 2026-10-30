module BRAM_singleport#(
    parameter RAM_WIDTH = 16, // 8 bits for mu + 8 bits for sigma
    parameter RAM_DEPTH = 512,
    parameter ADDR_WIDTH = 9  // log2(512)
) (
    input  logic clk,
    input  logic en,          
    input  logic wen,         // Write enable
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [RAM_WIDTH-1:0]  din,  // {mu_in, sigma_in}
    output logic [RAM_WIDTH-1:0]  dout  // {mu_out, sigma_out}
);

    // The memory array
    reg [RAM_WIDTH-1:0] bram [RAM_DEPTH-1:0];

    
    always_ff @(posedge clk) begin 
        if (en) begin
            if (wen) begin
                bram[addr] <= din;
            end
            // Synchronous read
            dout <= bram[addr]; 
        end
    end

endmodule