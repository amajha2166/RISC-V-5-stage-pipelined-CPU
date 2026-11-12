
module tb_data_memory;

reg clk;
reg mem_read;
reg mem_write;

reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

// Instantiate memory
data_memory uut (

    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)

);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    mem_read = 0;
    mem_write = 0;
    address = 0;
    write_data = 0;

    #10;

    // STORE 100 at address 0
    address = 0;
    write_data = 100;
    mem_write = 1;
    #10;

    // STORE 200 at address 4
    address = 4;
    write_data = 200;
    #10;

    // Disable writing
    mem_write = 0;

    // LOAD from address 0
    address = 0;
    mem_read = 1;
    #5;

    $display("Memory[0] = %d", read_data);

    // LOAD from address 4
    address = 4;
    #5;

    $display("Memory[4] = %d", read_data);

    // Test invalid/uninitialized location
    address = 8;
    #5;

    $display("Memory[8] = %d", read_data);

    $finish;

end

endmodule
