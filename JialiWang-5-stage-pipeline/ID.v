module ID(
    input clk,
    input rst_n,

    input [31:0] PC_in,
    input [31:0] PC4_in,
    input [31:0] Inst_raw, 

    input [4:0] write_dst_in,
    input  write_reg_in,  // reg write en
    input[31:0] write_reg_data,

    // input write_epc,
    // input [31:0] write_epc_data,
    // input write_cp0reg_in,
    input [31:0] epc,

    input flush,
    // input stall,
    input IF_addr_fault_in,

    input [31:0] ID_fwd_data1,
    input [31:0] ID_fwd_data2,
    input [1:0] ID_fwdSrc,

    output [31:0] PC_out,
    output [31:0] PC4_out,
    output [31:0] Inst_out,
    output reg [4:0] write_dst_out,
    output reg write_reg_out, 
    output write_cp0reg_out,

    output reg  [31:0] nextPC,
    output[31:0] reg_data1,
    output[31:0] reg_data2,
    output [31:0] extImm,
    output [1:0] write_hilo,
    output trap,
    output [2:0] extOp,
    output[3:0] write_data_src ,
    output [2:0] aluOp,
    output [4:0] sa,
    output reg isbranch,
    output reg [3:0] data_sram_wen,
    // output [31:0] epc_data,

    // for DM inferface 
    output [31:0] data_sram_addr,
    output addrSrc,
    
    output IF_addr_fault_out,
    output delay_slot_out,
    output reg ri_fault,
    output soft_int

    // output ID_flush


);

    // reg [31:0] epc;
    // reg[31:0] cp0[0:31];

    reg [31:0] branch_inst_PC;
    wire [31:0] Inst_in = flush ? 0 : Inst_raw;


    wire [15:0] Imm;
    wire [4:0] rs, rt, rd;
    wire [25:0] target;
    wire [5:0] func, opcode;
    wire [5:0] opcode_fun;

    wire [31:0] valA_raw, valB_raw;
    wire [31:0] valA, valB;

    assign Imm = Inst_in[15:0];
    assign opcode = Inst_in[31:26];
    assign rs = Inst_in[25:21];
    assign rt = Inst_in[20:16];
    assign rd = Inst_in[15:11];
    assign target = Inst_in[25:0];
    assign func = Inst_in[5:0];
    assign Rtype = opcode == 6'b000000;

    assign PC4_out = PC4_in;
    assign PC_out = PC_in;
    assign write_cp0reg_out = (opcode == 6'b010000 && Inst_in[25:21] == 5'b00100 ? 1'b1 : 1'b0) & (~flush);
    assign extImm = ImmExt(Imm, opcode[3]&opcode[2], opcode);
    assign Inst_out = Inst_in;
    assign write_hilo = WriteHiLo(Rtype, func) & (~flush);
    assign write_mem = WriteMem(opcode) & (~flush);
    assign trap = Rtype && (func[5:1] == 5'b00110) ? 1 : 0;
    assign extOp = lwExtOp(opcode);
    assign write_data_src = WriteDataSrc(Inst_in, opcode,func, Rtype);
    assign aluOp = AluOp(opcode, func, Rtype);
    // assign cp0_reg = cp0[rd];
    assign sa = Inst_in[10:6];
    // assign epc_data = epc;
    assign IF_addr_fault_out = IF_addr_fault_in & (~flush);
    assign delay_slot_out = branch_inst_PC + 4 == PC_in;
    assign soft_int = isbranch && (nextPC == PC_in) && (~flush);
    // assign ID_flush = flush;
    // assign ri_fault = RIFault(Inst_in);
    
    // assign isbranch = nextPC != PC_in + 8;
    // assign opcode_fun =Rtype ? func : opcode;

    RegFile RegFile_U(.clk(clk), .rst_n(rst_n), .readReg1(rs), .readReg2(rt), 
            .write_data(write_reg_data), .writeReg(write_dst_in), .write_en(write_reg_in),
            .read_data1(valA_raw), .read_data2(valB_raw));
    assign valA = ({32{ID_fwdSrc[0]}} & ID_fwd_data1) | ({32{~ID_fwdSrc[0]}} & valA_raw);
    assign valB = ({32{ID_fwdSrc[1]}} & ID_fwd_data2) | ({32{~ID_fwdSrc[1]}} & valB_raw);
    assign reg_data1 = valA;
    assign reg_data2 = valB;

    assign data_sram_addr = valA + extImm;
    assign addrSrc = Inst_in == 0 ? 1 : 0;

    //ri fault 
    always @(*) begin
        if (Rtype) begin
            case (func[5:3])
                3'b100: ri_fault = 0;
                3'b101: begin
                    if (func[2:0] == 3'b010 || func[2:0] == 3'b011)
                        ri_fault = 0;
                    else ri_fault = 1;
                end
                3'b000:begin
                    if(func[2:0] == 3'b001 || func[2:0] == 3'b101)
                        ri_fault = 1;
                    else ri_fault = 0;
                end
                3'b011: begin
                    if(func[2] == 1'b0) begin
                        ri_fault = 0;
                    end
                    else ri_fault = 1;
                end
                3'b001: begin
                    if(func[2:0] == 3'b000 || func[2:0] == 3'b001 || func[2:0] == 3'b101 || func[2:0] == 3'b100) 
                        ri_fault = 0;
                    else ri_fault = 1;
                end
                3'b010: begin
                    if(func[2] == 1'b0) 
                        ri_fault = 0;
                    else ri_fault = 1;
                end
                // 3'b001: begin
                //     if(func[2:0] == 3'b101 || func[2:0] == 3'b100)
                //         ri_fault = 0;
                //     else ri_fault = 1;
                // end
                default: ri_fault = 1;
            endcase
        end
        else begin
            case (opcode[5:3])
                3'b001:  ri_fault = 0;
                3'b000:  ri_fault = 0; // 000000 is R
                3'b100:  begin 
                    case (opcode[2:0])
                        3'b000:ri_fault = 0;
                        3'b100:ri_fault = 0;
                        3'b001:ri_fault = 0;
                        3'b101:ri_fault = 0;
                        3'b011:ri_fault = 0; 
                        default: ri_fault = 1;
                    endcase
                end
                3'b101: begin
                    case (opcode[2:0])
                        3'b000:ri_fault = 0;
                        3'b001:ri_fault = 0;
                        3'b011:ri_fault = 0; 
                        default: ri_fault = 1;
                    endcase
                end
                3'b010: begin
                    if(opcode[2:0] == 3'b000) 
                        ri_fault = 0;
                    else ri_fault = 1;
                end
                default: ri_fault = 1;
            endcase
        end
    end


    // assign data_sram_wen = DataSramWen(opcode);
    always @(*) begin
        case (opcode)
            6'b101000: begin
                case (data_sram_addr[1:0]) 
                    2'b00: data_sram_wen = 4'b0001;
                    2'b01: data_sram_wen = 4'b0010;
                    2'b10: data_sram_wen = 4'b0100;
                    2'b11: data_sram_wen = 4'b1000; 
                    default: data_sram_wen = 0;
                endcase
            end 
            6'b101001: begin
                case (data_sram_addr[1:0])
                    2'b00: data_sram_wen = 4'b0011;
                    2'b10: data_sram_wen = 4'b1100; 
                    default: data_sram_wen = 0;
                endcase
            end
            6'b101011: begin
                case (data_sram_addr[1:0])
                    2'b00: data_sram_wen = 4'b1111; 
                    default: data_sram_wen = 0;
                endcase 
            end
            default: data_sram_wen = 0;
        endcase
    end


    // wire branchOp = opcode[1:0] == 2'b01;
    // wire [31:0] branchPC ;
    // branchPC branchPC_U(.extImm(extImm), .PC(PC4_in), 
    //         .target({PC4_in[31:28],{target, 2'b00}}), .branchOp(branchOp), .branchPC(branchPC));
    wire  [31:0]  branchPC = BranchPC(opcode, PC4_in+{extImm[29:0],2'b00}, 
        {PC4_in[31:28],{target,2'b00}}, reg_data1);
        
    wire [1:0] PCSel;
    isBranch isBranch_U(.valA(valA), .valB(valB), .rt(rt), .opcode(opcode),
            .func(func), .Inst(Inst_in),.PCSel(PCSel));

    // determine whether Inst in branch delay slot
    // save last branch instructon PC
    always @(posedge clk) begin
        if(rst_n == 1'b0) 
            branch_inst_PC <= 0;
        else begin
            case (opcode[5:3])
                3'b000: begin
                    case (opcode[2:0])
                        3'b100:branch_inst_PC <= PC_in;
                        3'b101:branch_inst_PC <= PC_in;
                        3'b001:branch_inst_PC <= PC_in;
                        3'b111:branch_inst_PC <= PC_in;
                        3'b110:branch_inst_PC <= PC_in;
                        3'b010:branch_inst_PC <= PC_in;
                        3'b011:branch_inst_PC <= PC_in;
                        3'b000:begin
                            if (func == 6'b001000 || func == 6'b001001) 
                                branch_inst_PC <= PC_in;
                        end
                        default: branch_inst_PC <= branch_inst_PC;
                    endcase
                end 
                default: branch_inst_PC <= branch_inst_PC;
            endcase
        end
    end


    // always @(posedge clk) begin
    //     if (rst_n == 1'b0)
    //         epc <= 0;
    //     else if(write_epc)
    //         epc <= write_epc_data;
    //     else epc <= epc;
    // end
    
    // nextPC
    always @(*) begin
        // if(IF_stall) begin
        //     nextPC = PC_in;
        // end
        // else 
        begin
            case (PCSel)
                2'b00:begin 
                     nextPC = PC4_in;
                     isbranch = 0;
                end
                2'b01: begin 
                    nextPC = branchPC;
                    isbranch = 1;
                end
                2'b10: begin
                    nextPC = epc;
                    isbranch = 1;
                end
                default: begin 
                    nextPC = PC4_in ;
                    isbranch = 0;
                end
            endcase
        end
    end

    // write_reg write_dst
    always @(*) begin
        if(Inst_in == 0) begin
            write_reg_out = 0;
            write_dst_out = 0;
        end
        else if (Rtype) begin
            write_dst_out = rd;
            case (func[5:3])
                3'b100: write_reg_out = 1 & (~flush);
                3'b101: write_reg_out = (func[2:1] == 2'b01 ? 1 : 0) & (~flush);
                3'b000: write_reg_out = (func[2:0] == 3'b001 ? 0 : 1) & (~flush);
                3'b001: write_reg_out = (func[2:0] == 3'b001 ? 1 : 0) & (~flush);
                3'b010: write_reg_out = ((func[0] == 1'b0 && func[2] == 1'b0) ? 1: 0) & (~flush);
                default: write_reg_out = 0; 
            endcase
        end
        else begin
            case (opcode[5:3])
                3'b001: begin
                    write_dst_out = rt;
                    write_reg_out = 1 & (~flush);
                end 
                3'b000: begin
                    // if(opcode[2:0] == 3'b001 || opcode[2:0] == 3'b011) begin
                    //     write_dst_out = 31;
                    //     write_reg_out = 1 & (~flush);
                    // end
                    // else begin
                    //     write_reg_out = 0;
                    // end
                    case (opcode[2:0])  
                        3'b001: begin
                            if (rt == 5'b10001 || rt == 5'b10000) begin
                                write_dst_out = 31;
                                write_reg_out = 1 & (~flush);
                            end
                            else begin
                                write_reg_out  = 0;
                                write_dst_out = 0;
                            end
                        end 
                        3'b011 : begin
                            write_dst_out = 31;
                            write_reg_out = 1 & (~flush);
                        end
                        default: begin 
                            write_reg_out = 0;
                            write_dst_out = 0;
                        end
                    endcase
                end
                3'b100: begin
                    if (opcode[2:1] == 2'b10 || opcode[2:1] == 2'b00 || opcode[2:0] == 3'b011)  begin
                        write_dst_out = rt;
                        write_reg_out = 1 & (~flush);
                    end
                    else begin 
                        write_reg_out = 0;
                        write_dst_out = 0;
                    end
                end
                3'b010:begin
                    if (opcode[2:0] == 3'b000 && Inst_in[25:21] == 0) begin
                        write_dst_out = rt;
                        write_reg_out = 1 & (~flush);
                    end 
                    else begin
                        write_reg_out = 0;
                        write_dst_out = 0;
                    end
                end
                default: begin
                    write_reg_out = 0;
                    write_dst_out = 0;
                end
            endcase
        end
    end

    function[31:0] ImmExt;
        input[15:0] Imm;
        input extOp;
        input [31:0] opcode;
        // assign ImmExt = {{16{Imm[15]}}, Imm};     
        if(opcode == 6'b001111) ImmExt = ~{Imm,16'b0} ;
        else if(!extOp) ImmExt = {{16{Imm[15]}}, Imm};
        else ImmExt = {16'b0, Imm};
    endfunction
    function [1:0] WriteHiLo;
        input Rtype;
        input [5:0]func;
        // if (Rtype && (func[5:2] == 4'b0110 || func == 6'b010001 || func == 6'b010011) ) begin  
        if(Rtype) begin 
            if(func[5:2] == 4'b0110) WriteHiLo = 2'b11;
            else if(func == 6'b010001) WriteHiLo = 2'b10;
            else if(func == 6'b010011) WriteHiLo = 2'b01;
            else WriteHiLo = 0;
        end
        else WriteHiLo = 0;
    endfunction

    function WriteMem;
        input [5:0] opcode ;
        if (opcode == 6'b101000 ||  opcode == 6'b101001 || opcode == 6'b101011) 
            WriteMem = 1;
        else WriteMem = 0;
    endfunction

    function [2:0] lwExtOp;
        input [5:0] opcode;
        case (opcode[2:0])
            3'b000: lwExtOp = 3'b000;
            3'b100: lwExtOp = 3'b001;
            3'b001: lwExtOp = 3'b010;
            3'b101: lwExtOp = 3'b011;
            3'b011: lwExtOp = 3'b100;
            default: lwExtOp = 3'b000;
        endcase
    endfunction

    function [3:0] WriteDataSrc;
        input [31:0] Inst;
        input [5:0] opcode;
        input [5:0] func;
        input Rtype;
        if(Rtype) begin
            case (func[5:3])
                3'b100: WriteDataSrc = 0; 
                3'b101: WriteDataSrc = 1;
                3'b000: WriteDataSrc = 2;
                3'b001: WriteDataSrc = 3;
                3'b010: begin
                    if(func[2:0] == 3'b000 || func[2:0] == 3'b010 )
                        WriteDataSrc = 4;
                    else WriteDataSrc = 5;
                end
                default: WriteDataSrc = 0;
            endcase
        end
        else begin
            case (opcode[5:3])
                3'b001: begin
                    if (opcode[2:1] == 2'b01) begin
                        WriteDataSrc = 1;
                    end
                    else WriteDataSrc = 0;
                end 
                3'b000: WriteDataSrc = 3;
                3'b100: WriteDataSrc = 6;
                3'b010:begin
                    if(Inst[25:21] == 5'b00000) 
                        WriteDataSrc = 7;
                    else WriteDataSrc = 8;
                end
                default: WriteDataSrc = 0;
            endcase
        end
    endfunction 

    function [2:0] AluOp;
        input [5:0] opcode;
        input [5:0] func;
        input Rtype;
        if(Rtype) 
            AluOp = func[2:0];
        else begin
            AluOp = opcode[5:4] == 2'b10 ? 3'b000 : opcode[2:0];
        end
        
    endfunction

    function [31:0] BranchPC;
        input [5:0] opcode;
        input [31:0] extImm;
        input [31:0] target;
        input [31:0] reg_data1;
        case (opcode[2:0])
            3'b000: BranchPC = reg_data1;
            3'b010: BranchPC = target;
            3'b011: BranchPC = target;
            default: BranchPC = extImm;
        endcase
    endfunction

endmodule // ID