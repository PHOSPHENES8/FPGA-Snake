module MUL_DIV(
    input clk,
    input rst_n,

    input [31:0] ID_Inst,
    input [31:0] Inst,
    input [31:0] reg_data1,
    input [31:0] reg_data2,

    output running,
    output reg [31:0] hi,
    output reg [31:0] lo
);

    // reg [63:0] HiLo;
    reg Running;
    reg [5:0] state;

    reg [31:0] valA;
    reg [31:0] valB;

    reg [63:0] divisor;
    reg [63:0] remainder;
    reg [31:0] quotient;

    wire div_en = DivEN(Inst);

    // assign running = (!(state == 0)) || (state == 0 && div_en);
    assign running = Running;

    reg [63:0] mul_res;
    // reg [63:0] div_res;

    always @(*) begin
        case (Inst[1:0])
            2'b10: begin
                // div_res = (valA[31] ^ valB[31]) ? {-remainder, -quotient} : {remainder, quotient};
                hi = (valA[31] ^ remainder[31]) ? -(remainder[31:0]) : remainder[31:0];
                // lo = div_res[31:0];
                lo = (valA[31] ^ valB[31]) ? -quotient :  quotient;
            end 
            2'b11:begin
                hi = remainder[31:0];
                lo = quotient;
            end 
            2'b00: begin
                mul_res = $signed(reg_data1) * $signed(reg_data2);
                hi = mul_res[63:32] ;
                lo = mul_res[31:0] ;
            end
            2'b01: begin
                mul_res = reg_data1 * reg_data2;
                hi = mul_res[63:32];
                lo = mul_res[31:0] ;
            end
            default: begin
                hi = 0;
                lo = 0;
            end
        endcase
    end

    wire [63:0] tmp_val = remainder - divisor;
    always @(posedge clk) begin
        if(!rst_n) begin
            // HiLo <= 0;
            // Running <= 0;
            valA <= 0;
            valB <= 0;
            state <= 0;
            divisor <= 0;
            remainder <= 0;
            quotient <= 0;
        end
        else if(div_en && state == 0 && Running) begin
            valA <= reg_data1;
            valB <= reg_data2;
            remainder <= {32'b0, (Inst[0]==1'b0 & reg_data1[31]) ? (~reg_data1)+1 : reg_data1};
            divisor <= {1'b0, (Inst[0]==1'b0 & reg_data2[31]) ? (~reg_data2)+1 : reg_data2, 31'b0 };
            quotient <= 0;
            // HiLo <= {0, abs_op2};
            // Running <= 1;
            state <= 32;
        end
        else if (state != 0) begin
            if(tmp_val[63] == 1'b1) begin
                quotient <= quotient << 1;
            end
            else begin
                remainder <= tmp_val;
                quotient <= (quotient << 1) | 1;
            end
            divisor <= divisor >> 1;
            state <= state - 1;
        end
    end

    wire ID_div = DivEN(ID_Inst);
    always @(posedge clk) begin
        if(!rst_n) begin
            Running <= 0;
        end
        else if(ID_div && !Running) begin
            Running <= 1;
        end
        else if(state == 1) begin
            Running <= 0;
        end
    end

    function DivEN;
        input [31:0] Inst;
        if (Inst[31:26] == 0 && (Inst[5:0] == 6'b011010 || Inst[5:0] == 6'b011011))
            DivEN = 1;
        else DivEN = 0;
    endfunction

endmodule // MUL_DIV


// module MUL_DIV(
//     input [31:0] valA,
//     input [31:0] valB,
//     input [1:0] mult_div_op,
//     output [31:0] hi,
//     output [31:0] lo
// );
//     wire [63:0] hilo = GetHiLo(valA, valB, mult_div_op);

//     assign hi = hilo[63:32];
//     assign lo = hilo[31:0];

//     function [63:0] GetHiLo;
//         input [31:0] valA;
//         input [31:0] valB;
//         input [1:0] mult_div_op;
//         case (mult_div_op)
//             2'b00: begin
//                 GetHiLo = $signed(valA) * $signed(valB);
//             end
//             2'b01 : begin
//                 GetHiLo = valA * valB;
//             end
//             2'b10: begin
//                 GetHiLo[63:32] = $signed(valA) % $signed(valB);
//                 GetHiLo[31:0]  = $signed(valA) / $signed(valB);
//             end
//             2'b11: begin
//                 GetHiLo[63:32] = valA % valB;
//                 GetHiLo[31:0]  = valA / valB;
//             end
//             // 2'b01: GetHiLo = valA * valB;
//             // 2'b10: GetHiLo =valA / valB;
//             // 2'b11: GetHiLo = valA / valB;
//             default: GetHiLo = 0;
//         endcase
        
        
//     endfunction
// endmodule // MUL_DIB
