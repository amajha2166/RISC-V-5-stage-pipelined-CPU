
module riscv_cpu (
    input clk,
    input reset,

    output [31:0] pc_debug,
    output [31:0] instruction_debug,

    output [31:0] x1_debug,
    output [31:0] x2_debug,
    output [31:0] x3_debug,
    output [31:0] x4_debug,
    output [31:0] x5_debug,
    output [31:0] x6_debug,
    output [31:0] x7_debug,
    output [31:0] x8_debug
);

// =====================================================
// 1. INSTRUCTION MEMORY
// =====================================================

reg [31:0] imem [0:63];

integer i;
integer j;
integer k;

initial begin

    for (i = 0; i < 64; i = i + 1)
        imem[i] = 32'h00000013;

    imem[0] = 32'h00A00093; // ADDI x1, x0, 10
    imem[1] = 32'h01400113; // ADDI x2, x0, 20
    imem[2] = 32'h002081B3; // ADD  x3, x1, x2
    imem[3] = 32'h40110233; // SUB  x4, x2, x1
    imem[4] = 32'h0020F2B3; // AND  x5, x1, x2
    imem[5] = 32'h0020E333; // OR   x6, x1, x2
    imem[6] = 32'h00302023; // SW   x3, 0(x0)
    imem[7] = 32'h00002383; // LW   x7, 0(x0)
    imem[8] = 32'h00138413; // ADDI x8, x7, 1

end

// =====================================================
// 2. DATA MEMORY
// =====================================================

reg [31:0] dmem [0:63];

initial begin

    for (k = 0; k < 64; k = k + 1)
        dmem[k] = 32'b0;

end

// =====================================================
// 3. REGISTER FILE
// =====================================================

reg [31:0] regfile [0:31];

initial begin

    for (j = 0; j < 32; j = j + 1)
        regfile[j] = 32'b0;

end

assign x1_debug = regfile[1];
assign x2_debug = regfile[2];
assign x3_debug = regfile[3];
assign x4_debug = regfile[4];
assign x5_debug = regfile[5];
assign x6_debug = regfile[6];
assign x7_debug = regfile[7];
assign x8_debug = regfile[8];

// =====================================================
// 4. PROGRAM COUNTER
// =====================================================

reg [31:0] pc;

assign pc_debug = pc;

wire [31:0] instruction_debug_internal;

assign instruction_debug = instruction_debug_internal;

assign instruction_debug_internal =
    (pc[31:8] == 0) ? imem[pc[7:2]] : 32'h00000013;

wire [31:0] next_pc;
wire stall;
wire branch_taken;

// =====================================================
// 5. IF / ID PIPELINE REGISTER
// =====================================================

reg [31:0] ifid_pc;
reg [31:0] ifid_instruction;
reg ifid_valid;

// =====================================================
// 6. INSTRUCTION DECODER
// =====================================================

wire [6:0] id_opcode;
wire [4:0] id_rd;
wire [2:0] id_funct3;
wire [4:0] id_rs1;
wire [4:0] id_rs2;
wire [6:0] id_funct7;

assign id_opcode = ifid_instruction[6:0];
assign id_rd = ifid_instruction[11:7];
assign id_funct3 = ifid_instruction[14:12];
assign id_rs1 = ifid_instruction[19:15];
assign id_rs2 = ifid_instruction[24:20];
assign id_funct7 = ifid_instruction[31:25];

// =====================================================
// 7. REGISTER FILE READ
// =====================================================

wire [31:0] id_read_data1;
wire [31:0] id_read_data2;

assign id_read_data1 =
    (id_rs1 == 0) ? 32'b0 : regfile[id_rs1];

assign id_read_data2 =
    (id_rs2 == 0) ? 32'b0 : regfile[id_rs2];

// =====================================================
// 8. IMMEDIATE GENERATOR
// =====================================================

reg [31:0] id_immediate;

