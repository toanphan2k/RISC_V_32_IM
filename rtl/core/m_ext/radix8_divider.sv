import rv32im_pkg::*;

module radix8_divider(
    input logic clk,
    input logic rst_n,
    input logic start
    input logic [XLEN-1] operand_a,
    input logic [XLEN-1] operand_b,
    input m_ext_opcode_e m_opcode,
    output logic [XLEN-1] div_result,
    output logic is_busy,
    output logic done
);

endmodule
