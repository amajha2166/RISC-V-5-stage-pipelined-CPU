
module tb_pipeline_registers;

reg clk;
reg reset;

// IF/ID inputs
reg [31:0] pc_in;
reg [31:0] instruction_in;

wire [31:0] pc_out;
wire [31:0] instruction_out;

// ID/EX inputs
reg reg_write;
reg mem_read;
reg mem_write;
reg mem_to_reg;
reg alu_src;
reg branch;
reg branch_ne;

reg [3:0] alu_control;

reg [31:0] rs1_data;
reg [31:0] rs2_data;
reg [31:0] immediate;

reg [4:0] rd;

wire reg_write_idex;
wire mem_read_idex;
wire mem_write_idex;
wire [31:0] rs1_out;
wire [31:0] rs2_out;

// EX/MEM inputs
reg [31:0] branch_target;
reg [31:0] alu_result;
reg [31:0] write_data;
reg zero;

wire [31:0] alu_mem_out;
wire [31:0] write_data_out;

// MEM/WB inputs
reg [31:0] memory_data;

wire [31:0] memory_data_out;
wire [31:0] alu_wb_out;

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// IF/ID
if_id_register IF_ID (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .instruction_in(instruction_in),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

// ID/EX
id_ex_register ID_EX (
    .clk(clk),
    .reset(reset),

    .reg_write_in(reg_write),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .mem_to_reg_in(mem_to_reg),
    .alu_src_in(alu_src),
    .branch_in(branch),
    .branch_ne_in(branch_ne),

    .alu_control_in(alu_control),

    .pc_in(pc_in),
    .rs1_data_in(rs1_data),
    .rs2_data_in(rs2_data),
    .immediate_in(immediate),
    .rd_in(rd),

    .reg_write_out(reg_write_idex),
    .mem_read_out(mem_read_idex),
    .mem_write_out(mem_write_idex),
    .mem_to_reg_out(),
    .alu_src_out(),
    .branch_out(),
    .branch_ne_out(),

    .alu_control_out(),

    .pc_out(),
    .rs1_data_out(rs1_out),
    .rs2_data_out(rs2_out),
    .immediate_out(),
    .rd_out()
);

// EX/MEM
ex_mem_register EX_MEM (
    .clk(clk),
    .reset(reset),

    .reg_write_in(reg_write),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .mem_to_reg_in(mem_to_reg),
    .branch_in(branch),
    .branch_ne_in(branch_ne),

    .branch_target_in(branch_target),
    .alu_result_in(alu_result),
    .write_data_in(write_data),
    .zero_in(zero),
    .rd_in(rd),

    .reg_write_out(),
    .mem_read_out(),
    .mem_write_out(),
    .mem_to_reg_out(),
    .branch_out(),
    .branch_ne_out(),

    .branch_target_out(),
    .alu_result_out(alu_mem_out),
    .write_data_out(write_data_out),
    .zero_out(),
    .rd_out()
);

// MEM/WB
mem_wb_register MEM_WB (
    .clk(clk),
    .reset(reset),

    .reg_write_in(reg_write),
    .mem_to_reg_in(mem_to_reg),

    .memory_data_in(memory_data),
    .alu_result_in(alu_result),
    .rd_in(rd),

    .reg_write_out(),
    .mem_to_reg_out(),
    .memory_data_out(memory_data_out),
    .alu_result_out(alu_wb_out),
    .rd_out()
);

// Test sequence
initial begin

    reset = 1;

    pc_in = 0;
    instruction_in = 0;

    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    mem_to_reg = 0;
    alu_src = 0;
    branch = 0;
    branch_ne = 0;

    alu_control = 0;

    rs1_data = 0;
    rs2_data = 0;
    immediate = 0;
    rd = 0;

    branch_target = 0;
    alu_result = 0;
    write_data = 0;
    zero = 0;
    memory_data = 0;

    #12;
    reset = 0;

    // Send data into all pipeline registers
    pc_in = 32'h00000004;
    instruction_in = 32'h00A00093;

    reg_write = 1;
    alu_control = 4'b0000;

    rs1_data = 10;
    rs2_data = 20;
    immediate = 10;
    rd = 3;

    branch_target = 32'h00000020;
    alu_result = 30;
    write_data = 20;
    zero = 0;

    memory_data = 100;

    #8;

    $display("IF/ID PC = %h", pc_out);
    $display("IF/ID Instruction = %h", instruction_out);

    $display("ID/EX RS1 = %d", rs1_out);
    $display("ID/EX RS2 = %d", rs2_out);

    $display("EX/MEM ALU Result = %d", alu_mem_out);
    $display("EX/MEM Write Data = %d", write_data_out);

    $display("MEM/WB Memory Data = %d", memory_data_out);
    $display("MEM/WB ALU Result = %d", alu_wb_out);

    #10;

    $finish;

end

endmodule
