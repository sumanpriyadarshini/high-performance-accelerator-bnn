module tb_LFSR_galois;

    logic clk, rst, load;
    logic [31:0] scq;
    logic y;
    logic [63:0] cycle_count;     // wide enough for long counts
    logic [31:0] seed_val;
    logic found;

    LFSR_galois dut (
        .clk  (clk),
        .rst  (rst),
        .load (load),
        .scq  (scq),
        .y    (y)
    );

    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst  = 1;
        load = 0;
        scq  = 32'h0000_0000;
        cycle_count = 0;
        found = 0;

        @(posedge clk);
        rst = 0;

        seed_val = 32'hA3B1_799E;   // change this to test different taps/seeds
        scq  = seed_val;
        load = 1;
        @(posedge clk);
        load = 0;

        // now s should equal seed_val exactly here (just loaded)
        // start counting cycles until state returns to seed_val

        while (!found) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            if (dut.s == seed_val) begin
                found = 1;
                $display("REPEAT FOUND: state returned to seed %h after %0d cycles", seed_val, cycle_count);
            end

            // safety cutoff - avoid infinite sim if period is huge (e.g. 2^32-1)
            if (cycle_count > 64'd10_000_000) begin
                $display("No repeat found within %0d cycles - period too large to brute-force in sim", cycle_count);
                found = 1;   // force exit
            end
        end

        $finish;
    end

endmodule