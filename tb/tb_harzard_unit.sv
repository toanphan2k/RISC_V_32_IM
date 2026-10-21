//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-16
// Design Name:
// Module Name: tb_harzard_unit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for harzard_unit.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
import rv32im_pkg::*;

module tb_harzard_unit;
    logic [REG_ADDR_WIDTH-1:0] id_rs1_addr, id_rs2_addr, ex_rd_addr;
    logic                     branch_taken, m_busy;
    ctrl_signal_t             ex_ctrl, id_ctrl;
    logic                     if_pc_en, stall_if_id, stall_id_ex;
    logic                     stall_ex_mem, stall_mem_wb;
    logic                     flush_if_id, flush_id_ex, flush_ex_mem, flush_mem_wb;

    logic [8:0] actual_controls;
    int tests = 0;
    int errors = 0;

    assign actual_controls = {
        if_pc_en, stall_if_id, stall_id_ex, stall_ex_mem, stall_mem_wb,
        flush_if_id, flush_id_ex, flush_ex_mem, flush_mem_wb
    };

    harzard_unit dut (
        .id_rs1_addr   (id_rs1_addr),
        .id_rs2_addr   (id_rs2_addr),
        .ex_rd_addr    (ex_rd_addr),
        .branch_taken  (branch_taken),
        .m_busy        (m_busy),
        .ex_ctrl       (ex_ctrl),
        .id_ctrl       (id_ctrl),
        .if_pc_en      (if_pc_en),
        .stall_if_id   (stall_if_id),
        .stall_id_ex   (stall_id_ex),
        .stall_ex_mem  (stall_ex_mem),
        .stall_mem_wb  (stall_mem_wb),
        .flush_if_id   (flush_if_id),
        .flush_id_ex   (flush_id_ex),
        .flush_ex_mem  (flush_ex_mem),
        .flush_mem_wb  (flush_mem_wb)
    );

    task automatic check_case(
        input string name,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [4:0] ex_rd,
        input logic       branch,
        input logic       busy,
        input logic       mem_read,
        input logic       uses_rs1,
        input logic       uses_rs2,
        input logic [8:0] expected_controls
    );
        begin
            id_rs1_addr    = rs1;
            id_rs2_addr    = rs2;
            ex_rd_addr     = ex_rd;
            branch_taken   = branch;
            m_busy         = busy;
            ex_ctrl        = '0;
            id_ctrl        = '0;
            ex_ctrl.en_mem_read = mem_read;
            id_ctrl.uses_rs1 = uses_rs1;
            id_ctrl.uses_rs2 = uses_rs2;
            #10;
            tests++;
            if (actual_controls !== expected_controls) begin
                errors++;
                $display("[FAIL] [%0t] %-42s expected controls=%b; got controls=%b",
                         $time, name, expected_controls, actual_controls);
            end else begin
                $display("[PASS] [%0t] %s", $time, name);
            end
        end
    endtask

    initial begin
        $display("===== harzard_unit testbench start =====");

        // Control order: PC enable, IF/ID stall, ID/EX stall, EX/MEM stall,
        // MEM/WB stall, then IF/ID, ID/EX, EX/MEM, and MEM/WB flushes.
        check_case("T01: no hazard", 5'd1, 5'd2, 5'd3, 0, 0, 1, 1, 1, 9'b100000000);
        check_case("T02: used rs1 has load-use dependency", 5'd5, 5'd7, 5'd5, 0, 0, 1, 1, 0, 9'b010000100);
        check_case("T03: used rs2 has load-use dependency", 5'd5, 5'd7, 5'd7, 0, 0, 1, 0, 1, 9'b010000100);
        check_case("T04: both used sources depend on load", 5'd6, 5'd6, 5'd6, 0, 0, 1, 1, 1, 9'b010000100);
        check_case("T05: matching unused rs1 does not hazard", 5'd8, 5'd2, 5'd8, 0, 0, 1, 0, 0, 9'b100000000);
        check_case("T06: matching unused rs2 does not hazard", 5'd1, 5'd9, 5'd9, 0, 0, 1, 0, 0, 9'b100000000);
        check_case("T07: unused matching rs1, used rs2 differs", 5'd10, 5'd2, 5'd10, 0, 0, 1, 0, 1, 9'b100000000);
        check_case("T08: unused matching rs2, used rs1 differs", 5'd1, 5'd11, 5'd11, 0, 0, 1, 1, 0, 9'b100000000);
        check_case("T09: x0 destination does not hazard", 5'd0, 5'd2, 5'd0, 0, 0, 1, 1, 1, 9'b100000000);
        check_case("T10: matching used rs1 without a load", 5'd9, 5'd2, 5'd9, 0, 0, 0, 1, 0, 9'b100000000);
        check_case("T11: matching used rs2 without a load", 5'd1, 5'd10, 5'd10, 0, 0, 0, 0, 1, 9'b100000000);
        check_case("T12: load destination matches neither source", 5'd1, 5'd2, 5'd3, 0, 0, 1, 1, 1, 9'b100000000);
        check_case("T13: branch flushes IF/ID and ID/EX", 5'd1, 5'd2, 5'd3, 1, 0, 0, 0, 0, 9'b100001100);
        check_case("T14: busy M unit stalls and flushes EX/MEM", 5'd1, 5'd2, 5'd3, 0, 1, 0, 0, 0, 9'b011000010);
        check_case("T15: busy M unit takes priority over branch", 5'd1, 5'd2, 5'd3, 1, 1, 0, 0, 0, 9'b011000010);
        check_case("T16: busy M unit takes priority over load-use", 5'd11, 5'd2, 5'd11, 0, 1, 1, 1, 0, 9'b011000010);
        check_case("T17: branch takes priority over load-use", 5'd12, 5'd2, 5'd12, 1, 0, 1, 1, 0, 9'b100001100);
        check_case("T18: x31 load-use dependency", 5'd31, 5'd1, 5'd31, 0, 0, 1, 1, 0, 9'b010000100);
        check_case("T19: x31 without dependency", 5'd1, 5'd2, 5'd31, 0, 0, 1, 1, 1, 9'b100000000);
        check_case("T20: no-source instruction has matching encoded fields", 5'd13, 5'd13, 5'd13, 0, 0, 1, 0, 0, 9'b100000000);

        $display("===== harzard_unit SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d",
                 tests, tests - errors, errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("RESULT: TESTS FAILED");
        $display("================================");
        if (errors != 0) $fatal(1, "harzard_unit: %0d test(s) failed", errors);
        $finish;
    end
endmodule
