module ALU_a(
    input [31:0] valA,
    input [31:0] valB ,
    input [2:0] aluOp,
    
    output [31:0] alu_out,
    output overflow
);
    assign alu_out = AluOut(valA, valB, aluOp);
    assign overflow=OverFlow(valA, valB, aluOp, alu_out);

    function [31:0] AluOut;
        input [31:0] valA;
        input [31:0] valB;
        input [2:0] aluOp;
        case (aluOp)
            0:AluOut = valA+valB; 
            1: AluOut = valA+valB;
            2:AluOut = valA-valB;
            3:AluOut = valA-valB;
            4:AluOut = valA & valB;
            5: AluOut = valA | valB;
            6:AluOut = valA ^ valB;
            7:AluOut = ~(valA | valB);
            // 6:AluOut = ~(valA | valB);
            // 7:AluOut = valA ^ valB;
            default: AluOut = 0;
        endcase
    endfunction

    function OverFlow;
        input [31:0] valA;
        input [31:0] valB;
        input [2:0] aluOp;
        input [31:0] alu_out;
        case (aluOp)
            3'b000:OverFlow=(~(valA[31] ^ valB[31])) & (alu_out[31] ^ valA[31]);
            3'b010:OverFlow =(valA[31]^valB[31]) & (valA[31]^alu_out[31]) ;
            default: OverFlow = 0;
        endcase
        
    endfunction
endmodule // ALU_

module ALU_s(
    input[31:0] valA, // rs/sa
    input[31:0] valB, // rt
    input [2:0] aluOp,
    output [31:0] alu_out
);
    assign alu_out = AluOut(valA, valB, aluOp);

    function [31:0] AluOut;
        input [31:0]valA;
        input [31:0] valB; 
        input [2:0] aluOp;
        case (aluOp)
            0:AluOut= valB << valA;
            2:AluOut = valB >> valA;
            3:AluOut = ($signed(valB)) >>> valA;
            4:AluOut = valB << valA;
            6:AluOut = valB >> valA;
            7:AluOut = ($signed(valB)) >>> valA;
            default: AluOut = 0;
        endcase
    endfunction
endmodule // ALU_s

module ALU_c(
    input [31:0] valA,
    input [31:0] valB,
    input [2:0] aluOp,
    output [31:0] alu_out
);
    assign alu_out = AluOut(valA,valB, aluOp);

    function [31:0]AluOut;
        input [31:0] valA;
        input [31:0] valB;
        input [2:0] aluOp;
        case (aluOp)
            3'b010 : begin
                if(valA[31] == 1'b0 && valB[31] == 1'b0)
                    AluOut = valA < valB ? 1 : 0;
                else if(valA[31] == 1'b0 && valB[31] == 1'b1)
                    AluOut = 0;
                else if(valA[31] == 1'b1 && valB[31] == 1'b0)
                    AluOut = 1;
                else AluOut = valA < valB ? 1 : 0; 
            end 
            3'b011:begin
                AluOut = valA < valB ? 1 : 0;
            end
            default: AluOut = 0;
        endcase
        
    endfunction
endmodule // ALU_c