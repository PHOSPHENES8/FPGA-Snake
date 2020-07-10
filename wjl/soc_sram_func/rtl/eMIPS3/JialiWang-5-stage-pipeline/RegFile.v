module RegFile(
    input clk,
    input rst_n,

    input [4:0] readReg1,
    input [4:0] readReg2,
    input [31:0] write_data,
    input [4:0] writeReg,
    input write_en,
    
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] Regs[0:31];
    
    parameter SIZE = 32;
    // genvar i;
    // generate 
    always @(posedge clk) begin
        if(rst_n == 1'b0) begin : reg_init
            integer i;
            for(i = 0; i < 32; i=i+1) begin
                Regs[i] <= 0;
            end
        end
        else if(write_en && writeReg != 0) begin
            Regs[writeReg] <= write_data;
        end
    end

    // assign read_data1 = write_en & (readReg1 == writeReg) ? write_data : Regs[readReg1] ;
    // assign read_data2 = write_en & (readReg2 == writeReg) ? write_data : Regs[readReg2];
    assign read_data1 = ReadReg(write_en, readReg1, Regs[readReg1], writeReg, write_data);
    assign read_data2 = ReadReg(write_en, readReg2, Regs[readReg2], writeReg, write_data);
    
    function [31:0] ReadReg;
        input write_en;
        input [4:0] reg_num;
        input [31:0] reg_val;
        input [4:0] write_reg;
        input [31:0] write_data;
        if(reg_num == 0)
            ReadReg = 0;
        else if(write_en && reg_num == writeReg) 
            ReadReg = write_data;
        else 
            ReadReg = reg_val;
    endfunction
    // endgenerate
//    parameter SIZE = 32;
    // wire [31:0] r0 = Regs[0];
    // wire [31:0] r1 = Regs[1];
    // wire [31:0] r2 = Regs[2];
    // wire [31:0] r3 = Regs[3];
    // wire [31:0] r4 = Regs[4];
    // wire [31:0] r5 = Regs[5];
    // wire [31:0] r6 = Regs[6];
    // wire [31:0] r7 = Regs[7];
    // wire [31:0] r8 = Regs[8];
    // wire [31:0] r9 = Regs[9];
    // wire [31:0] r10 = Regs[10];
    // wire [31:0] r11 = Regs[11];
    // wire [31:0] r12 = Regs[12];
    // wire [31:0] r13 = Regs[13];
    // wire [31:0] r14 = Regs[14];
    // wire [31:0] r15 = Regs[15];
    // wire [31:0] r16 = Regs[16];
    // wire [31:0] r17 = Regs[17];
    // wire [31:0] r18 = Regs[18];
    // wire [31:0] r19 = Regs[19];
    // wire [31:0] r20 = Regs[20];
    // wire [31:0] r21 = Regs[21];
    // wire [31:0] r22 = Regs[22];
    // wire [31:0] r23 = Regs[23];
    // wire [31:0] r24 = Regs[24];
    // wire [31:0] r25 = Regs[25];
    // wire [31:0] r26 = Regs[26];
    // wire [31:0] r27 = Regs[27];
    // wire [31:0] r28 = Regs[28];
    // wire [31:0] r29 = Regs[29];
    // wire [31:0] r30 = Regs[30];
    // wire [31:0] r31 = Regs[31];
endmodule // RegFile