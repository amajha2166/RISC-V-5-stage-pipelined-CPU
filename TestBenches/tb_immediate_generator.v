
module tb_immediate_generator;

reg [31:0] instruction;

wire [31:0] immediate;

immediate_generator uut (
    .instruction(instruction),
    .immediate(immediate)
);

initial begin

    // ADDI x1, x0, 10
    instruction = 32'h00A00093;
    #10;
    $display("ADDI Immediate = %d", immediate);

    // LW x2, 4(x0)
    instruction = 32'h00402103;
    #10;
    $display("LW Immediate = %d", immediate);

    // SW x1, 8(x0)
    instruction = 32'h00102423;
    #10;
    $display("SW Immediate = %d", immediate);

    // BEQ x1, x2, +8
    instruction = 32'h00208463;
    #10;
    $display("BEQ Immediate = %d", immediate);

    $finish;

end

endmodule
