// W = mu + sigma * eps      (3-stage pipeline, 1 weight per clock)
//   stage 1 : BRAM read of {sigma, mu}                       (param_rom)
//   stage 2 : acc = (mu << 8) + sigma * eps   -> one DSP48 (A*B + C)
//   stage 3 : round, shift right by 8, saturate to int8      -> w
// eps is Q8.8 (from top_RBG). mu, sigma, w all share the SAME 8-bit format.
module weight_gen #(
    parameter int    DEPTH      = 256,
    parameter int    AW         = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter string PARAM_FILE = "params.mem"
)(
    input  logic                clk, rst,
    input  logic                start,       // 1-clk pulse: stream addresses 0..DEPTH-1
    input  logic signed [15:0]  eps,         // Q8.8 gaussian from top_RBG
    input  logic                eps_valid,   // must be high before start and stay high
    output logic signed [7:0]   w,
    output logic                w_valid,
    output logic [AW-1:0]       w_addr,      // which weight this is (aligned with w)
    output logic                w_last
);
    // ---------------- address generator ----------------
    logic [AW-1:0] addr;
    logic          run;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin run <= 1'b0; addr <= '0; end
        else if (start && !run) begin run <= 1'b1; addr <= '0; end
        else if (run) begin
            if (addr == DEPTH-1) begin run <= 1'b0; addr <= '0; end
            else                 addr <= addr + 1'b1;
        end
    end

    // ---------------- stage 1 : BRAM read ----------------
    logic signed [7:0] mu;
    logic        [7:0] sigma;
    param_rom #(.DEPTH(DEPTH), .AW(AW), .PARAM_FILE(PARAM_FILE)) rom (
        .clk(clk), .addr(addr), .mu(mu), .sigma(sigma));

    logic          v1, last1;
    logic [AW-1:0] a1;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin v1 <= 0; last1 <= 0; a1 <= '0; end
        else begin
            v1    <= run;
            a1    <= addr;
            last1 <= run && (addr == DEPTH-1);
        end
    end

    // ---------------- stage 2 : multiply-add ----------------
    logic signed [8:0]  sig_s;
    logic signed [25:0] mu_al, prod, acc;
    assign sig_s = {1'b0, sigma};          // sigma is unsigned
    assign mu_al = mu <<< 8;               // align mu with the Q.8 fraction of the product
    assign prod  = sig_s * eps;

    logic          v2, last2;
    logic [AW-1:0] a2;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin acc <= '0; v2 <= 0; last2 <= 0; a2 <= '0; end
        else begin
            acc   <= mu_al + prod;
            v2    <= v1 & eps_valid;
            a2    <= a1;
            last2 <= last1;
        end
    end

    // ---------------- stage 3 : round + saturate ----------------
    logic signed [25:0] rnd;
    assign rnd = (acc + 26'sd128) >>> 8;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin w <= 0; w_valid <= 0; w_addr <= '0; w_last <= 0; end
        else begin
            if      (rnd >  26'sd127)  w <= 8'sd127;
            else if (rnd < -26'sd128)  w <= -8'sd128;
            else                       w <= rnd[7:0];
            w_valid <= v2;
            w_addr  <= a2;
            w_last  <= last2;
        end
    end
endmodule
