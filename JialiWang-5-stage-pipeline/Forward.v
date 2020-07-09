module Forward(
    input [31:0] ID_Inst,
    input [31:0] EX_Inst,
    input [31:0] MEM_Inst ,
    input [31:0] WB_Inst,
    input [4:0] WB_write_dst,
    input [4:0] MEM_write_dst,
    input  WB_write_reg,
    input MEM_write_reg,
    input [3:0] WB_write_data_src,
    input [3:0] MEM_write_data_src,

    input [31:0] MEM_alu_a,
    input [31:0] MEM_alu_s,
    input [31:0] MEM_alu_c,
    input [31:0] MEM_data_sram_rdata,
    input [31:0] WB_alu_a, 
    input [31:0] WB_alu_s,
    input [31:0] WB_alu_c,
    input [31:0] WB_PC4,
    input [31:0] WB_data_sram_rdata,
    input [1:0] WB_write_hilo,
    input [63:0] WB_hilo,

    input [31:0] reg_hi,
    input [31:0] reg_lo,

    input [31:0] CP0_BadVAddr,
    input [31:0] CP0_Status,
    input [31:0] CP0_Cause,
    input [31:0] CP0_EPC,
    // input EX_Rtype,

    output reg [31:0] ID_fwd_data1,
    output reg [31:0] ID_fwd_data2,
    output reg [1:0] ID_fwdSrc,

    output reg [31:0] fwd_data1,
    output reg [31:0] fwd_data2,
    output reg [1:0] fwdSrc // [1:0] -> rt rs, or none
);
    wire [4:0] ID_rs = ID_Inst[25:21];
    wire [4:0] ID_rt = ID_Inst[20:16];

    wire [4:0] rs = EX_Inst[25:21];
    wire [4:0] rt = EX_Inst[20:16];

    wire EX_Rtype = EX_Inst[31:26] == 0 ? 1 : 0;

    // forward rs
    always @(*) begin
        if(MEM_write_dst == rs && MEM_write_dst != 0 && MEM_write_reg) begin
            fwdSrc[0] = 1;
            case (MEM_write_data_src)
                0: fwd_data1 = MEM_alu_a;
                1: fwd_data1 = MEM_alu_c;
                2: fwd_data1 = MEM_alu_s;
                7: begin // mfc0 
                    case (MEM_Inst[15:11])
                        8 :fwd_data1 = CP0_BadVAddr;
                        12:fwd_data1 = CP0_Status;
                        13:fwd_data1 = CP0_Cause;
                        14:fwd_data1 = CP0_EPC;
                        default: begin 
                            fwdSrc[0] = 0;
                            fwd_data1 = 0;
                        end
                    endcase
                end
                default: begin
                    fwd_data1 = 0;
                    fwdSrc[0] = 0;
                end
            endcase
        end
        else if(WB_write_dst == rs && WB_write_dst != 0 && WB_write_reg) begin
            fwdSrc[0] = 1;
            case (WB_write_data_src)
                0: fwd_data1 = WB_alu_a;
                1: fwd_data1 = WB_alu_c;
                2: fwd_data1 = WB_alu_s;
                3: fwd_data1 = WB_PC4 + 4;
                6: fwd_data1 = WB_data_sram_rdata;
                default: begin
                    fwd_data1 = 0;
                    fwdSrc[0] = 0;
                end
            endcase
        end
        else begin
            fwd_data1 = 0;
            fwdSrc[0] = 0;
        end
    end

    // forward rt 
    always @(*) begin
        if(MEM_write_dst == rt && MEM_write_dst != 0 && MEM_write_reg) begin
            fwdSrc[1] = 1;
            case (MEM_write_data_src)
                0: fwd_data2 = MEM_alu_a;
                1: fwd_data2 = MEM_alu_c;
                2: fwd_data2 = MEM_alu_s;
                7: begin // mfc0 
                    case (MEM_Inst[15:11])
                        8 :fwd_data2 = CP0_BadVAddr;
                        12:fwd_data2 = CP0_Status;
                        13:fwd_data2 = CP0_Cause;
                        14:fwd_data2 = CP0_EPC;
                        default: begin 
                            fwdSrc[1] = 0;
                            fwd_data2 = 0;
                        end
                    endcase
                end
                default: begin
                    fwd_data2 = 0;
                    fwdSrc[1] = 0;
                end
            endcase
        end
        else if(WB_write_dst == rt && WB_write_dst != 0 && WB_write_reg) begin
            fwdSrc[1] = 1;
            case (WB_write_data_src)
                0: fwd_data2 = WB_alu_a;
                1: fwd_data2 = WB_alu_c;
                2: fwd_data2 = WB_alu_s;
                6: fwd_data2 = WB_data_sram_rdata;
                default: begin
                    fwd_data2 = 0;
                    fwdSrc[1] = 0;
                end
            endcase
        end
        else begin
            fwd_data2 = 0;
            fwdSrc[1] = 0;
        end
    end

