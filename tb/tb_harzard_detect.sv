`timescale 1ns/1ps
// import rv32im_pkg::*;

module tb_harzard_detect;
    logic [4:0] i_id_rs1, i_id_rs2, i_id_rd;
    logic [4:0] i_ex_rd;
    logic       i_ex_read;
    logic       o_if_pc_en;
    logic       o_stall_if_id;

    int tests = 0;
    int errors = 0;

    harzard_detect dut (
        .i_id_rs1      (i_id_rs1),
        .i_id_rs2      (i_id_rs2),
        .i_id_rd       (i_id_rd),
        .i_ex_rd       (i_ex_rd),
        .i_ex_read     (i_ex_read),
        .o_if_pc_en    (o_if_pc_en),
        .o_stall_if_id (o_stall_if_id)
    );

    task automatic check_case(
        input string name,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [4:0] id_rd,
        input logic [4:0] ex_rd,
        input logic ex_read,
        input logic exp_pc_en,
        input logic exp_stall
    );
        begin
            i_id_rs1  = rs1;
            i_id_rs2  = rs2;
            i_id_rd   = id_rd;
            i_ex_rd   = ex_rd;
            i_ex_read = ex_read;
            #10;
            tests++;
            if ((o_if_pc_en !== exp_pc_en) ||
                (o_stall_if_id !== exp_stall)) begin
                errors++;
                $error("[%0t] FAIL %-42s expected pc_en=%b stall=%b; got pc_en=%b stall=%b",
                       $time, name, exp_pc_en, exp_stall,
                       o_if_pc_en, o_stall_if_id);
            end else begin
                $display("[%0t] PASS %s", $time, name);
            end
        end
    endtask

    initial begin
        $display("===== harzard_detect testbench start =====");

        // No hazard: EX destination does not match either source.
        check_case("T01: no source dependency",
                   5'd1, 5'd2, 5'd3, 5'd4, 1'b1, 1'b1, 1'b1);

        // Load-use hazard: EX destination matches rs1 or rs2.
        check_case("T02: EX read matches rs1",
                   5'd5, 5'd7, 5'd8, 5'd5, 1'b1, 1'b0, 1'b0);

        check_case("T03: EX read matches rs2",
                   5'd5, 5'd7, 5'd8, 5'd7, 1'b1, 1'b0, 1'b0);

        // Both source registers depend on the EX destination.
        check_case("T04: EX read matches both sources",
                   5'd6, 5'd6, 5'd8, 5'd6, 1'b1, 1'b0, 1'b0);

        // x0 is not a real destination dependency.
        check_case("T05: EX destination x0, rs1 x0",
                   5'd0, 5'd2, 5'd3, 5'd0, 1'b1, 1'b1, 1'b1);

        check_case("T06: EX destination x0, rs2 x0",
                   5'd1, 5'd0, 5'd3, 5'd0, 1'b1, 1'b1, 1'b1);

        // i_ex_read low should disable this load-use hazard condition.
        check_case("T07: rs1 matches but EX read low",
                   5'd9, 5'd2, 5'd3, 5'd9, 1'b0, 1'b1, 1'b1);

        check_case("T08: rs2 matches but EX read low",
                   5'd1, 5'd10, 5'd3, 5'd10, 1'b0, 1'b1, 1'b1);

        check_case("T09: both match but EX read low",
                   5'd11, 5'd11, 5'd3, 5'd11, 1'b0, 1'b1, 1'b1);

        // EX destination matches neither source.
        check_case("T10: destination matches ID rd only",
                   5'd1, 5'd2, 5'd12, 5'd12, 1'b1, 1'b1, 1'b1);

        // Same source registers but a different EX destination.
        check_case("T11: no match with rs1/rs2",
                   5'd13, 5'd14, 5'd15, 5'd16, 1'b1, 1'b1, 1'b1);

        // Register-address boundaries.
        check_case("T12: x31 dependency through rs1",
                   5'd31, 5'd1, 5'd2, 5'd31, 1'b1, 1'b0, 1'b0);

        check_case("T13: x31 dependency through rs2",
                   5'd1, 5'd31, 5'd2, 5'd31, 1'b1, 1'b0, 1'b0);

        check_case("T14: x31 without dependency",
                   5'd1, 5'd2, 5'd3, 5'd31, 1'b1, 1'b1, 1'b1);

        // Exercise combinations where one source is x0 and the other matches.
        check_case("T15: rs1 x0, rs2 has dependency",
                   5'd0, 5'd17, 5'd3, 5'd17, 1'b1, 1'b0, 1'b0);

        check_case("T16: rs2 x0, rs1 has dependency",
                   5'd18, 5'd0, 5'd3, 5'd18, 1'b1, 1'b0, 1'b0);

        // i_id_rd is not used in the supplied combinational equation;
        // vary it to verify that it does not affect outputs.
        check_case("T17: ID rd x0, hazard via rs1",
                   5'd19, 5'd2, 5'd0, 5'd19, 1'b1, 1'b0, 1'b0);

        check_case("T18: ID rd x31, no hazard",
                   5'd1, 5'd2, 5'd31, 5'd3, 1'b1, 1'b1, 1'b1);

        $display("===== harzard_detect summary: %0d tests, %0d errors =====", tests, errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $fatal(1, "harzard_detect: %0d test(s) failed", errors);
        $finish;
    end
endmodule
