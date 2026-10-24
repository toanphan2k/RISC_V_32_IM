//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Copilot
//
// Create Date: 2026-10-13
// Design Name:
// Module Name: tb_soc_memories
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for soc_memories.
//
// Dependencies:
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tb_soc_memories;

    localparam int DATA_WIDTH = 32;
    localparam int ADDR_WIDTH = 4;
    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic clk;
    logic en_write;
    logic req;
    logic [3:0] wstrobe;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] ram_rdata;
    logic en_read;
    logic [ADDR_WIDTH-1:0] rom_raddr;
    logic [DATA_WIDTH-1:0] rom_rdata;

    int tests = 0;
    int passed = 0;
    int failed = 0;

    single_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) ram_dut (
        .clk(clk),
        .en_write(en_write),
        .req(req),
        .wstrobe(wstrobe),
        .addr(addr),
        .wdata(wdata),
        .rdata(ram_rdata)
    );

    instruction_rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .HEX_FILE("tb/instruction_rom_test.hex")
    ) rom_dut (
        .clk(clk),
        .en_read(en_read),
        .raddr(rom_raddr),
        .rdata(rom_rdata)
    );

    always #5 clk = ~clk;

    function automatic logic [DATA_WIDTH-1:0] ram_word(input integer index);
        ram_word = 32'hA500_0000 ^ (index * 32'h0001_0101);
    endfunction

    task automatic check_ram(
        input logic [ADDR_WIDTH-1:0] access_address,
        input logic request,
        input logic write_enable,
        input logic [3:0] byte_strobe,
        input logic [DATA_WIDTH-1:0] write_data,
        input logic [DATA_WIDTH-1:0] expected_read_data,
        input string label
    );
        begin
            @(negedge clk);
            addr = access_address;
            req = request;
            en_write = write_enable;
            wstrobe = byte_strobe;
            wdata = write_data;

            @(posedge clk);
            #1;

            tests++;
            if (ram_rdata !== expected_read_data) begin
                failed++;
                $display("[FAIL] %s", label);
                $display("  read address=%0d got=%h expected=%h",
                         access_address, ram_rdata, expected_read_data);
            end else begin
                passed++;
                $display("[PASS] %s", label);
            end
        end
    endtask

    task automatic check_rom(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] expected_data
    );
        begin
            @(negedge clk);
            rom_raddr = address;
            en_read = 1'b1;

            @(posedge clk);
            #1;

            tests++;
            if (rom_rdata !== expected_data) begin
                failed++;
                $display("[FAIL] ROM address=%0d got=%h expected=%h",
                         address, rom_rdata, expected_data);
            end else begin
                passed++;
                $display("[PASS] ROM address=%0d", address);
            end
        end
    endtask

    task automatic check_rom_hold(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] expected_data
    );
        begin
            @(negedge clk);
            rom_raddr = address;
            en_read = 1'b0;

            @(posedge clk);
            #1;

            tests++;
            if (rom_rdata !== expected_data) begin
                failed++;
                $display("[FAIL] ROM output hold got=%h expected=%h",
                         rom_rdata, expected_data);
            end else begin
                passed++;
                $display("[PASS] ROM output holds while read is disabled");
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        en_write = 1'b0;
        req = 1'b0;
        wstrobe = '0;
        addr = '0;
        wdata = '0;
        en_read = 1'b0;
        rom_raddr = '0;

        $display("Initializing RAM");
        for (int i = 0; i < DEPTH; i++) begin
            @(negedge clk);
            req = 1'b1;
            en_write = 1'b1;
            wstrobe = 4'hF;
            addr = i[ADDR_WIDTH-1:0];
            wdata = ram_word(i);
            @(posedge clk);
            #1;
        end
        en_write = 1'b0;
        req = 1'b0;
        wstrobe = '0;

        $display("Checking all RAM and ROM addresses");
        for (int i = 0; i < DEPTH; i++) begin
            check_ram(i[ADDR_WIDTH-1:0], 1'b1, 1'b0, '0, '0, ram_word(i),
                      $sformatf("RAM address %0d", i));
            check_rom(i[ADDR_WIDTH-1:0], 32'h1000_0000 + i);
        end
        check_rom_hold(4'd0, 32'h1000_000F);

        check_ram(4'd3, 1'b1, 1'b1, 4'hF, 32'hDEAD_BEEF, ram_word(3),
                  "read and write same address returns old data");
        check_ram(4'd3, 1'b1, 1'b0, '0, '0, 32'hDEAD_BEEF,
                  "full-word write updates target address");

        check_ram(4'd3, 1'b1, 1'b1, 4'b0101, 32'h1122_3344, 32'hDEAD_BEEF,
                  "byte-strobe write returns old data");
        check_ram(4'd3, 1'b1, 1'b0, '0, '0, 32'hDE22_BE44,
                  "byte strobes update selected lanes only");

        check_ram(4'd3, 1'b1, 1'b1, 4'b0000, 32'hFFFF_FFFF, 32'hDE22_BE44,
                  "zero byte strobes preserve stored data");
        check_ram(4'd3, 1'b0, 1'b1, 4'hF, 32'hFFFF_FFFF, 32'hDE22_BE44,
                  "write disabled when request is absent");

        $display("===== SoC memories SUMMARY =====");
        $display("Total: %0d | Passed: %0d | Failed: %0d", tests, passed, failed);
        if (failed == 0) $display("RESULT: ALL TESTS PASSED");
        else             $display("RESULT: TESTS FAILED");
        $display("================================");
        if (failed != 0) $fatal(1, "SoC memories: %0d test(s) failed", failed);
        $finish;
    end

endmodule
