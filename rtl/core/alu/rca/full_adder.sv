//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Toan Phan Minh
//
// Create Date: 2026-10-16
// Design Name:
// Module Name: full_adder_1bit
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: SystemVerilog implementation of the full_adder_1bit module.
//
// Dependencies:
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module full_adder_1bit(
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic cout,
    output logic sum
);

    assign sum = a + b + cin;
    assign cout = (a & b) | cin & (a ^ b);

endmodule