package rv32im_pkg;

    // RISC-V 32-bit base opcodes, [6:0] of instruction
    typedef enum logic [6:0] {
        OP_LUI      = 7'b0110111,
        OP_AUIPC    = 7'b0010111,
        OP_JAL      = 7'b1101111,
        OP_JALR     = 7'b1100111,
        OP_BRANCH   = 7'b1100011,
        OP_LOAD     = 7'b0000011,
        OP_STORE    = 7'b0100011,
        OP_IMM      = 7'b0010011,
        OP_REG      = 7'b0110011,
        OP_FENCE    = 7'b0001111,  // Zifencei Standard Extension
        OP_SYSTEM   = 7'b1110011   // Zicsr Standard Extension
    } opcode_e;

    // RISC-V 32 branch funct3, [14:12] of instruction
    typedef enum logic [2:0] {
        BR_BEQ      = 3'b000,
        BR_BNE      = 3'b001,
        BR_BLT      = 3'b100,
        BR_BGE      = 3'b101,
        BR_BLTU     = 3'b110,
        BR_BGEU     = 3'b111
    } branch_funct3_e;

    // RISC-V 32 load funct3, [14:12] of instruction
    typedef enum logic [2:0] {
        LD_LB   = 3'b000,
        LD_LH   = 3'b001,
        LD_LW   = 3'b010,
        LD_LBU  = 3'b100,
        LD_LHU  = 3'b101
    } load_funct3_e;

    // RISC-V 32 STORE funct3, [14:12] of instruction
    typedef enum logic [2:0] {
        ST_SB   = 3'b000,
        ST_SH   = 3'b001,
        ST_SW   = 3'b010
    } store_funct3_e;

    // RISC-V 32 M extension funct3, [14:12] of instruction
    // encoding when opcode=OP_REG and funct7=7'b0000001
    typedef enum logic [2:0] {
        M_MUL       = 3'b000,
        M_MULH      = 3'b001,
        M_MULHSU    = 3'b010,
        M_MULHU     = 3'b011,
        M_DIV       = 3'b100,
        M_DIVU      = 3'b101,
        M_REM       = 3'b110,
        M_REMU      = 3'b111
    } m_ext_opcode_e;

    // Self define ALU opcode
    // ALU opcode is 4 bit to switch more than 9 operations
    typedef enum logic [3:0] {
        ALU_ADD     = 4'b0000,
        ALU_SUB     = 4'b0001,
        ALU_SLL     = 4'b0010,
        ALU_SLT     = 4'b0011,
        ALU_SLTU    = 4'b0100,
        ALU_XOR     = 4'b0101,
        ALU_SRL     = 4'b0110,
        ALU_SRA     = 4'b0111,
        ALU_OR      = 4'b1000,
        ALU_AND     = 4'b1001,
        ALU_PASS_B  = 4'b1010
    } alu_opcode_e;

endpackage : rv32im_pkg
