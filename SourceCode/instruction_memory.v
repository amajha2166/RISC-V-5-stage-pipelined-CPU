
module instruction_memory (
    input  [31:0] address,
    output [31:0] instruction
);

// 64 instruction locations, 32 bits each
reg [31:0] memory [0:63];

integer i;

initial begin

    // Initialize memory with NOP instructions
    for (i = 0; i < 64; i = i + 1)
        memory[i] = 32'h00000013;

    // RISC-V RV32I program

    memory[0] = 32'h00A00093; // ADDI x1, x0, 10
    memory[1] = 32'h01400113; // ADDI x2, x0, 20
    memory[2] = 32'h002081B3; // ADD  x3, x1, x2
    memory[3] = 32'h40110233; // SUB  x4, x2, x1
    memory[4] = 32'h0020F2B3; // AND  x5, x1, x2
    memory[5] = 32'h0020E333; // OR   x6, x1, x2

end

// Combinational instruction fetch
assign instruction =
    (address[31:8] == 0 && address[7:2] < 64)
    ? memory[address[7:2]]
    : 32'h00000013;

endmodule
