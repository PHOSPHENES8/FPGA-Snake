module Control(
    input exception,
    input isbranch,
    input mult_div_run,
    input [31:0] EX_Inst,
    input [31:0] ID_Inst,
    input [31:0] MEM_Inst,
    
    input [4:0] EX_write_dst,
    input EX_write_reg,

    output reg IF_flush,
    output reg ID_flush,
    output reg EX_flush,
    output reg MEM_flush,
    output reg WB_flush,

    output reg IF_stall,
    output reg ID_stall,
    output reg EX_stall,

    output reg [1:0] PCSrc

);
    reg load_relate;
    reg ID_branch_reg_relate;
    wire EX_load = EXLoad(EX_Inst);
    wire MEM_store = MEMStore(MEM_Inst);
    wire load_store_hazard = EX_load & MEM_store;

    wire ID_eret = ID_Inst[31:26] == 6'b010000 && ID_Inst[5:0] == 6'b011000;

    reg ID_read_rs, ID_read_rt;
    wire [4:0] ID_rs = ID_Inst[25:21] ;
    wire [4:0] ID_rt = ID_Inst[20:16];

    always @(*) begin
        if(exception) begin
            IF_flush = 1;
            ID_flush = 1;
            EX_flush = 1;
            MEM_flush = 1;
            WB_flush = 1;
        end
        else if(ID_branch_reg_relate | load_relate) begin
            IF_flush = 0;
            ID_flush = 1;
            EX_flush = 0;
            MEM_flush = 0;
            WB_flush = 0;
        end
        else if(load_store_hazard | mult_div_run) begin
            IF_flush = 0;
            ID_flush = 0;
            EX_flush = 1;
            MEM_flush = 0;
            WB_flush = 0;
        end
        else if(ID_eret) begin
            IF_flush = 1;
            ID_flush = 0;
            EX_flush = 0;
            MEM_flush= 0;
            WB_flush = 0;
        end
        else begin
            IF_flush = 0;
            ID_flush = 0;
            EX_flush = 0;
            MEM_flush = 0;
            WB_flush = 0;
        end
    end

    

     // stall control
    always @(*) begin
        if( ID_branch_reg_relate | load_relate) begin
            IF_stall = 1 & (~exception);
            ID_stall = 1 & (~exception);
            EX_stall = 0 & (~exception);
        end
        else if(load_store_hazard | mult_div_run) begin
            IF_stall = 1 & (~exception);
            ID_stall = 1 & (~exception);
            EX_stall = 1 & (~exception);
        end
        else begin
            IF_stall = 0;
            ID_stall = 0;
            EX_stall = 0;
        end
    end

    always @(*) begin
        if(exception) begin
            PCSrc = 2'b10;
        end
        else if(isbranch) begin
            PCSrc = 2'b01;
        end
        else PCSrc = 0;
    end

    always @(*) begin
        if(ID_Inst[31:26] == 0)  begin// Rtype
            case (ID_Inst[5:3]) 
                3'b100:ID_read_rs = 1 ;
                3'b101:ID_read_rs = 1;
                3'b000: begin
                    case (ID_Inst[2:0])
                        3'b100:ID_read_rs = 1;
                        3'b111:ID_read_rs = 1;
                        3'b110:ID_read_rs = 1; 
                        default: ID_read_rs = 0;
                    endcase
                end
                3'b011:ID_read_rs = 1;
                3'b001:ID_read_rs = 0; // ID_branch_reg_relate consider this 
                3'b010:ID_read_rs = 0; // not necessary
//                3'b001:ID_read_rs = 0; repeat 
                default: ID_read_rs = 0;
            endcase
        end
        else begin
            case (ID_Inst[31:29])
                3'b001:ID_read_rs = 1; 
                3'b000:ID_read_rs = 0; // ID_branch_reg_relate consider this
                3'b100:ID_read_rs = 1;
                3'b101:ID_read_rs = 1;
                default: ID_read_rs = 0;
            endcase
        end
    end
    always @(*) begin
        if(ID_Inst[31:26] == 0) begin // Rtype
            case (ID_Inst[5:3]) 
                3'b100:ID_read_rt = 1 ;
                3'b101:ID_read_rt = 1;
                3'b000:ID_read_rt = 1;
                3'b011:ID_read_rt = 1;
                3'b001:ID_read_rt = 0; // ID_branch_reg_relate consider this 
                3'b010:ID_read_rt = 0; // not necessary
                // 3'b001:ID_read_rt = 0;
                default: ID_read_rt = 0;
            endcase
        end
        else ID_read_rt = 0;
    end

    always @(*) begin
        if(ID_Inst[31:29] == 0) begin
            case (ID_Inst[28:26])
                3'b100: ID_branch_reg_relate = (( EX_write_dst == ID_Inst[25:21] ) || (EX_write_dst == ID_Inst[20:16])) && EX_write_dst != 0 && EX_write_reg;
                3'b101: ID_branch_reg_relate = (( EX_write_dst == ID_Inst[25:21] ) || (EX_write_dst == ID_Inst[20:16])) && EX_write_dst != 0 && EX_write_reg;
                3'b001: ID_branch_reg_relate = EX_write_reg &&  EX_write_dst != 0 && EX_write_dst == ID_Inst[25:21];
                3'b111: ID_branch_reg_relate = EX_write_reg && EX_write_dst != 0 && EX_write_dst == ID_Inst[25:21];
                3'b110: ID_branch_reg_relate = EX_write_reg && EX_write_dst != 0 && EX_write_dst == ID_Inst[25:21];
                3'b000: begin // Rtype Jr
                    if((ID_Inst[5:0] == 6'b001000 || ID_Inst[5:0] == 6'b001001) && EX_write_dst != 0 && EX_write_reg && EX_write_dst == ID_Inst[25:21])
                        ID_branch_reg_relate = 1;
                    else ID_branch_reg_relate = 0;
                end
                default: ID_branch_reg_relate = 0;
            endcase
        end
        else begin
            ID_branch_reg_relate = 0;
        end
    end

    always @(*) begin
        if(EX_Inst[31:26] == 6'b100000 || EX_Inst[31:26] == 6'b100100 
        || EX_Inst[31:26] == 6'b100001 || EX_Inst[31:26] == 6'b100101
        || EX_Inst[31:26] == 6'b100011) // load 
        begin
            if(EX_write_dst == ID_rs && ID_read_rs && EX_write_dst != 0 && EX_write_reg
            || EX_write_dst == ID_rt && ID_read_rt && EX_write_dst != 0 && EX_write_reg) 
            begin
                load_relate = 1;
            end
            else load_relate = 0;
        end
        else begin
            load_relate = 0;
        end
    end

    function EXLoad;
        input [31:0] EX_Inst;
        if(EX_Inst[31:26] == 6'b100000 || EX_Inst[31:26] == 6'b100100 
        || EX_Inst[31:26] == 6'b100001 || EX_Inst[31:26] == 6'b100101
        || EX_Inst[31:26] == 6'b100011) 
        begin
            EXLoad = 1;
        end
        else begin
            EXLoad = 0;
        end
    endfunction

    function MEMStore;
        input [31:0] MEM_Inst;
        if(MEM_Inst[31:26] == 6'b101000 || MEM_Inst[31:26] == 6'b101001
        || MEM_Inst[31:26] == 6'b101011)
        begin
            MEMStore = 1;
        end
        else begin
            MEMStore = 0;
        end
    endfunction
endmodule // Control