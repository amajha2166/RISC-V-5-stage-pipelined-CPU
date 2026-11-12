
module tb_program_counter;

reg clk;
reg reset;
reg pc_enable;

reg [31:0] next_pc;

wire [31:0] pc;

program_counter uut (
    .clk(clk),
    .reset(reset),
    .pc_enable(pc_enable),
    .next_pc(next_pc),
    .pc(pc)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    reset = 1;
    pc_enable = 1;
    next_pc = 0;

    #10;
    reset = 0;

    next_pc = 4;
    #10;
    $display("PC = %d", pc);

    next_pc = 8;
    #10;
    $display("PC = %d", pc);

    next_pc = 12;
    #10;
    $display("PC = %d", pc);

    next_pc = 16;
    #10;
    $display("PC = %d", pc);

    $finish;

end

endmodule
