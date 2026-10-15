import rv32im_pkg::*;

module alu_rv32 (
    input  logic [XLEN-1:0] operand_a,
    input  logic [XLEN-1:0] operand_b,
    input  alu_opcode_e     opcode,
    output logic [XLEN-1:0] result,
    output logic            zero_flag,
    output logic            less_than_flag,
    output logic            less_than_unsigned_flag
);

    logic [XLEN-1:0] adder_result;
    logic            is_less_than;
    logic            is_less_than_u;
    logic            en_sub;
    logic            adder_cout;
    logic            adder_overflow;

    assign en_sub = (opcode == ALU_SUB) ||
                    (opcode == ALU_SLT) ||
                    (opcode == ALU_SLTU);
    //------------------------------------------------------
    // Start of Carry Look Ahead Adder (CLA) implementation
    //------------------------------------------------------

    cla_32bit cla_32bit_u(
        .a(operand_a),
        .b(operand_b),
        .sub_en(en_sub),
        .result(adder_result),
        .cout(adder_cout),
        .overflow(adder_overflow),
        .zero(),
        .negative()
    );

    //------------------------------------------------------
    // End of Carry Look Ahead Adder (CLA) implementation
    //------------------------------------------------------

    assign is_less_than   = adder_result[XLEN-1] ^ adder_overflow;
    assign is_less_than_u = ~adder_cout;

    always_comb begin
        case (opcode)
            ALU_ADD:  result = adder_result;
            ALU_SUB:  result = adder_result;
            ALU_AND:  result = operand_a & operand_b;
            ALU_OR:   result = operand_a | operand_b;
            ALU_XOR:  result = operand_a ^ operand_b;
            ALU_SLL:  result = operand_a << operand_b[4:0];
            ALU_SRL:  result = operand_a >> operand_b[4:0];
            ALU_SRA:  result = $signed(operand_a) >>> operand_b[4:0];
            ALU_SLT:  result = {{(XLEN-1){1'b0}}, is_less_than};
            ALU_SLTU: result = {{(XLEN-1){1'b0}}, is_less_than_u};
            default:  result = '0; // Default case to handle unexpected opcodes
        endcase
    end

    // FLAGS FOR BRANCH INSTRUCTION
    // BR_BEQ, BR_BNE use zero_flag
    // BR_BLT, BR_BGE use less_than_flag
    // BR_BLTU, BR_BGEU use less_than_unsigned_flag
    assign zero_flag               = (result == '0);
    assign less_than_flag          = (opcode == ALU_SLT || opcode == ALU_SUB) && is_less_than;
    assign less_than_unsigned_flag = (opcode == ALU_SLTU || opcode == ALU_SUB) && is_less_than_u;

endmodule
