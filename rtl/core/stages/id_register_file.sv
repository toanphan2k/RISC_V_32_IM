module id_register_file (
    input logic clk;
    input logic rstn;

    input  logic [REG_ADDR_WIDTH-1:0]   raddr1;
    output logic [XLEN-1:0]             rdata1;

    input  logic [REG_ADDR_WIDTH-1:0]   raddr2;
    output logic [XLEN-1:0]             rdata2;

    input  logic en_write;
    input  logic [REG_ADDR_WIDTH-1:0]   waddr;
    input  logic [XLEN-1:0]             wdata;
);

    logic [XLEN-1:0] regs[0:REG_NUM-1];

    // Synchronous write data
    integer i;
    always_ff @(posedge clk or negedge rstn) begin: WRITE_DATA
        if(!rstn) begin
            for (i = 0; i < REG_NUM; i = i + 1) begin
                regs[i] <= {XLEN{1'b0}}
            end
        end else begin
            if (en_write && (waddr != 5'b0)) begin
                regs[waddr] <= wdata;
            end
        end
    end

    // Asynchronous read
    always_comb begin : READ_DATA_1
        if (raddr1 == 5'b0) begin
            rdata1 = {XLEN{1'b0}};
        end else if ((en_write && (waddr == raddr1))) begin
            rdata1 = wdata;
        end else begin
            rdata1 = regs[raddr1];
        end
    end

    always_comb begin : READ_DATA_2
        if (raddr2 == 5'b0) begin
            rdata2 = {XLEN{1'b0}};
        end else if ((en_write && (waddr == raddr2))) begin
            rdata2 = wdata;
        end else begin
            rdata2 = regs[raddr2];
        end
    end

endmodule
