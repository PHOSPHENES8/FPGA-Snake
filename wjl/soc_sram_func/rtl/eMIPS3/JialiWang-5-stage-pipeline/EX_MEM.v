module EX_MEM(
    input clk,
    input rst_n,

    input [31:0] PC_in,
    input [31:0] PC4_in,
    input [31:0] Inst_in,
    input [3:0] data_sram_wen_in,
    input [31:0] data_sram_addr_in,
    input [31:0] data_sram_wdata_in,
    // input [31:0] write_data_in,
    input write_reg_in,
    input write_cp0reg_in,
    input [4:0] write_dst_in,
    input [31:0] reg_data1_in,
    input [31:0] reg_data2_in,
    input [1:0] write_hilo_in,
    input [63:0] hilo_in, // from mult and div
    input [2:0] extOp_in,
    input [3:0] write_data_src_in,
    input [31:0] alu_a_in,
    input [31:0] alu_s_in,
    input [31:0] alu_c_in,
    input trap_in,
    input IF_addr_fault_in,
    input ri_fault_in,
    input overflow_in,
    input soft_int_in,
    input delay_slot_in,

    output [31:0] PC_out,
    output [31:0] PC4_out,
    output [31:0] Inst_out,
    output [3:0] data_sram_wen_out,
    output [31:0] data_sram_addr_out,
    output [31:0] data_sram_wdata_out,
    // output [31:0] write_data_out,
    output write_reg_out,
    output write_cp0reg_out,
    output [4:0] write_dst_out,
    output [31:0] reg_data1_out,
    output [31:0] reg_data2_out,
    output [1:0] write_hilo_out,
    output [63:0] hilo_out,  
    output [2:0] extOp_out,
    output [3:0] write_data_src_out,
    output [31:0] alu_a_out,
    output [31:0] alu_s_out,
    output [31:0] alu_c_out,
    output trap_out ,
    output IF_addr_fault_out,
    output ri_fault_out,
    output overflow_out,
    output soft_int_out,
    output delay_slot_out
);

    reg [31:0] PC;
    reg [31:0] PC4;
    reg [31:0] Inst;
    reg [3:0] data_sram_wen;
    reg [31:0] data_sram_addr;
    reg [31:0] data_sram_wdata;
    // reg [31:0] write_data;
    reg write_reg;
    reg write_cp0reg;
    reg [4:0] write_dst;
    reg [31:0] reg_data1;
    reg [31:0] reg_data2;
    reg [1:0] write_hilo;
    reg [63:0] hilo;
    reg [2:0] extOp;
    reg [3:0] write_data_src;
    reg [31:0] alu_a;
    reg [31:0] alu_s;
    reg [31:0] alu_c;
    reg trap;
    reg IF_addr_fault;
    reg ri_fault;
    reg overflow;
    reg soft_int;
    reg delay_slot;
    
    assign PC_out = PC;
    assign PC4_out = PC4;
    assign Inst_out = Inst;
    assign data_sram_wen_out = data_sram_wen;
    assign data_sram_addr_out = data_sram_addr;
    assign data_sram_wdata_out = data_sram_wdata;
    // assign write_data_out = write_data;
    assign write_reg_out = write_reg;
    assign write_cp0reg_out = write_cp0reg;
    assign write_dst_out = write_dst;
    assign reg_data1_out = reg_data1;
    assign reg_data2_out = reg_data2;
    assign write_hilo_out = write_hilo;
    assign hilo_out = hilo;
    assign extOp_out = extOp;
    assign write_data_src_out = write_data_src;
    assign alu_a_out = alu_a;
    assign alu_s_out = alu_s;
    assign alu_c_out = alu_c;
    assign trap_out  = trap;
    assign IF_addr_fault_out = IF_addr_fault;
    assign ri_fault_out = ri_fault;
    assign overflow_out = overflow;
    assign delay_slot_out = delay_slot;
    assign soft_int_out = soft_int;


    always @(posedge clk) begin
        if(!rst_n) begin 
            PC <= 0;
            PC4 <= 0;
            Inst <= 0;
            data_sram_wen <= 0;
            data_sram_addr <= 0;
            data_sram_wdata <= 0;
            // write_data <= 0;
            write_reg <= 0;
            write_cp0reg <=0 ;
            write_dst <= 0;
            reg_data1 <= 0;
            reg_data2 <= 0;
            write_hilo <= 0;
            hilo <=0 ;
            extOp <= 0;
            write_data_src <= 0;
            alu_a <= 0;
            alu_s <= 0;
            alu_c <= 0;
            trap <= 0;
            IF_addr_fault <= 0;
            ri_fault <= 0;
            overflow <= 0;
            delay_slot <= 0;
            soft_int <= 0;
        end 
        else begin
            PC <= PC_in;
            PC4 <= PC4_in;
            Inst <= Inst_in;
            data_sram_wen <= data_sram_wen_in;
            data_sram_addr <= data_sram_addr_in;
            data_sram_wdata <= data_sram_wdata_in ;
            // write_data <= write_data_in;
            write_reg <= write_reg_in;
            write_cp0reg <= write_cp0reg_in;
            write_dst <= write_dst_in;
            reg_data1 <= reg_data1_in;
            reg_data2 <= reg_data2_in;
            write_hilo <= write_hilo_in;
            hilo <= hilo_in;
            extOp <= extOp_in;
            write_data_src <= write_data_src_in;
            alu_a <= alu_a_in;
            alu_s <= alu_s_in;
            alu_c <= alu_c_in;
            trap <= trap_in;
            IF_addr_fault <= IF_addr_fault_in;
            ri_fault <= ri_fault_in;
            overflow <= overflow_in;
            delay_slot <= delay_slot_in;
            soft_int <= soft_int_in;
        end
    end
endmodule // EX_MEM