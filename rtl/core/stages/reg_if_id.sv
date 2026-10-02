import rv32im_pkg::*;

module reg_if_id (
    input  logic                clk,
    input  logic                rst_n,
    input  logic                stall,
    input  logic                flush,
    // Inputs from IF stage
    input  logic [XLEN-1:0]     if_instruction,
    input  logic [XLEN-1:0]     if_pc4,
    input  logic [XLEN-1:0]     if_pc,
    // Outputs to ID stage
    output logic [XLEN-1:0]     id_instruction,
    output logic [XLEN-1:0]     id_pc4,
    output logic [XLEN-1:0]     id_pc,
);
    localparam logic [XLEN-1:0] NOP_INSTR = 32'h0000_0013;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_instruction  <= NOP_INSTR;
            id_pc4          <= 32'b0;
            id_pc           <= 32'b0;
        end else if (flush) begin
            id_instruction  <= NOP_INSTR;
            id_pc4          <= 32'b0;
            id_pc           <= 32'b0;
        end else if (!stall) begin
            id_instruction  <= if_instruction;
            id_pc4          <= if_pc4;
            id_pc           <= if_pc;
        end
    end

endmodule