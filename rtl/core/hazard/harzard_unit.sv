//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-15
// Design Name:
// Module Name: harzard_unit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: SystemVerilog implementation of the harzard_unit module.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

import rv32im_pkg::*;

module harzard_unit (
    // ID stage REGs
    input  logic [REG_ADDR_WIDTH-1:0]   id_rs1_addr,
    input  logic [REG_ADDR_WIDTH-1:0]   id_rs2_addr,
    // EX stage REGs
    input  logic [REG_ADDR_WIDTH-1:0]   ex_rd_addr,
    input  logic                        branch_taken,
    input  logic                        m_busy,
    input  ctrl_signal_t                ex_ctrl, id_ctrl,
    // Output
    output logic                        if_pc_en,
    output logic                        stall_if_id,
    output logic                        stall_id_ex,
    output logic                        stall_ex_mem,
    output logic                        stall_mem_wb,
    output logic                        flush_if_id,
    output logic                        flush_id_ex,
    output logic                        flush_ex_mem,
    output logic                        flush_mem_wb


);
logic load_use_hazard;

    // Detect load-use hazard
    // A load-use hazard occurs when an instruction in the EX stage is a load instruction (ex_ctrl.en_mem_read is true)
    // and the instruction in the ID stage is trying to use the result of that load instruction (id_ctrl.uses_rs1 or id_ctrl.uses_rs2 is true)
    assign load_use_hazard = (ex_ctrl.en_mem_read
                            && (ex_rd_addr != '0)
                            && (( id_ctrl.uses_rs1 && (ex_rd_addr == id_rs1_addr)) || (id_ctrl.uses_rs2 && (ex_rd_addr == id_rs2_addr)))
                            );

    always_comb begin
        // Default values
        if_pc_en       = 1'b1;
        stall_if_id    = 1'b0;
        stall_id_ex    = 1'b0;
        stall_ex_mem   = 1'b0;
        stall_mem_wb   = 1'b0;
        flush_if_id    = 1'b0;
        flush_id_ex    = 1'b0;
        flush_ex_mem   = 1'b0;
        flush_mem_wb   = 1'b0;

        if (m_busy) begin
            // DIV Stall
            if_pc_en       = 1'b0;
            stall_if_id    = 1'b1;
            stall_id_ex    = 1'b1;
            flush_ex_mem   = 1'b1;
        end else if (branch_taken) begin
            // Branch taken, flush IF/ID and ID/EX
            flush_if_id    = 1'b1;
            flush_id_ex    = 1'b1;
        end else if (load_use_hazard) begin
            // Load-use hazard detected, stall IF/ID and ID/EX
            if_pc_en       = 1'b0;
            stall_if_id    = 1'b1;
            flush_id_ex    = 1'b1;
        end
    end

endmodule