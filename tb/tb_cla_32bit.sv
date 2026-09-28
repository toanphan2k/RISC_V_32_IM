`timescale 1ns/1ps

module tb_cla_32bit;
    // Testbench signals
    logic [31:0]  a;
    logic [31:0]  b;
    logic         sub_en;
    logic [31:0]  result;
    logic         cout;
    logic         overflow;
    logic         zero;
    logic         negative;

    // Instantiate the module under test
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

    // Test procedure
    initial begin
        $display("Starting CLA 32-bit Testbench");
        $display("================================");

        // Test 1: Addition - Simple case (5 + 3 = 8)
        a = 32'd5;
        b = 32'd3;
        sub_en = 1'b0;
        #10;
        $display("Test 1 - ADD: %d + %d = %d (Expected: 8)", a, b, result);
        assert(result == 32'd8) else $error("Test 1 Failed");

        // Test 2: Addition - Zero result
        a = 32'd0;
        b = 32'd0;
        sub_en = 1'b0;
        #10;
        $display("Test 2 - ADD: %d + %d = %d (Expected: 0, zero=%b)", a, b, result, zero);
        assert(result == 32'd0 && zero == 1'b1) else $error("Test 2 Failed");

        // Test 3: Subtraction - Simple case (10 - 3 = 7)
        a = 32'd10;
        b = 32'd3;
        sub_en = 1'b1;
        #10;
        $display("Test 3 - SUB: %d - %d = %d (Expected: 7)", a, b, result);
        assert(result == 32'd7) else $error("Test 3 Failed");

        // Test 4: Subtraction - Negative result (5 - 10 = -5)
        a = 32'd5;
        b = 32'd10;
        sub_en = 1'b1;
        #10;
        $display("Test 4 - SUB: %d - %d = %d (Expected: -5, negative=%b)", a, b, $signed(result), negative);
        assert(result == 32'hFFFFFFFB && negative == 1'b1) else $error("Test 4 Failed");

        // Test 5: Addition - Large numbers
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        sub_en = 1'b0;
        #10;
        $display("Test 5 - ADD: 0x%h + 0x%h = 0x%h (cout=%b)", a, b, result, cout);
        assert(cout == 1'b1) else $error("Test 5 Failed - Carry out not set");

        // Test 6: Addition - Positive overflow (0x7FFFFFFF + 0x7FFFFFFF)
        a = 32'h7FFFFFFF;
        b = 32'h7FFFFFFF;
        sub_en = 1'b0;
        #10;
        $display("Test 6 - ADD: 0x%h + 0x%h = 0x%h (overflow=%b)", a, b, result, overflow);
        assert(overflow == 1'b1) else $error("Test 6 Failed - Overflow not detected");

        // Test 7: Addition - No overflow
        a = 32'h40000000;
        b = 32'h30000000;
        sub_en = 1'b0;
        #10;
        $display("Test 7 - ADD: 0x%h + 0x%h = 0x%h (overflow=%b)", a, b, result, overflow);
        assert(overflow == 1'b0) else $error("Test 7 Failed - False overflow");

        // Test 8: Subtraction - Zero result (15 - 15 = 0)
        a = 32'd15;
        b = 32'd15;
        sub_en = 1'b1;
        #10;
        $display("Test 8 - SUB: %d - %d = %d (Expected: 0, zero=%b)", a, b, result, zero);
        assert(result == 32'd0 && zero == 1'b1) else $error("Test 8 Failed");

        // Test 9: Addition - Maximum positive values
        a = 32'h7FFFFFFF;
        b = 32'h00000000;
        sub_en = 1'b0;
        #10;
        $display("Test 9 - ADD: 0x%h + 0x%h = 0x%h (negative=%b)", a, b, result, negative);
        assert(negative == 1'b0) else $error("Test 9 Failed");

        // Test 10: Mixed bit patterns
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        sub_en = 1'b0;
        #10;
        $display("Test 10 - ADD: 0x%h + 0x%h = 0x%h (Expected: 0xFFFFFFFF)", a, b, result);
        assert(result == 32'hFFFFFFFF) else $error("Test 10 Failed");

        $display("================================");
        $display("Testbench Complete");
        $finish;
    end

endmodule