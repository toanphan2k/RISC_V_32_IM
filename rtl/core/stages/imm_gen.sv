import rv32im_pkg::*;

module imm_gen (
    input  logic [XLEN-1:0] id_pc,
    input  logic [XLEN-1:0] id_instr,
    output logic [XLEN-1:0] id_imm
);
    always_comb begin: IMMEDIATE_GENERATOR
        case(id_instr[6:0]):
            OP_IMM:     id_imm = {{20{id_instr[31]}}, id_instr[31], id_instr[31:20]};
            OP_STORE:   id_imm = {{20{id_instr[31]}}, id_instr[31:25], id_instr[11:7]};
            OP_BRANCH:  id_imm = {{20{id_instr[31]}}, id_instr[7], id_instr[30:25], id_instr[11:8], 1'b0};
            OP_LUI:     id_imm = {id_instr[31:12], 12'b0};
            OP_AUIPC:   id_imm = {id_instr[31:12], 12'b0};
            OP_JAL:     id_imm = {{12{id_instr[31]}}, id_instr[19:12], id_instr[20], id_instr[30:21], 1'b0};
            default:    id_imm = 32'b0;
        endcase
    end

endmodule