// -------------------------- ID fwd (branch inst reg relate) ---------------------------------

    always @(*) begin
        if(MEM_write_dst == ID_rs && MEM_write_dst != 0 && MEM_write_reg) begin
            ID_fwdSrc[0] = 1;
            case (MEM_write_data_src)
                0: ID_fwd_data1 = MEM_alu_a;
                1: ID_fwd_data1 = MEM_alu_c;
                2: ID_fwd_data1 = MEM_alu_s;
                4: begin
                    if(MEM_Inst[1]) begin // mflo
                        if(WB_write_hilo[0]) 
                            ID_fwd_data1 = WB_hilo[31:0];
                        else ID_fwd_data1 = reg_lo;    
                    end
                    else begin // mfhi
                        if(WB_write_hilo[1]) 
                            ID_fwd_data1 = WB_hilo[63:32];
                        else ID_fwd_data1 = reg_hi;
                    end
                end
                6: ID_fwd_data1 = MEM_data_sram_rdata;
                7: begin // mfc0 
                    case (MEM_Inst[15:11])
                        8 :ID_fwd_data1 = CP0_BadVAddr;
                        12:ID_fwd_data1 = CP0_Status;
                        13:ID_fwd_data1 = CP0_Cause;
                        14:ID_fwd_data1 = CP0_EPC;
                        default: begin 
                            ID_fwdSrc[0] = 0;
                            ID_fwd_data1 = 0;
                        end
                    endcase
                end
                default: begin
                    ID_fwd_data1 = 0;
                    ID_fwdSrc[0] = 0;
                end
            endcase
        end
        else if(WB_write_dst == ID_rs && WB_write_dst != 0 && WB_write_reg) begin
            ID_fwdSrc[0] = 1;
            case (WB_write_data_src)
                0: ID_fwd_data1 = WB_alu_a;
                1: ID_fwd_data1 = WB_alu_c;
                2: ID_fwd_data1 = WB_alu_s;
                4: begin
                    if(WB_Inst[1]) begin
                        ID_fwd_data1 = reg_lo;
                    end
                    else ID_fwd_data1 = reg_hi;
                end
                6: ID_fwd_data1 = WB_data_sram_rdata;
                default: begin
                    ID_fwd_data1 = 0;
                    ID_fwdSrc[0] = 0;
                end
            endcase
        end
        else begin
            ID_fwd_data1 = 0;
            ID_fwdSrc[0] = 0;
        end
    end

    // forward rt 
    always @(*) begin
        if(MEM_write_dst == ID_rt && MEM_write_dst != 0 && MEM_write_reg) begin
            ID_fwdSrc[1] = 1;
            case (MEM_write_data_src)
                0: ID_fwd_data2 = MEM_alu_a;
                1: ID_fwd_data2 = MEM_alu_c;
                2: ID_fwd_data2 = MEM_alu_s;
                4: begin
                    if(MEM_Inst[1]) begin // mflo
                        if(WB_write_hilo[0]) 
                            ID_fwd_data2 = WB_hilo[31:0];
                        else ID_fwd_data2 = reg_lo;    
                    end
                    else begin // mfhi
                        if(WB_write_hilo[1]) 
                            ID_fwd_data2 = WB_hilo[63:32];
                        else ID_fwd_data2 = reg_hi;
                    end
                end
                6: ID_fwd_data2 = MEM_data_sram_rdata;
                7: begin // mfc0 
                    case (MEM_Inst[15:11])
                        8 :ID_fwd_data2 = CP0_BadVAddr;
                        12:ID_fwd_data2 = CP0_Status;
                        13:ID_fwd_data2 = CP0_Cause;
                        14:ID_fwd_data2 = CP0_EPC;
                        default: begin
                            ID_fwd_data2 = 0;
                            ID_fwdSrc[1] = 0;
                        end
                    endcase
                end
                default: begin
                    ID_fwd_data2 = 0;
                    ID_fwdSrc[1] = 0;
                end
            endcase
        end
        else if(WB_write_dst == ID_rt && WB_write_dst != 0 && WB_write_reg) begin
            ID_fwdSrc[1] = 1;
            case (WB_write_data_src)
                0: ID_fwd_data2 = WB_alu_a;
                1: ID_fwd_data2 = WB_alu_c;
                2: ID_fwd_data2 = WB_alu_s;
                4: begin
                    if(WB_Inst[1]) begin
                        ID_fwd_data2 = reg_lo;
                    end
                    else ID_fwd_data2 = reg_hi;
                end
                6: ID_fwd_data2 = WB_data_sram_rdata;
                default: begin
                    ID_fwd_data2 = 0;
                    ID_fwdSrc[1] = 0;
                end
            endcase
        end
        else begin
            ID_fwd_data2 = 0;
            ID_fwdSrc[1] = 0;
        end
    end

    // ! ! ! bug here
    // always @(*) begin
    //    if(EX_Rtype) begin
    //        if(((MEM_write_dst == rt || MEM_write_dst == rs) && MEM_write_dst != 0 && MEM_write_reg) 
    //         && ((WB_write_dst == rt || WB_write_dst == rs) && WB_write_dst != 0 && WB_write_reg)) begin
    //             if(MEM_write_dst == WB_write_dst) begin
    //                 if(MEM_write_dst == rt) fwdSrc = 2'b10;
    //             end
    //        end
    //        else if((MEM_write_dst == rt || MEM_write_dst == rs) && MEM_write_dst != 0 && MEM_write_reg) begin
    //            if(MEM_write_dst == rt) fwdSrc[1] = 2'b10;
    //            else fwdSrc = 2'b01;
    //            case (MEM_write_data_src)
    //                0: fwd_data = MEM_alu_a;
    //                1: fwd_data = MEM_alu_c;
    //                2: fwd_data = MEM_alu_s;
    //                default: begin
    //                    fwd_data = 0;
    //                    fwdSrc = 0;
    //                end
    //            endcase
    //        end
    //        else if((WB_write_dst == rt || WB_write_dst == rs) && WB_write_dst != 0 && WB_write_reg) begin
    //            if(MEM_write_dst == rt) fwdSrc = 2'b10;
    //            else fwdSrc = 2'b01;
    //            case (WB_write_data_src)
    //                0: fwd_data = WB_alu_a;
    //                1: fwd_data = WB_alu_c;
    //                2: fwd_data = WB_alu_s;
    //                6: fwd_data = WB_data_sram_rdata;
    //                default: begin
    //                    fwd_data = 0;
    //                    fwdSrc = 0;
    //                end
    //            endcase
    //        end
    //        else begin
    //            fwdSrc = 0;
    //            fwd_data = 0;
    //        end
    //    end
    //    else begin
    //        if(MEM_write_dst == rs && MEM_write_dst != 0 && MEM_write_reg) begin
    //            fwdSrc = 2'b01;
    //            case (MEM_write_data_src)
    //                0: fwd_data = MEM_alu_a;
    //                1: fwd_data = MEM_alu_c;
    //                2: fwd_data = MEM_alu_s;
    //                default: begin
    //                    fwd_data = 0;
    //                    fwdSrc = 0;
    //                end
    //            endcase
    //        end
    //        else if (WB_write_dst == rs && WB_write_dst != 0 && WB_write_reg) begin
    //            fwdSrc = 2'b01;
    //            case (WB_write_data_src)
    //                0: fwd_data = WB_alu_a;
    //                1: fwd_data = WB_alu_c;
    //                2: fwd_data = WB_alu_s;
    //                6: fwd_data = WB_data_sram_rdata;
    //                default: begin
    //                    fwd_data = 0;
    //                    fwdSrc = 0;
    //                end
    //            endcase
    //        end
    //        else begin
    //            fwdSrc = 0;
    //            fwd_data = 0;
    //        end
    //    end
    // end    
endmodule // Forward