`timescale 1ns/1ps

module tb_soc_memories;

    localparam int DATA_WIDTH = 32;
    localparam int ADDR_WIDTH = 4;
    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic clk;
    logic en_write;
    logic [ADDR_WIDTH-1:0] waddr;
    logic [ADDR_WIDTH-1:0] raddr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] ram_rdata;
    logic [ADDR_WIDTH-1:0] rom_raddr;
    logic [DATA_WIDTH-1:0] rom_rdata;

    single_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) ram_dut (
        .clk(clk),
        .en_write(en_write),
        .waddr(waddr),
        .raddr(raddr),
        .wdata(wdata),
        .rdata(ram_rdata)
    );

    instruction_rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .HEX_FILE("tb/instruction_rom_test.hex")
    ) rom_dut (
        .clk(clk),
        .raddr(rom_raddr),
        .rdata(rom_rdata)
    );

    always #5 clk = ~clk;

    function automatic logic [DATA_WIDTH-1:0] ram_word(input integer index);
        ram_word = 32'hA500_0000 ^ (index * 32'h0001_0101);
    endfunction

    task automatic check_ram(
        input logic [ADDR_WIDTH-1:0] read_address,
        input logic write_enable,
        input logic [ADDR_WIDTH-1:0] write_address,
        input logic [DATA_WIDTH-1:0] write_data,
        input logic [DATA_WIDTH-1:0] expected_read_data,
        input string label
    );
        begin
            @(negedge clk);
            raddr = read_address;
            en_write = write_enable;
            waddr = write_address;
            wdata = write_data;

            @(posedge clk);
            #1;

            if (ram_rdata !== expected_read_data) begin
                $display("FAIL: %s", label);
                $display("  read address=%0d got=%h expected=%h",
                         read_address, ram_rdata, expected_read_data);
                $fatal(1, "RAM read mismatch");
            end
            $display("PASS: %s", label);
        end
    endtask

    task automatic check_rom(
        input logic [ADDR_WIDTH-1:0] address,
        input logic [DATA_WIDTH-1:0] expected_data
    );
        begin
            @(negedge clk);
            rom_raddr = address;

            @(posedge clk);
            #1;

            if (rom_rdata !== expected_data) begin
                $display("FAIL: ROM address=%0d got=%h expected=%h",
                         address, rom_rdata, expected_data);
                $fatal(1, "ROM read mismatch");
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        en_write = 1'b0;
        waddr = '0;
        raddr = '0;
        wdata = '0;
        rom_raddr = '0;

        $display("Initializing RAM");
        for (int i = 0; i < DEPTH; i++) begin
            @(negedge clk);
            en_write = 1'b1;
            waddr = i[ADDR_WIDTH-1:0];
            wdata = ram_word(i);
            raddr = '0;
            @(posedge clk);
            #1;
        end
        en_write = 1'b0;

        $display("Checking all RAM and ROM addresses");
        for (int i = 0; i < DEPTH; i++) begin
            check_ram(i[ADDR_WIDTH-1:0], 1'b0, '0, '0, ram_word(i),
                      $sformatf("RAM address %0d", i));
            check_rom(i[ADDR_WIDTH-1:0], 32'h1000_0000 + i);
        end

        check_ram(4'd3, 1'b1, 4'd9, 32'hDEAD_BEEF, ram_word(3),
                  "simultaneous read and write to different addresses");
        check_ram(4'd9, 1'b0, '0, '0, 32'hDEAD_BEEF,
                  "write updates target address");

        check_ram(4'd5, 1'b1, 4'd5, 32'hCAFE_BABE, ram_word(5),
                  "same-address read-during-write returns old data");
        check_ram(4'd5, 1'b0, '0, '0, 32'hCAFE_BABE,
                  "same-address write is committed");

        $display("All SoC memory tests passed");
        $finish;
    end

endmodule
