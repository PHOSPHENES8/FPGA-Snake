module isBranch (
    input[31:0] valA,
    input [31:0] valB,
    input [4:0] rt,
    input [5:0] opcode,
    input [5:0] func,
    input [31:0] Inst,
    output reg [1:0] PCSel
    
);
    always @(*) begin
        case (opcode[5:3])
            3'b000:begin
                case (opcode[2:0])
                    3'b000: begin        //PCSel = 0;
                        PCSel = func[5:1] == 5'b00100 ? 1 : 0;
                    end
                    3'b001:begin
                        case (rt)
                            // 5'b00001:PCSel = valA >= 0 ? 1:0;
                            5'b00001:PCSel= valA[31] == 1'b0 ?1 : 0;
                            // 5'b00000:PCSel = valA < 0 ? 1 : 0;
                            5'b00000:PCSel = valA[31] == 1'b1 ? 1 : 0;
                            // 5'b10001:PCSel = valA >= 0 ? 1 : 0;
                            5'b10001:PCSel = valA[31] == 1'b0 ? 1 : 0;
                            // 5'b10000:PCSel = valA < 0 ? 1 : 0;
                            5'b10000:PCSel = valA[31] == 1'b1 ? 1 : 0;
                            default: PCSel = 0;
                        endcase
                    end
                    3'b010:PCSel=1;
                    3'b011:PCSel=1;
                    3'b100:PCSel = valA == valB ? 1:0;
                    3'b101:PCSel = valA != valB ? 1:0;
                    // 3'b110:PCSel = valA <= 0 ? 1 : 0;
                    3'b110:PCSel = ( valA[31] == 1'b1 || valA == 0 ) ? 1 : 0;
                    // 3'b111:PCSel = valA > 0 ? 1 : 0;
                    3'b111:PCSel = (valA > 0 && valA[31] != 1'b1) ? 1 : 0;
                    default PCSel = 0; 
                endcase 
            end
            3'b010:
                PCSel = (opcode[2:0] == 3'b000 && func==6'b011000) ? 2 : 0;      
            default:  
                PCSel = 0;
        endcase
    end
endmodule // 