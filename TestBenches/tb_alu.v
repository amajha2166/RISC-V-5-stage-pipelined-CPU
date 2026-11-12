
module tb_alu;

reg [31:0] a, b;
reg [3:0] alu_control;
wire [31:0] result;
wire zero;

alu uut (
    .a(a),
    .b(b),
    .alu_control(alu_control),
    .result(result),
    .zero(zero)
);

initial begin

    a = 10; b = 20;
    alu_control = 4'b0000;
    #10;

    a = 20; b = 10;
    alu_control = 4'b0001;
    #10;

    a = 10; b = 20;
    alu_control = 4'b0010;
    #10;

    a = 10; b = 20;
    alu_control = 4'b0011;
    #10;
    
    a = 10; b = 20;
    alu_control = 4'b0101;
    #10;

    $finish;
end

endmodule
