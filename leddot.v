`define LEDDOTR_ADDR       16'hf000   //32'hbfaf_f000
module leddot (
    input clk,
    input resetn,
    input [31:0]conf_addr,
    input [31:0]cpu_data_wdata,
    output [7:0]led_dotr,
    output [7:0]led_dotc
);
    reg [7:0]led_dotr_reg, led_dotc_reg;
    always @(posedge clk) begin
        if(!resetn)begin
            led_dotr_reg<=8'b00100100;
            led_dotc_reg<=8'b11011011;
        end
        else begin
            if(conf_addr[15:0] == `LEDDOTR_ADDR)begin
                led_dotc_reg<=cpu_data_wdata[31:24];
                led_dotr_reg<=cpu_data_wdata[7:0];
            end
        end
    end
    assign led_dotc=led_dotc_reg;
    assign led_dotr=led_dotr_reg;
endmodule

