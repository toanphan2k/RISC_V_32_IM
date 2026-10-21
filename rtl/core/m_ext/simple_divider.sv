import rv32im_pkg::*;

module simple_divider(
    // divider using DSP resources
    input  logic [XLEN-1:0] operand_a,
    input  logic [XLEN-1:0] operand_b,
    input  m_ext_opcode_e   m_opcode,
    output logic [XLEN-1:0] div_result
);
    logic overflow;
    logic div_by_zero;

    assign div_by_zero = (operand_b == '0);
    assign overflow = (operand_a == 32'h8000_0000) && (operand_b == 32'hFFFF_FFFF);

    always_comb begin : DIV_RESULT_CALCULATION
        if (div_by_zero) begin
            case(m_opcode)
                M_REM, M_REMU:  div_result = operand_a;
                M_DIV, M_DIVU:  div_result = 32'hFFFF_FFFF;
                default:        div_result = 32'hFFFF_FFFF;
            endcase
        end else if (overflow && ((m_opcode == M_DIV) || (m_opcode == M_REM))) begin
            case (m_opcode)
                M_DIV:      div_result = 32'h8000_0000;
                M_REM:      div_result = 32'h0000_0000;
                default:    div_result = '0;
            endcase
        end else begin
            case (m_opcode)
                M_DIV:      div_result = $signed(operand_a) / $signed(operand_b);
                M_DIVU:     div_result = operand_a / operand_b;
                M_REM:      div_result = $signed(operand_a) % $signed(operand_b);
                M_REMU:     div_result = operand_a % operand_b;
                default:    div_result = '0;
            endcase
        end
    end

endmodule
