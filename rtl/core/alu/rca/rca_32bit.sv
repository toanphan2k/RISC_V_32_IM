//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-16
// Design Name:
// Module Name: rca_32bit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: SystemVerilog implementation of the rca_32bit module.
//
// Dependencies: rv32im_pkg.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

import rv32im_pkg::*;

module rca_32bit (
    input  logic [XLEN-1:0] a,
    input  logic [XLEN-1:0] b,
    input  logic            sub_en, // 0 for addition, 1 for subtraction
    output logic [XLEN-1:0] result,
    output logic            cout,
    output logic            overflow,
    output logic            zero,
    output logic            negative
);

    logic [XLEN-1:0] operand_b;
    logic            cin;
    logic [8:0]      carry;

    assign operand_b = sub_en ? ~b : b;
    assign cin       = sub_en ? 1'b1 : 1'b0;
    assign carry[0]  = cin;
    assign cout      = carry[8];

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : GEN_RCA_4_BIT
            rca_4bit rca_4bit_u (
                .a(a[(i*4)+:4]),
                .b(operand_b[(i*4)+:4]),
                .cin(carry[i]),
                .cout(carry[i+1]),
                .sum(result[(i*4)+:4])
            );
        end;
    endgenerate

    // Overflow detection:
    // Overflow = ~(A[31] ^ B[31]) & (A[31] ^ sum[31])
    assign overflow = !(a[XLEN-1] ^ operand_b[XLEN-1]) & (a[XLEN-1] ^ result[XLEN-1]);
    // Zero detection: result is zero if all bits are zero
    assign zero = (result == '0);
    ///////////////////////
    // FOR SIGN EXTENSION//
    ///////////////////////
    // Negative detection: result is negative if the sign bit (MSB) is 1
    assign negative = result[XLEN-1];

endmodule