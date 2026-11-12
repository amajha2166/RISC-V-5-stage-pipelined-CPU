
module tb_riscv_cpu;

reg clk;
reg reset;

wire [31:0] pc_debug;
wire [31:0] instruction_debug;

wire [31:0] x1_debug;
wire [31:0] x2_debug;
wire [31:0] x3_debug;
wire [31:0] x4_debug;
wire [31:0] x5_debug;
wire [31:0] x6_debug;
wire [31:0] x7_debug;
wire [31:0] x8_debug;

// Complete CPU
riscv_cpu uut (

    .clk(clk),
    .reset(reset),

    .pc_debug(pc_debug),
    .instruction_debug(instruction_debug),

    .x1_debug(x1_debug),
    .x2_debug(x2_debug),
    .x3_debug(x3_debug),
    .x4_debug(x4_debug),
    .x5_debug(x5_debug),
    .x6_debug(x6_debug),
    .x7_debug(x7_debug),
    .x8_debug(x8_debug)

);

// Clock generation: 10 ns period
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// CPU simulation
initial begin

    reset = 1;

    #20;
    reset = 0;

    // Allow the instructions to pass through
    // all five pipeline stages
    repeat (35) begin
        @(posedge clk);
        #1;
    end

    $display("");
    $display("==================================");
    $display("       RISC-V CPU RESULTS");
    $display("==================================");

    $display("x1 = %d", x1_debug);
    $display("x2 = %d", x2_debug);
    $display("x3 = %d", x3_debug);
    $display("x4 = %d", x4_debug);
    $display("x5 = %d", x5_debug);
    $display("x6 = %d", x6_debug);
    $display("x7 = %d", x7_debug);
    $display("x8 = %d", x8_debug);

    $display("Memory[0] = %d", uut.dmem[0]);

    $display("==================================");

    $finish;

end

endmodule
