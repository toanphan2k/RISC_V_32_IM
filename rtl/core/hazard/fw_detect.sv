import rv32im_pkg::*;

module fw_detect (
    input logic        i_mem_rd_wren, i_wb_rd_wren,
    input logic  [4:0] i_rs1_addr, i_rs2_addr, i_mem_rd_addr, i_wb_rd_addr, 

    output fwd_sel_e   o_fw_a, o_fw_b    
);
    assign o_fw_a =           (i_mem_rd_wren & (i_mem_rd_addr !=0) 
							& (i_mem_rd_addr == i_rs1_addr)) ? FWD_WB 
                            : (i_wb_rd_wren & (i_wb_rd_addr != 0) 
							& (i_wb_rd_addr == i_rs1_addr)) ? FWD_MEM : FWD_NONE;

    assign o_fw_b =           (i_mem_rd_wren & (i_mem_rd_addr !=0) 
							& (i_mem_rd_addr == i_rs2_addr)) ? FWD_WB 
                            : (i_wb_rd_wren & (i_wb_rd_addr != 0) 
							& (i_wb_rd_addr == i_rs2_addr)) ? FWD_MEM : FWD_NONE; 
endmodule