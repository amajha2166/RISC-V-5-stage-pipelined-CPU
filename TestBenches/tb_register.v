
module tb_register;

reg clk;
reg reg_write;

reg [4:0] read_reg1;
reg [4:0] read_reg2;
reg [4:0] write_reg;

reg [31:0] write_data;

wire [31:0] read_data1;
wire [31:0] read_data2;

// Register file instance
register_file uut (
    .clk(clk),
    .reg_write(reg_write),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    reg_write = 0;
    read_reg1 = 0;
    read_reg2 = 0;
    write_reg = 0;
    write_data = 0;

    #10;

    // Write 10 into x1
    reg_write = 1;
    write_reg = 1;
    write_data = 10;
    #10;

    // Write 20 into x2
    write_reg = 2;
    write_data = 20;
    #10;

    // Disable writing
    reg_write = 0;

    // Read x1 and x2
    read_reg1 = 1;
    read_reg2 = 2;
    #5;

    $display("x1 = %d", read_data1);
    $display("x2 = %d", read_data2);

    // Test x0
    read_reg1 = 0;
    #5;

    $display("x0 = %d", read_data1);

    // Test x3 (initially zero)
    read_reg1 = 3;
    #5;

    $display("x3 = %d", read_data1);

    $finish;

end

endmodule
