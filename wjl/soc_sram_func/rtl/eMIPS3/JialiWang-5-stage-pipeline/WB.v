module WB(
    input clk,
    input rst_n,

    input [31:0] PC_in,
    input [31:0] PC4,
    input [31:0] Inst,
    input write_reg_in,
    input write_cp0reg_in,
    input [4:0] write_dst_in,
    input [31:0] reg_data1,
    input [31:0] reg_data2,
    input [1:0] write_hilo,
    input [63:0] hilo,
    input [3:0] write_data_src,
    input [31:0] alu_a,
    inout [31:0] alu_s,
    input [31:0] alu_c,
    input [31:0] mem_ext_data,
    // input [31:0] cp0_reg_data,
    // input trap,
    // input IF_addr_fault,
    // input ri_fault,
    // input soft_int,
    // input overflow,
    // input load_addr_fault,
    // input store_addr_fault,
    // input delay_slot,
    input flush,

    input [31:0] cause,
    input [31:0] status,
    input [31:0] badVaddr,
    input [31:0] epc  ,

    output [31:0] PC_out,
    output [31:0] Inst_out,
    // output exception,
    output write_reg_out,
    output [4:0] write_dst_out,
    output [31:0] write_data,
    output write_cp0reg_out,

    output [31:0] reg_hi,
    output [31:0] reg_lo
);
    reg [31:0] Hi;
    reg [31:0] Lo;

    assign PC_out =  PC_in;
    assign Inst_out = Inst;
    assign write_reg_out = write_reg_in & (~flush);
    wire [31:0] hilo_data = Inst[1] ? Lo : Hi;

    reg  [31:0] cp0_reg_data;

    assign write_data = WriteData(write_data_src, alu_a, alu_c, alu_s,
            PC4, hilo_data, reg_data1, mem_ext_data, cp0_reg_data, reg_data2);
    // assign epc = EpcData(exception, trap, write_cp0reg_in, reg_data2, Inst, PC_in, delay_slot);
    assign write_cp0reg_out = write_cp0reg_in & (~flush);
    assign write_dst_out = write_dst_in;

    assign reg_hi = Hi;
    assign reg_lo = Lo;
    // Exception Exception_U(trap, overflow, IF_addr_fault, load_addr_fault, store_addr_fault, ri_fault, 
    //             soft_int, delay_slot,
    //     exception, cause);
    always @(*) begin
        if(Inst[2:0] == 0) begin
            case (Inst[15:11])
                8:  cp0_reg_data = badVaddr;
                12: cp0_reg_data = status;
                13: cp0_reg_data = cause;
                14: cp0_reg_data = epc; 
                default: cp0_reg_data = 0;
            endcase
        end
        else cp0_reg_data = 0;
    end


    always @(posedge clk) begin
        if(!rst_n) begin
            Hi <= 0;
            Lo <= 0;
        end
        else begin
           if(write_hilo == 2'b11 && flush == 1'b0) begin
                Hi <= hilo[63:32];
                Lo <= hilo[31:0];
            end
            else if(write_hilo == 2'b10 && flush == 1'b0) 
                Hi <= reg_data1;  
            else if(write_hilo == 2'b01 && flush == 1'b0)
                Lo <= reg_data1;
        end
    end

    function [31:0] WriteData;
        input [3:0] write_data_src;
        input [31:0] alu_a_out, alu_c_out, alu_s_out;
        input [31:0] PC4;
        input [31:0] hilo;
        input [31:0] reg_data1;
        input [31:0] mem_data_ext;
        input [31:0] cp0_reg;
        input [31:0] reg_data2;
        case (write_data_src)
            0 : WriteData = alu_a_out;
            1: WriteData = alu_c_out;
            2: WriteData = alu_s_out;
            3: WriteData = PC4+4; // delay slot
            4: WriteData = hilo;
            5: WriteData = reg_data1;
            6: WriteData = mem_data_ext;
            7: WriteData = cp0_reg;
            8: WriteData = reg_data2;
            default: WriteData = 0;
        endcase
    endfunction

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
    // /    /         EpcData = reg_data;
    //     else EpcData = 0;
    // endfunction
endmodule // MEM_WB