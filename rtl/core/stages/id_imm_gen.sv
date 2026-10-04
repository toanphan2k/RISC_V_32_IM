import rv32im_pkg::*;

module id_imm_gen (
    input  logic [XLEN-1:0] instr,
    output logic [XLEN-1:0] imm
);
    always_comb begin: IMMEDIATE_GENERATOR
        case(instr[6:0])
            // I-type instructions: OP_IMM, OP_LOAD, OP_JALR
            OP_IMM:     imm = {{20{instr[31]}}, instr[31:20]};
            OP_LOAD:    imm = {{20{instr[31]}}, instr[31:20]};
            OP_JALR:    imm = {{20{instr[31]}}, instr[31:20]};
            // S-type instructions: OP_STORE
            OP_STORE:   imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // B-type instructions: OP_BRANCH
            OP_BRANCH:  imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            // U-type instructions: OP_LUI, OP_AUIPC
            OP_LUI:     imm = {instr[31:12], 12'b0};
            OP_AUIPC:   imm = {instr[31:12], 12'b0};
            // J-type instructions: OP_JAL
            OP_JAL:     imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            // Default case: if the opcode does not match any known type, set immediate to zero
            default:    imm = 32'b0;
        endcase
    end
endmodule
