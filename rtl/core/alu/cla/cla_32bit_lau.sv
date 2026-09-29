module cla_32bit_lau (
    input logic [7:0]   gen_group, // 8 groups of generate signals from 4-bit adders
    input logic [7:0]   prop_group, // 8 groups of propagate signals from 4-bit adders
    input logic         cin, // global carry-in for the 32-bit adder
    output logic [7:0]  block_carry, // block carry-out input for each 4-bit adder
    output logic        cout // final carry-out for the 32-bit adder

);
    logic [3:0] c_low;
    logic [3:0] c_high;
    logic       c_mid;
    logic       low_block_gen;
    logic       low_block_prop;
    logic       high_block_gen;
    logic       high_block_prop;

    // Low 4 blocks of 4 bit CLA adder
    assign c_low[0] = cin;
    assign c_low[1] = gen_group[0] | (prop_group[0] & c_low[0]);
    assign c_low[2] = gen_group[1] | (prop_group[1] & gen_group[0])
                                   | (prop_group[1] & prop_group[0] & c_low[0]);
    assign c_low[3] = gen_group[2] | (prop_group[2] & gen_group[1])
                                   | (prop_group[2] & prop_group[1] & gen_group[0])
                                   | (prop_group[2] & prop_group[1] & prop_group[0] & c_low[0]);

    assign low_block_gen = gen_group[3] | (prop_group[3] & gen_group[2])
                                        | (prop_group[3] & prop_group[2] & gen_group[1])
                                        | (prop_group[3] & prop_group[2] & prop_group[1] & gen_group[0]);
    assign low_block_prop = prop_group[3] & prop_group[2] & prop_group[1] & prop_group[0];
    assign c_mid = low_block_gen | (low_block_prop & cin);

    // High 4 blocks of 4 bit CLA adder
    assign c_high[0] = c_mid;
    assign c_high[1] = gen_group[4] | (prop_group[4] & c_high[0]);
    assign c_high[2] = gen_group[5] | (prop_group[5] & gen_group[4])
                                    | (prop_group[5] & prop_group[4] & c_high[0]);
    assign c_high[3] = gen_group[6] | (prop_group[6] & gen_group[5])
                                    | (prop_group[6] & prop_group[5] & gen_group[4])
                                    | (prop_group[6] & prop_group[5] & prop_group[4] & c_high[0]);
    assign high_block_gen = gen_group[7] | (prop_group[7] & gen_group[6])
                                         | (prop_group[7] & prop_group[6] & gen_group[5])
                                         | (prop_group[7] & prop_group[6] & prop_group[5] & gen_group[4]);
    assign high_block_prop = prop_group[7] & prop_group[6] & prop_group[5] & prop_group[4];

    assign cout = high_block_gen | (high_block_prop & c_mid);

    assign block_carry[0] = c_low[0];
    assign block_carry[1] = c_low[1];
    assign block_carry[2] = c_low[2];
    assign block_carry[3] = c_low[3];
    assign block_carry[4] = c_high[0];
    assign block_carry[5] = c_high[1];
    assign block_carry[6] = c_high[2];
    assign block_carry[7] = c_high[3];

endmodule
