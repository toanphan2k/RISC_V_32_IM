import rv32im_pkg::*;

module alu_rv32 (
    input logic [31:0] operand_a,
    input logic [31:0] operand_b,
    input alu_opcode_e opcode,
    output logic [31:0] result,
    output logic zero_flag,
    output logic less_than_flag,
    output logic less_than_unsigned_flag
);

    always_comb begin
        case (opcode)
            ALU_ADD: result = operand_a + operand_b;
            ALU_SUB: result = operand_a - operand_b;
            ALU_AND: result = operand_a & operand_b;
            ALU_OR:  result = operand_a | operand_b;
            ALU_XOR: result = operand_a ^ operand_b;
            ALU_SLL: result = operand_a << operand_b[4:0];
            ALU_SRL: result = operand_a >> operand_b[4:0];
            ALU_SRA: result = $signed(operand_a) >>> operand_b[4:0];
            ALU_SLT: result = ($signed(operand_a) < $signed(operand_b)) ? 32'b1 : 32'b0;
            ALU_SLTU: result = (operand_a < operand_b) ? 32'b1 : 32'b0;
            default: result = 32'b0; // Default case to handle unexpected opcodes
        endcase

        zero_flag = (result == 32'b0);
        less_than_flag = ($signed(operand_a) < $signed(operand_b));
        less_than_unsigned_flag = (operand_a < operand_b);
    end

endmodule