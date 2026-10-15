import rv32im_pkg::*;

module forward_unit (
    input logic         mem_rd_wren, wb_rd_wren,
    input logic         [REG_ADDR_WIDTH-1:0] ex_rs1_addr,
    input logic         [REG_ADDR_WIDTH-1:0] ex_rs2_addr,
    input logic         [REG_ADDR_WIDTH-1:0] mem_rd_addr,
    input logic         [REG_ADDR_WIDTH-1:0] wb_rd_addr,
    output fwd_sel_e    fwd_a,
    output fwd_sel_e    fwd_b
);
    // Forwading for RS1
    always_comb begin : FORWARDING_RS1
        if(mem_rd_wren && (mem_rd_addr != 5'd0) && (mem_rd_addr == ex_rs1_addr)) begin
            fwd_a = FWD_MEM;
        end else if (wb_rd_wren && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs1_addr)) begin
            fwd_a = FWD_WB;
        end else begin
            fwd_a = FWD_NONE;
        end
    end

    // Forwading for RS2
    always_comb begin : FORWARDING_RS2
        if(mem_rd_wren && (mem_rd_addr != 5'd0) && (mem_rd_addr == ex_rs2_addr)) begin
            fwd_b = FWD_MEM;
        end else if (wb_rd_wren && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs2_addr)) begin
            fwd_b = FWD_WB;
        end else begin
            fwd_b = FWD_NONE;
        end
    end

endmodule
