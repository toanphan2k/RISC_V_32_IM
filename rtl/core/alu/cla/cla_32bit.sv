module cla_32bit (
    input logic [31:0]  a,
    input logic [31:0]  b,
    input logic         sub_en, // 0 for addition, 1 for subtraction
    output logic [31:0] result,
    output logic        cout,
    output logic        overflow,
    output logic        zero,
    output logic        negative
);
    logic [31:0]    operand_b;
    logic           cin;
    logic [7:0]     gen_group;
    logic [7:0]     prop_group;
    logic [7:0]     block_carry;
    logic [7:0]     block_out;
    // SUM: A + B
    // SUB: A + ~B + 1
    assign operand_b = sub_en ? ~b : b;
    assign cin = sub_en ? 1'b1 : 1'b0;

    // Look ahead carry generator for 8 groups of 4-bit adders
    cla_32bit_lau cla_32bit_lau_inst (
        .gen_group(gen_group),
        .prop_group(prop_group),
        .cin(cin),
        .carry_out(block_carry),
        .cout(cout)
    );

    // 8 groups of 4-bit adders
    cla_4bit cla_4bit_inst0 (
        .a(a[3:0]),
        .b(operand_b[3:0]),
        .cin(cin),
        .sum(result[3:0]),
        .gen_group(gen_group[0]),
        .prop_group(prop_group[0]),
        .cout(block_out[0])
    );

    cla_4bit cla_4bit_inst1 (
        .a(a[7:4]),
        .b(operand_b[7:4]),
        .cin(block_out[0]),
        .sum(result[7:4]),
        .gen_group(gen_group[1]),
        .prop_group(prop_group[1]),
        .cout(block_out[1])
    );

    cla_4bit cla_4bit_inst2 (
        .a(a[11:8]),
        .b(operand_b[11:8]),
        .cin(block_out[1]),
        .sum(result[11:8]),
        .gen_group(gen_group[2]),
        .prop_group(prop_group[2]),
        .cout(block_out[2])
    );

    cla_4bit cla_4bit_inst3 (
        .a(a[15:12]),
        .b(operand_b[15:12]),
        .cin(block_out[2]),
        .sum(result[15:12]),
        .gen_group(gen_group[3]),
        .prop_group(prop_group[3]),
        .cout(block_out[3])
    );

    cla_4bit cla_4bit_inst4 (
        .a(a[19:16]),
        .b(operand_b[19:16]),
        .cin(block_out[3]),
        .sum(result[19:16]),
        .gen_group(gen_group[4]),
        .prop_group(prop_group[4]),
        .cout(block_out[4])
    );

    cla_4bit cla_4bit_inst5 (
        .a(a[23:20]),
        .b(operand_b[23:20]),
        .cin(block_out[4]),
        .sum(result[23:20]),
        .gen_group(gen_group[5]),
        .prop_group(prop_group[5]),
        .cout(block_out[5])
    );

    cla_4bit cla_4bit_inst6 (
        .a(a[27:24]),
        .b(operand_b[27:24]),
        .cin(block_out[5]),
        .sum(result[27:24]),
        .gen_group(gen_group[6]),
        .prop_group(prop_group[6]),
        .cout(block_out[6])
    );

    cla_4bit cla_4bit_inst7 (
        .a(a[31:28]),
        .b(operand_b[31:28]),
        .cin(block_out[6]),
        .sum(result[31:28]),
        .gen_group(gen_group[7]),
        .prop_group(prop_group[7]),
        .cout(block_out[7])
    );

    // Overflow detection: overflow occurs when the carry into the sign bit differs from the carry out of the sign bit
    assign overflow = block_out[6] ^ block_out[7];
    // Zero detection: result is zero if all bits are zero
    assign zero = (result == 32'b0);
    // Negative detection: result is negative if the sign bit (MSB) is 1
    assign negative = result[31];

endmodule
