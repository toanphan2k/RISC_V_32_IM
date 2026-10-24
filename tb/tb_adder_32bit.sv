//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Copilot
//
// Create Date: 2026-10-16
// Design Name:
// Module Name: tb_adder_32bit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for adder_32bit.
//
// Dependencies:
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

 module tb_adder_32bit;
    // Testbench signals
    logic [31:0]  a;
    logic [31:0]  b;
    logic         sub_en;
    logic [31:0]  result;
    logic         cout;
    logic         overflow;
    logic         zero;
    logic         negative;
    int tests = 0;
    int passed = 0;
    int failed = 0;

    task automatic record_result(input string label, input logic passed_case);
        begin
            tests++;
            if (passed_case === 1'b1) begin
                passed++;
                $display("[PASS] %s", label);
            end else begin
                failed++;
                $display("[FAIL] %s", label);
            end
        end
    endtask

    // Instantiate CLA module under test
    /*
    cla_32bit dut (
        .a(a),
        .b(b),
        .sub_en(sub_en),
        .result(result),
        .cout(cout),
        .overflow(overflow),
        .zero(zero),
        .negative(negative)
    );
    */
    // END CLA module under test

    // Instantiate Simple Adder module under test
    /*
    simple_32bit_adder dut (
        .a(a),
        .b(b),
        .sub_en(sub_en),
        .result(result),
        .cout(cout),
        .overflow(overflow),
        .zero(zero),
        .negative(negative)
    );
    */
    // END Simple Adder module under test

    // Instantiate RCA module under test
    rca_32bit dut (
        .a(a),
        .b(b),
        .sub_en(sub_en),
        .result(result),
        .cout(cout),
        .overflow(overflow),
        .zero(zero),
        .negative(negative)
    );
    // END RCA module under test

    // Test procedure
    initial begin
        $display("Starting ADDER 32-bit Testbench");
        $display("================================");

        // Test 1: Addition - Simple case (5 + 3 = 8)
        a = 32'd5;
        b = 32'd3;
        sub_en = 1'b0;
        #10;
        $display("Test 1 - ADD: %d + %d = %d (Expected: 8)", a, b, result);
        record_result("Test 1 - simple addition", result === 32'd8);

        // Test 2: Addition - Zero result
        a = 32'd0;
        b = 32'd0;
        sub_en = 1'b0;
        #10;
        $display("Test 2 - ADD: %d + %d = %d (Expected: 0, zero=%b)", a, b, result, zero);
        record_result("Test 2 - addition zero result", result === 32'd0 && zero === 1'b1);

        // Test 3: Subtraction - Simple case (10 - 3 = 7)
        a = 32'd10;
        b = 32'd3;
        sub_en = 1'b1;
        #10;
        $display("Test 3 - SUB: %d - %d = %d (Expected: 7)", a, b, result);
        record_result("Test 3 - simple subtraction", result === 32'd7);

        // Test 4: Subtraction - Negative result (5 - 10 = -5)
        a = 32'd5;
        b = 32'd10;
        sub_en = 1'b1;
        #10;
        $display("Test 4 - SUB: %d - %d = %d (Expected: -5, negative=%b)", a, b, $signed(result), negative);
        record_result("Test 4 - negative subtraction result",
                      result === 32'hFFFFFFFB && negative === 1'b1);

        // Test 5: Addition - Large numbers
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        sub_en = 1'b0;
        #10;
        $display("Test 5 - ADD: 0x%h + 0x%h = 0x%h (cout=%b)", a, b, result, cout);
        record_result("Test 5 - carry out", cout === 1'b1);

        // Test 6: Addition - Positive overflow (0x7FFFFFFF + 0x7FFFFFFF)
        a = 32'h7FFFFFFF;
        b = 32'h7FFFFFFF;
        sub_en = 1'b0;
        #10;
        $display("Test 6 - ADD: 0x%h + 0x%h = 0x%h (overflow=%b)", a, b, result, overflow);
        record_result("Test 6 - positive overflow", overflow === 1'b1);

        // Test 7: Addition - No overflow
        a = 32'h40000000;
        b = 32'h30000000;
        sub_en = 1'b0;
        #10;
        $display("Test 7 - ADD: 0x%h + 0x%h = 0x%h (overflow=%b)", a, b, result, overflow);
        record_result("Test 7 - no overflow", overflow === 1'b0);

        // Test 8: Subtraction - Zero result (15 - 15 = 0)
        a = 32'd15;
        b = 32'd15;
        sub_en = 1'b1;
        #10;
        $display("Test 8 - SUB: %d - %d = %d (Expected: 0, zero=%b)", a, b, result, zero);
        record_result("Test 8 - subtraction zero result", result === 32'd0 && zero === 1'b1);

        // Test 9: Addition - Maximum positive values
        a = 32'h7FFFFFFF;
        b = 32'h00000000;
        sub_en = 1'b0;
        #10;
        $display("Test 9 - ADD: 0x%h + 0x%h = 0x%h (negative=%b)", a, b, result, negative);
        record_result("Test 9 - nonnegative result", negative === 1'b0);

        // Test 10: Mixed bit patterns
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        sub_en = 1'b0;
        #10;
        $display("Test 10 - ADD: 0x%h + 0x%h = 0x%h (Expected: 0xFFFFFFFF)", a, b, result);
        record_result("Test 10 - mixed bit patterns", result === 32'hFFFFFFFF);

        $display("===== rca_32bit SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d", tests, passed, failed);
        if (failed == 0) $display("RESULT: ALL TESTS PASSED");
        else             $display("RESULT: TESTS FAILED");
        $display("=============================");
        if (failed != 0) $fatal(1, "rca_32bit: %0d test(s) failed", failed);
        $finish;
    end

endmodule