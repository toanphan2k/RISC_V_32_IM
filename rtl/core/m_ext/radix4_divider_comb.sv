
import rv32im_pkg::*;

module radix4_divider_comb (
    input  logic [XLEN-1:0] operand_a,
    input  logic [XLEN-1:0] operand_b,
    input  m_ext_opcode_e   m_opcode,
    output logic [XLEN-1:0] div_result
);

    // --------------------------------------------------
    // 1. Internal signals
    // --------------------------------------------------
    logic [XLEN-1:0] dividend_abs;
    logic [XLEN-1:0] divisor_abs;

    logic [XLEN-1:0] quotient_unsigned;
    logic [XLEN-1:0] remainder_unsigned;

    logic [XLEN-1:0] quotient_signed;
    logic [XLEN-1:0] remainder_signed;

    logic signed_mode;
    logic dividend_negative;
    logic divisor_negative;

    logic div_by_zero;
    logic overflow;

    // --------------------------------------------------
    // 2. Decode operation
    // --------------------------------------------------
    always_comb begin : DECODE_DIV_OPERATION
        signed_mode = 1'b0;

        case (m_opcode)
            M_DIV, M_REM:
                signed_mode = 1'b1;

            M_DIVU, M_REMU:
                signed_mode = 1'b0;

            default:
                signed_mode = 1'b0;
        endcase
    end

    assign div_by_zero = (operand_b == '0);

    assign overflow =
        (operand_a == {1'b1, {(XLEN-1){1'b0}}}) &&
        (operand_b == {XLEN{1'b1}});

    // --------------------------------------------------
    // 3. Convert signed operands to unsigned magnitudes
    // --------------------------------------------------
    always_comb begin : ABS_OPERANDS
        dividend_negative = 1'b0;
        divisor_negative  = 1'b0;

        dividend_abs = operand_a;
        divisor_abs  = operand_b;

        if (signed_mode) begin
            dividend_negative = operand_a[XLEN-1];
            divisor_negative  = operand_b[XLEN-1];

            if (dividend_negative)
                dividend_abs = (~operand_a) + 1'b1;

            if (divisor_negative)
                divisor_abs = (~operand_b) + 1'b1;
        end
    end

    // --------------------------------------------------
    // 4. Radix-4 restoring divider
    //    No / or % operators are used
    // --------------------------------------------------
    radix4_divider_comb u_radix4_divider (
        .dividend  (dividend_abs),
        .divisor   (divisor_abs),
        .quotient  (quotient_unsigned),
        .remainder (remainder_unsigned)
    );

    // --------------------------------------------------
    // 5. Restore signs
    // --------------------------------------------------
    always_comb begin : RESTORE_RESULT_SIGN

        // Quotient sign = sign(A) XOR sign(B)
        if (dividend_negative ^ divisor_negative)
            quotient_signed = (~quotient_unsigned) + 1'b1;
        else
            quotient_signed = quotient_unsigned;

        // Remainder sign follows dividend (operand_a)
        if (dividend_negative)
            remainder_signed = (~remainder_unsigned) + 1'b1;
        else
            remainder_signed = remainder_unsigned;
    end

    // --------------------------------------------------
    // 6. Select final result according to RISC-V opcode
    // --------------------------------------------------
    always_comb begin : DIV_RESULT_CALCULATION

        if (div_by_zero) begin
            case (m_opcode)
                M_DIV, M_DIVU:
                    div_result = {XLEN{1'b1}};

                M_REM, M_REMU:
                    div_result = operand_a;

                default:
                    div_result = '0;
            endcase
        end
        else if (overflow &&
                 ((m_opcode == M_DIV) || (m_opcode == M_REM))) begin

            case (m_opcode)
                M_DIV:
                    div_result = {1'b1, {(XLEN-1){1'b0}}};

                M_REM:
                    div_result = '0;

                default:
                    div_result = '0;
            endcase
        end
        else begin
            case (m_opcode)
                M_DIV:
                    div_result = quotient_signed;

                M_DIVU:
                    div_result = quotient_unsigned;

                M_REM:
                    div_result = remainder_signed;

                M_REMU:
                    div_result = remainder_unsigned;

                default:
                    div_result = '0;
            endcase
        end
    end

endmodule
