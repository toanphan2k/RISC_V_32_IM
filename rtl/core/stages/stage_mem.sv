import rv32im_pkg::*;

module stage_mem(
    // input from EX/MEM register
    input  ctrl_signal_t                mem_ctrl,
    input  logic [XLEN-1:0]             mem_alu_result,
    input  logic [XLEN-1:0]             mem_m_unit_result,
    input  logic [XLEN-1:0]             mem_rs2_data,
    input  logic [XLEN-1:0]             mem_pc4,
    input  logic [REG_ADDR_WIDTH-1:0]   mem_rd_addr,
    // Data memory Bus inteface
    output logic [XLEN-1:0]             dmem_addr,
    output logic [XLEN-1:0]             dmem_wdata,
    output logic [3:0]                  dmem_wstrobe,
    output logic                        dmem_req, // Request RW data memory
    output logic                        en_dmem_write,
    // output to MEM/WB register
    output ctrl_signal_t                wb_out_ctrl,
    output logic [XLEN-1:0]             wb_out_alu_result,
    output logic [XLEN-1:0]             wb_out_m_unit_result,
    output logic [XLEN-1:0]             wb_out_pc4,
    output logic [REG_ADDR_WIDTH-1:0]   wb_out_rd_addr,
    //Forwarding data to EX STAGE
    output logic [XLEN-1:0]             mem_fwd_data
);

    logic [1:0] byte_offset;
    assign byte_offset = mem_alu_result[1:0];

    // Data memory request && adddress
    assign dmem_req = mem_ctrl.en_mem_read || mem_ctrl.en_mem_write; // Request RW data memory
    assign dmem_addr = {mem_alu_result[31:2],2'b00};
    assign en_dmem_write = mem_ctrl.en_mem_write;

    always_comb begin : DMEM_STORE_FORMAT
        dmem_wdata = 32'h0;
        dmem_wstrobe = WSTRB_NONE;
        if (mem_ctrl.en_mem_write) begin
            case(mem_ctrl.funct3)
                ST_SB: begin : STORE_LAST_BYTE
                    case (byte_offset)
                        2'b00: begin
                            dmem_wdata = {24'b0, mem_rs2_data[7:0]};
                            dmem_wstrobe = WSTRB_BYTE_0;
                        end
                        2'b01: begin
                            dmem_wdata = {16'b0, mem_rs2_data[7:0], 8'b0};
                            dmem_wstrobe = WSTRB_BYTE_1;
                        end
                        2'b10: begin
                            dmem_wdata = {8'b0, mem_rs2_data[7:0], 16'b0};
                            dmem_wstrobe = WSTRB_BYTE_2;
                        end
                        2'b11: begin
                            dmem_wdata = {mem_rs2_data[7:0], 24'b0};
                            dmem_wstrobe = WSTRB_BYTE_3;
                        end
                    endcase
                end
                ST_SH: begin : STORE_HALF_BYTE
                    case (byte_offset[1])
                        1'b0: begin
                            dmem_wdata = {16'b0, mem_rs2_data[15:0]};
                            dmem_wstrobe = WSTRB_HALF_LOW;
                        end
                        1'b1: begin
                            dmem_wdata = {mem_rs2_data[15:0], 16'b0};
                            dmem_wstrobe = WSTRB_HALF_HIGH;
                        end
                    endcase
                end
                ST_SW: begin : STORE_FULL_WORD
                    dmem_wdata = mem_rs2_data;
                    dmem_wstrobe = WSTRB_FULL_WORD;
                end
                default: ;
            endcase
        end
    end

    // Passthrough signal to MEM/WB register
    assign wb_out_ctrl          = mem_ctrl;
    assign wb_out_alu_result    = mem_alu_result;
    assign wb_out_m_unit_result = mem_m_unit_result;
    assign wb_out_pc4           = mem_pc4;
    assign wb_out_rd_addr       = mem_rd_addr;

    // Forwarding Data (ALU, M-EXT, PC4)
    // Load data is collected in in WB, because of sync dmem
    // Fisrt clk request, second clk return data
    always_comb begin : FWB_DATA_BLOCk
        case (mem_ctrl.wb_src_sel)
            WB_SRC_ALU:     mem_fwd_data = mem_alu_result;
            WB_SRC_PC_4:    mem_fwd_data = mem_pc4;
            WB_SRC_M_EXT:   mem_fwd_data = mem_m_unit_result;
            default:        mem_fwd_data = mem_alu_result;
        endcase
    end

endmodule
