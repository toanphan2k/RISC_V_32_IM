import rv32im_pkg::*;

module radix4_divider_comb(
    // divider_32_radix4_restoring
    input  logic [XLEN-1:0] dividend,
    input  logic [XLEN-1:0] divisor,

    output logic [XLEN-1:0] quotient,
    output logic [XLEN-1:0] remainder
);

    // 34-bit intermediate values prevent overflow
    logic [XLEN+2:0] rem_tmp;
    logic [XLEN+2:0] divisor_ext;
    logic [XLEN+2:0] divisor_2x;
    logic [XLEN+2:0] divisor_3x;

    logic [XLEN-1:0] quotient_tmp;
    logic [1:0]  q_digit;

    always_comb begin : divider_logic
        integer i;

        rem_tmp      = 34'd0;
        divisor_ext  = {2'b00, divisor};
        divisor_2x   = divisor_ext << 1;
        divisor_3x   = divisor_ext + divisor_2x;
        quotient_tmp = 32'd0;
        q_digit      = 2'd0;

        quotient     = 32'd0;
        remainder    = 32'd0;

        if (divisor == 32'd0) begin
            quotient  = 32'hFFFF_FFFF;
            remainder = dividend;
        end
        else begin
            for (i = 15; i >= 0; i = i - 1) begin
                rem_tmp = (rem_tmp << 2)
                        | {32'd0, dividend[2*i +: 2]};

                if (rem_tmp >= divisor_3x) begin
                    rem_tmp = rem_tmp - divisor_3x;
                    q_digit = 2'd3;
                end
                else if (rem_tmp >= divisor_2x) begin
                    rem_tmp = rem_tmp - divisor_2x;
                    q_digit = 2'd2;
                end
                else if (rem_tmp >= divisor_ext) begin
                    rem_tmp = rem_tmp - divisor_ext;
                    q_digit = 2'd1;
                end
                else begin
                    q_digit = 2'd0;
                end

                quotient_tmp[2*i +: 2] = q_digit;
            end

            quotient  = quotient_tmp;
            remainder = rem_tmp[31:0];
        end
    end

endmodule
