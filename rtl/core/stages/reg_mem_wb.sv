import rv32im_pkg::*;

module reg_mem_wb (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    stall,
    input  logic                    flush,
    // Inputs from MEM stage
    input  control_signal_t         mem_ctrl,
    input  logic [XLEN-1:0]         mem_alu_result,
    input  logic [XLEN-1:0]         mem_m_unit_result,
    input  logic [XLEN-1:0]         mem_pc4;
    input  logic [REG_ADDR_WIDTH-1:0]    mem_rd_addr;


    // Outputs to WB stage
    output control_signal_t         wb_ctrl,
    output logic [XLEN-1:0]         wb_alu_result,
    output logic [XLEN-1:0]         wb_m_unit_result,
    output logic [XLEN-1:0]         wb_pc4;
    output logic [REG_ADDR_WIDTH-1:0]    wb_rd_addr;
);

    control_signal_t nop_ctrl;
    assign nop_ctrl = '0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_ctrl             <= nop_ctrl;
            wb_alu_result       <= 32'b0;
            wb_m_unit_result    <= 32'b0;
            wb_pc4              <= 32'b0;
            wb_rd_addr          <= 5'b0;
        end else if (flush) begin
            wb_ctrl             <= nop_ctrl;
            wb_alu_result       <= 32'b0;
            wb_m_unit_result    <= 32'b0;
            wb_pc4              <= 32'b0;
            wb_rd_addr          <= 5'b0;
        end else if (!stall) begin
            wb_ctrl             <= mem_ctrl;
            wb_alu_result       <= mem_alu_result;
            wb_m_unit_result    <= mem_m_unit_result;
            wb_pc4              <= mem_pc4;
            wb_rd_addr          <= mem_rd_addr;
        end
    end

endmodule