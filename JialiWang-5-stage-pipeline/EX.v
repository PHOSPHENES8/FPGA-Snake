module EX(
    input clk,
    input rst_n,

    input [31:0] PC_in,
    input [31:0] PC4_in,
    input [4:0] write_dst_in,
    input write_reg_in,
    input write_cp0reg_in,
    input [31:0]  reg_data1_in,
    input [31:0] reg_data2_in,
    input [31:0] extImm,
    input [31:0] Inst_in,
    input [1:0] write_hilo_in,
    input trap_in,
    input [2:0] extOp_in,
    input [3:0] write_data_src_in,
    input [2:0] aluOp,
    input [4:0] sa,
    // input [31:0] data_sram_rdata,
    input flush,
    // input stall ,
    // input [31:0] nextPC_in,
    // input isbranch_in,
    input [3:0] data_sram_wen_in,
    // input [31:0] epc_data,
    input IF_addr_fault_in,
    input delay_slot_in,
    // input ID_flush,
    input ri_fault_in,
    input soft_int_in,

    input [31:0] fwd_data1,
    input [31:0] fwd_data2,
    input [1:0] fwdSrc,

    // output data_sram_en,
    output [31:0] PC_out,
    output [31:0] Inst_out,
    output [31:0] PC4_out,
    output[3:0]  data_sram_wen_out,
    output [31:0] data_sram_addr, 
    output [31:0] data_sram_wdata,
    // output exception,
    // output [31:0] write_data,
    // output [31:0] epc,
    output write_reg_out,
    // output write_epc,
    output write_cp0reg_out,
    output [4:0] write_dst_out,
    // output [31:0] nextPC_out,
    output [31:0] reg_data1_out,
    output [31:0] reg_data2_out,
    output [1:0] write_hilo_out,
    output [2:0] extOp_out,
    output [3:0] write_data_src_out,
    output [31:0] alu_a_out,
    output [31:0] alu_s_out,
    output [31:0] alu_c_out,

    output trap_out,
    output IF_addr_fault_out,
    output ri_fault_out,
    output overflow_out,
    output soft_int_out,
    output delay_slot_out
    // output isbranch_out,
);

    // reg[31:0] Hi, Lo;
    // reg[31:0] Cause;
    // reg[31:0] BadVAddr;
    // reg[31:0] Status;
    reg [31:0] reg_data1;
    reg [31:0] reg_data2;

    wire [31:0] valA_a = reg_data1;
    wire [31:0] valB_a = Inst_in[31:29] == 3'b000 ? reg_data2 : extImm;
    wire [31:0] valA_s = Inst_in[2] == 1'b1 ? reg_data1[4:0] : sa;
    wire [31:0] valB_s = reg_data2;
    wire [31:0] valA_c = valA_a;
    wire [31:0] valB_c = valB_a;
    // wire [31:0] alu_a_out, alu_s_out, alu_c_out;
    wire overflow;
    // wire [31:0] exception_cause;
    // wire [31:0] hi_out, lo_out; // mult div

    // wire soft_int; // ??? not sure 
    // wire exception;

    wire alu_a_overflow;
    ALU_a ALU_a_U(valA_a, valB_a, aluOp, alu_a_out, alu_a_overflow);
    // assign overflow = (Inst[31:26] == 0 ? (Inst[5:0] == 6'b100000 || 6'b100010) : (Inst[31:26] == 6'b001000) ) & alu_a_overflow;
    assign overflow = OverFlow(Inst_in, alu_a_overflow);
    
    // assign isbranch_out = isbranch_in;


    ALU_s ALU_s_U(valA_s, valB_s, aluOp, alu_s_out);
    ALU_c ALU_c_U(valA_c, valB_c, aluOp, alu_c_out);
    // MUL_DIV MUL_DIV_U(reg_data1_in, reg_data2_in, Inst_in[1:0], hi_out, lo_out);

    // wire addrFault = AddrFault(alu_a_out, Inst);
    // Exception Exception_U(trap, overflow, addrFault, IF_addr_fault, ri_fault, soft_int, Inst, delay_slot,
    //     exception, exception_cause);

    // assign data_sram_en = 1;
    // assign data_sram_wen = write_data & {4{flush}};
    assign data_sram_wen_out = data_sram_wen_in & {4{~flush}};
    assign PC_out = PC_in;
    assign Inst_out = Inst_in & {32{~flush}};
    assign PC4_out = PC4_in;
    assign data_sram_addr = alu_a_out;
    // assign data_sram_addr = reg_data1 + (extImm << 2); // because addr to datas_sram is [17:2]; 
    assign data_sram_wdata = reg_data2;
    // assign soft_int_out = soft_int_in;
    // assign delay_slot_out = delay_slot_in;
    assign write_reg_out = write_reg_in & (~flush);
    assign write_cp0reg_out = write_cp0reg_in & (~flush);
    assign write_dst_out = write_dst_in;
    assign reg_data1_out = reg_data1;
    assign reg_data2_out = reg_data2;
    assign write_hilo_out = write_hilo_in & {2{~flush}};
    assign extOp_out = extOp_in;
    assign write_data_src_out = write_data_src_in;

    assign trap_out = trap_in & (~flush);
    assign IF_addr_fault_out = IF_addr_fault_in & (~flush);
    assign ri_fault_out = ri_fault_in &  (~flush);
    assign overflow_out = overflow & (~flush);
    assign soft_int_out = soft_int_in & (~flush);
    assign delay_slot_out = delay_slot_in & (~flush);

    // fwd
    always @(*) begin
        if(fwdSrc[0]) reg_data1 = fwd_data1;
        else reg_data1 = reg_data1_in;
    end
    always @(*) begin
        if(fwdSrc[1]) reg_data2 = fwd_data2;
        else reg_data2 = reg_data2_in;
    end


    function OverFlow;
        input[31:0] Inst;
        input alu_a_overflow;
        if(Inst[31:26] == 0) begin // Rtype
            case (Inst[5:0])    
                6'b100000:OverFlow = alu_a_overflow;
                6'b100010:OverFlow = alu_a_overflow; 
                default: OverFlow = 0;
            endcase
        end
        else if(Inst[31:26] == 6'b001000)begin
            OverFlow = alu_a_overflow;
        end
        else OverFlow = 0;
    endfunction
    // wire [31:0] mem_data_ext = MemDataExt(data_sram_rdata, extOp, data_sram_addr);

    // assign exception =
    // wire [31:0] hilo = Inst[1] ? Lo : Hi;
    // reg  [31:0] cp0_reg_data;
    // always @(*) begin
    //     if(Inst[2:0] == 0) begin
    //         case (Inst[15:11])
    //             8:  cp0_reg_data = BadVAddr;
    //             12: cp0_reg_data = Status;
    //             13: cp0_reg_data = Cause;
    //             14: cp0_reg_data = epc_data; 
    //             default: cp0_reg_data = 0;
    //         endcase
    //     end
    //     else cp0_reg_data = 0;
    // end
    // assign write_data = WriteData(write_data_src, alu_a_out, alu_c_out, alu_s_out,
    //         PC4, hilo, reg_data1, mem_data_ext, cp0_reg_data, reg_data2);
    // // assign epc = exception ? (trap ? PC4 : PC) : 0;
    // assign epc = EpcData(exception, trap, write_cp0reg_in, reg_data2, Inst, PC, delay_slot);
    // assign write_reg_out = write_reg_in & (~flush);
    // assign write_epc = (exception || ( write_cp0reg_out && Inst[15:11] == 14 && Inst[2:0] == 0 ) ) ;
    // assign write_cp0reg_out = write_cp0reg_in & (~flush);
    // assign write_dst_out = write_dst_in;
    // assign nextPC_out = nextPC_in;

    // assign soft_int = isbranch_in && (nextPC_in == PC ? 1 : 0);

    // hi lo
    // always @(posedge clk) begin
    //     if(rst_n == 1'b0) begin
    //         Hi <= 0;
    //         Lo <= 0;
    //     end  
    //     else begin
    //         if(write_hilo == 2'b11 && flush == 1'b0) begin
    //             Hi <= hi_out;
    //             Lo <= lo_out;
    //         end
    //         else if(write_hilo == 2'b10 && flush == 1'b0) 
    //             Hi <= reg_data1;  
    //         else if(write_hilo == 2'b01 && flush == 1'b0)
    //             Lo <= reg_data1;
    //     end
    // end
    // // cause status badVaddr
    // always @(posedge clk) begin
    //     if(rst_n == 1'b0) Cause <= 0;
    //     else if(ID_flush) Cause <= Cause;
    //     else if(exception) Cause <= exception_cause; 
    //     else if(write_cp0reg_in && Inst[15:11] == 13 && Inst[2:0] == 0) begin
    //         Cause <= reg_data2;
    //     end 
    // end
    // always @(posedge clk) begin
    //     if(!rst_n) BadVAddr <= 0;
    //     else if(ID_flush) BadVAddr <= BadVAddr;
    //     else if (addrFault) begin // data mem addr fault
    //         BadVAddr <= data_sram_addr;
    //     end
    //     else if(IF_addr_fault) begin
    //         BadVAddr <= PC;
    //     end
    //     else if(write_cp0reg_in && Inst[15:11] == 8 && Inst[2:0] == 0) // mtc0
    //         BadVAddr <= reg_data2;
    // end
    // always @(posedge clk) begin
    //     if(!rst_n) Status <= 0;
    //     if(ID_flush) Status <= Status;
    //     else if(exception) begin
    //         Status <= Status | 2;
    //     end 
    //     else if(write_cp0reg_in && Inst[15:11] == 12 && Inst[2:0] == 0) 
    //         Status <= reg_data2;
    // end

  
    

    // function [31:0] WriteData;
    //     input [3:0] write_data_src;
    //     input [31:0] alu_a_out, alu_c_out, alu_s_out;
    //     input [31:0] PC4;
    //     input [31:0] hilo;
    //     input [31:0] reg_data1;
    //     input [31:0] mem_data_ext;
    //     input [31:0] cp0_reg;
    //     input [31:0] reg_data2;
    //     case (write_data_src)
    //         0 : WriteData = alu_a_out;
    //         1: WriteData = alu_c_out;
    //         2: WriteData = alu_s_out;
    //         3: WriteData = PC4+4; // delay slot
    //         4: WriteData = hilo;
    //         5: WriteData = reg_data1;
    //         6: WriteData = mem_data_ext;
    //         7: WriteData = cp0_reg;
    //         8: WriteData = reg_data2;
    //         default: WriteData = 0;
    //     endcase
    // endfunction



    // function [31:0] EpcData;
    //     input exception;
    //     input trap;
    //     input write_cp0reg;
    //     input [31:0] reg_data;
    //     input [31:0] Inst;
    //     input [31:0] PC;
    //     input delay_slot;

    //     if(exception) begin
    //         EpcData = delay_slot ? PC-4 : PC;
    //     end
    //     else if(write_cp0reg)   
    //         EpcData = reg_data;
    //     else EpcData = 0;
    // endfunction
endmodule // 