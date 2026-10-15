import rv32im_pkg::*;

module simple_32bit_adder (
    input  logic [XLEN-1:0] a,
    input  logic [XLEN-1:0] b,
    input  logic            sub_en, // 0 for addition, 1 for subtraction
    output logic [XLEN-1:0] result,
    output logic            cout,
    output logic            overflow,
    output logic            zero,
    output logic            negative
);

    logic [XLEN-1:0]    operand_b;
    logic               cin;

    // SUM: A + B
    // SUB: A + ~B + 1
    assign operand_b = sub_en ? ~b : b;
    assign cin = sub_en ? 1'b1 : 1'b0;

    assign {cout, result} = a + operand_b + cin;

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
