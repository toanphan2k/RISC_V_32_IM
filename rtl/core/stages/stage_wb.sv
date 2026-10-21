//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-09-28
// Design Name:
// Module Name: stage_wb
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: SystemVerilog implementation of the stage_wb module.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

import rv32im_pkg::*;

module stage_wb(
    input  ctrl_signal_t                wb_ctrl,
    input  logic [XLEN-1:0]             wb_alu_result,
    input  logic [XLEN-1:0]             wb_m_unit_result,
    input  logic [XLEN-1:0]             dmem_rdata,
    input  logic [XLEN-1:0]             wb_pc4,
    input  logic [REG_ADDR_WIDTH-1:0]   wb_rd_addr,
    // write signal travel back to ID stage
    output logic                        wb_en_reg_write,
    output logic [REG_ADDR_WIDTH-1:0]   wb_out_rd_addr,
    output logic [XLEN-1:0]             wb_data
);

    logic [1:0] byte_offset;
    logic [7:0] loaded_byte;
    logic [15:0] loaded_half;
    logic [31:0] wb_load_data;

    assign wb_en_reg_write = wb_ctrl.en_reg_write;
    assign byte_offset = wb_alu_result[1:0];
    assign wb_out_rd_addr = wb_rd_addr;

    always_comb begin : LOADED_BYTE_DATA
        case (byte_offset)
            2'b00:      loaded_byte = dmem_rdata[7:0];
            2'b01:      loaded_byte = dmem_rdata[15:8];
            2'b10:      loaded_byte = dmem_rdata[23:16];
            default:    loaded_byte = dmem_rdata[31:24];
        endcase

        loaded_half = byte_offset[1] ? dmem_rdata[31:16] : dmem_rdata[15:0];
        case (wb_ctrl.funct3)
            LD_LB:      wb_load_data = {{24{loaded_byte[7]}}, loaded_byte};
            LD_LH:      wb_load_data = {{16{loaded_half[15]}}, loaded_half};
            LD_LBU:     wb_load_data = {24'b0, loaded_byte};
            LD_LHU:     wb_load_data = {16'b0, loaded_half};
            default:    wb_load_data = dmem_rdata;
        endcase
    end

    always_comb begin : WB_SRC_SELECT
        case (wb_ctrl.wb_src_sel)
            WB_SRC_ALU:     wb_data = wb_alu_result;
            WB_SRC_MEM:     wb_data = wb_load_data;
            WB_SRC_PC_4:    wb_data = wb_pc4;
            WB_SRC_M_EXT:   wb_data = wb_m_unit_result;
            default:        wb_data = wb_alu_result;
        endcase
    end

endmodule
