//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-18
// Design Name:
// Module Name: tb_m_extension_unit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for m_extension_unit.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

import rv32im_pkg::*;

module tb_m_extension_unit;
    logic clk;
    logic rst_n;
    logic start;
    m_ext_opcode_e m_opcode;
    logic [XLEN-1:0] operand_a;
    logic [XLEN-1:0] operand_b;
    logic [XLEN-1:0] m_result;
    logic is_busy;
    logic done;

    int tests = 0;
    int passed = 0;
    int failed = 0;

    m_extesion_unit dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .m_opcode  (m_opcode),
        .operand_a (operand_a),
        .operand_b (operand_b),
        .m_result  (m_result),
        .is_busy   (is_busy),
        .done      (done)
    );

    always #5 clk = ~clk;

    task automatic check_case(
        input string name,
        input m_ext_opcode_e op,
        input logic [XLEN-1:0] a,
        input logic [XLEN-1:0] b,
        input logic start_value,
        input logic [XLEN-1:0] expected_result
    );
        begin
            m_opcode  = op;
            operand_a = a;
            operand_b = b;
            start     = start_value;
            #1;

            tests++;
            if ((m_result !== expected_result) ||
                (is_busy !== 1'b0) ||
                (done !== 1'b1)) begin
                failed++;
                $display("[FAIL] %s op=%b a=%h b=%h", name, op, a, b);
                $display("       result got=%h expected=%h | busy=%b expected=0 | done=%b expected=1",
                         m_result, expected_result, is_busy, done);
            end else begin
                passed++;
                $display("[PASS] %s", name);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b1;
        start = 1'b0;
        m_opcode = M_MUL;
        operand_a = '0;
        operand_b = '0;

        $display("===== m_extesion_unit testbench start =====");

        check_case("MUL low product", M_MUL, 32'hFFFF_FFFF, 32'd2,
                   1'b1, 32'hFFFF_FFFE);
        check_case("MULH signed high product", M_MULH,
                   32'h8000_0000, 32'h8000_0000, 1'b1, 32'h4000_0000);
        check_case("MULHSU signed-by-unsigned high product", M_MULHSU,
                   32'h8000_0000, 32'hFFFF_FFFF, 1'b1, 32'h8000_0000);
        check_case("MULHU unsigned high product", M_MULHU,
                   32'h8000_0000, 32'hFFFF_FFFF, 1'b1, 32'h7FFF_FFFF);

        check_case("DIV signed negative dividend", M_DIV,
                   32'hFFFF_FFEC, 32'd3, 1'b1, 32'hFFFF_FFFA);
        check_case("DIVU unsigned quotient", M_DIVU,
                   32'hFFFF_FFFF, 32'd2, 1'b1, 32'h7FFF_FFFF);
        check_case("REM signed negative dividend", M_REM,
                   32'hFFFF_FFEC, 32'd3, 1'b1, 32'hFFFF_FFFE);
        check_case("REMU unsigned remainder", M_REMU,
                   32'hFFFF_FFFF, 32'd2, 1'b1, 32'd1);

        check_case("DIV by zero result", M_DIV,
                   32'h1234_5678, 32'd0, 1'b1, 32'hFFFF_FFFF);
        check_case("REM by zero result", M_REM,
                   32'h1234_5678, 32'd0, 1'b1, 32'h1234_5678);
        check_case("MUL result is combinational when start is low", M_MUL,
                   32'd7, 32'd9, 1'b0, 32'd63);

        $display("===== m_extension_unit SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d",
                 tests, passed, failed);
        if (failed == 0) $display("RESULT: ALL TESTS PASSED");
        else             $display("RESULT: TESTS FAILED");
        $display("====================================");
        if (failed != 0) $fatal(1, "m_extension_unit: %0d test(s) failed", failed);
        $finish;
    end
endmodule
