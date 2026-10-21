//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-13
// Design Name:
// Module Name: instruction_rom
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: SystemVerilog implementation of the instruction_rom module.
//
// Dependencies:
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

// Read-only Memory
// For instruction memory
module instruction_rom #(
    parameter int   DATA_WIDTH = 32,
    parameter int   ADDR_WIDTH = 12,
    parameter       HEX_FILE = ""
)
(
    input  logic clk,
    input  logic en_read,
    input  logic [ADDR_WIDTH-1:0] raddr,
    output logic [DATA_WIDTH-1:0] rdata
);
    // DEPTH = 1 << ADDR_WIDTH; DEPTH = 2^ADDR_WIDTH; DEPTH = 4096
    // 4096 Storage location
    localparam int DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    initial begin
        if (HEX_FILE != "") $readmemh(HEX_FILE, rom);
    end

    // Synchronous Read
    always_ff @(posedge clk) begin : SYNC_ROM
        if (en_read) rdata <= rom[raddr];
    end

endmodule
