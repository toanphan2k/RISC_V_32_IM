`timescale 1ns/1ps

import rv32im_pkg::*;

module tb_alu_32rv;

    logic [31:0] operand_a;
    logic [31:0] operand_b;
    alu_opcode_e opcode;
    logic [31:0] result;
    logic zero_flag;
    logic less_than_flag;
    logic less_than_unsigned_flag;

    alu_rv32 dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .opcode(opcode),
        .result(result),
        .zero_flag(zero_flag),
        .less_than_flag(less_than_flag),
        .less_than_unsigned_flag(less_than_unsigned_flag)
    );

    task automatic check_case(
        input logic [31:0] a,
        input logic [31:0] b,
        input alu_opcode_e op,
        input logic [31:0] expected_result,
        input logic expected_zero,
        input logic expected_lt,
        input logic expected_ltu,
        input string label
    );
        begin
            operand_a = a;
            operand_b = b;
            opcode    = op;

            #1;

            if ((result !== expected_result) ||
                (zero_flag !== expected_zero) ||
                (less_than_flag !== expected_lt) ||
                (less_than_unsigned_flag !== expected_ltu)) begin
                $display("FAIL: %s", label);
                $display("  a=%0d b=%0d op=%0d", a, b, op);
                $display("  got: result=%0d zero=%0b lt=%0b ltu=%0b", result, zero_flag, less_than_flag, less_than_unsigned_flag);
                $display("  exp: result=%0d zero=%0b lt=%0b ltu=%0b", expected_result, expected_zero, expected_lt, expected_ltu);
                $fatal(1, "ALU mismatch");
            end else begin
                $display("PASS: %s", label);
            end
        end
    endtask

    initial begin
        $display("Starting ALU testbench");

        // ADD
        check_case(32'd10, 32'd5, ALU_ADD, 32'd15, 1'b0, 1'b0, 1'b0, "ADD");

        // SUB
        check_case(32'd10, 32'd5, ALU_SUB, 32'd5, 1'b0, 1'b0, 1'b0, "SUB");

        // AND with zero result
        check_case(32'hAA55_AA55, 32'h55AA_55AA, ALU_AND, 32'd0, 1'b1, 1'b0, 1'b0, "AND");

        // OR
        check_case(32'h0F0F_0000, 32'h0000_F0F0, ALU_OR, 32'h0F0F_F0F0, 1'b0, 1'b0, 1'b0, "OR");

        // XOR
        check_case(32'hA5A5_A5A5, 32'h5A5A_5A5A, ALU_XOR, 32'hFFFF_FFFF, 1'b0, 1'b0, 1'b0, "XOR");

        // SLL
        check_case(32'd3, 32'd2, ALU_SLL, 32'd12, 1'b0, 1'b0, 1'b0, "SLL");

        // SRL
        check_case(32'h8000_0001, 32'd1, ALU_SRL, 32'h4000_0000, 1'b0, 1'b0, 1'b0, "SRL");

        // SRA
        check_case(32'h8000_0001, 32'd1, ALU_SRA, 32'hC000_0000, 1'b0, 1'b0, 1'b0, "SRA");

        // SLT signed compare
        check_case(32'hFFFF_FFFF, 32'd1, ALU_SLT, 32'd1, 1'b0, 1'b1, 1'b0, "SLT");

        // SLTU unsigned compare
        check_case(32'd1, 32'd2, ALU_SLTU, 32'd1, 1'b0, 1'b0, 1'b1, "SLTU");

        $display("All ALU tests passed");
        $finish;
    end

endmodule
