// Read-only Memory
// For instruction memory
module instruction_rom #(
    parameter int   DATA_WIDTH = 32,
    parameter int   ADDR_WIDTH = 5,
    parameter       HEX_FILE = "program.hex"
)
(
    input  logic clk,
    input  logic [ADDR_WIDTH-1:0] raddr,
    output logic [DATA_WIDTH-1:0] rdata
);
    // DEPTH = 1 << ADDR_WIDTH; DEPTH = 2^ADDR_WIDTH; DEPTH = 32
    // 32 Storage location
    localparam int DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    initial begin
        $readmemh(HEX_FILE, rom);
    end

    // Synchronous Read
    always_ff @(posedge clk) begin : SYNC_ROM
        rdata <= rom[raddr];
    end

endmodule
