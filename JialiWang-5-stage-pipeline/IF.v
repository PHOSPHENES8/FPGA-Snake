module IF(
    input clk,
    input rst_n,

    input [1:0] PCSrc,
    input [31:0] nextPC,
    input [31:0] inst_sram_rdata,
    input stall,
    input flush,
    output [31:0] Inst,
    output [31:0] PC,
    output [31:0] PC4,
    output reg IF_addr_fault
);

    reg [31:0] PC_reg;
    reg start;

    assign PC = PC_reg;
    assign PC4 = PC_reg + 4;
    assign Inst = (inst_sram_rdata & {32{start}}) & {32{~flush}};

    always @(posedge clk) begin
        if(!rst_n)
            PC_reg <= 32'hbfc00000 - 4;
        else if(stall) begin
            PC_reg <= PC_reg;
        end
        else begin 
            case (PCSrc)
                2'b00: PC_reg <= PC_reg + 4;
                2'b01: PC_reg <= nextPC;
                2'b10: PC_reg <= 32'hBFC00380;
                default: PC_reg <= 0;
            endcase
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            start <= 0;
        end
        else start <= 1;
    end

    always @(*) begin
        case (PC[1:0])
            2'b00:IF_addr_fault = 0;
            2'b01:IF_addr_fault = 1 & (~flush);
            2'b10:IF_addr_fault = 1 & (~flush);
            2'b11:IF_addr_fault = 1 & (~flush);
            default: IF_addr_fault = 0;
        endcase
    end
endmodule // IF