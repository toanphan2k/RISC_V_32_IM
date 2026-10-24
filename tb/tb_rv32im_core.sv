//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:  Chat GPT and Copilot
//
// Create Date: 2026-10-24
// Design Name:
// Module Name: tb_rv32im_core
// Project Name: riscv-32im
// Target Devices:
// Tool Versions:
// Description: Simulation testbench for simple_divider.
//
// Dependencies: tb_rv32im_core.sv
//
// Revision: 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
// tb_rv32im_core.sv
//
// Self-checking smoke + directed-hazard testbench for rv32im_core.
//
// IMPORTANT INTEGRATION ASSUMPTIONS:
// 1. XLEN is 32.
// 2. imem_addr and dmem_addr are byte addresses.
// 3. imem_req is a request/enable; instruction data is registered one cycle
//    after a request (synchronous read).
// 4. dmem_req is a request/enable; data is registered on every request,
//    including writes, which return the old word (synchronous BRAM-style
//    read-during-write behavior). The output holds when there is no request.
// 5. Stores use dmem_wstrobe[0] for bits [7:0] of the addressed 32-bit word.
// 6. The core can tolerate the memory response timing above. If your core has
//    a ready/valid or busy protocol, adapt the models to that protocol.
// 7. The test ends by checking the data-memory signature. It does not depend
//    on private DUT hierarchy such as register-file signal names.
//
// Run example (adjust source files/package ordering for your simulator):
//   iverilog -g2012 -s tb_rv32im_core -o simv rv32im_pkg.sv rv32im_core.sv tb_rv32im_core.sv
//   vvp simv
//
// This test uses RV32I instructions. RV32M instructions should be added once
// the core's M-extension latency/handshake behavior is known.

