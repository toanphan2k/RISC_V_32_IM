//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Anh Tran
//
// Create Date: 2026-10-14
// Design Name:
// Module Name: tb_radix4_divider_comb
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for radix4_divider_comb.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

import rv32im_pkg::*;

module tb_radix4_divider_comb;

    // --------------------------------------------------
    // DUT signals
    // --------------------------------------------------
    logic [XLEN-1:0] operand_a;
    logic [XLEN-1:0] operand_b;
    m_ext_opcode_e   m_opcode;
    logic [XLEN-1:0] div_result;

    integer pass_count = 0;
    integer fail_count = 0;

    // --------------------------------------------------
    // DUT
    // --------------------------------------------------
    radix4_divider_comb dut (
        .operand_a (operand_a),
        .operand_b (operand_b),
        .m_opcode  (m_opcode),
        .div_result(div_result)
    );

    // --------------------------------------------------
    // Test task
    // Expected value uses / and % in the testbench only.
    // --------------------------------------------------
    task automatic run_test(
        input logic [XLEN-1:0] a,
        input logic [XLEN-1:0] b,
        input m_ext_opcode_e   op
    );
        logic [XLEN-1:0] expected;
        logic signed [XLEN-1:0] signed_a;
        logic signed [XLEN-1:0] signed_b;

        begin
            operand_a = a;
            operand_b = b;
            m_opcode = op;

            signed_a = $signed(a);
            signed_b = $signed(b);

            // Reference model
            if (b == '0) begin
                case (op)
                    M_DIV, M_DIVU:
                        expected = {XLEN{1'b1}};

                    M_REM, M_REMU:
                        expected = a;

                    default:
                        expected = '0;
                endcase
            end
            else if ((a == {1'b1, {(XLEN-1){1'b0}}}) &&
                     (b == {XLEN{1'b1}}) &&
                     ((op == M_DIV) || (op == M_REM))) begin
                case (op)
                    M_DIV: expected =
                        {1'b1, {(XLEN-1){1'b0}}};

                    M_REM: expected = '0;

                    default: expected = '0;
                endcase
            end
            else begin
                case (op)
                    M_DIV:
                        expected = signed_a / signed_b;

                    M_DIVU:
                        expected = a / b;

                    M_REM:
                        expected = signed_a % signed_b;

                    M_REMU:
                        expected = a % b;

                    default:
                        expected = '0;
                endcase
            end

            // Allow combinational logic to settle
            #1;

            if (div_result !== expected) begin
                fail_count++;

                $error(
                    "[FAIL] op=%s A=%h B=%h expected=%h actual=%h",
                    op.name(),
                    a, b, expected, div_result
                );
            end
            else begin
                pass_count++;

                $display(
                    "[PASS] op=%s A=%h B=%h result=%h",
                    op.name(),
                    a, b, div_result
                );
            end
        end
    endtask

    // --------------------------------------------------
    // Test sequence
    // --------------------------------------------------
    initial begin
        $display("========================================");
        $display("  Radix-4 Divider Testbench Start");
        $display("========================================");

        operand_a = '0;
        operand_b = '0;
        m_opcode  = M_DIV;

        // ----------------------------------------------
        // TEST 1: Basic positive operands
        // ----------------------------------------------
        $display("\n--- TEST 1: Basic division ---");

        run_test(32'd10, 32'd3, M_DIV);
        run_test(32'd10, 32'd3, M_DIVU);
        run_test(32'd10, 32'd3, M_REM);
        run_test(32'd10, 32'd3, M_REMU);

        run_test(32'd100, 32'd10, M_DIV);
        run_test(32'd100, 32'd10, M_REM);

        run_test(32'd7, 32'd9, M_DIV);
        run_test(32'd7, 32'd9, M_REM);

        // ----------------------------------------------
        // TEST 2: Signed operands
        // ----------------------------------------------
        $display("\n--- TEST 2: Signed division ---");

        run_test(-32'sd10, 32'd3, M_DIV);
        run_test(-32'sd10, 32'd3, M_REM);

        run_test(32'd10, -32'sd3, M_DIV);
        run_test(32'd10, -32'sd3, M_REM);

        run_test(-32'sd10, -32'sd3, M_DIV);
        run_test(-32'sd10, -32'sd3, M_REM);

        run_test(-32'sd1, 32'd2, M_DIV);
        run_test(-32'sd1, 32'd2, M_REM);

        // ----------------------------------------------
        // TEST 3: Divide by zero
        // ----------------------------------------------
        $display("\n--- TEST 3: Divide by zero ---");

        run_test(32'd100, 32'd0, M_DIV);
        run_test(32'd100, 32'd0, M_DIVU);
        run_test(32'd100, 32'd0, M_REM);
        run_test(32'd100, 32'd0, M_REMU);

        run_test(32'hFFFF_FFFF, 32'd0, M_DIV);
        run_test(32'hFFFF_FFFF, 32'd0, M_REM);

        // ----------------------------------------------
        // TEST 4: Signed overflow
        // INT_MIN / -1
        // ----------------------------------------------
        $display("\n--- TEST 4: Signed overflow ---");

        run_test(32'h8000_0000, 32'hFFFF_FFFF, M_DIV);
        run_test(32'h8000_0000, 32'hFFFF_FFFF, M_REM);

        // Same bit patterns, unsigned operations
        run_test(32'h8000_0000, 32'hFFFF_FFFF, M_DIVU);
        run_test(32'h8000_0000, 32'hFFFF_FFFF, M_REMU);

        // ----------------------------------------------
        // TEST 5: Boundary values
        // ----------------------------------------------
        $display("\n--- TEST 5: Boundary values ---");

        run_test(32'hFFFF_FFFF, 32'd1, M_DIV);
        run_test(32'hFFFF_FFFF, 32'd1, M_DIVU);
        run_test(32'hFFFF_FFFF, 32'd2, M_DIVU);
        run_test(32'hFFFF_FFFF, 32'd2, M_REMU);

        run_test(32'h8000_0000, 32'd1, M_DIV);
        run_test(32'h8000_0000, 32'd1, M_REM);

        run_test(32'h7FFF_FFFF, 32'd2, M_DIV);
        run_test(32'h7FFF_FFFF, 32'd2, M_REM);

        run_test(32'd0, 32'd5, M_DIV);
        run_test(32'd0, 32'd5, M_REM);

        run_test(32'd5, 32'd5, M_DIV);
        run_test(32'd5, 32'd5, M_REM);

        // ----------------------------------------------
        // TEST 6: Radix-4 digit boundary patterns
        // ----------------------------------------------
        $display("\n--- TEST 6: Radix-4 patterns ---");

        run_test(32'h5555_5555, 32'd3, M_DIVU);
        run_test(32'h5555_5555, 32'd3, M_REMU);

        run_test(32'hAAAA_AAAA, 32'd7, M_DIVU);
        run_test(32'hAAAA_AAAA, 32'd7, M_REMU);

        run_test(32'hCCCC_CCCC, 32'h0000_0101, M_DIVU);
        run_test(32'hCCCC_CCCC, 32'h0000_0101, M_REMU);

        run_test(32'hFFFF_FFFF, 32'h4000_0000, M_DIVU);
        run_test(32'hFFFF_FFFF, 32'h4000_0000, M_REMU);

        // ----------------------------------------------
        // TEST 7: Randomized tests
        // ----------------------------------------------
        $display("\n--- TEST 7: Randomized tests ---");

        repeat (500) begin
            logic [XLEN-1:0] random_a;
            logic [XLEN-1:0] random_b;
            logic [1:0] random_op;

            random_a = $urandom;
            random_b = $urandom;
            random_op = $urandom_range(0, 3);

            case (random_op)
                2'd0: run_test(random_a, random_b, M_DIV);
                2'd1: run_test(random_a, random_b, M_DIVU);
                2'd2: run_test(random_a, random_b, M_REM);
                2'd3: run_test(random_a, random_b, M_REMU);
            endcase
        end

        // ----------------------------------------------
        // Final report
        // ----------------------------------------------
        $display("\n========================================");
        $display("  Radix-4 Divider Testbench Summary");
        $display("  PASS : %0d", pass_count);
        $display("  FAIL : %0d", fail_count);
        $display("========================================");

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $error("TESTBENCH FAILED");

        $finish;
    end

endmodule
