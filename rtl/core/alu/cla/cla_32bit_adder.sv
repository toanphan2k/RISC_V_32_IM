module cla_32bit (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic        operation, // 0 for addition, 1 for subtraction
    output logic [31:0] result,
    output logic        cout,
    output logic        overflow,
    output logic        zero,
    output logic        negative
);

endmodule