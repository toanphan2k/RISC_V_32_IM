import rv32im_pkg::*;

module simple_multiplier(
    // multiplier using DSP resources
    input  logic [XLEN-1:0] operand_a,
    input  logic [XLEN-1:0] operand_b,
    input  m_ext_opcode_e m_opcode,
    output logic [XLEN-1:0] mul_result
);

    logic signed [(XLEN*2)-1:0] prod_66;
    logic signed [XLEN:0] a_ext;
    logic signed [XLEN:0] b_ext;

    always_comb begin : SLICING_OPERAND
        case (m_opcode)
            // MUL signed a x signed b
            M_MUL, M_MULH: begin
                    a_ext = {operand_a[31], operand_a};
                    b_ext = {operand_b[31], operand_b};
                end
            // MUL signed a x unsigned b
            M_MULHSU: begin
                    a_ext = {operand_a[31], operand_a};
                    b_ext = {1'b0, operand_b};
                end
            // MUL unsigned a x unsigned b
            M_MULHU: begin
                    a_ext = {1'b0, operand_a};
                    b_ext = {1'b0, operand_b};
                end
            default: begin
                    a_ext = '0;
                    b_ext = '0;
                end
        endcase
    end

    assign prod_66 = a_ext * b_ext;

    always_comb begin : MUL_RESULT_SELECTION
        case (m_opcode)
            M_MUL:                      mul_result = prod_66[31:0];
            M_MULH, M_MULHSU, M_MULHU : mul_result = prod_66[63:32];
            default:                    mul_result = '0;
        endcase
    end

endmodule
