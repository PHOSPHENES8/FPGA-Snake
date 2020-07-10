// pipeline reg

module ID_EX(
    input clk, 
    input rst_n,

    input [31:0] PC_in ,
    input [31:0] PC4_in,
    input [31:0] Inst_in,
    input [4:0] write_dst_in,
    input write_reg_in,
    input write_cp0reg_in,
    input [31:0] reg_data1_in,
    input [31:0] reg_data2_in,
    input [31:0] extImm_in,
    input [1:0] write_hilo_in,
    input trap_in,
    input [2:0] extOp_in,
    input [3:0] write_data_src_in,
    input [2:0] aluOp_in,
    // input [31:0] cp0_reg_in,
    input [4:0] sa_in,
    // input [31:0] nextPC_in,
    // input isbranch_in,
    input [3:0] data_sram_wen_in,
    // input [31:0] epc_data_in,
    input IF_addr_fault_in,
    input delay_slot_in,
    input ri_fault_in,
    input soft_int_in,

    input stall,

    output [31:0] PC_out ,            
    output [31:0] PC4_out,          
    output [31:0] Inst_out,         
    output [4:0] write_dst_out,      
    output write_reg_out,           
    output write_cp0reg_out,       
    output [31:0] reg_data1_out,    
    output [31:0] reg_data2_out,      
    output [31:0] extImm_out,       
    output [1:0] write_hilo_out,      
    // output [3:0] write_mem_out,      
    output trap_out,                
    output [2:0] extOp_out,         
    output [3:0] write_data_src_out,  
    output [2:0] aluOp_out,         
    // output [31:0] cp0_reg_out,       
    output [4:0] sa_out,
    // output [31:0] nextPC_out,
    // output isbranch_out,
    output [3:0] data_sram_wen_out,
    // output [31:0] epc_data_out,
    output IF_addr_fault_out,
    output delay_slot_out,
    // output ID_flush_out,
    output ri_fault_out,
    output soft_int_out
);
    reg [31:0] PC;
    reg [31:0] PC4;
    reg [4:0] write_dst;
    reg write_reg;
    reg write_cp0reg;
    reg [31:0] reg_data1, reg_data2,extImm, Inst;
    reg [1:0] write_hilo;
    // reg [3:0] write_mem;
    reg trap;
    reg [2:0] aluOp;
    reg [3:0] write_data_src;
    reg [2:0] extOp;
    // reg [31:0] cp0_reg;
    reg [4:0] sa;
    // reg [31:0] nextPC;
    // reg isbranch;
    reg [3:0]  data_sram_wen;
    // reg [31:0] epc_data;
    reg IF_addr_fault;
    reg delay_slot;
    // reg ID_flush;
    reg ri_fault;
    reg soft_int;

    assign PC_out = PC;
    assign PC4_out = PC4;
    assign write_dst_out = write_dst;
    assign write_reg_out = write_reg;
    assign write_cp0reg_out = write_cp0reg;
    assign reg_data1_out = reg_data1;
    assign reg_data2_out = reg_data2;
    assign extImm_out = extImm;
    assign Inst_out = Inst;
    assign write_hilo_out = write_hilo;
    // assign write_mem_out = write_mem;
    assign trap_out = trap;
    assign extOp_out = extOp;
    assign write_data_src_out = write_data_src;
    assign aluOp_out = aluOp;
    // assign cp0_reg_out = cp0_reg;
    assign sa_out = sa;
    // assign nextPC_out = nextPC;
    // assign isbranch_out = isbranch;
    assign data_sram_wen_out = data_sram_wen;
    // assign epc_data_out = epc_data;
    assign IF_addr_fault_out = IF_addr_fault;
    assign delay_slot_out = delay_slot;
    // assign ID_flush_out = ID_flush;
    assign ri_fault_out = ri_fault;
    assign soft_int_out = soft_int;

    always @(posedge clk) begin
        if(rst_n == 1'b0) begin
            PC <= 0;
            PC4 <= 0;
            write_dst <= 0;
            write_reg <= 0;
            write_cp0reg <= 0;
            reg_data1 <= 0;
            reg_data2 <= 0;
            extImm <= 0;
            Inst <= 0;
            write_hilo <= 0;
            // write_mem <= 0;
            trap <= 0;
            aluOp <= 0;
            write_data_src <= 0;
            extOp <= 0;
            // cp0_reg <= 0;
            sa <= 0;
            // nextPC <= 32'hbfc00000;
            // isbranch <= 0;
            data_sram_wen <= 0;
            // epc_data <= 0;
            IF_addr_fault <= 0;
            delay_slot <= 0;
            // ID_flush <= 0;
            ri_fault <= 0;
            soft_int <= 0;
        end
        else if(!stall) begin
            PC <=  PC_in;
            PC4 <= PC4_in;
            write_dst <= write_dst_in;
            write_reg <= write_reg_in ;
            write_cp0reg <= write_cp0reg_in;
            reg_data1 <= reg_data1_in;
            reg_data2 <= reg_data2_in;
            extImm <= extImm_in;
            Inst <= Inst_in;    
            write_hilo <= write_hilo_in;
            // write_mem <= write_mem_in;
            trap <= trap_in;
            extOp <= extOp_in;
            write_data_src <=  write_data_src_in;
            aluOp <= aluOp_in;
            // cp0_reg <= cp0_reg_in;
            sa <= sa_in;
            // nextPC <= nextPC_in;
            // isbranch <= isbranch_in;
            data_sram_wen <= data_sram_wen_in;
            // epc_data <= epc_data_in;
            IF_addr_fault <= IF_addr_fault_in;
            delay_slot <= delay_slot_in;
            // ID_flush <= ID_flush_in;
            ri_fault <= ri_fault_in;
            soft_int <= soft_int_in;
        end
    end


endmodule // ID_EX