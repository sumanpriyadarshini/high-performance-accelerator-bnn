// Holds mu and sigma for every weight. One word = {sigma[7:0], mu[7:0]}.
// Synchronous read -> Vivado infers Block RAM. Read latency = 1 clock.
module param_rom #(
    parameter int    DEPTH      = 256,
    parameter int    AW         = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter string PARAM_FILE = "params.mem"
)(
    input  logic                clk,
    input  logic [AW-1:0]       addr,
    output logic signed [7:0]   mu,
    output logic        [7:0]   sigma
);
    (* rom_style = "block" *) logic [15:0] mem [0:DEPTH-1];
    initial $readmemh(PARAM_FILE, mem);

    logic [15:0] rd;
    always_ff @(posedge clk) rd <= mem[addr];   // no reset on purpose (lets BRAM be inferred)

    assign mu    = rd[7:0];
    assign sigma = rd[15:8];
endmodule
