// BLOCK RAM
module single_port_ram #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 5
)
(
    input  logic clk,
    input  logic en_write,

    input  logic [ADDR_WIDTH-1:0] waddr,
    input  logic [ADDR_WIDTH-1:0] raddr,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic [DATA_WIDTH-1:0] rdata
);
    // DEPTH = 1 << ADDR_WIDTH; DEPTH = 2^ADDR_WIDTH; DEPTH = 32
    // 32 Storage location
    localparam int DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] ram [0:DEPTH-1];

    // Synchronous Read/Write
    always_ff @(posedge clk) begin : SYNC_READ_WRITE_RAM
        rdata <= ram[raddr];
        if (en_write) begin
            ram[waddr] <= wdata;
        end
    end

endmodule
