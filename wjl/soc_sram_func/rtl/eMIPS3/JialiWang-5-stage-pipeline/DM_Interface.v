// 5 stage pipeline 

module DM_Interface(
    input [3:0] data_sram_wen_in, // from MEM stage 
    input [31:0] EX_data_sram_addr,
    input [31:0] MEM_data_sram_addr,
    input addrSrc,                     // if ID nop then 1
    input [31:0] data_sram_wdata_in ,  // from EX stage
    input [31:0] data_sram_rdata_in,   // from MEM

    output data_sram_en,               // to MEM
    output [3:0] data_sram_wen_out,    // to MEM
    output [31:0] data_sram_addr,      // to MEM
    output [31:0] data_sram_wdata_out, // to MEM
    output [31:0] data_sram_rdata_out // to EX stage 

);

    assign data_sram_en = 1;
    assign data_sram_wen_out = data_sram_wen_in;
    wire [31:0] data_sram_addr_raw = addrSrc ? MEM_data_sram_addr : EX_data_sram_addr;
    assign data_sram_addr = ( data_sram_addr_raw[31:28] == 4'ha 
        || data_sram_addr_raw[31:28] == 4'hb ) ? data_sram_addr_raw - 32'ha0000000 : data_sram_addr_raw;
    // assign data_sram_wdata_out = data_sram_wdata_in;
    assign data_sram_wdata_out = DataSramWdata(data_sram_wdata_in, data_sram_addr);
    assign data_sram_rdata_out = data_sram_rdata_in;

    function [31:0] DataSramWdata;
        input [31:0] data_sram_wdata_in;
        input [31:0] data_sram_addr;

        case (data_sram_addr[1:0])
            2'b00: DataSramWdata = data_sram_wdata_in;
            2'b01: DataSramWdata = {data_sram_wdata_in[23:0], 8'b0};
            2'b10: DataSramWdata = {data_sram_wdata_in[15:0], 16'b0};
            2'b11: DataSramWdata = {data_sram_wdata_in[7:0], 24'b0};
            default: DataSramWdata = data_sram_wdata_in;
        endcase
    endfunction

endmodule // DM_inferface