
module tb_control_unit;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;
wire branch;
wire branch_ne;
wire [3:0] alu_control;

control_unit uut (

    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),

    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .branch_ne(branch_ne),

    .alu_control(alu_control)

);

initial begin

    // ADD
    opcode = 7'b0110011;
    funct3 = 3'b000;
    funct7 = 7'b0000000;
    #10;
    $display("ADD: reg_write=%b alu_control=%b",
             reg_write, alu_control);

    // SUB
    funct7 = 7'b0100000;
    #10;
    $display("SUB: reg_write=%b alu_control=%b",
             reg_write, alu_control);

    // ADDI
    opcode = 7'b0010011;
    funct3 = 3'b000;
    funct7 = 0;
    #10;
    $display("ADDI: reg_write=%b alu_src=%b",
             reg_write, alu_src);

    // LW
    opcode = 7'b0000011;
    funct3 = 3'b010;
    #10;
    $display("LW: mem_read=%b mem_to_reg=%b",
             mem_read, mem_to_reg);

    // SW
    opcode = 7'b0100011;
    #10;
    $display("SW: mem_write=%b",
             mem_write);

    // BEQ
    opcode = 7'b1100011;
    funct3 = 3'b000;
    #10;
    $display("BEQ: branch=%b",
             branch);

    // BNE
    funct3 = 3'b001;
    #10;
    $display("BNE: branch=%b branch_ne=%b",
             branch, branch_ne);

    $finish;

end

endmodule
