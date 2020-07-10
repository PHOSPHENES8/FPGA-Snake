module IF_ID(
    input clk,
    input rst_n,

    input [31:0] Inst_in,
    input [31:0] PC_in,
    input [31:0] PC4_in,
    input IF_addr_fault_in,
    input stall,
    
    output [31:0] Inst_out,
    output [31:0] PC_out,
    output [31:0] PC4_out,
    output IF_addr_fault_out
);

    reg [31:0] Inst;
    reg [31:0] PC;
    reg [31:0] PC4;
    reg IF_addr_fault;

    assign Inst_out = Inst;
    assign PC_out = PC; 
    assign PC4_out = PC4;
    assign IF_addr_fault_out =  IF_addr_fault;

    always @(posedge clk) begin
        if(!rst_n) begin
            Inst <= 0;
            PC <= 0;
            PC4 <= 0;
            IF_addr_fault <= 0;
        end
        else if(!stall)begin
            Inst <= Inst_in ;
            PC <= PC_in;
            PC4 <= PC4_in;
            IF_addr_fault <= IF_addr_fault_in;
        end
    end

endmodule // IF_ID