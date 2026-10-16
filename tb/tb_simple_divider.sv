`timescale 1ns/1ps

import rv32im_pkg::*;

module tb_simple_divider;
    logic [XLEN-1:0] operand_a;
    logic [XLEN-1:0] operand_b;
    m_ext_opcode_e  m_opcode;
    logic [XLEN-1:0] div_result;
    integer tests_run;
    integer passed;
    integer failed;

    simple_divider dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .m_opcode(m_opcode),
        .div_result(div_result)
    );

    task automatic check_case(
        input logic [XLEN-1:0] a,
        input logic [XLEN-1:0] b,
        input m_ext_opcode_e op,
        input logic [XLEN-1:0] expected,
        input string label
    );
        begin
            operand_a = a;
            operand_b = b;
            m_opcode = op;
            #1;

            tests_run = tests_run + 1;
            if (div_result !== expected) begin
                failed = failed + 1;
                $display("[FAIL] %s op=%b a=%h b=%h got=%h expected=%h",
                       label, op, a, b, div_result, expected);
            end else begin
                passed = passed + 1;
                $display("[PASS] %s", label);
            end
        end
    endtask

    initial begin
        tests_run = 0;
        passed = 0;
        failed = 0;
        operand_a = '0;
        operand_b = '0;
        m_opcode = M_DIV;

        $display("Starting simple divider tests");

        check_case(32'd20, 32'd3, M_DIV, 32'd6, "signed division");
        check_case(32'hFFFF_FFEC, 32'd3, M_DIV, 32'hFFFF_FFFA,
                   "negative dividend division");
        check_case(32'd20, 32'hFFFF_FFFD, M_DIV, 32'hFFFF_FFFA,
                   "negative divisor division");
        check_case(32'hFFFF_FFFF, 32'd2, M_DIVU, 32'h7FFF_FFFF,
                   "unsigned division");
        check_case(32'h8000_0000, 32'hFFFF_FFFF, M_DIV, 32'h8000_0000,
                   "signed division overflow");
        check_case(32'h8000_0000, 32'hFFFF_FFFF, M_REM, 32'h0000_0000,
                   "signed remainder overflow");
        check_case(32'hFFFF_FFEC, 32'd3, M_REM, 32'hFFFF_FFFE,
                   "negative dividend remainder");
        check_case(32'd20, 32'hFFFF_FFFD, M_REM, 32'd2,
                   "negative divisor remainder");
        check_case(32'hFFFF_FFFF, 32'd2, M_REMU, 32'd1,
                   "unsigned remainder");
        check_case(32'h8765_4321, 32'd0, M_DIV, 32'hFFFF_FFFF,
                   "signed divide by zero");
        check_case(32'h8765_4321, 32'd0, M_DIVU, 32'hFFFF_FFFF,
                   "unsigned divide by zero");
        check_case(32'h8765_4321, 32'd0, M_REM, 32'h8765_4321,
                   "signed remainder by zero");
        check_case(32'h8765_4321, 32'd0, M_REMU, 32'h8765_4321,
                   "unsigned remainder by zero");
        check_case(32'd0, 32'd7, M_DIV, 32'd0, "zero dividend");

        $display("===== simple_divider SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d",
                 tests_run, passed, failed);
        if (failed == 0) $display("RESULT: ALL TESTS PASSED");
        else             $display("RESULT: TESTS FAILED");
        $display("==================================");
        if (failed != 0) $fatal(1, "simple_divider: %0d test(s) failed", failed);
        $finish;
    end
endmodule
