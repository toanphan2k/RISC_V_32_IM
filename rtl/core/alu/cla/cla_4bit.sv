module cla_4bit (
    input logic [3:0] a,
    input logic [3:0] b,
    input logic cin,
    output logic [3:0] sum,
    output logic cout
);
    logic [3:0] gen;
    logic [3:0] prop;
    logic [3:0] carry;

    assign prop = a ^ b;
    assign gen = a & b;

    assign carry[0] = gen[0] | (prop[0]&cin);
    assign carry[1] = gen[1] | (prop[1]&gen[0]) | (prop[1]&prop[0]&cin);
    assign carry[2] = gen[2] | (prop[2]&gen[1]) | (prop[2]&prop[1]&gen[0]) | (prop[2]&prop[1]&prop[0]&cin);
    assign carry[3] = gen[3] | (prop[3]&gen[2]) | (prop[3]&prop[2]&gen[1]) | (prop[3]&prop[2]&prop[1]&gen[0]) | (prop[3]&prop[2]&prop[1]&prop[0]&cin);

    assign sum[0] = prop[0] ^ cin;
    assign sum[1] = prop[1] ^ carry[0];
    assign sum[2] = prop[2] ^ carry[1];
    assign sum[3] = prop[3] ^ carry[2];

    assign cout = carry[3];

endmodule