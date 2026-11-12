
module tb_instruction_memory;

reg [31:0] address;
wire [31:0] instruction;

instruction_memory uut (
    .address(address),
    .instruction(instruction)
);

initial begin

    // Fetch instruction 1
    address = 0;
    #10;
    $display("PC = %h | Instruction = %h",
             address, instruction);

    // Fetch instruction 2
    address = 4;
    #10;
    $display("PC = %h | Instruction = %h",
             address, instruction);

    // Fetch instruction 3
    address = 8;
    #10;
    $display("PC = %h | Instruction = %h",
             address, instruction);

    // Fetch instruction 4
    address = 12;
    #10;
    $display("PC = %h | Instruction = %h",
             address, instruction);

    // Fetch instruction 5
    address = 16;
    #10;
    $display("PC = %h | Instruction = %h",
             address, instruction);

    // Fetch instruction 6
    address = 20;
    #10;
    $display("PC = %h | Instruction = %h",
             address, instruction);

    $finish;

end

endmodule
