module IM_Interface(
    input [1:0] PCSrc,
    input [31:0] PC4,
    input [31:0] nextPC,
    input [31:0] inst_sram_rdata,

    input stall,
    
    output inst_sram_en,
    output [3:0]  inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] Inst
);

    assign Inst = inst_sram_rdata;
    assign inst_sram_en = 1;
    assign inst_sram_wen = 0;
    assign inst_sram_addr = (InstSramAddr(PCSrc, PC4, nextPC) & {32{~stall}})
                            | ({32{stall}} & (PC4-4));

    function [31:0] InstSramAddr;
        input [1:0] PCSrc;
        input [31:0] PC4;
        input [31:0] nextPC;
        case (PCSrc)
            2'b00: InstSramAddr = PC4;
            2'b01: InstSramAddr = nextPC;
            2'b10: InstSramAddr = 32'hBFC00380;
            default: InstSramAddr = PC4+4;
        endcase
    endfunction
endmodule // IM_Interface