module tb_rv32im_core;

  localparam int XLEN       = 32;
  localparam int IMEM_WORDS = 256;
  localparam int DMEM_WORDS = 256;
  localparam int MAX_CYCLES = 1000;
  localparam int CORE_TCS   = 4; // Expected signature stores / test cases

  localparam logic [31:0] NOP = 32'h0000_0013; // addi x0,x0,0

  logic clk = 1'b0;
  logic rst_n = 1'b0;

  logic [XLEN-1:0] imem_rdata;
  logic [XLEN-1:0] imem_addr;
  logic            imem_req;

  logic [XLEN-1:0] dmem_rdata;
  logic [XLEN-1:0] dmem_addr;
  logic [3:0]      dmem_wstrobe;
  logic            dmem_req;
  logic            dmem_en_write;
  logic [XLEN-1:0] dmem_wdata;

  logic [31:0] imem [0:IMEM_WORDS-1];
  logic [31:0] dmem [0:DMEM_WORDS-1];

  int cycle_count = 0;
  int store_count = 0;
  int tests = 0;
  int passed = 0;
  int failed = 0;

  rv32im_core dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .imem_rdata    (imem_rdata),
    .imem_addr     (imem_addr),
    .imem_req      (imem_req),
    .dmem_rdata    (dmem_rdata),
    .dmem_addr     (dmem_addr),
    .dmem_wstrobe  (dmem_wstrobe),
    .dmem_req      (dmem_req),
    .dmem_en_write (dmem_en_write),
    .dmem_wdata    (dmem_wdata)
  );

  always #5 clk = ~clk;

  // ---------------- Instruction encoders ----------------

  function automatic logic [31:0] enc_i(
    input logic [6:0] opcode,
    input logic [4:0] rd,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input integer signed imm
  );
    enc_i = {imm[11:0], rs1, funct3, rd, opcode};
  endfunction

  function automatic logic [31:0] enc_r(
    input logic [6:0] opcode,
    input logic [4:0] rd,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [6:0] funct7
  );
    enc_r = {funct7, rs2, rs1, funct3, rd, opcode};
  endfunction

  function automatic logic [31:0] enc_s(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input integer signed imm
  );
    logic [11:0] x;
    begin
      x = imm[11:0];
      enc_s = {x[11:5], rs2, rs1, funct3, x[4:0], opcode};
    end
  endfunction

  function automatic logic [31:0] enc_b(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input integer signed offset
  );
    logic [12:0] x;
    begin
      x = offset[12:0];
      enc_b = {x[12], x[10:5], rs2, rs1, funct3,
               x[4:1], x[11], opcode};
    end
  endfunction

  // ---------------- Memory models ----------------
  //
  // Registered reads model synchronous memories. Because nonblocking
  // assignments update after the active region, the DUT sees the prior
  // registered value at the same edge and consumes the response on a later
  // edge. This is the conventional simple one-cycle synchronous-read model.

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      imem_rdata <= NOP;
    end else if (imem_req) begin
      if ((imem_addr[1:0] != 2'b00) ||
          ((imem_addr >> 2) >= IMEM_WORDS)) begin
        $error("IMEM address invalid/out of range: %08x at cycle %0d",
               imem_addr, cycle_count);
        failed <= failed + 1;
        imem_rdata <= NOP;
      end else begin
        imem_rdata <= imem[imem_addr[31:2]];
      end
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      dmem_rdata <= '0;
    end else if (dmem_req) begin
      if ((dmem_addr[1:0] != 2'b00) ||
          ((dmem_addr >> 2) >= DMEM_WORDS)) begin
        $error("DMEM address invalid/out of range: %08x at cycle %0d",
               dmem_addr, cycle_count);
        failed <= failed + 1;
        dmem_rdata <= '0;
      end else begin
        // Nonblocking assignments preserve the old word on a simultaneous
        // read and write, matching single_port_ram.
        dmem_rdata <= dmem[dmem_addr[31:2]];

        if (dmem_en_write) begin
          if (dmem_wstrobe[0])
            dmem[dmem_addr[31:2]][7:0]   <= dmem_wdata[7:0];
          if (dmem_wstrobe[1])
            dmem[dmem_addr[31:2]][15:8]  <= dmem_wdata[15:8];
          if (dmem_wstrobe[2])
            dmem[dmem_addr[31:2]][23:16] <= dmem_wdata[23:16];
          if (dmem_wstrobe[3])
            dmem[dmem_addr[31:2]][31:24] <= dmem_wdata[31:24];

          store_count <= store_count + 1;
        end
      end
    end
  end

  // ---------------- Simple protocol assertions ----------------

  always @(posedge clk) begin
    if (rst_n) begin
      cycle_count <= cycle_count + 1;

      if ((^imem_req) === 1'bx) begin
        $error("imem_req is X at cycle %0d", cycle_count);
        failed <= failed + 1;
      end

      if ((^dmem_req) === 1'bx) begin
        $error("dmem_req is X at cycle %0d", cycle_count);
        failed <= failed + 1;
      end

      if (dmem_req && dmem_en_write && ((^dmem_wstrobe) === 1'bx)) begin
        $error("dmem_wstrobe contains X on a store at cycle %0d", cycle_count);
        failed <= failed + 1;
      end

      if (dmem_req && dmem_en_write && (dmem_wstrobe == 4'b0000)) begin
        $error("Store request has zero byte strobe at cycle %0d", cycle_count);
        failed <= failed + 1;
      end
    end
  end

  // ---------------- Test program ----------------
  //
  // Program outline:
  //  0: x1 = 10
  //  1: x2 = 20
  //  2: x3 = x1 + x2 = 30              (EX forwarding dependency)
  //  3: x4 = x3 - x1 = 20              (back-to-back dependency)
  //  4: x5 = 0x100                     (data-memory base)
  //  5: sw x3, 0(x5)                   (expect dmem[64] = 30)
  //  6: lw x6, 0(x5)
  //  7: add x7, x6, x2 = 50            (load-use hazard)
  //  8: x8 = 30
  //  9: beq x6,x8,+8                   (taken; skips instruction 10)
  // 10: x9 = 99                        (must be flushed/skipped)
  // 11: x9 = 7
  // 12: sw x7, 4(x5)                   (expect dmem[65] = 50)
  // 13: sw x9, 8(x5)                   (expect dmem[66] = 7)
  // 14: sw x4, 12(x5)                  (expect dmem[67] = 20)
  // 15: jal x0, 0                      (park forever)
  //
  // The test checks memory signatures rather than internal registers, so it
  // remains usable if the register-file hierarchy changes.

  task automatic load_program;
    begin
      for (int i = 0; i < IMEM_WORDS; i++)
        imem[i] = NOP;

      imem[0]  = enc_i(7'b0010011, 5'd1, 3'b000, 5'd0, 10); // addi x1,x0,10
      imem[1]  = enc_i(7'b0010011, 5'd2, 3'b000, 5'd0, 20); // addi x2,x0,20
      imem[2]  = enc_r(7'b0110011, 5'd3, 3'b000, 5'd1, 5'd2, 7'b0000000); // add x3,x1,x2: 10 + 20 = 30
      imem[3]  = enc_r(7'b0110011, 5'd4, 3'b000, 5'd3, 5'd1, 7'b0100000); // sub x4,x3,x1: 30 - 10 = 20
      imem[4]  = enc_i(7'b0010011, 5'd5, 3'b000, 5'd0, 256); // addi x5,x0,256
      imem[5]  = enc_s(7'b0100011, 3'b010, 5'd5, 5'd3, 0); // sw x3,0(x5)
      imem[6]  = enc_i(7'b0000011, 5'd6, 3'b010, 5'd5, 0); // lw x6,0(x5)
      imem[7]  = enc_r(7'b0110011, 5'd7, 3'b000, 5'd6, 5'd2, 7'b0000000); // add x7,x6,x2
      imem[8]  = enc_i(7'b0010011, 5'd8, 3'b000, 5'd0, 30); // addi x8,x0,30
      imem[9]  = enc_b(7'b1100011, 3'b000, 5'd6, 5'd8, 8); // beq x6,x8,+8
      imem[10] = enc_i(7'b0010011, 5'd9, 3'b000, 5'd0, 99); // wrong path
      imem[11] = enc_i(7'b0010011, 5'd9, 3'b000, 5'd0, 7); // target
      imem[12] = enc_s(7'b0100011, 3'b010, 5'd5, 5'd7, 4); // sw x7,4(x5)
      imem[13] = enc_s(7'b0100011, 3'b010, 5'd5, 5'd9, 8); // sw x9,8(x5)
      imem[14] = enc_s(7'b0100011, 3'b010, 5'd5, 5'd4, 12); // sw x4,12(x5)
      imem[15] = 32'h0000_006f; // jal x0,0
    end
  endtask

  task automatic check_word(input int word_index,
                            input logic [31:0] expected,
                            input string description);
    begin
      tests++;
      if (dmem[word_index] !== expected) begin
        $error("FAIL: %s: dmem[%0d] expected %08x, got %08x",
               description, word_index, expected, dmem[word_index]);
        failed++;
      end else begin
        passed++;
        $display("PASS: %s: dmem[%0d] = %08x",
                 description, word_index, dmem[word_index]);
      end
    end
  endtask

  initial begin : test_sequence
    $display("==================================================");
    $display(" rv32im_core self-checking testbench");
    $display("==================================================");

    load_program();

    for (int i = 0; i < DMEM_WORDS; i++)
      dmem[i] = 32'h0000_0000;

    // Hold reset for several rising edges.
    repeat (4) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    // Wait until the three signature stores should have completed.
    // The program then loops at PC=0x3C (instruction index 15).
    repeat (100) @(posedge clk);
    @(negedge clk);

    check_word(64, 32'd30, "SW/forwarding: x3 = 30");
    check_word(65, 32'd50, "LW-use dependency: x7 = 50");
    check_word(66, 32'd7,  "Taken branch flush: x9 = 7, not 99");
    check_word(67, 32'd20, "SUB: x4 = 20");

    tests++;
    if (store_count != CORE_TCS) begin
      failed++;
      $error("FAIL: expected exactly %0d data-memory stores, observed %0d",
             CORE_TCS, store_count);
    end else begin
      passed++;
      $display("PASS: observed exactly %0d data-memory stores", CORE_TCS);
    end

    $display("===== rv32im_core SUMMARY =====");
    $display("Total: %0d | Passed: %0d | Failed: %0d",
             tests, passed, failed);
    if (failed == 0) $display("RESULT: ALL TESTS PASSED");
    else             $display("RESULT: TESTS FAILED");
    $display("===============================");
    if (failed != 0) $fatal(1, "rv32im_core: %0d test(s) failed", failed);
    $finish;
  end

  // Global timeout catches a core stuck in reset, fetch, or a hazard stall.
  initial begin
    repeat (MAX_CYCLES) @(posedge clk);
    $fatal(1, "TIMEOUT: no test completion after %0d cycles", MAX_CYCLES);
  end

endmodule
