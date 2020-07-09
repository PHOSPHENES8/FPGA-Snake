module mycpu_top(
    input clk, 
    input resetn,
    input int,

    output inst_sram_en,
    output [3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input [31:0] inst_sram_rdata,

    output data_sram_en,
    output [3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input [31:0] data_sram_rdata,

    output [31:0] debug_wb_pc,
    output [3:0] debug_wb_rf_wen,
    output [4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata

);
    // IF in
    wire [1:0] IF_PCSrc_in;
    wire [31:0] IF_nextPC_in;
    wire [31:0] IF_inst_sram_rdata_in;
    wire IF_stall_in;
    wire IF_flush_in;
    // IF out
    wire [31:0] IF_Inst_out;
    wire [31:0] IF_PC_out;
    wire [31:0] IF_PC4_out;
    wire IF_addr_fault_out;

    // IM interface in
    wire [1:0] IM_Interface_PCSrc_in;
    wire [31:0] IM_Interface_PC4_in ;
    wire [31:0] IM_Interface_nextPC_in;
    wire [31:0] IM_Interface_inst_sram_rdata_in = inst_sram_rdata;
    // IM interface out
    wire IM_Interface_inst_sram_en_out;
    wire [3:0] IM_Interface_inst_sram_wen_out;
    wire [31:0] IM_Interface_inst_sram_addr_out;
    wire [31:0] IM_Interface_Inst_out;

    assign inst_sram_en = IM_Interface_inst_sram_en_out;
    assign inst_sram_wen = IM_Interface_inst_sram_wen_out;
    assign inst_sram_wdata = 0;
    assign inst_sram_addr = IM_Interface_inst_sram_addr_out;

    IF IF_U(
        .clk(clk),
        .rst_n(resetn),
        
        .PCSrc(IF_PCSrc_in),
        .nextPC(IF_nextPC_in),
        .inst_sram_rdata(IF_inst_sram_rdata_in),
        .stall(IF_stall_in),
        .flush(IF_flush_in),

        .Inst(IF_Inst_out),
        .PC(IF_PC_out),
        .PC4(IF_PC4_out),
        .IF_addr_fault(IF_addr_fault_out)
    );

    wire IF_ID_stall;
    IM_Interface IM_Interface_U(
        .PCSrc(IM_Interface_PCSrc_in),
        .PC4(IM_Interface_PC4_in),
        .nextPC(IM_Interface_nextPC_in),
        .inst_sram_rdata(IM_Interface_inst_sram_rdata_in),

        .stall(IF_ID_stall),
        
        .inst_sram_en(IM_Interface_inst_sram_en_out),
        .inst_sram_wen(IM_Interface_inst_sram_wen_out),
        .inst_sram_addr(IM_Interface_inst_sram_addr_out),
        .Inst(IM_Interface_Inst_out)
    );

    // ID in
    wire [31:0] ID_PC_in;
    wire [31:0] ID_PC4_in;
    wire [31:0] ID_Inst_in;
    wire [4:0] ID_write_dst_in;
    wire ID_write_reg_in;
    wire [31:0] ID_write_reg_data_in;
    wire [31:0] ID_epc_in;
    wire ID_flush_in;
    wire ID_IF_addr_fault_in;
    // ID out
    wire [31:0] ID_PC_out;
    wire [31:0] ID_PC4_out;
    wire [31:0] ID_Inst_out;
    wire [4:0] ID_write_dst_out;
    wire ID_write_reg_out;
    wire ID_write_cp0reg_out;
    wire [31:0] ID_nextPC_out;
    wire [31:0] ID_reg_data1_out;
    wire [31:0] ID_reg_data2_out;
    wire [31:0] ID_extImm_out;
    wire [1:0] ID_write_hilo_out;
    wire ID_trap_out;
    wire [2:0] ID_extOp_out;
    wire [3:0] ID_write_data_src_out;
    wire [2:0] ID_aluOp_out;
    wire [4:0] ID_sa_out;
    wire ID_isbranch_out;
    wire [3:0] ID_data_sram_wen_out;
    wire [31:0] ID_data_sram_addr_out;
    wire ID_addrSrc_out;
    wire ID_IF_addr_fault_out;
    wire ID_delay_slot_out;
    wire ID_ri_fault_out;
    wire ID_soft_int_out;

    wire ID_stall_in;
    assign IF_ID_stall = ID_stall_in;
    IF_ID IF_ID_U(
        .clk(clk),
        .rst_n(resetn),

        .Inst_in(IF_Inst_out),
        .PC_in(IF_PC_out),
        .PC4_in(IF_PC4_out),
        .IF_addr_fault_in(IF_addr_fault_out),
        .stall(ID_stall_in),

        .Inst_out(ID_Inst_in),
        .PC_out(ID_PC_in),
        .PC4_out(ID_PC4_in),
        .IF_addr_fault_out(ID_IF_addr_fault_in)
    );

    wire [31:0] ID_fwd_data1;
    wire [31:0] ID_fwd_data2;
    wire [1:0] ID_fwdSrc;

    ID ID_U(
        .clk(clk),
        .rst_n(resetn),
        
        .PC_in(ID_PC_in),
        .PC4_in(ID_PC4_in),
        .Inst_raw(ID_Inst_in),
        .write_dst_in(ID_write_dst_in),
        .write_reg_in(ID_write_reg_in),
        .write_reg_data(ID_write_reg_data_in),
        .epc(ID_epc_in),
        .flush(ID_flush_in),
        .IF_addr_fault_in(ID_IF_addr_fault_in),

        .ID_fwd_data1(ID_fwd_data1),
        .ID_fwd_data2(ID_fwd_data2),
        .ID_fwdSrc(ID_fwdSrc),
        
        .PC_out(ID_PC_out),
        .PC4_out(ID_PC4_out),
        .Inst_out(ID_Inst_out),
        .write_dst_out(ID_write_dst_out),
        .write_reg_out(ID_write_reg_out),
        .write_cp0reg_out(ID_write_cp0reg_out),
        .nextPC(ID_nextPC_out),
        .reg_data1(ID_reg_data1_out),
        .reg_data2(ID_reg_data2_out),
        .extImm(ID_extImm_out),
        .write_hilo(ID_write_hilo_out),
        .trap(ID_trap_out),
        .extOp(ID_extOp_out),
        .write_data_src(ID_write_data_src_out),
        .aluOp(ID_aluOp_out),
        .sa(ID_sa_out),
        .isbranch(ID_isbranch_out),
        .data_sram_wen(ID_data_sram_wen_out),
        .data_sram_addr(ID_data_sram_addr_out),
        .addrSrc(ID_addrSrc_out),
        .IF_addr_fault_out(ID_IF_addr_fault_out),
        .delay_slot_out(ID_delay_slot_out),
        .ri_fault(ID_ri_fault_out),
        .soft_int(ID_soft_int_out)
    );

    // inital IM interface input 
    // assign IM_Interface_PCSrc_in 
    assign IM_Interface_PC4_in = IF_PC4_out;
    assign IM_Interface_nextPC_in = ID_nextPC_out; 
    // --------------


    // EX_ in
    wire [31:0] EX_PC_in;
    wire [31:0] EX_PC4_in;
    wire [4:0] EX_write_dst_in;
    wire EX_write_reg_in;
    wire EX_write_cp0reg_in;
    wire [31:0] EX_reg_data1_in;
    wire [31:0] EX_reg_data2_in;
    wire [31:0] EX_extImm_in;
    wire [31:0] EX_Inst_in;
    wire [1:0] EX_write_hilo_in;
    // wire [3:0] EX_write_mem_in; // not use
    wire EX_trap_in;
    wire [2:0] EX_extOp_in;
    wire [3:0] EX_write_data_src_in;
    wire [2:0] EX_aluOp_in;
    wire [4:0] EX_sa_in;
    wire EX_flush_in;
    wire [3:0] EX_data_sram_wen_in;
    wire EX_IF_addr_fault_in;
    wire EX_delay_slot_in;
    wire EX_ri_fault_in;
    wire EX_soft_int_in;
    // EX_out
    wire [31:0] EX_PC_out;
    wire [31:0] EX_Inst_out;
    wire [31:0] EX_PC4_out;
    wire [3:0] EX_data_sram_wen_out;
    wire [31:0] EX_data_sram_addr_out;
    wire [31:0] EX_data_sram_wdata_out;
    wire EX_write_reg_out;
    wire EX_write_cp0reg_out;
    wire [4:0] EX_write_dst_out;
    wire [31:0] EX_reg_data1_out;
    wire [31:0] EX_reg_data2_out;
    wire [1:0] EX_write_hilo_out;
    wire [2:0] EX_extOp_out;
    wire [3:0] EX_write_data_src_out;
    wire [31:0] EX_alu_a_out;
    wire [31:0] EX_alu_s_out;
    wire [31:0] EX_alu_c_out;
    wire EX_trap_out;
    wire EX_IF_addr_fault_out;
    wire EX_ri_fault_out;
    wire EX_overflow_out;
    wire EX_soft_int_out;
    wire EX_delay_slot_out;

    wire EX_stall ;
    ID_EX ID_EX_U(
        .clk(clk),
        .rst_n(resetn),

        .PC_in(ID_PC_out),
        .PC4_in(ID_PC4_out),
        .Inst_in(ID_Inst_out),
        .write_dst_in(ID_write_dst_out),
        .write_reg_in(ID_write_reg_out),
        .write_cp0reg_in(ID_write_cp0reg_out),
        .reg_data1_in(ID_reg_data1_out),
        .reg_data2_in(ID_reg_data2_out),
        .extImm_in(ID_extImm_out),
        .write_hilo_in(ID_write_hilo_out),
        .trap_in(ID_trap_out),
        .extOp_in(ID_extOp_out),
        .write_data_src_in(ID_write_data_src_out),
        .aluOp_in(ID_aluOp_out),
        .sa_in(ID_sa_out),
        .data_sram_wen_in(ID_data_sram_wen_out),
        .IF_addr_fault_in(ID_IF_addr_fault_out),
        .delay_slot_in(ID_delay_slot_out),
        .ri_fault_in(ID_ri_fault_out),
        .soft_int_in(ID_soft_int_out),

        .stall(EX_stall),

        .PC_out(EX_PC_in),
        .PC4_out(EX_PC4_in),
        .Inst_out(EX_Inst_in),
        .write_dst_out(EX_write_dst_in),
        .write_reg_out(EX_write_reg_in),
        .write_cp0reg_out(EX_write_cp0reg_in),
        .reg_data1_out(EX_reg_data1_in),
        .reg_data2_out(EX_reg_data2_in),
        .extImm_out(EX_extImm_in),
        .write_hilo_out(EX_write_hilo_in),
        // .write_mem_out(EX_write_mem_in),
        .trap_out(EX_trap_in),
        .extOp_out(EX_extOp_in),
        .write_data_src_out(EX_write_data_src_in),
        .aluOp_out(EX_aluOp_in),
        .sa_out(EX_sa_in),
        .data_sram_wen_out(EX_data_sram_wen_in),
        .IF_addr_fault_out(EX_IF_addr_fault_in),
        .delay_slot_out(EX_delay_slot_in),
        .ri_fault_out(EX_ri_fault_in),
        .soft_int_out(EX_soft_int_in)
    );

    // forwarding 
    
    wire [31:0] fwd_data1;
    wire [31:0] fwd_data2;
    wire [1:0] fwdSrc;



    EX EX_U(
        .clk(clk),
        .rst_n(resetn),
        
        .PC_in(EX_PC_in),
        .PC4_in(EX_PC4_in),
        .write_dst_in(EX_write_dst_in),
        .write_reg_in(EX_write_reg_in),
        .write_cp0reg_in(EX_write_cp0reg_in),
        .reg_data1_in(EX_reg_data1_in),
        .reg_data2_in(EX_reg_data2_in),
        .extImm(EX_extImm_in),
        .Inst_in(EX_Inst_in),
        .write_hilo_in(EX_write_hilo_in),
        .trap_in(EX_trap_in),
        .extOp_in(EX_extOp_in),
        .write_data_src_in(EX_write_data_src_in),
        .aluOp(EX_aluOp_in),
        .sa(EX_sa_in),
        .flush(EX_flush_in),
        .data_sram_wen_in(EX_data_sram_wen_in),
        .IF_addr_fault_in(EX_IF_addr_fault_in),
        .delay_slot_in(EX_delay_slot_in),
        .ri_fault_in(EX_ri_fault_in),
        .soft_int_in(EX_soft_int_in),
        .fwd_data1(fwd_data1),
        .fwd_data2(fwd_data2),
        .fwdSrc(fwdSrc),

        .PC_out(EX_PC_out),
        .Inst_out(EX_Inst_out),
        .PC4_out(EX_PC4_out),
        .data_sram_wen_out(EX_data_sram_wen_out),
        .data_sram_addr(EX_data_sram_addr_out),
        .data_sram_wdata(EX_data_sram_wdata_out),
        .write_reg_out(EX_write_reg_out),
        .write_cp0reg_out(EX_write_cp0reg_out),
        .write_dst_out(EX_write_dst_out),
        .reg_data1_out(EX_reg_data1_out),
        .reg_data2_out(EX_reg_data2_out),
        .write_hilo_out(EX_write_hilo_out),
        .extOp_out(EX_extOp_out),
        .write_data_src_out(EX_write_data_src_out),
        .alu_a_out(EX_alu_a_out),
        .alu_c_out(EX_alu_c_out),
        .alu_s_out(EX_alu_s_out),
        .trap_out(EX_trap_out),
        .IF_addr_fault_out(EX_IF_addr_fault_out),
        .ri_fault_out(EX_ri_fault_out),
        .overflow_out(EX_overflow_out),
        .soft_int_out(EX_soft_int_out),
        .delay_slot_out(EX_delay_slot_out)
    );

    wire MUL_DIV_running;
    wire [63:0] MUL_DIV_hilo;
    
    // use * / % temporarily
    wire [31:0] MUL_DIV_hi;
    wire [31:0] MUL_DIV_lo;
    MUL_DIV MUL_DIV_U(
        .clk(clk),
        .rst_n(resetn),

        .reg_data1(EX_reg_data1_out),
        .reg_data2(EX_reg_data2_out),
        // .mult_div_op(EX_Inst_in[1:0]),
        .ID_Inst(ID_Inst_out),
        .Inst(EX_Inst_in),
        .running(MUL_DIV_running),
        .hi(MUL_DIV_hi),
        .lo(MUL_DIV_lo)
    );
    assign MUL_DIV_hilo = {MUL_DIV_hi, MUL_DIV_lo};

    /* --------- comment temporarily ---------- 
     * MUL_DIV MUL_DIV_U(
     *     .clk(clk),
     *     .rst_n(resetn),
     *     
     *     .Inst(ID_Inst_out),
     *     .reg_data1(ID_reg_data1_out),
     *     .reg_data2(ID_reg_data2_out),
     *     
     *     .running(MUL_DIV_running),
     *     .hilo(MUL_DIV_hilo)
     * );
     * ---------------------------------------*/


    // MEM in
    wire [31:0] MEM_PC_in;
    wire [31:0] MEM_PC4_in;
    wire [31:0] MEM_Inst_in;
    wire [3:0] MEM_data_sram_wen_in;
    wire [31:0] MEM_data_sram_wdata_in;
    wire [31:0] MEM_data_sram_rdata_in;
    wire MEM_write_reg_in;
    wire MEM_write_cp0reg_in;
    wire [4:0] MEM_write_dst_in;
    wire [31:0] MEM_reg_data1_in;
    wire [31:0] MEM_reg_data2_in;
    wire [1:0] MEM_write_hilo_in;
    wire [63:0] MEM_hilo_in;
    wire [2:0] MEM_extOp_in;
    wire [3:0] MEM_write_data_src_in;
    wire [31:0] MEM_alu_a_in;
    wire [31:0] MEM_alu_s_in;
    wire [31:0] MEM_alu_c_in;
    wire MEM_trap_in;
    wire MEM_IF_addr_fault_in;
    wire MEM_ri_fault_in;
    wire MEM_overflow_in;
    wire MEM_soft_int_in;
    wire MEM_delay_slot_in;
    wire MEM_flush_in;
    // MEM out 
    wire [31:0] MEM_PC_out;
    wire [31:0] MEM_PC4_out;
    wire [31:0] MEM_Inst_out;
    wire [3:0] MEM_data_sram_wen_out;
    wire [31:0] MEM_data_sram_wdata_out;
    wire [31:0] MEM_data_sram_addr_out;
    wire MEM_write_reg_out;
    wire MEM_write_cp0reg_out;
    wire [4:0] MEM_write_dst_out;
    wire [31:0] MEM_reg_data1_out;
    wire [31:0] MEM_reg_data2_out;
    wire [1:0] MEM_write_hilo_out;
    wire [63:0] MEM_hilo_out;
    wire [3:0] MEM_write_data_src_out;
    wire [31:0] MEM_alu_a_out;
    wire [31:0] MME_alu_s_out;
    wire [31:0] MEM_alu_c_out;
    wire [31:0] MEM_mem_ext_data_out;
    wire MEM_trap_out;
    wire MEM_IF_addr_fault_out;
    wire MEM_ri_fault_out;
    wire MEM_soft_int_out;
    wire MEM_overflow_out;
    wire MEM_load_addr_fault_out;
    wire MEM_store_addr_fault_out;
    wire MEM_delay_slot_out;

    EX_MEM EX_MEM_U(
        .clk(clk),
        .rst_n(resetn),

        .PC_in(EX_PC_out),
        .PC4_in(EX_PC4_out),
        .Inst_in(EX_Inst_out),
        .data_sram_wen_in(EX_data_sram_wen_out),
        .data_sram_addr_in(EX_data_sram_addr_out),
        .data_sram_wdata_in(EX_data_sram_wdata_out),
        .write_reg_in(EX_write_reg_out),
        .write_cp0reg_in(EX_write_cp0reg_out),
        .write_dst_in(EX_write_dst_out),
        .reg_data1_in(EX_reg_data1_out),
        .reg_data2_in(EX_reg_data2_out),
        .write_hilo_in(EX_write_hilo_out),
        .hilo_in(MUL_DIV_hilo),
        .extOp_in(EX_extOp_out),
        .write_data_src_in(EX_write_data_src_out),
        .alu_a_in(EX_alu_a_out),
        .alu_s_in(EX_alu_s_out),
        .alu_c_in(EX_alu_c_out),
        .trap_in(EX_trap_out),
        .IF_addr_fault_in(EX_IF_addr_fault_out),
        .ri_fault_in(EX_ri_fault_out),
        .overflow_in(EX_overflow_out),
        .soft_int_in(EX_soft_int_out),
        .delay_slot_in(EX_delay_slot_out),

        .PC_out(MEM_PC_in),
        .PC4_out(MEM_PC4_in),
        .Inst_out(MEM_Inst_in),
        .data_sram_wen_out(MEM_data_sram_wen_in),
        .data_sram_addr_out(),
        .data_sram_wdata_out(MEM_data_sram_wdata_in),
        .write_reg_out(MEM_write_reg_in),
        .write_cp0reg_out(MEM_write_cp0reg_in),
        .write_dst_out(MEM_write_dst_in),
        .reg_data1_out(MEM_reg_data1_in),
        .reg_data2_out(MEM_reg_data2_in),
        .write_hilo_out(MEM_write_hilo_in),
        .hilo_out(MEM_hilo_in),
        .extOp_out(MEM_extOp_in),
        .write_data_src_out(MEM_write_data_src_in),
        .alu_a_out(MEM_alu_a_in),
        .alu_s_out(MEM_alu_s_in),
        .alu_c_out(MEM_alu_c_in),
        .trap_out(MEM_trap_in),
        .IF_addr_fault_out(MEM_IF_addr_fault_in),
        .ri_fault_out(MEM_ri_fault_in),
        .overflow_out(MEM_overflow_in),
        .soft_int_out(MEM_soft_int_in),
        .delay_slot_out(MEM_delay_slot_in)
    );

    // +-------------------+
    // |MEM Interface here |
    // +-------------------+
    wire DM_Interface_addrSrc = DMInterfaceAddrSrc(EX_Inst_in, MEM_Inst_in);
    DM_Interface DM_Interface_U(
        .data_sram_wen_in(MEM_data_sram_wen_out),
        .EX_data_sram_addr(EX_data_sram_addr_out),
        .MEM_data_sram_addr(MEM_data_sram_addr_out),
        .addrSrc(DM_Interface_addrSrc),
        .data_sram_wdata_in(MEM_data_sram_wdata_out),
        .data_sram_rdata_in(data_sram_rdata),
        
        .data_sram_en(data_sram_en),
        .data_sram_wen_out(data_sram_wen),
        .data_sram_addr(data_sram_addr),
        .data_sram_wdata_out(data_sram_wdata),
        .data_sram_rdata_out(MEM_data_sram_rdata_in)
    );


    MEM MEM_U(
        .clk(clk),
        .rst_n(resetn),

        .PC_in(MEM_PC_in),
        .PC4_in(MEM_PC4_in),
        .Inst_in(MEM_Inst_in),
        .data_sram_wen_in(MEM_data_sram_wen_in),
        .data_sram_wdata_in(MEM_data_sram_wdata_in),
        .data_sram_rdata(MEM_data_sram_rdata_in),
        .write_reg_in(MEM_write_reg_in),
        .write_cp0reg_in(MEM_write_cp0reg_in),
        .write_dst_in(MEM_write_dst_in),
        .reg_data1_in(MEM_reg_data1_in),
        .reg_data2_in(MEM_reg_data2_in),
        .write_hilo_in(MEM_write_hilo_in),
        .hilo_in(MEM_hilo_in),
        .extOp(MEM_extOp_in),
        .write_data_src_in(MEM_write_data_src_in),
        .alu_a_in(MEM_alu_a_in),
        .alu_s_in(MEM_alu_s_in),
        .alu_c_in(MEM_alu_c_in),
        .trap_in(MEM_trap_in),
        .IF_addr_fault_in(MEM_IF_addr_fault_in),
        .ri_fault_in(MEM_ri_fault_in),
        .soft_int_in(MEM_soft_int_in),
        .overflow_in(MEM_overflow_in),
        .delay_slot_in(MEM_delay_slot_in),
        .flush(MEM_flush_in),

        .PC_out(MEM_PC_out),
        .PC4_out(MEM_PC4_out),
        .Inst_out(MEM_Inst_out),
        .data_sram_wen_out(MEM_data_sram_wen_out),
        .data_sram_wdata_out(MEM_data_sram_wdata_out),
        .data_sram_addr(MEM_data_sram_addr_out),
        .write_reg_out(MEM_write_reg_out),
        .write_cp0reg_out(MEM_write_cp0reg_out),
        .write_dst_out(MEM_write_dst_out),
        .reg_data1_out(MEM_reg_data1_out),
        .reg_data2_out(MEM_reg_data2_out),
        .write_hilo_out(MEM_write_hilo_out),
        .hilo_out(MEM_hilo_out),
        .write_data_src_out(MEM_write_data_src_out),
        .alu_a_out(MEM_alu_a_out),
        .alu_s_out(MME_alu_s_out),
        .alu_c_out(MEM_alu_c_out),
        .mem_ext_data(MEM_mem_ext_data_out),
        .trap_out(MEM_trap_out),
        .IF_addr_fault_out(MEM_IF_addr_fault_out),
        .ri_fault_out(MEM_ri_fault_out),
        .overflow_out(MEM_overflow_out),
        .soft_int_out(MEM_soft_int_out),
        .load_addr_fault(MEM_load_addr_fault_out),
        .store_addr_fault(MEM_store_addr_fault_out),
        .delay_slot_out(MEM_delay_slot_out)
    );

    // WB in
    wire [31:0] WB_PC_in;
    wire [31:0] WB_PC4_in;
    wire [31:0] WB_Inst_in;
    wire WB_write_reg_in;
    wire WB_write_cp0reg_in;
    wire [4:0] WB_write_dst_in;
    wire [31:0] WB_reg_data1_in;
    wire [31:0] WB_reg_data2_in;
    wire [1:0] WB_write_hilo_in;
    wire [63:0] WB_hilo_in;
    wire [3:0] WB_write_data_src_in;
    wire [31:0] WB_alu_a_in;
    wire [31:0] WB_alu_s_in;
    wire [31:0] WB_alu_c_in;
    wire [31:0] WB_mem_ext_data_in;
    wire WB_flush_in;
    wire [31:0] WB_cause_in;
    wire [31:0] WB_status_in;
    wire [31:0] WB_badVaddr_in;
    wire [31:0] WB_epc_in;
    // WB  out
    wire [31:0] WB_PC_out;
    wire [31:0] WB_Inst_out;
    wire WB_write_reg_out;
    wire [31:0] WB_write_data_out;
    wire  WB_write_cp0reg_out;
    wire [4:0] WB_write_dst_out;

    // CP0 in
    wire CP0_trap_in;
    wire CP0_IF_addr_fault_in;
    wire CP0_ri_fault_in;
    wire CP0_soft_int_in;
    wire CP0_overflow_in;
    wire CP0_load_addr_fault_in;
    wire CP0_store_addr_fault_in;
    wire CP0_delay_slot_in;
    // CP0 out
    wire CP0_exception_out;

    MEM_WB MEM_WB_U(
        .clk(clk),
        .rst_n(resetn),
        
        .PC_in(MEM_PC_out),
        .PC4_in(MEM_PC4_out),
        .Inst_in(MEM_Inst_out),
        .write_reg_in(MEM_write_reg_out),
        .write_cp0reg_in(MEM_write_cp0reg_out),
        .write_dst_in(MEM_write_dst_out),
        .reg_data1_in(MEM_reg_data1_out),
        .reg_data2_in(MEM_reg_data2_out),
        .write_hilo_in(MEM_write_hilo_out),
        .hilo_in(MEM_hilo_out),
        .write_data_src_in(MEM_write_data_src_out),
        .alu_a_in(MEM_alu_a_out),
        .alu_s_in(MME_alu_s_out),
        .alu_c_in(MEM_alu_c_out),
        .mem_ext_data_in(MEM_mem_ext_data_out),
        .trap_in(MEM_trap_out),
        .IF_addr_fault_in(MEM_IF_addr_fault_out),
        .ri_fault_in(MEM_ri_fault_out),
        .overflow_in(MEM_overflow_out),
        .soft_int_in(MEM_soft_int_out),
        .load_addr_fault_in(MEM_load_addr_fault_out),
        .store_addr_fault_in(MEM_store_addr_fault_out),
        .delay_slot_in(MEM_delay_slot_out),

        .PC_out(WB_PC_in),
        .PC4_out(WB_PC4_in),
        .Inst_out(WB_Inst_in),
        .write_reg_out(WB_write_reg_in),
        .write_cp0reg_out(WB_write_cp0reg_in),
        .write_dst_out(WB_write_dst_in),
        .reg_data1_out(WB_reg_data1_in),
        .reg_data2_out(WB_reg_data2_in),
        .write_hilo_out(WB_write_hilo_in),
        .hilo_out(WB_hilo_in),
        .write_data_src_out(WB_write_data_src_in),
        .alu_a_out(WB_alu_a_in),
        .alu_s_out(WB_alu_s_in),
        .alu_c_out(WB_alu_c_in),
        .mem_ext_data_out(WB_mem_ext_data_in),
        .trap_out(CP0_trap_in),
        .IF_addr_fault_out(CP0_IF_addr_fault_in),
        .ri_fault_out(CP0_ri_fault_in),
        .overflow_out(CP0_overflow_in),
        .soft_int_out(CP0_soft_int_in),
        .load_addr_fault_out(CP0_load_addr_fault_in),
        .store_addr_fault_out(CP0_store_addr_fault_in),
        .delay_slot_out(CP0_delay_slot_in)
    );

    wire [31:0] reg_hi;
    wire [31:0] reg_lo;
    Forward Forward_U(
        .ID_Inst(ID_Inst_in),
        .EX_Inst(EX_Inst_in),
        .MEM_Inst(MEM_Inst_in),
        .WB_Inst(WB_Inst_in),
        .WB_write_dst(WB_write_dst_in),
        .MEM_write_dst(MEM_write_dst_in),
        .WB_write_reg(WB_write_reg_in),
        .MEM_write_reg(MEM_write_reg_in),
        .WB_write_data_src(WB_write_data_src_in),
        .MEM_write_data_src(MEM_write_data_src_in),

        .MEM_alu_a(MEM_alu_a_in),
        .MEM_alu_s(MEM_alu_s_in),
        .MEM_alu_c(MEM_alu_c_in),
        .MEM_data_sram_rdata(MEM_mem_ext_data_out),

        .WB_alu_a(WB_alu_a_in),
        .WB_alu_c(WB_alu_c_in),
        .WB_alu_s(WB_alu_s_in),
        .WB_PC4(WB_PC4_in),
        .WB_data_sram_rdata(WB_mem_ext_data_in),
        .WB_write_hilo(WB_write_hilo_in),
        .WB_hilo(WB_hilo_in),

        .reg_hi(reg_hi),
        .reg_lo(reg_lo),

        .CP0_BadVAddr(WB_badVaddr_in),
        .CP0_Status(WB_status_in),
        .CP0_Cause(WB_cause_in),
        .CP0_EPC(WB_epc_in),

        .ID_fwd_data1(ID_fwd_data1),
        .ID_fwd_data2(ID_fwd_data2),
        .ID_fwdSrc(ID_fwdSrc),

        .fwd_data1(fwd_data1),
        .fwd_data2(fwd_data2),
        .fwdSrc(fwdSrc)
    );

    WB WB_U(
        .clk(clk),
        .rst_n(resetn),

        .PC_in(WB_PC_in),
        .PC4(WB_PC4_in),
        .Inst(WB_Inst_in),
        .write_reg_in(WB_write_reg_in),
        .write_cp0reg_in(WB_write_cp0reg_in),
        .write_dst_in(WB_write_dst_in),
        .reg_data1(WB_reg_data1_in),
        .reg_data2(WB_reg_data2_in),
        .write_hilo(WB_write_hilo_in),
        .hilo(WB_hilo_in),
        .write_data_src(WB_write_data_src_in),
        .alu_a(WB_alu_a_in),
        .alu_s(WB_alu_s_in),
        .alu_c(WB_alu_c_in),
        .mem_ext_data(WB_mem_ext_data_in),
        // .trap(WB_trap_in),
        .flush(WB_flush_in),
        .cause(WB_cause_in),
        .status(WB_status_in),
        .badVaddr(WB_badVaddr_in),
        .epc(WB_epc_in),

        .PC_out(WB_PC_out),
        .Inst_out(WB_Inst_out),
        .write_reg_out(WB_write_reg_out),   
        .write_dst_out(WB_write_dst_out),
        .write_data(WB_write_data_out),
        .write_cp0reg_out(WB_write_cp0reg_out),

        .reg_hi(reg_hi),
        .reg_lo(reg_lo)
    );

    assign ID_write_reg_in = WB_write_reg_out;
    assign ID_write_dst_in = WB_write_dst_out;
    assign ID_write_reg_data_in = WB_write_data_out;


    CP0 CP0_U(
        .clk(clk),
        .rst_n(resetn),

        .PC(WB_PC_out),
        .Inst(WB_Inst_in),
        .write_cp0reg(WB_write_cp0reg_out),
        .reg_data2(WB_reg_data2_in),
        .trap(CP0_trap_in),
        .IF_addr_fault(CP0_IF_addr_fault_in),
        .ri_fault(CP0_ri_fault_in),
        .soft_int(CP0_soft_int_in),
        .overflow(CP0_overflow_in),
        .load_addr_fault(CP0_load_addr_fault_in),
        .store_addr_fault(CP0_store_addr_fault_in),
        .delay_slot(CP0_delay_slot_in),
        .data_sram_addr(WB_alu_a_in),

        .exception(CP0_exception_out),
        .cause(WB_cause_in),
        .status(WB_status_in),
        .badVAddr(WB_badVaddr_in),
        .epc(WB_epc_in)
    );

    wire [1:0] Control_PCSrc;
    Control Control_U(
        .exception(CP0_exception_out),
        .isbranch(ID_isbranch_out),
        .mult_div_run(MUL_DIV_running),
        .EX_Inst(EX_Inst_in),
        .ID_Inst(ID_Inst_in),
        .MEM_Inst(MEM_Inst_in),

        .EX_write_dst(EX_write_dst_in),
        .EX_write_reg(EX_write_reg_in),

        .IF_flush(IF_flush_in),
        .ID_flush(ID_flush_in),
        .EX_flush(EX_flush_in),
        .MEM_flush(MEM_flush_in),
        .WB_flush(WB_flush_in),

        .IF_stall(IF_stall_in),
        .ID_stall(ID_stall_in),
        .EX_stall(EX_stall),
        
        .PCSrc(Control_PCSrc)
    );

    // initial IF input , IM interface 
    assign IF_PCSrc_in = Control_PCSrc;
    assign IF_nextPC_in = ID_nextPC_out;
    assign IF_inst_sram_rdata_in = IM_Interface_Inst_out;

    assign IM_Interface_PCSrc_in = Control_PCSrc;


    // ---------------------


    assign debug_wb_pc = WB_PC_in;
    assign debug_wb_rf_wen = {4{WB_write_reg_out}};
    assign debug_wb_rf_wnum = WB_write_dst_in;
    assign debug_wb_rf_wdata = WB_write_data_out;


    function DMInterfaceAddrSrc;
        input [31:0] EX_Inst;
        input [31:0] MEM_Inst;
        case (MEM_Inst[31:26])
            6'b101000:DMInterfaceAddrSrc = 1;
            6'b101001:DMInterfaceAddrSrc = 1;
            6'b101011:DMInterfaceAddrSrc = 1;
            default: DMInterfaceAddrSrc = 0;
        endcase
        
    endfunction

    reg [31:0] fwdEpc_data;
    reg  fwdEpc;
    always @(*) begin
        if(EX_write_cp0reg_in && EX_Inst_in[15:11] == 14 && EX_Inst_in[2:0] == 0) begin
            fwdEpc = 1;
            fwdEpc_data = EX_reg_data2_out;
        end
        else if(MEM_write_cp0reg_in && MEM_Inst_in[15:11] == 14 && MEM_Inst_in[2:0] == 0) begin
            fwdEpc = 1;
            fwdEpc_data = MEM_reg_data2_out;
        end
        else if(WB_write_cp0reg_in && WB_Inst_in[15:11] == 14 && WB_Inst_in[2:0] == 0) begin
            fwdEpc = 1;
            fwdEpc_data = WB_reg_data2_in;
        end
        else begin
            fwdEpc = 0;
            fwdEpc_data = 0;
        end
    end

     assign ID_epc_in = fwdEpc ? fwdEpc_data :  WB_epc_in;
endmodule // mycpu