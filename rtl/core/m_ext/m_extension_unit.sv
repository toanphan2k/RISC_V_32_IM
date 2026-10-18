import rv32im_pkg::*;

module m_extesion_unit(
    input  logic            clk,
    input  logic            rst_n,
    input  logic            start,
    input  m_ext_opcode_e   m_opcode,
    input  logic [XLEN-1:0] operand_a,
    input  logic [XLEN-1:0] operand_b,
    output logic [XLEN-1:0] m_result,
    output logic            is_busy,
    output logic            done
);

    logic is_mul;
    logic is_div;

    logic div_start;
    logic div_done;

    logic [XLEN-1:0] mul_result;
    logic [XLEN-1:0] div_result;

    assign is_mul = (m_opcode == M_MUL) ||
                    (m_opcode == M_MULH) ||
                    (m_opcode == M_MULHSU) ||
                    (m_opcode == M_MULHU);
    assign is_div = (m_opcode == M_DIV) ||
                    (m_opcode == M_DIVU) ||
                    (m_opcode == M_REM) ||
                    (m_opcode == M_REMU);

    //-----------------------------------------------
    // BEGIN CODE BLOCK FOR SIMPLE M UNITS USING DSP
    //-----------------------------------------------
    simple_multiplier simple_multiplier_u(
        .operand_a(operand_a),
        .operand_b(operand_b),
        .m_opcode(m_opcode),
        .mul_result(mul_result)
    );

    simple_divider simple_divider_u(
        .operand_a(operand_a),
        .operand_b(operand_b),
        .m_opcode(m_opcode),
        .div_result(div_result)
    );
    // temp logic since simple divider is combinational logic
    // and do not have have start and odne
    assign div_start    = 1'b0;
    assign div_done     = 1'b1;
    //-----------------------------------------------
    // ENDs CODE BLOCK FOR SIMPLE M UNITS USING DSP
    //-----------------------------------------------


    //-----------------------------------------------
    // BEGIN CODE BLOCK FOR OHER ALGORITHMS
    //-----------------------------------------------


    //-----------------------------------------------
    // END CODE BLOCK FOR OHER ALGORITHMS
    //-----------------------------------------------


    // General Pipeline signals
    assign is_busy  = div_start && !div_done;
    assign done     = is_mul ? 1'b1 : div_done;
    assign m_result = is_div ? div_result : mul_result;

endmodule
