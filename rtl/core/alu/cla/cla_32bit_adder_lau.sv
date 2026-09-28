module cla_32bit_lau (
    input logic [7:0]   gen_group, // 8 groups of generate signals from 4-bit adders
    input logic [7:0]   prop_group, // 8 groups of propagate signals from 4-bit adders
    input logic         cin, // global carry-in for the 32-bit adder
    output logic [7:0]  carry_out, // block carry-out input for each 4-bit adder
    output logic        cout // final carry-out for the 32-bit adder

);

endmodule