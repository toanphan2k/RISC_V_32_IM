import rv32im_pkg::*;

module stage_id (
    input  logic [XLEN-1:0]             id_pc,
    input  logic [XLEN-1:0]             id_pc4,
    input  logic [XLEN-1:0]             id_instr,
    // Writeback port from WB stage
    input  logic                        en_wb_reg_write,
    input  logic [XLEN-1:0]             wb_data,
    input  logic [XLEN-1:0]             wb_rd_addr,
    // Ouput signals to ID/EX Register
    output ctrl_signal_t                id_ctrl,
    output logic [XLEN-1:0]             id_imm,
    output logic [XLEN-1:0]             id_out_pc,
    output logic [XLEN-1:0]             id_out_pc4,
    output logic [XLEN-1:0]             id_rs1_data,
    output logic [XLEN-1:0]             id_rs2_data,
    output logic [REG_ADDR_WIDTH-1:0]   id_rs1_addr,
    output logic [REG_ADDR_WIDTH-1:0]   id_rs2_addr,
    output logic [REG_ADDR_WIDTH-1:0]   id_rd_addr

);
    id_decoder_ctrl id_decoder_ctrl_u(
        .instr(id_instr),
        .ctrl(id_ctrl),
        .rs2_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .rd_addr(id_rd_addr)
    );

    id_imm_gen id_imm_gen_u (
        .instr(id_instr),
        .imm(id_imm)
    );

    id_register_file id_register_file_u (
        .clk(clk),
        .rstn(rstn),
        .raddr1(id_rs1_addr),
        .rdata1(id_rs1_data),
        .raddr2(id_rs2_addr),
        .rdata2(id_rs2_data),
        .en_write(en_wb_reg_write),
        .waddr(wb_rd_addr),
        .wdata(wb_data)
    );

endmodule
