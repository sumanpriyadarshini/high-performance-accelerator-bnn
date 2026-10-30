module BRAM_simple_dual_port #(
    parameter RAM_WIDTH = 16, // 8 bits for mu + 8 bits for sigma
    parameter RAM_DEPTH = 512,
    parameter ADDR_WIDTH = 9  // log2(512)
) (
    input  logic clk,
    
    // PORT A: Write Port (Used by CPU/DMA to load parameters)
    input  logic en_a,
    input  logic wen_a,
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic [RAM_WIDTH-1:0]  din_a,
    
    // PORT B: Read Port (Used by BNN hardware during inference)
    input  logic en_b,
    input  logic [ADDR_WIDTH-1:0] addr_b,
    output logic [RAM_WIDTH-1:0]  dout_b
);

    // The memory array
    reg [RAM_WIDTH-1:0] bram [RAM_DEPTH-1:0];

    // Port A: Synchronous Write
    always_ff @(posedge clk) begin 
        if (en_a) begin
            if (wen_a) begin
                bram[addr_a] <= din_a;
            end
        end
    end

    // Port B: Synchronous Read
    always_ff @(posedge clk) begin
        if (en_b) begin
            dout_b <= bram[addr_b]; 
        end
    end

endmodule