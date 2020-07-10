// cp0 reg & exception handle

module CP0(
    input clk,
    input rst_n,

    input [31:0] PC,
    input [31:0] Inst,
    input write_cp0reg,
    input [31:0] reg_data2,
    input trap,
    input IF_addr_fault,
    input ri_fault,
    input soft_int,
    input overflow,
    input load_addr_fault,
    input store_addr_fault,
    input delay_slot,
    input [31:0] data_sram_addr,

    output exception,
    output [31:0] epc,
    output [31:0] cause,
    output [31:0] badVAddr,
    output [31:0] status
);

    reg [31:0] Epc;
    reg [31:0] Cause;
    reg [31:0] BadVAddr;
    reg [31:0] Status;

    assign exception = trap | overflow | load_addr_fault | store_addr_fault | IF_addr_fault | ri_fault | soft_int;
    assign epc = Epc;
    assign cause = Cause;
    assign badVAddr = BadVAddr;
    assign status = Status;

    wire [6:0]tmp = {trap, overflow,load_addr_fault, store_addr_fault,
                    IF_addr_fault, ri_fault, soft_int};

    wire [31:0] exception_cause = ExceptionCause(
            .trap(trap),
            .overflow(overflow),
            .load_addr_fault(load_addr_fault),
            .store_addr_fault(store_addr_fault),
            .IF_addr_fault(IF_addr_fault),
            .ri_fault(ri_fault),
            .soft_int(soft_int),
            .delay_slot(delay_slot),
            .Inst(Inst)
    );

    always @(posedge clk) begin
        if(!rst_n) begin
            Epc <= 0;
        end
        else if(exception || (write_cp0reg && Inst[15:11] == 14 && Inst[2:0] == 0))begin
            Epc <= EpcData(exception, trap, write_cp0reg, reg_data2, Inst, PC, delay_slot);
        end
    end
    always @(posedge clk) begin
        if(rst_n == 1'b0) Cause <= 0;
        else if(exception) Cause <= exception_cause; 
        else if(write_cp0reg && Inst[15:11] == 13 && Inst[2:0] == 0) begin
            Cause <= reg_data2;
        end 
    end
    always @(posedge clk) begin
        if(!rst_n) BadVAddr <= 0;
        else if (load_addr_fault | store_addr_fault) begin // data mem addr fault
            BadVAddr <= data_sram_addr;
        end
        else if(IF_addr_fault) begin
            BadVAddr <= PC;
        end
        else if(write_cp0reg && Inst[15:11] == 8 && Inst[2:0] == 0) // mtc0
            BadVAddr <= reg_data2;
    end
    always @(posedge clk) begin
        if(!rst_n) Status <= 0;
        else if(exception) begin
            Status <= Status | 2;
        end 
        else if(write_cp0reg && Inst[15:11] == 12 && Inst[2:0] == 0) 
            Status <= reg_data2;
    end

    function [31:0] EpcData;
        input exception;
        input trap;
        input write_cp0reg;
        input [31:0] reg_data;
        input [31:0] Inst;
        input [31:0] PC;
        input delay_slot;

        if(exception) begin
            EpcData = delay_slot ? PC-4 : PC;
        end
        else if(write_cp0reg)   
            EpcData = reg_data;
        else EpcData = 0;
    endfunction

    function [31:0] ExceptionCause;
        input trap;
        input overflow;
        input load_addr_fault ;
        input store_addr_fault;
        input IF_addr_fault;
        input ri_fault;
        input soft_int;
        input delay_slot;
        input [31:0] Inst ;
        reg [31:0] ExceptionCause1;
        begin
            
            case ({trap, overflow,load_addr_fault, store_addr_fault,
                    IF_addr_fault, ri_fault, soft_int})
                7'b1000000: begin
                    case (Inst[5:0])
                        6'b001101:ExceptionCause1 = {25'b0, 5'b01001, 2'b0};
                        6'b001100:ExceptionCause1 = {25'b0, 5'b01000, 2'b0};
                        default: ExceptionCause1 = 0;
                    endcase
                end
                7'b0100000:ExceptionCause1  = {25'b0, 5'b01100, 2'b0};
                7'b0010000:ExceptionCause1 = {25'b0, 5'b00100, 2'b0};
                7'b0001000:ExceptionCause1 = {25'b0, 5'b00101, 2'b0}; 
                7'b0000100:ExceptionCause1 = {25'b0, 5'b00100, 2'b0};
                7'b0000010:ExceptionCause1 = {25'b0, 5'b01010, 2'b0};
                7'b0000001:ExceptionCause1 = 0;
                default: ExceptionCause1 = 0;
            endcase

            ExceptionCause = {delay_slot, 31'b0} | ExceptionCause1;
        end
        // input [31:0] Inst;
        // Cause = 0; // 
        // if (trap) begin
        //     case (Inst[5:0]) 
        //         6'b001101:Cause = {25'b0, 5'b01001, 2'b0};
        //         6'b001100:Cause = {25'b0, 5'b01000, 2'b0};
        //         default: Cause = 0;
        //     endcase
        // end
        // else if (overflow) begin
        //     Cause = {25'b0, 5'b01100, 2'b0};
        // end
        // else if(addrFault) begin
        //     case (Inst[31:29])
        //         3'b100:Cause = {25'b0, 5'b00100, 2'b0};
        //         3'b101:Cause = {25'b0, 5'b00101, 2'b0}; 
        //         default: Cause = 0;
        //     endcase
        // end
        // else if(IF_addr_fault) begin
        //     Cause = {25'b0, 5'b00100, 2'b0};
        // end
        // else if(ri_fault) begin
        //     Cause = {25'b0, 5'b01010, 2'b0};
        // end
        // else Cause = 0;
    endfunction
endmodule // CP0