
`timescale 1ns/1ps

module tb_div;

    // Inputs
    logic [31:0] dividend;
    logic [31:0] divisor;

    // Outputs from DUT
    logic [31:0] quotient;
    logic [31:0] remainder;

    // Reference results
    logic [31:0] expected_quotient;
    logic [31:0] expected_remainder;

    integer test_count;
    integer error_count;
    integer i;

    // DUT: Divider under test
    div_function dut (
        .dividend  (dividend),
        .divisor   (divisor),
        .quotient  (quotient),
        .remainder (remainder)
    );

    // Task to test one division operation
    task automatic run_test(
        input logic [31:0] a,
        input logic [31:0] b
    );
        begin
            dividend = a;
            divisor  = b;

            // Allow combinational logic to settle
            #1;

            // Calculate expected results
            if (b == 32'd0) begin
                expected_quotient  = 32'hFFFF_FFFF;
                expected_remainder = a;
            end
            else begin
                expected_quotient  = a / b;
                expected_remainder = a % b;
            end

            test_count = test_count + 1;

            // Compare DUT results against reference
            if ((quotient !== expected_quotient) ||
                (remainder !== expected_remainder)) begin

                error_count = error_count + 1;

                $display("[FAIL] Test %0d", test_count);
                $display("       Dividend  = 0x%08h (%0d)",
                         a, a);
                $display("       Divisor   = 0x%08h (%0d)",
                         b, b);
                $display("       Quotient  = 0x%08h, Expected = 0x%08h",
                         quotient, expected_quotient);
                $display("       Remainder = 0x%08h, Expected = 0x%08h",
                         remainder, expected_remainder);
            end
            else begin
                $display("[PASS] Test %0d: %0d / %0d = %0d, rem = %0d",
                         test_count, a, b,
                         quotient, remainder);
            end
        end
    endtask

    initial begin
        test_count = 0;
        error_count = 0;
        dividend = 32'd0;
        divisor  = 32'd0;

        $display("========================================");
        $display("  32-bit Radix-4 Restoring Divider Test");
        $display("========================================");

        // Test 1: Basic division
        run_test(32'd10, 32'd2);

        // Test 2: Division with remainder
        run_test(32'd10, 32'd3);

        // Test 3: Exact division
        run_test(32'd100, 32'd10);

        // Test 4: Dividend smaller than divisor
        run_test(32'd5, 32'd10);

        // Test 5: Divide by one
        run_test(32'hFFFF_FFFF, 32'd1);

        // Test 6: Dividend equals divisor
        run_test(32'd12345, 32'd12345);

        // Test 7: Zero dividend
        run_test(32'd0, 32'd123);

        // Test 8: Divide by zero
        run_test(32'h1234_5678, 32'd0);

        // Test 9: Maximum unsigned dividend
        run_test(32'hFFFF_FFFF, 32'd3);

        // Test 10: Large operands
        run_test(32'hFFFF_FFFF, 32'h8000_0000);

        // Test 11: Powers of two
        run_test(32'h8000_0000, 32'd2);
        run_test(32'h8000_0000, 32'd256);

        // Test 12: Boundary values
        run_test(32'hFFFF_FFFF, 32'hFFFF_FFFF);
        run_test(32'h0000_0001, 32'hFFFF_FFFF);
        run_test(32'h7FFF_FFFF, 32'h0000_0003);

        // Test 13: Random tests
        for (i = 0; i < 1000; i = i + 1) begin
            run_test($urandom(), $urandom());
        end

        // Final report
        $display("");
        $display("===== radix4_divider_comb SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d",
                 test_count, test_count - error_count, error_count);

        if (error_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TESTS FAILED");

        $display("=======================================");

        if (error_count != 0)
            $fatal(1, "radix4_divider_comb: %0d test(s) failed", error_count);
        $finish;
    end

endmodule
