
module control_unit (

    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,
    output reg branch,
    output reg branch_ne,

    output reg [3:0] alu_control

);

always @(*) begin

    // Default control signals
    reg_write  = 0;
    mem_read   = 0;
    mem_write  = 0;
    mem_to_reg = 0;
    alu_src    = 0;
    branch     = 0;
    branch_ne  = 0;
    alu_control = 4'b0000;

    case (opcode)

        // R-Type Instructions
        7'b0110011: begin
            reg_write = 1;

            case (funct3)

                3'b000: begin
                    if (funct7 == 7'b0100000)
                        alu_control = 4'b0001; // SUB
                    else
                        alu_control = 4'b0000; // ADD
                end

                3'b111: alu_control = 4'b0010; // AND
                3'b110: alu_control = 4'b0011; // OR
                3'b100: alu_control = 4'b0100; // XOR
                3'b001: alu_control = 4'b0101; // SLL
                3'b101: alu_control = 4'b0110; // SRL
                3'b010: alu_control = 4'b0111; // SLT

                default: reg_write = 0;

            endcase
        end

        // ADDI
        7'b0010011: begin
            if (funct3 == 3'b000) begin
                reg_write = 1;
                alu_src = 1;
                alu_control = 4'b0000;
            end
        end

        // LW
        7'b0000011: begin
            if (funct3 == 3'b010) begin
                reg_write = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_src = 1;
                alu_control = 4'b0000;
            end
        end

        // SW
        7'b0100011: begin
            if (funct3 == 3'b010) begin
                mem_write = 1;
                alu_src = 1;
                alu_control = 4'b0000;
            end
        end

        // Branch Instructions
        7'b1100011: begin
            if (funct3 == 3'b000) begin
                branch = 1; // BEQ
                alu_control = 4'b0001;
            end
            else if (funct3 == 3'b001) begin
                branch = 1; // BNE
                branch_ne = 1;
                alu_control = 4'b0001;
            end
        end

        default: begin
            // All signals remain zero
        end

    endcase

end

endmodule
