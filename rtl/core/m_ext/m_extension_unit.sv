import rv32im_pkg::*;

module m_extesion_unit(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic [XLEN-1] operand_a,
    input logic [XLEN-1] operand_b,
    output logic [XLEN-1] m_result,
    output logic is_busy,
    output logic done
);

endmodule
