// will do not use

module Exception(
    input trap,
    input overflow,
    input addrFault,
    input IF_addr_fault,
    input ri_fault,
    input soft_int,
    input [31:0] Inst,
    input delay_slot,

    output exception,
    output[31:0]  cause 
);
    assign exception = trap | overflow | addrFault | IF_addr_fault | ri_fault | soft_int;
    assign cause = Cause(trap, overflow, addrFault, IF_addr_fault, ri_fault,  Inst) | ({32{delay_slot}} & 32'h80000000);

    function [31:0] Cause;
        input trap;
        input overflow;
        input addrFault ;
        input IF_addr_fault;
        input ri_fault;
        input [31:0] Inst;
        // Cause = 0; // 
        if (trap) begin
            case (Inst[5:0]) 
                6'b001101:Cause = {25'b0, 5'b01001, 2'b0};
                6'b001100:Cause = {25'b0, 5'b01000, 2'b0};
                default: Cause = 0;
            endcase
        end
        else if (overflow) begin
            Cause = {25'b0, 5'b01100, 2'b0};
        end
        else if(addrFault) begin
            case (Inst[31:29])
                3'b100:Cause = {25'b0, 5'b00100, 2'b0};
                3'b101:Cause = {25'b0, 5'b00101, 2'b0}; 
                default: Cause = 0;
            endcase
        end
        else if(IF_addr_fault) begin
            Cause = {25'b0, 5'b00100, 2'b0};
        end
        else if(ri_fault) begin
            Cause = {25'b0, 5'b01010, 2'b0};
        end
        else Cause = 0;
    endfunction
endmodule // Exception