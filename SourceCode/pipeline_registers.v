
module if_id_register (

    input clk,
    input reset,

    input [31:0] pc_in,
    input [31:0] instruction_in,

    output reg [31:0] pc_out,
    output reg [31:0] instruction_out

);

always @(posedge clk) begin

    if (reset) begin
        pc_out <= 0;
        instruction_out <= 0;
    end

    else begin
        pc_out <= pc_in;
        instruction_out <= instruction_in;
    end

end

endmodule


// ======================================
// ID / EX PIPELINE REGISTER
// ======================================

module id_ex_register (

    input clk,
    input reset,

    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input alu_src_in,
    input branch_in,
    input branch_ne_in,

    input [3:0] alu_control_in,

    input [31:0] pc_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [31:0] immediate_in,

    input [4:0] rd_in,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg alu_src_out,
    output reg branch_out,
    output reg branch_ne_out,

    output reg [3:0] alu_control_out,

    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] immediate_out,

    output reg [4:0] rd_out

);

always @(posedge clk) begin

    if (reset) begin

        reg_write_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        mem_to_reg_out <= 0;
        alu_src_out <= 0;
        branch_out <= 0;
        branch_ne_out <= 0;

        alu_control_out <= 0;

        pc_out <= 0;
        rs1_data_out <= 0;
        rs2_data_out <= 0;
        immediate_out <= 0;

        rd_out <= 0;

    end

    else begin

        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        alu_src_out <= alu_src_in;
        branch_out <= branch_in;
        branch_ne_out <= branch_ne_in;

        alu_control_out <= alu_control_in;

        pc_out <= pc_in;
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        immediate_out <= immediate_in;

        rd_out <= rd_in;

    end

end

endmodule


// ======================================
// EX / MEM PIPELINE REGISTER
// ======================================

module ex_mem_register (

    input clk,
    input reset,

    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input branch_in,
    input branch_ne_in,

    input [31:0] branch_target_in,
    input [31:0] alu_result_in,
    input [31:0] write_data_in,

    input zero_in,

    input [4:0] rd_in,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg branch_out,
    output reg branch_ne_out,

    output reg [31:0] branch_target_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,

    output reg zero_out,

    output reg [4:0] rd_out

);

always @(posedge clk) begin

    if (reset) begin

        reg_write_out <= 0;
        mem_read_out <= 0;
        mem_write_out <= 0;
        mem_to_reg_out <= 0;
        branch_out <= 0;
        branch_ne_out <= 0;

        branch_target_out <= 0;
        alu_result_out <= 0;
        write_data_out <= 0;

        zero_out <= 0;
        rd_out <= 0;

    end

    else begin

        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        branch_out <= branch_in;
        branch_ne_out <= branch_ne_in;

        branch_target_out <= branch_target_in;
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;

        zero_out <= zero_in;
        rd_out <= rd_in;

    end

end

endmodule


// ======================================
// MEM / WB PIPELINE REGISTER
// ======================================

module mem_wb_register (

    input clk,
    input reset,

    input reg_write_in,
    input mem_to_reg_in,

    input [31:0] memory_data_in,
    input [31:0] alu_result_in,

    input [4:0] rd_in,

    output reg reg_write_out,
    output reg mem_to_reg_out,

    output reg [31:0] memory_data_out,
    output reg [31:0] alu_result_out,

    output reg [4:0] rd_out

);

always @(posedge clk) begin

    if (reset) begin

        reg_write_out <= 0;
        mem_to_reg_out <= 0;

        memory_data_out <= 0;
        alu_result_out <= 0;

        rd_out <= 0;

    end

    else begin

        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;

        memory_data_out <= memory_data_in;
        alu_result_out <= alu_result_in;

        rd_out <= rd_in;

    end

end

endmodule
