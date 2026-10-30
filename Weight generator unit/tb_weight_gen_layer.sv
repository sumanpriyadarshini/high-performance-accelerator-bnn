`timescale 1ns/1ps
// Per-layer testbench for weight_gen. Same checking as tb_weight_gen.sv, but DEPTH / file / passes
// are parameters and the address width follows DEPTH.
//   C1: DEPTH=156   "c1_params.mem"      C2: 2416    "c2_params.mem"
//   C3: DEPTH=48120 "c3_params.mem"      F4: 10164   "f4_params.mem"      F5: 850  "f5_params.mem"
// Edit the three default values below (or override them as generics in the simulator).
module tb_weight_gen_layer #(
    parameter int    DEPTH      = 156,
    parameter string PARAM_FILE = "c1_params.mem",
    parameter int    PASSES     = 20          // use ~3 for C3 / F4 (they are long)
)();
    localparam int AW = $clog2(DEPTH);

    logic clk = 0, rst, load, start;
    always #5 clk = ~clk;

    logic signed [15:0] z;  logic z_valid;
    top_RBG grng (.clk(clk), .rst(rst), .load(load), .z(z), .z_valid(z_valid));

    logic signed [7:0] w; logic w_valid, w_last; logic [AW-1:0] w_addr;
    weight_gen #(.DEPTH(DEPTH), .PARAM_FILE(PARAM_FILE)) dut (
        .clk, .rst, .start, .eps(z), .eps_valid(z_valid), .w, .w_valid, .w_addr, .w_last);

    // ---- bit-exact reference model ----
    logic [15:0] ref_mem [0:DEPTH-1];
    initial $readmemh(PARAM_FILE, ref_mem);

    logic signed [15:0] e1, e2;            // eps delayed 2 clocks to line up with w
    always_ff @(posedge clk) begin e1 <= z; e2 <= e1; end

    integer errors = 0, checked = 0, fout, last_seen = 0;
    initial fout = $fopen("w_dump.txt", "w");

    always @(posedge clk) if (w_valid) begin
        automatic integer mu  = $signed(ref_mem[w_addr][7:0]);
        automatic integer sg  = ref_mem[w_addr][15:8];
        automatic integer acc = mu*256 + sg*e2;
        automatic integer r   = (acc + 128) >>> 8;
        automatic integer exp = (r > 127) ? 127 : (r < -128) ? -128 : r;
        checked++;
        if (w_last) last_seen++;
        if (w !== exp[7:0]) begin
            errors++;
            if (errors < 10) $display("MISMATCH addr=%0d eps=%0d got=%0d exp=%0d", w_addr, e2, w, exp);
        end
        $fwrite(fout, "%0d %0d\n", w_addr, w);
    end

    initial begin
        rst = 1; load = 0; start = 0;
        repeat (3) @(posedge clk);
        rst = 0;
        @(posedge clk); load = 1;
        @(posedge clk); load = 0;
        wait (z_valid);
        repeat (PASSES) begin
            @(posedge clk); start = 1;
            @(posedge clk); start = 0;
            wait (w_valid && w_last);
            @(posedge clk);
        end
        repeat (5) @(posedge clk);
        $display("DEPTH=%0d passes=%0d checked=%0d (expected %0d) errors=%0d", DEPTH, PASSES, checked, DEPTH*PASSES, errors);
        if (errors == 0 && checked == DEPTH*PASSES) $display("PASS"); else $display("FAIL");
        $fclose(fout);
        $finish;
    end
endmodule
