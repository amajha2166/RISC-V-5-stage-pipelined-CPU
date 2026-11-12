
module data_memory (

    input clk,
    input mem_read,
    input mem_write,

    input [31:0] address,
    input [31:0] write_data,

    output reg [31:0] read_data

);

reg [31:0] memory [0:63];

integer i;

// Initialize memory
initial begin
    for (i = 0; i < 64; i = i + 1)
        memory[i] = 32'b0;
end

// Store data on rising clock edge
always @(posedge clk) begin

    if (mem_write &&
        address[31:8] == 0 &&
        address[1:0] == 0) begin

        memory[address[7:2]] <= write_data;

    end

end

// Read data
always @(*) begin

    if (mem_read &&
        address[31:8] == 0 &&
        address[1:0] == 0)

        read_data = memory[address[7:2]];

    else

        read_data = 32'b0;

end

endmodule
