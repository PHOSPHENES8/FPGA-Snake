module MEM(
    input clk,
    input rst_n,

    input [31:0] PC_in,
    input [31:0] PC4_in,
    input [31:0] Inst_in,
    input [3:0] data_sram_wen_in,
    input [31:0] data_sram_wdata_in,
    input [31:0] data_sram_rdata,
    // input [31:0] write_data
    input write_reg_in,
    input write_cp0reg_in,
    input [4:0] write_dst_in,
    input [31:0] reg_data1_in,
    input [31:0] reg_data2_in,
    input [1:0] write_hilo_in,
    input [63:0] hilo_in,
    input [2:0] extOp,
    input [3:0] write_data_src_in,
    input [31:0] alu_a_in,
    input [31:0] alu_s_in,
    input [31:0] alu_c_in,
    input trap_in,
    input IF_addr_fault_in,
    input ri_fault_in,
    input soft_int_in,
    input overflow_in,
    input delay_slot_in,
    input flush,

    output [31:0] PC_out,
    output [31:0] PC4_out,
    output [31:0] Inst_out,
    output [3:0] data_sram_wen_out,
    output [31:0] data_sram_wdata_out,
    output [31:0] data_sram_addr,
    output write_reg_out,
    output write_cp0reg_out,
    output [4:0] write_dst_out,
    output [31:0] reg_data1_out,
    output [31:0] reg_data2_out,
    output [1:0] write_hilo_out,
    output [63:0] hilo_out,
    output [3:0] write_data_src_out,
    output [31:0] alu_a_out,
    output [31:0] alu_s_out,
    output [31:0] alu_c_out,
    output [31:0] mem_ext_data,
    output trap_out,
    output IF_addr_fault_out,
    output ri_fault_out,
    output overflow_out,
    output soft_int_out,
    output reg load_addr_fault,
    output reg store_addr_fault,
    output delay_slot_out
);

    assign PC_out = PC_in;
    assign PC4_out = PC4_in;
    assign Inst_out = Inst_in & {32{~flush}};
    assign data_sram_wen_out = data_sram_wen_in & {4{~flush}};
    assign data_sram_wdata_out = data_sram_wdata_in;
    assign data_sram_addr = alu_a_in;
    assign write_reg_out = write_reg_in & (~flush);
    assign write_cp0reg_out = write_cp0reg_in & (~flush);
    assign write_dst_out = write_dst_in;
    assign reg_data1_out = reg_data1_in;
    assign reg_data2_out = reg_data2_in;
    assign write_hilo_out = write_hilo_in & {2{~flush}};
    assign hilo_out = hilo_in;
    assign write_data_src_out = write_data_src_in;
    assign alu_a_out = alu_a_in;
    assign alu_c_out = alu_c_in;
    assign alu_s_out = alu_s_in;
    assign mem_ext_data = MemDataExt(data_sram_rdata, extOp, data_sram_addr);

    assign trap_out = trap_in &(~flush);  
    assign IF_addr_fault_out = IF_addr_fault_in &(~flush);
    assign ri_fault_out = ri_fault_in &(~flush) ;
    assign soft_int_out = soft_int_in &(~flush) ;
    assign overflow_out = overflow_in &(~flush) ;
    assign delay_slot_out = delay_slot_in & (~flush);


    always @(*) begin
        case (Inst_in[31:26])
            6'b100001: begin
                load_addr_fault = alu_a_out[0];
                store_addr_fault = 0;
            end 
            6'b100101: begin
                load_addr_fault = alu_a_out[0];
                store_addr_fault = 0;
            end
            6'b100011: begin
                load_addr_fault = alu_a_out | alu_a_out[1];
                store_addr_fault = 0;
            end
            6'b101001:begin
                load_addr_fault = 0;
                store_addr_fault = alu_a_out[0];
            end
            6'b101011:begin
                load_addr_fault = 0;
                store_addr_fault = alu_a_out[0] | alu_a_out[1];
            end
            default: begin
                load_addr_fault = 0;
                store_addr_fault = 0;
            end
        endcase
    end
    // function AddrFault;
    //     input [31:0]  alu_a_out;
    //     input [31:0] Inst;
    //     case (Inst[31:26])
    //         6'b100001:AddrFault = alu_a_out[0] ;
    //         6'b100101: AddrFault = alu_a_out[0];
    //         6'b100011: AddrFault = alu_a_out[0] | alu_a_out[1];
    //         6'b101001: AddrFault = alu_a_out[0];
    //         6'b101011: AddrFault = alu_a_out[0] | alu_a_out[1];
    //         default: AddrFault = 0; 
    //     endcase
    // endfunction


    function [31:0] MemDataExt;
        input[31:0] data_sram_rdata;
        input [2:0] extOp;
        input [31:0] data_sram_addr;
        reg [31:0] data_sram_rdata_real;
        begin
        case (data_sram_addr[1:0]) 
            2'b00: data_sram_rdata_real = data_sram_rdata;
            2'b01: data_sram_rdata_real = {8'b0, data_sram_rdata[31:8]} ;
            // 2'b10: data_sram_rdata_real = {16'b0, data_sram_rdata[8:31]} ;
            2'b10: data_sram_rdata_real = {16'b0, data_sram_rdata[31:16]};
            2'b11: data_sram_rdata_real = {24'b0, data_sram_rdata[31:24]};
            default: data_sram_rdata_real = data_sram_rdata;
        endcase
        case (extOp)
            3'b000:MemDataExt = {{24{data_sram_rdata_real[7]}} ,data_sram_rdata_real[7:0]};
            3'b001:MemDataExt = {24'b0, data_sram_rdata_real[7:0]};
            3'b010:MemDataExt = {{16{data_sram_rdata_real[15]}}, data_sram_rdata_real[15:0]};
            3'b011:MemDataExt = {16'b0, data_sram_rdata_real[15:0]};
            3'b100:MemDataExt = data_sram_rdata_real;
            default: MemDataExt = data_sram_rdata_real;
        endcase
        end
    endfunction
endmodule // MEM