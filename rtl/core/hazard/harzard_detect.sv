// import rv32im_pkg::*;

module harzard_detect (
    // Input
    input logic [4:0] i_id_rs1, i_id_rs2, i_id_rd,
    input logic [4:0] i_ex_rd,
    input logic       i_ex_read,
    // Output
    output logic      o_if_pc_en,
    output logic      o_stall_if_id
);
/******************************************  Execute after Read *******************************************************/
    always_comb begin
        if (((i_ex_rd == i_id_rs1 && i_ex_rd != 5'd0) || (i_ex_rd == i_id_rs2 && i_ex_rd != 5'd0)) && i_ex_read) begin
            o_if_pc_en = 1'b0;
            o_stall_if_id = 1'b0;
        end else begin
            o_if_pc_en = 1'b1;
            o_stall_if_id = 1'b1;
        end
    end

endmodule