always @(*) begin

    case (id_opcode)

        // I-type: ADDI, LW
        7'b0010011,
        7'b0000011: begin

            id_immediate = {
                {20{ifid_instruction[31]}},
                ifid_instruction[31:20]
            };

        end

        // S-type: SW
        7'b0100011: begin

            id_immediate = {
                {20{ifid_instruction[31]}},
                ifid_instruction[31:25],
                ifid_instruction[11:7]
            };

        end

        // B-type: BEQ, BNE
        7'b1100011: begin

            id_immediate = {
                {19{ifid_instruction[31]}},
                ifid_instruction[31],
                ifid_instruction[7],
                ifid_instruction[30:25],
                ifid_instruction[11:8],
                1'b0
            };

        end

        default: id_immediate = 32'b0;

    endcase

end

// =====================================================
// 9. CONTROL UNIT
// =====================================================

reg id_regwrite;
reg id_memread;
reg id_memwrite;
reg id_memtoreg;
reg id_alusrc;
reg id_branch;
reg id_branch_ne;

reg [3:0] id_alu_control;

always @(*) begin

    id_regwrite = 0;
    id_memread = 0;
    id_memwrite = 0;
    id_memtoreg = 0;
    id_alusrc = 0;
    id_branch = 0;
    id_branch_ne = 0;
    id_alu_control = 4'b0000;

    case (id_opcode)

        // R-type instructions
        7'b0110011: begin

            id_regwrite = 1;

            case (id_funct3)

                3'b000:
                    id_alu_control =
                        (id_funct7 == 7'b0100000)
                        ? 4'b0001 : 4'b0000;

                3'b111: id_alu_control = 4'b0010;
                3'b110: id_alu_control = 4'b0011;
                3'b100: id_alu_control = 4'b0100;
                3'b001: id_alu_control = 4'b0101;
                3'b101: id_alu_control = 4'b0110;
                3'b010: id_alu_control = 4'b0111;

                default: begin
                    id_regwrite = 0;
                    id_alu_control = 0;
                end

            endcase

        end

        // ADDI
        7'b0010011: begin

            if (id_funct3 == 3'b000) begin
                id_regwrite = 1;
                id_alusrc = 1;
                id_alu_control = 4'b0000;
            end

        end

        // LW
        7'b0000011: begin

            if (id_funct3 == 3'b010) begin
                id_regwrite = 1;
                id_memread = 1;
                id_memtoreg = 1;
                id_alusrc = 1;
                id_alu_control = 4'b0000;
            end

        end

        // SW
        7'b0100011: begin

            if (id_funct3 == 3'b010) begin
                id_memwrite = 1;
                id_alusrc = 1;
                id_alu_control = 4'b0000;
            end

        end

        // BEQ / BNE
        7'b1100011: begin

            if (id_funct3 == 3'b000) begin
                id_branch = 1;
                id_alu_control = 4'b0001;
            end

            else if (id_funct3 == 3'b001) begin
                id_branch = 1;
                id_branch_ne = 1;
                id_alu_control = 4'b0001;
            end

        end

        default: begin
        end

    endcase

end

// =====================================================
// 10. ID / EX PIPELINE REGISTER
// =====================================================

reg idex_valid;

reg [31:0] idex_pc;
reg [31:0] idex_rs1_data;
reg [31:0] idex_rs2_data;
reg [31:0] idex_immediate;

reg [4:0] idex_rs1;
reg [4:0] idex_rs2;
reg [4:0] idex_rd;

reg idex_regwrite;
reg idex_memread;
reg idex_memwrite;
reg idex_memtoreg;
reg idex_alusrc;
reg idex_branch;
reg idex_branch_ne;

reg [3:0] idex_alu_control;

// =====================================================
// 11. HAZARD DETECTION
// =====================================================

wire id_uses_rs1;
wire id_uses_rs2;

assign id_uses_rs1 =
    (id_opcode == 7'b0110011) ||
    (id_opcode == 7'b0010011) ||
    (id_opcode == 7'b0000011) ||
    (id_opcode == 7'b0100011) ||
    (id_opcode == 7'b1100011);

assign id_uses_rs2 =
    (id_opcode == 7'b0110011) ||
    (id_opcode == 7'b0100011) ||
    (id_opcode == 7'b1100011);

assign stall =
    idex_valid &&
    idex_memread &&
    (idex_rd != 0) &&
    (
        (id_uses_rs1 && id_rs1 == idex_rd) ||
        (id_uses_rs2 && id_rs2 == idex_rd)
    );

// =====================================================
// 12. EX STAGE: DATA FORWARDING
// =====================================================

reg [31:0] ex_operand_a;
wire [31:0] ex_operand_b;
reg [31:0] ex_forwarded_b;

wire [31:0] wb_write_data;

// EX/MEM and MEM/WB registers are declared below.

reg exmem_valid;

reg [31:0] exmem_alu_result;
reg [31:0] exmem_write_data;

reg [4:0] exmem_rd;

reg exmem_regwrite;
reg exmem_memread;
reg exmem_memwrite;
reg exmem_memtoreg;

reg memwb_valid;

reg [31:0] memwb_memory_data;
reg [31:0] memwb_alu_result;

reg [4:0] memwb_rd;

reg memwb_regwrite;
reg memwb_memtoreg;

// Correct forwarding priority:
// MEM/WB first, then EX/MEM overrides it.

always @(*) begin

    ex_operand_a = idex_rs1_data;
    ex_forwarded_b = idex_rs2_data;

    // Forward from MEM/WB
    if (memwb_valid &&
        memwb_regwrite &&
        memwb_rd != 0 &&
        memwb_rd == idex_rs1)
        ex_operand_a = wb_write_data;

    if (memwb_valid &&
        memwb_regwrite &&
        memwb_rd != 0 &&
        memwb_rd == idex_rs2)
        ex_forwarded_b = wb_write_data;

    // Forward from EX/MEM: higher priority
    if (exmem_valid &&
        exmem_regwrite &&
        !exmem_memread &&
        exmem_rd != 0 &&
        exmem_rd == idex_rs1)
        ex_operand_a = exmem_alu_result;

    if (exmem_valid &&
        exmem_regwrite &&
        !exmem_memread &&
        exmem_rd != 0 &&
        exmem_rd == idex_rs2)
        ex_forwarded_b = exmem_alu_result;

end

assign ex_operand_b =
    idex_alusrc ? idex_immediate : ex_forwarded_b;

// =====================================================
// 13. ALU
// =====================================================

reg [31:0] ex_alu_result;

always @(*) begin

    case (idex_alu_control)

        4'b0000: ex_alu_result =
            ex_operand_a + ex_operand_b;

        4'b0001: ex_alu_result =
            ex_operand_a - ex_operand_b;

        4'b0010: ex_alu_result =
            ex_operand_a & ex_operand_b;

        4'b0011: ex_alu_result =
            ex_operand_a | ex_operand_b;

        4'b0100: ex_alu_result =
            ex_operand_a ^ ex_operand_b;

        4'b0101: ex_alu_result =
            ex_operand_a << ex_operand_b[4:0];

        4'b0110: ex_alu_result =
            ex_operand_a >> ex_operand_b[4:0];

        4'b0111: ex_alu_result =
            ($signed(ex_operand_a) < $signed(ex_operand_b))
            ? 32'd1 : 32'd0;

        default: ex_alu_result = 0;

    endcase

end

wire ex_zero;

assign ex_zero =
    (ex_operand_a == ex_forwarded_b);

// =====================================================
// 14. BRANCH CONTROL
// =====================================================

wire [31:0] ex_branch_target;

assign ex_branch_target =
    idex_pc + idex_immediate;

assign branch_taken =
    idex_valid &&
    idex_branch &&
    (idex_branch_ne ? !ex_zero : ex_zero);

// =====================================================
// 15. MEM / WB DATA PATH
// =====================================================

wire [31:0] mem_read_data;

assign mem_read_data =
    (exmem_memread &&
     exmem_alu_result[31:8] == 0 &&
     exmem_alu_result[1:0] == 0)
    ? dmem[exmem_alu_result[7:2]]
    : 32'b0;

assign wb_write_data =
    memwb_memtoreg
    ? memwb_memory_data
    : memwb_alu_result;

// =====================================================
// 16. MAIN PIPELINE SEQUENTIAL LOGIC
// =====================================================

always @(posedge clk) begin

    if (reset) begin

        // PC
        pc <= 0;

        // IF/ID
        ifid_pc <= 0;
        ifid_instruction <= 32'h00000013;
        ifid_valid <= 0;

        // ID/EX
        idex_valid <= 0;

        idex_pc <= 0;
        idex_rs1_data <= 0;
        idex_rs2_data <= 0;
        idex_immediate <= 0;

        idex_rs1 <= 0;
        idex_rs2 <= 0;
        idex_rd <= 0;

        idex_regwrite <= 0;
        idex_memread <= 0;
        idex_memwrite <= 0;
        idex_memtoreg <= 0;
        idex_alusrc <= 0;
        idex_branch <= 0;
        idex_branch_ne <= 0;
        idex_alu_control <= 0;

        // EX/MEM
        exmem_valid <= 0;

        exmem_alu_result <= 0;
        exmem_write_data <= 0;
        exmem_rd <= 0;

        exmem_regwrite <= 0;
        exmem_memread <= 0;
        exmem_memwrite <= 0;
        exmem_memtoreg <= 0;

        // MEM/WB
        memwb_valid <= 0;

        memwb_memory_data <= 0;
        memwb_alu_result <= 0;
        memwb_rd <= 0;

        memwb_regwrite <= 0;
        memwb_memtoreg <= 0;

        // Register file
        for (j = 0; j < 32; j = j + 1)
            regfile[j] <= 0;

    end

    else begin

        // ---------------------------------------------
        // WRITEBACK STAGE
        // ---------------------------------------------

        if (memwb_valid &&
            memwb_regwrite &&
            memwb_rd != 0)
            regfile[memwb_rd] <= wb_write_data;

        regfile[0] <= 0;

        // ---------------------------------------------
        // MEMORY WRITE
        // ---------------------------------------------

        if (exmem_valid &&
            exmem_memwrite &&
            exmem_alu_result[31:8] == 0 &&
            exmem_alu_result[1:0] == 0)
            dmem[exmem_alu_result[7:2]]
                <= exmem_write_data;

        // ---------------------------------------------
        // MEM/WB REGISTER
        // ---------------------------------------------

        memwb_valid <= exmem_valid;

        memwb_memory_data <= mem_read_data;
        memwb_alu_result <= exmem_alu_result;

        memwb_rd <= exmem_rd;

        memwb_regwrite <= exmem_regwrite;
        memwb_memtoreg <= exmem_memtoreg;

        // ---------------------------------------------
        // EX/MEM REGISTER
        // ---------------------------------------------

        exmem_valid <= idex_valid;

        exmem_alu_result <= ex_alu_result;
        exmem_write_data <= ex_forwarded_b;

        exmem_rd <= idex_rd;

        exmem_regwrite <= idex_regwrite;
        exmem_memread <= idex_memread;
        exmem_memwrite <= idex_memwrite;
        exmem_memtoreg <= idex_memtoreg;

        // ---------------------------------------------
        // PC AND IF/ID
        // ---------------------------------------------

        if (branch_taken) begin

            pc <= ex_branch_target;

            ifid_pc <= 0;
            ifid_instruction <= 32'h00000013;
            ifid_valid <= 0;

        end

        else if (!stall) begin

            pc <= pc + 4;

            ifid_pc <= pc;

            ifid_instruction <=
                (pc[31:8] == 0)
                ? imem[pc[7:2]]
                : 32'h00000013;

            ifid_valid <= 1;

        end

        // ---------------------------------------------
        // ID/EX
        // ---------------------------------------------

        if (branch_taken || stall) begin

            idex_valid <= 0;

            idex_regwrite <= 0;
            idex_memread <= 0;
            idex_memwrite <= 0;
            idex_memtoreg <= 0;
            idex_alusrc <= 0;
            idex_branch <= 0;
            idex_branch_ne <= 0;

            idex_alu_control <= 0;

        end

        else begin

            idex_valid <= ifid_valid;

            idex_pc <= ifid_pc;

            idex_rs1_data <= id_read_data1;
            idex_rs2_data <= id_read_data2;

            idex_immediate <= id_immediate;

            idex_rs1 <= id_rs1;
            idex_rs2 <= id_rs2;
            idex_rd <= id_rd;

            idex_regwrite <= id_regwrite;
            idex_memread <= id_memread;
            idex_memwrite <= id_memwrite;
            idex_memtoreg <= id_memtoreg;
            idex_alusrc <= id_alusrc;
            idex_branch <= id_branch;
            idex_branch_ne <= id_branch_ne;

            idex_alu_control <= id_alu_control;

        end

    end

end

endmodule
