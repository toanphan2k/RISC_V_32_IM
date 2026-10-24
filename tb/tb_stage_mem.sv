//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Copilot
//
// Create Date: 2026-10-22
// Design Name:
// Module Name: tb_stage_mem
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for stage_mem.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import rv32im_pkg::*;

module tb_stage_mem;
    ctrl_signal_t mem_ctrl;
    logic [XLEN-1:0] mem_alu_result;
    logic [XLEN-1:0] mem_m_unit_result;
    logic [XLEN-1:0] mem_rs2_data;
    logic [XLEN-1:0] mem_pc4;
    logic [REG_ADDR_WIDTH-1:0] mem_rd_addr;

    logic [XLEN-1:0] dmem_addr;
    logic [XLEN-1:0] dmem_wdata;
    logic [3:0] dmem_wstrobe;
    logic dmem_req;
    logic en_dmem_write;
    ctrl_signal_t mem_out_ctrl;
    logic [XLEN-1:0] mem_out_alu_result;
    logic [XLEN-1:0] mem_out_m_unit_result;
    logic [XLEN-1:0] mem_out_pc4;
    logic [REG_ADDR_WIDTH-1:0] mem_out_rd_addr;
    logic [XLEN-1:0] mem_fwd_data;

    int tests = 0;
    int passed = 0;
    int failed = 0;

    stage_mem dut (
        .mem_ctrl          (mem_ctrl),
        .mem_alu_result    (mem_alu_result),
        .mem_m_unit_result (mem_m_unit_result),
        .mem_rs2_data      (mem_rs2_data),
        .mem_pc4           (mem_pc4),
        .mem_rd_addr       (mem_rd_addr),
        .dmem_addr         (dmem_addr),
        .dmem_wdata        (dmem_wdata),
        .dmem_wstrobe      (dmem_wstrobe),
        .dmem_req          (dmem_req),
        .en_dmem_write     (en_dmem_write),
        .mem_out_ctrl      (mem_out_ctrl),
        .mem_out_alu_result(mem_out_alu_result),
        .mem_out_m_unit_result(mem_out_m_unit_result),
        .mem_out_pc4        (mem_out_pc4),
        .mem_out_rd_addr    (mem_out_rd_addr),
        .mem_fwd_data       (mem_fwd_data)
    );

    task automatic check_case(
        input string name,
        input ctrl_signal_t ctrl,
        input logic [XLEN-1:0] alu_result,
        input logic [XLEN-1:0] m_result,
        input logic [XLEN-1:0] rs2_data,
        input logic [XLEN-1:0] pc4,
        input logic [REG_ADDR_WIDTH-1:0] rd,
        input logic [XLEN-1:0] expected_addr,
        input logic [XLEN-1:0] expected_wdata,
        input logic [3:0] expected_wstrobe,
        input logic expected_req,
        input logic expected_write,
        input logic [XLEN-1:0] expected_forward
    );
        logic ok;
        begin
            mem_ctrl = ctrl;
            mem_alu_result = alu_result;
            mem_m_unit_result = m_result;
            mem_rs2_data = rs2_data;
            mem_pc4 = pc4;
            mem_rd_addr = rd;
            #1;

            tests++;
            ok = (dmem_addr === expected_addr) &&
                 (dmem_wdata === expected_wdata) &&
                 (dmem_wstrobe === expected_wstrobe) &&
                 (dmem_req === expected_req) &&
                 (en_dmem_write === expected_write) &&
                 (mem_out_ctrl === ctrl) &&
                 (mem_out_alu_result === alu_result) &&
                 (mem_out_m_unit_result === m_result) &&
                 (mem_out_pc4 === pc4) &&
                 (mem_out_rd_addr === rd) &&
                 (mem_fwd_data === expected_forward);
            if (ok) begin
                passed++;
                $display("[PASS] %s", name);
            end else begin
                failed++;
                $display("[FAIL] %s", name);
                $display("       addr=%h expected=%h wdata=%h expected=%h",
                         dmem_addr, expected_addr, dmem_wdata, expected_wdata);
                $display("       strobe=%b expected=%b req=%b expected=%b write=%b expected=%b",
                         dmem_wstrobe, expected_wstrobe, dmem_req, expected_req,
                         en_dmem_write, expected_write);
                $display("       forward=%h expected=%h ctrl_match=%b alu_match=%b m_match=%b pc4_match=%b rd_match=%b",
                         mem_fwd_data, expected_forward, mem_out_ctrl === ctrl,
                         mem_out_alu_result === alu_result,
                         mem_out_m_unit_result === m_result,
                         mem_out_pc4 === pc4, mem_out_rd_addr === rd);
            end
        end
    endtask

    task automatic set_idle_ctrl;
        begin
            mem_ctrl = '0;
            mem_ctrl.wb_src_sel = WB_SRC_ALU;
            mem_ctrl.funct3 = ST_SW;
        end
    endtask

    initial begin
        set_idle_ctrl();
        mem_alu_result = '0;
        mem_m_unit_result = '0;
        mem_rs2_data = '0;
        mem_pc4 = '0;
        mem_rd_addr = '0;
        $display("===== stage_mem testbench start =====");

        set_idle_ctrl();
        check_case("idle has no memory request and forwards ALU",
                   mem_ctrl, 32'h1003, 32'hAABB_CCDD, 32'h1234_5678,
                   32'h2004, 5'd3, 32'h1000, 32'd0, WSTRB_NONE,
                   0, 0, 32'h1003);

        set_idle_ctrl();
        mem_ctrl.en_mem_read = 1'b1;
        mem_ctrl.en_reg_write = 1'b1;
        mem_ctrl.wb_src_sel = WB_SRC_MEM;
        check_case("load request aligns address and disables write",
                   mem_ctrl, 32'h1002, 32'h1234_5678, 32'hDEAD_BEEF,
                   32'h3004, 5'd7, 32'h1000, 32'd0, WSTRB_NONE,
                   1, 0, 32'h1002);

        for (int offset = 0; offset < 4; offset++) begin
            set_idle_ctrl();
            mem_ctrl.en_mem_write = 1'b1;
            mem_ctrl.funct3 = ST_SB;
            case (offset)
                0: check_case("SB byte lane 0", mem_ctrl, 32'h2000 + offset,
                              32'h0, 32'hA1B2_C3D4, 32'h10, 5'd1, 32'h2000,
                              32'h0000_00D4, WSTRB_BYTE_0, 1, 1, 32'h2000 + offset);
                1: check_case("SB byte lane 1", mem_ctrl, 32'h2000 + offset,
                              32'h0, 32'hA1B2_C3D4, 32'h10, 5'd1, 32'h2000,
                              32'h0000_D400, WSTRB_BYTE_1, 1, 1, 32'h2000 + offset);
                2: check_case("SB byte lane 2", mem_ctrl, 32'h2000 + offset,
                              32'h0, 32'hA1B2_C3D4, 32'h10, 5'd1, 32'h2000,
                              32'h00D4_0000, WSTRB_BYTE_2, 1, 1, 32'h2000 + offset);
                3: check_case("SB byte lane 3", mem_ctrl, 32'h2000 + offset,
                              32'h0, 32'hA1B2_C3D4, 32'h10, 5'd1, 32'h2000,
                              32'hD400_0000, WSTRB_BYTE_3, 1, 1, 32'h2000 + offset);
            endcase
        end

        set_idle_ctrl();
        mem_ctrl.en_mem_write = 1'b1;
        mem_ctrl.funct3 = ST_SH;
        check_case("SH lower halfword lane", mem_ctrl, 32'h3000, 32'h0,
                   32'hA1B2_C3D4, 32'h20, 5'd2, 32'h3000, 32'h0000_C3D4,
                   WSTRB_HALF_LOW, 1, 1, 32'h3000);
        check_case("SH upper halfword lane", mem_ctrl, 32'h3002, 32'h0,
                   32'hA1B2_C3D4, 32'h20, 5'd2, 32'h3000, 32'hC3D4_0000,
                   WSTRB_HALF_HIGH, 1, 1, 32'h3002);

        set_idle_ctrl();
        mem_ctrl.en_mem_write = 1'b1;
        mem_ctrl.funct3 = ST_SW;
        check_case("SW writes full word", mem_ctrl, 32'h4000, 32'h0,
                   32'hCAFE_BABE, 32'h30, 5'd3, 32'h4000, 32'hCAFE_BABE,
                   WSTRB_FULL_WORD, 1, 1, 32'h4000);

        set_idle_ctrl();
        mem_ctrl.en_mem_write = 1'b1;
        mem_ctrl.funct3 = 3'b011;
        check_case("unsupported store funct3 has no byte lanes",
                   mem_ctrl, 32'h5000, 32'h0, 32'h1234_5678, 32'h40,
                   5'd4, 32'h5000, 32'd0, WSTRB_NONE, 1, 1, 32'h5000);

        set_idle_ctrl();
        mem_ctrl.wb_src_sel = WB_SRC_PC_4;
        check_case("PC+4 selected for memory forwarding", mem_ctrl,
                   32'h6000, 32'h0, 32'h1, 32'h6004, 5'd5, 32'h6000,
                   32'd0, WSTRB_NONE, 0, 0, 32'h6004);

        set_idle_ctrl();
        mem_ctrl.wb_src_sel = WB_SRC_M_EXT;
        check_case("M-extension result selected for forwarding", mem_ctrl,
                   32'h7000, 32'hFACE_CAFE, 32'h1, 32'h7004, 5'd6,
                   32'h7000, 32'd0, WSTRB_NONE, 0, 0, 32'hFACE_CAFE);

        set_idle_ctrl();
        mem_ctrl.wb_src_sel = WB_SRC_MEM;
        check_case("load source defaults to ALU forwarding path",
                   mem_ctrl, 32'h8000, 32'h0, 32'h1, 32'h8004, 5'd7,
                   32'h8000, 32'd0, WSTRB_NONE, 0, 0, 32'h8000);

        $display("===== stage_mem SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d",
                 tests, passed, failed);
        if (failed == 0) $display("RESULT: ALL TESTS PASSED");
        else             $display("RESULT: TESTS FAILED");
        $display("=============================");
        if (failed != 0) $fatal(1, "stage_mem: %0d test(s) failed", failed);
        $finish;
    end
endmodule
