//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-16
// Design Name:
// Module Name: rca_4bit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: SystemVerilog implementation of the rca_4bit module.
//
// Dependencies:
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module rca_4bit(
    input  logic [3:0]  a,
    input  logic [3:0]  b,
    input  logic        cin,
    output logic        cout,
    output logic [3:0]  sum
);

    logic [4:0] carry;

    assign carry[0] = cin;
    assign cout     = carry[4];

    genvar i;
    generate
        for(i = 0; i < 4; i ++) begin : GEN_FULL_ADDER
            full_adder_1bit full_adder_1bit_u (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

endmodule
