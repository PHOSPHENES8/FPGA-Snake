/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

//*************************************************************************
//   > File Name   : confreg.v
//   > Description : Control module of 
//                   16 red leds, 2 green/red leds,
//                   7-segment display, 
//                   switchs, 
//                   key board,
//                   bottom STEP,
//                   timer.
//
//   > Author      : LOONGSON
//   > Date        : 2017-08-04
//*************************************************************************
`define RANDOM_SEED {7'b1010101,16'h01FF}

`define CR0_ADDR       16'h8000   //32'hbfaf_8000 
`define CR1_ADDR       16'h8004   //32'hbfaf_8004 
`define CR2_ADDR       16'h8008   //32'hbfaf_8008 
`define CR3_ADDR       16'h800c   //32'hbfaf_800c 
`define CR4_ADDR       16'h8010   //32'hbfaf_8010 
`define CR5_ADDR       16'h8014   //32'hbfaf_8014 
`define CR6_ADDR       16'h8018   //32'hbfaf_8018 
`define CR7_ADDR       16'h801c   //32'hbfaf_801c 

`define LED_ADDR       16'hf000   //32'hbfaf_f000 
`define LED_RG0_ADDR   16'hf004   //32'hbfaf_f004 
`define LED_RG1_ADDR   16'hf008   //32'hbfaf_f008 
`define NUM_ADDR       16'hf010   //32'hbfaf_f010 
`define SWITCH_ADDR    16'hf020   //32'hbfaf_f020 
`define BTN_KEY_ADDR   16'hf024   //32'hbfaf_f024
`define BTN_STEP_ADDR  16'hf028   //32'hbfaf_f028
`define SW_INTER_ADDR  16'hf02c   //32'hbfaf_f02c 
`define TIMER_ADDR     16'he000   //32'hbfaf_e000 

`define IO_SIMU_ADDR      16'hffec  //32'hbfaf_ffec
`define VIRTUAL_UART_ADDR 16'hfff0  //32'hbfaf_fff0
`define SIMU_FLAG_ADDR    16'hfff4  //32'hbfaf_fff4 
`define OPEN_TRACE_ADDR   16'hfff8  //32'hbfaf_fff8
`define NUM_MONITOR_ADDR  16'hfffc  //32'hbfaf_fffc

`define RAND_ADDR      16'h8040    // 32'hbfaf_8040
`define LED_DOT1_ADDR  16'h8044    // 32'hbfaf_8044
`define LED_DOT2_ADDR  16'h8048    // 32'hbfaf_8048
`define BUTTON_ADDR    16'h804c    // 32'hbfaf_804c 

`define LCD_ADDR 16'h2000
`define LCD_T_PEN_ADDR 16'h2004
`define LCD_SDA_ADDR 16'h2008
`define LCD_SCL_ADDR 16'h200c
`define LCD_T_CS_ADDR 16'h2010

`define LCD_CS_ADDR 16'h2014
`define LCD_RS_ADDR 16'h2018
`define LCD_WR_ADDR 16'h2020
`define LCD_RD_ADDR 16'h2024
`define LCD_BL_CTR_ADDR 16'h2028

module confreg
#(parameter SIMULATION=1'b0)
(                     
    input             clk,          
    input             timer_clk,
    input             resetn,     
    // read and write from cpu
	input             conf_en,      
	input      [3 :0] conf_wen,      
	input      [31:0] conf_addr,    
	input      [31:0] conf_wdata,   
	output     [31:0] conf_rdata,   
    // read and write to device on board
    output     [15:0] led,          
    output     [1 :0] led_rg0,      
    output     [1 :0] led_rg1,      
    output reg [7 :0] num_csn,      
    output reg [6 :0] num_a_g,      
    input      [7 :0] switch,       
    output     [3 :0] btn_key_col,  
    input      [3 :0] btn_key_row,  
    input      [1 :0] btn_step   ,

    // lcd
    inout [15:0] lcd_db,
    output lcd_rst,
    output lcd_cs,
    output lcd_rs,
    output lcd_wr,
    output lcd_rd,
    output lcd_bl_ctr,
    output lcd_T_PEN,
    inout lcd_sda,
    output lcd_scl,
    inout lcd_T_int,

    output     [31:0] led_dot 
);

    wire display_valid;
    wire [39:0]display_name;
    wire [31:0]display_value;
    wire [5:0]display_number;
    wire input_valid;
    wire input_value;

    assign display_name[39:16] = "NO.";

    lcd_module lcd_module(
        .clk            (clk           ),   //10Mhz
        .resetn         (resetn        ),

        //调用触摸屏的接口
        .display_valid  (display_valid ),
        .display_name   (display_name  ),
        .display_value  (display_value ),
        .display_number (display_number),
        .input_valid    (input_valid   ),
        .input_value    (input_value   ),

        //lcd触摸屏相关接口，不需要更改
        .lcd_rst        (lcd_rst       ),
        .lcd_cs         (lcd_cs        ),
        .lcd_rs         (lcd_rs        ),
        .lcd_wr         (lcd_wr        ),
        .lcd_rd         (lcd_rd        ),
        .lcd_data_io    (lcd_db   ),
        .lcd_bl_ctr     (lcd_bl_ctr    ),
        .ct_int         (lcd_T_int        ),
        .ct_sda         (lcd_sda        ),
        .ct_scl         (lcd_scl        ),
        .ct_rstn        (lcd_T_PEN       )
    );

    reg  [31:0] cr0;
    reg  [31:0] cr1;
    reg  [31:0] cr2;
    reg  [31:0] cr3;
    reg  [31:0] cr4;
    reg  [31:0] cr5;
    reg  [31:0] cr6;
    reg  [31:0] cr7;

    reg  [31:0] led_data;
    reg  [31:0] led_rg0_data;
    reg  [31:0] led_rg1_data;
    reg  [31:0] num_data;
    wire [31:0] switch_data;
    wire [31:0] sw_inter_data; //switch interleave
    wire [31:0] btn_key_data;
    wire [31:0] btn_step_data;
    reg  [31:0] timer_r2;
    reg  [31:0] simu_flag;
    reg  [31:0] io_simu;
    reg  [7 :0] virtual_uart_data;
    reg         open_trace;
    reg         num_monitor;

    // -------- extra reg ---------
    reg  [31:0] button;
    always@(posedge clk)begin
        if(!resetn)begin
            button <= 32'h0;
        end
        else begin
            button <= btn_key_row;
        end
    end

    reg  [31:0] rand_data ; // rand 
    always @(posedge clk) begin
        if(~resetn) 
            rand_data <= 0;
        else 
            rand_data <= rand_data + 1;
    end

    reg [31:0] led_dot_data1;
    reg [31:0] led_dot_data2;
    reg [7:0] led_dot_row; // 1
    reg [7:0] led_dot_col; // 0
    assign led_dot = {led_dot_col, 16'b0, led_dot_row};

    // wire write_led_dot1 = conf_we & (conf_addr[15:0]==`LED_DOT1_ADDR)
    // wire write_led_dot2 = conf_we 
    // always @(posedge clk) begin
    //     if(~resetn) 
    //         led_dot_data <= 0;
    //     else 
    //         led_dot_data <= conf_wdata;
    // end
                        
    // read data has one cycle delay
    reg [31:0] conf_rdata_reg;
    assign conf_rdata = conf_rdata_reg;
    always @(posedge clk)
    begin
        if(~resetn)
        begin
            conf_rdata_reg <= 32'd0;
        end
        else if (conf_en)
        begin
            case (conf_addr[15:0])
                `CR0_ADDR      : conf_rdata_reg <= cr0          ;
                `CR1_ADDR      : conf_rdata_reg <= cr1          ;
                `CR2_ADDR      : conf_rdata_reg <= cr2          ;
                `CR3_ADDR      : conf_rdata_reg <= cr3          ;
                `CR4_ADDR      : conf_rdata_reg <= cr4          ;
                `CR5_ADDR      : conf_rdata_reg <= cr5          ;
                `CR6_ADDR      : conf_rdata_reg <= cr6          ;
                `CR7_ADDR      : conf_rdata_reg <= cr7          ;
                `LED_ADDR      : conf_rdata_reg <= led_data     ;
                `LED_RG0_ADDR  : conf_rdata_reg <= led_rg0_data ;
                `LED_RG1_ADDR  : conf_rdata_reg <= led_rg1_data ;
                `NUM_ADDR      : conf_rdata_reg <= num_data     ;
                `SWITCH_ADDR   : conf_rdata_reg <= switch_data  ;
                `BTN_KEY_ADDR  : conf_rdata_reg <= btn_key_data ;
                `BTN_STEP_ADDR : conf_rdata_reg <= btn_step_data;
                `SW_INTER_ADDR : conf_rdata_reg <= sw_inter_data;
                `TIMER_ADDR    : conf_rdata_reg <= timer_r2     ;
                `SIMU_FLAG_ADDR: conf_rdata_reg <= simu_flag    ;
                `IO_SIMU_ADDR  : conf_rdata_reg <= io_simu      ;
                `VIRTUAL_UART_ADDR : conf_rdata_reg <= {24'd0,virtual_uart_data} ;
                `OPEN_TRACE_ADDR : conf_rdata_reg <= {31'd0,open_trace} ;
                `NUM_MONITOR_ADDR: conf_rdata_reg <= {31'd0,num_monitor} ;
                `RAND_ADDR     : conf_rdata_reg <= rand_data ;
                `LED_DOT1_ADDR : conf_rdata_reg <= led_dot_data1;
                `LED_DOT2_ADDR : conf_rdata_reg <= led_dot_data2;
                `BUTTON_ADDR   : conf_rdata_reg <= button ;
                default        : conf_rdata_reg <= 32'd0;
            endcase
        end
    end

    //conf write, only support a word write
    assign conf_we = conf_en & (|conf_wen);


// ---------- EXTRA --------------------
wire write_led_dot1 = conf_we & (conf_addr[15:0]==`LED_DOT1_ADDR);
wire write_led_dot2 = conf_we & (conf_addr[15:0]==`LED_DOT2_ADDR);
always @(posedge clk) begin
    if(!resetn)
    begin
        led_dot_data1 <= 32'h0;
    end
    else if(write_led_dot1)
    begin
        led_dot_data1 <= conf_wdata[31:0];
    end

    if(!resetn)
    begin
        led_dot_data2 <= 32'h0;
    end
    else if(write_led_dot2)
    begin
        led_dot_data2 <= conf_wdata[31:0];
    end
end

//--------------------------------------


//-------------------------{confreg register}begin-----------------------//
wire write_cr0 = conf_we & (conf_addr[15:0]==`CR0_ADDR);
wire write_cr1 = conf_we & (conf_addr[15:0]==`CR1_ADDR);
wire write_cr2 = conf_we & (conf_addr[15:0]==`CR2_ADDR);
wire write_cr3 = conf_we & (conf_addr[15:0]==`CR3_ADDR);
wire write_cr4 = conf_we & (conf_addr[15:0]==`CR4_ADDR);
wire write_cr5 = conf_we & (conf_addr[15:0]==`CR5_ADDR);
wire write_cr6 = conf_we & (conf_addr[15:0]==`CR6_ADDR);
wire write_cr7 = conf_we & (conf_addr[15:0]==`CR7_ADDR);
always @(posedge clk)
begin
    cr0 <= !resetn    ? 32'd0      :
           write_cr0 ? conf_wdata : cr0;
    cr1 <= !resetn    ? 32'd0      :
           write_cr1 ? conf_wdata : cr1;
    cr2 <= !resetn    ? 32'd0      :
           write_cr2 ? conf_wdata : cr2;
    cr3 <= !resetn    ? 32'd0      :
           write_cr3 ? conf_wdata : cr3;
    cr4 <= !resetn    ? 32'd0      :
           write_cr4 ? conf_wdata : cr4;
    cr5 <= !resetn    ? 32'd0      :
           write_cr5 ? conf_wdata : cr5;
    cr6 <= !resetn    ? 32'd0      :
           write_cr6 ? conf_wdata : cr6;
    cr7 <= !resetn    ? 32'd0      :
           write_cr7 ? conf_wdata : cr7;
end
//--------------------------{confreg register}end------------------------//

//-------------------------------{timer}begin----------------------------//
reg         write_timer_begin,write_timer_begin_r1, write_timer_begin_r2,write_timer_begin_r3;
reg         write_timer_end_r1, write_timer_end_r2;
reg  [31:0] conf_wdata_r, conf_wdata_r1,conf_wdata_r2;

reg  [31:0] timer_r1;
reg  [31:0] timer;

wire write_timer = conf_we & (conf_addr[15:0]==`TIMER_ADDR);
always @(posedge clk)
begin
    if (!resetn)
    begin
        write_timer_begin <= 1'b0;
    end 
    else if (write_timer)
    begin
        write_timer_begin <= 1'b1;
        conf_wdata_r      <= conf_wdata;
    end 
    else if (write_timer_end_r2)
    begin
        write_timer_begin <= 1'b0;
    end 

    write_timer_end_r1 <= write_timer_begin_r2;
    write_timer_end_r2 <= write_timer_end_r1;
end

always @(posedge timer_clk)
begin
    write_timer_begin_r1 <= write_timer_begin;
    write_timer_begin_r2 <= write_timer_begin_r1;
    write_timer_begin_r3 <= write_timer_begin_r2;
    conf_wdata_r1        <= conf_wdata_r;
    conf_wdata_r2        <= conf_wdata_r1;

    if(!resetn)
    begin
        timer <= 32'd0;
    end
    else if (write_timer_begin_r2 && !write_timer_begin_r3)
    begin
        timer <= conf_wdata_r2[31:0];
    end
    else
    begin
        timer <= timer + 1'b1;
    end
end

always @(posedge clk)
begin
    timer_r1 <= timer;
    timer_r2 <= timer_r1;
end
//--------------------------------{timer}end-----------------------------//

//--------------------------{simulation flag}begin-----------------------//
always @(posedge clk)
begin
    if(!resetn)
    begin
        simu_flag <= {32{SIMULATION}};
    end
end
//---------------------------{simulation flag}end------------------------//

//---------------------------{io simulation}begin------------------------//
wire write_io_simu = conf_we & (conf_addr[15:0]==`IO_SIMU_ADDR);
always @(posedge clk)
begin
    if(!resetn)
    begin
        io_simu <= 32'd0;
    end
    else if(write_io_simu)
    begin
        io_simu <= {conf_wdata[15:0],conf_wdata[31:16]};
    end
end
//----------------------------{io simulation}end-------------------------//

//-----------------------------{open trace}begin-------------------------//
wire write_open_trace = conf_we & (conf_addr[15:0]==`OPEN_TRACE_ADDR);
always @(posedge clk)
begin
    if(!resetn)
    begin
        open_trace <= 1'b1;
    end
    else if(write_open_trace)
    begin
        open_trace <= |conf_wdata;
    end
end
//-----------------------------{open trace}end---------------------------//

//----------------------------{num monitor}begin-------------------------//
wire write_num_monitor = conf_we & (conf_addr[15:0]==`NUM_MONITOR_ADDR);
always @(posedge clk)
begin
    if(!resetn)
    begin
        num_monitor <= 1'b1;
    end
    else if(write_num_monitor)
    begin
        num_monitor <= conf_wdata[0];
    end
end
//----------------------------{num monitor}end---------------------------//

//---------------------------{virtual uart}begin-------------------------//
wire [7:0] write_uart_data;
wire write_uart_valid  = conf_we & (conf_addr[15:0]==`VIRTUAL_UART_ADDR);
assign write_uart_data = conf_wdata[7:0];
always @(posedge clk)
begin
    if(!resetn)
    begin
        virtual_uart_data <= 8'd0;
    end
    else if(write_uart_valid)
    begin
        virtual_uart_data <= write_uart_data;
    end
end
//----------------------------{virtual uart}end--------------------------//

//--------------------------------{led}begin-----------------------------//
//led display
//led_data[31:0]
wire write_led = conf_we & (conf_addr[15:0]==`LED_ADDR);
assign led = led_data[15:0];
always @(posedge clk)
begin
    if(!resetn)
    begin
        led_data <= 32'h0;
    end
    else if(write_led)
    begin
        led_data <= conf_wdata[31:0];
    end
end
//---------------------------------{led}end------------------------------//

//-------------------------------{switch}begin---------------------------//
//switch data
//switch_data[7:0]
assign switch_data   = {24'd0,switch};
assign sw_inter_data = {16'd0,
                        switch[7],1'b0,switch[6],1'b0,
                        switch[5],1'b0,switch[4],1'b0,
                        switch[3],1'b0,switch[2],1'b0,
                        switch[1],1'b0,switch[0],1'b0};
//--------------------------------{switch}end----------------------------//

//------------------------------{btn key}begin---------------------------//
//btn key data
reg [15:0] btn_key_r;
assign btn_key_data = {16'd0,btn_key_r};

//state machine
reg  [2:0] state;
wire [2:0] next_state;

//eliminate jitter
reg        key_flag;
reg [19:0] key_count;
reg [ 3:0] state_count;
wire key_start = (state==3'b000) && !(&btn_key_row);
wire key_end   = (state==3'b111) &&  (&btn_key_row);
wire key_sample= key_count[19];
always @(posedge clk)
begin
    if(!resetn)
    begin
        key_flag <= 1'd0;
    end
    else if (key_sample && state_count[3]) 
    begin
        key_flag <= 1'b0;
    end
    else if( key_start || key_end )
    begin
        key_flag <= 1'b1;
    end

    if(!resetn || !key_flag)
    begin
        key_count <= 20'd0;
    end
    else
    begin
        key_count <= key_count + 1'b1;
    end
end

always @(posedge clk)
begin
    if(!resetn || state_count[3])
    begin
        state_count <= 4'd0;
    end
    else
    begin
        state_count <= state_count + 1'b1;
    end
end

always @(posedge clk)
begin
    if(!resetn)
    begin
        state <= 3'b000;
    end
    else if (state_count[3])
    begin
        state <= next_state;
    end
end

assign next_state = (state == 3'b000) ? ( (key_sample && !(&btn_key_row)) ? 3'b001 : 3'b000 ) :
                    (state == 3'b001) ? (                !(&btn_key_row)  ? 3'b111 : 3'b010 ) :
                    (state == 3'b010) ? (                !(&btn_key_row)  ? 3'b111 : 3'b011 ) :
                    (state == 3'b011) ? (                !(&btn_key_row)  ? 3'b111 : 3'b100 ) :
                    (state == 3'b100) ? (                !(&btn_key_row)  ? 3'b111 : 3'b000 ) :
                    (state == 3'b111) ? ( (key_sample &&  (&btn_key_row)) ? 3'b000 : 3'b111 ) :
                                                                                        3'b000;
assign btn_key_col = (state == 3'b000) ? 4'b0000:
                     (state == 3'b001) ? 4'b1110:
                     (state == 3'b010) ? 4'b1101:
                     (state == 3'b011) ? 4'b1011:
                     (state == 3'b100) ? 4'b0111:
                                         4'b0000;
wire [15:0] btn_key_tmp;
always @(posedge clk) begin
    if(!resetn) begin
        btn_key_r   <= 16'd0;
    end
    else if(next_state==3'b000)
    begin
        btn_key_r   <=16'd0;
    end
    else if(next_state == 3'b111 && state != 3'b111) begin
        btn_key_r   <= btn_key_tmp;
    end
end

assign btn_key_tmp = (state == 3'b001)&(btn_key_row == 4'b1110) ? 16'h0001:
                     (state == 3'b001)&(btn_key_row == 4'b1101) ? 16'h0010:
                     (state == 3'b001)&(btn_key_row == 4'b1011) ? 16'h0100:
                     (state == 3'b001)&(btn_key_row == 4'b0111) ? 16'h1000:
                     (state == 3'b010)&(btn_key_row == 4'b1110) ? 16'h0002:
                     (state == 3'b010)&(btn_key_row == 4'b1101) ? 16'h0020:
                     (state == 3'b010)&(btn_key_row == 4'b1011) ? 16'h0200:
                     (state == 3'b010)&(btn_key_row == 4'b0111) ? 16'h2000:
                     (state == 3'b011)&(btn_key_row == 4'b1110) ? 16'h0004:
                     (state == 3'b011)&(btn_key_row == 4'b1101) ? 16'h0040:
                     (state == 3'b011)&(btn_key_row == 4'b1011) ? 16'h0400:
                     (state == 3'b011)&(btn_key_row == 4'b0111) ? 16'h4000:
                     (state == 3'b100)&(btn_key_row == 4'b1110) ? 16'h0008:
                     (state == 3'b100)&(btn_key_row == 4'b1101) ? 16'h0080:
                     (state == 3'b100)&(btn_key_row == 4'b1011) ? 16'h0800:
                     (state == 3'b100)&(btn_key_row == 4'b0111) ? 16'h8000:16'h0000;
//-------------------------------{btn key}end----------------------------//

//-----------------------------{btn step}begin---------------------------//
//btn step data
reg btn_step0_r; //0:press
reg btn_step1_r; //0:press
assign btn_step_data = {30'd0,~btn_step0_r,~btn_step1_r}; //1:press

//-----step0
//eliminate jitter
reg        step0_flag;
reg [19:0] step0_count;
wire step0_start = btn_step0_r && !btn_step[0];
wire step0_end   = !btn_step0_r && btn_step[0];
wire step0_sample= step0_count[19];
always @(posedge clk)
begin
    if(!resetn)
    begin
        step0_flag <= 1'd0;
    end
    else if (step0_sample) 
    begin
        step0_flag <= 1'b0;
    end
    else if( step0_start || step0_end )
    begin
        step0_flag <= 1'b1;
    end

    if(!resetn || !step0_flag)
    begin
        step0_count <= 20'd0;
    end
    else
    begin
        step0_count <= step0_count + 1'b1;
    end

    if(!resetn)
    begin
        btn_step0_r <= 1'b1;
    end
    else if(step0_sample)
    begin
        btn_step0_r <= btn_step[0];
    end
end

//-----step1
//eliminate jitter
reg        step1_flag;
reg [19:0] step1_count;
wire step1_start = btn_step1_r && !btn_step[1];
wire step1_end   = !btn_step1_r && btn_step[1];
wire step1_sample= step1_count[19];
always @(posedge clk)
begin
    if(!resetn)
    begin
        step1_flag <= 1'd0;
    end
    else if (step1_sample) 
    begin
        step1_flag <= 1'b0;
    end
    else if( step1_start || step1_end )
    begin
        step1_flag <= 1'b1;
    end

    if(!resetn || !step1_flag)
    begin
        step1_count <= 20'd0;
    end
    else
    begin
        step1_count <= step1_count + 1'b1;
    end

    if(!resetn)
    begin
        btn_step1_r <= 1'b1;
    end
    else if(step1_sample)
    begin
        btn_step1_r <= btn_step[1];
    end
end
//------------------------------{btn step}end----------------------------//

//-------------------------------{led rg}begin---------------------------//
//led_rg0_data[31:0]  led_rg0_data[31:0]
//bfd0_f010           bfd0_f014
wire write_led_rg0 = conf_we & (conf_addr[15:0]==`LED_RG0_ADDR);
wire write_led_rg1 = conf_we & (conf_addr[15:0]==`LED_RG1_ADDR);
assign led_rg0 = led_rg0_data[1:0];
assign led_rg1 = led_rg1_data[1:0];
always @(posedge clk)
begin
    if(!resetn)
    begin
        led_rg0_data <= 32'h0;
    end
    else if(write_led_rg0)
    begin
        led_rg0_data <= conf_wdata[31:0];
    end

    if(!resetn)
    begin
        led_rg1_data <= 32'h0;
    end
    else if(write_led_rg1)
    begin
        led_rg1_data <= conf_wdata[31:0];
    end
end
//--------------------------------{led rg}end----------------------------//

//---------------------------{digital number}begin-----------------------//
//digital number display
//num_data[31:0]
wire write_num = conf_we & (conf_addr[15:0]==`NUM_ADDR);
always @(posedge clk)
begin
    if(!resetn)
    begin
        num_data <= 32'h0;
    end
    else if(write_num)
    begin
        num_data <= conf_wdata[31:0];
    end
end


reg [19:0] count;
always @(posedge clk)
begin
    if(!resetn)
    begin
        count <= 20'd0;
    end
    else
    begin
        count <= count + 1'b1;
    end
end
//scan data
reg [3:0] scan_data;
always @ ( posedge clk )  
begin
    if ( !resetn )
    begin
        scan_data <= 32'd0;  
        num_csn   <= 8'b1111_1111;
        led_dot_row <= 8'h00;
        led_dot_col <= 8'h11;
    end
    else
    begin
        case(count[19:17])
            3'b000 : scan_data <= num_data[31:28];
            3'b001 : scan_data <= num_data[27:24];
            3'b010 : scan_data <= num_data[23:20];
            3'b011 : scan_data <= num_data[19:16];
            3'b100 : scan_data <= num_data[15:12];
            3'b101 : scan_data <= num_data[11: 8];
            3'b110 : scan_data <= num_data[7 : 4];
            3'b111 : scan_data <= num_data[3 : 0];
        endcase

        case(count[19:17])
            3'b000 : num_csn <= 8'b0111_1111;
            3'b001 : num_csn <= 8'b1011_1111;
            3'b010 : num_csn <= 8'b1101_1111;
            3'b011 : num_csn <= 8'b1110_1111;
            3'b100 : num_csn <= 8'b1111_0111;
            3'b101 : num_csn <= 8'b1111_1011;
            3'b110 : num_csn <= 8'b1111_1101;
            3'b111 : num_csn <= 8'b1111_1110;
        endcase

        case(count[19:17]) 
            3'b000 : led_dot_col <= 8'b0111_1111;
            3'b001 : led_dot_col <= 8'b1011_1111;
            3'b010 : led_dot_col <= 8'b1101_1111;
            3'b011 : led_dot_col <= 8'b1110_1111;
            3'b100 : led_dot_col <= 8'b1111_0111;
            3'b101 : led_dot_col <= 8'b1111_1011;
            3'b110 : led_dot_col <= 8'b1111_1101;
            3'b111 : led_dot_col <= 8'b1111_1110;
        endcase

        case (count[19:17])
            3'b000 : led_dot_row <= {led_dot_data1[31], led_dot_data1[23], led_dot_data1[15], led_dot_data1[7],   led_dot_data2[31], led_dot_data2[23], led_dot_data2[15], led_dot_data2[7] };
            3'b001 : led_dot_row <= {led_dot_data1[30], led_dot_data1[22], led_dot_data1[14], led_dot_data1[6],   led_dot_data2[30], led_dot_data2[22], led_dot_data2[14], led_dot_data2[6] };
            3'b010 : led_dot_row <= {led_dot_data1[29], led_dot_data1[21], led_dot_data1[13], led_dot_data1[5],   led_dot_data2[29], led_dot_data2[21], led_dot_data2[13], led_dot_data2[5] };
            3'b011 : led_dot_row <= {led_dot_data1[28], led_dot_data1[20], led_dot_data1[12], led_dot_data1[4],   led_dot_data2[28], led_dot_data2[20], led_dot_data2[12], led_dot_data2[4] };
            3'b100 : led_dot_row <= {led_dot_data1[27], led_dot_data1[19], led_dot_data1[11], led_dot_data1[3],   led_dot_data2[27], led_dot_data2[19], led_dot_data2[11], led_dot_data2[3] };
            3'b101 : led_dot_row <= {led_dot_data1[26], led_dot_data1[18], led_dot_data1[10], led_dot_data1[2],   led_dot_data2[26], led_dot_data2[18], led_dot_data2[10], led_dot_data2[2] };
            3'b110 : led_dot_row <= {led_dot_data1[25], led_dot_data1[17], led_dot_data1[ 9], led_dot_data1[1],   led_dot_data2[25], led_dot_data2[17], led_dot_data2[ 9], led_dot_data2[1] };
            3'b111 : led_dot_row <= {led_dot_data1[24], led_dot_data1[16], led_dot_data1[ 8], led_dot_data1[0],   led_dot_data2[24], led_dot_data2[16], led_dot_data2[ 8], led_dot_data2[0] };
            // 3'b000 : led_dot_row <= led_dot_data1[31:24];
            // 3'b001 : led_dot_row <= led_dot_data1[23:16];
            // 3'b010 : led_dot_row <= led_dot_data1[15: 8];
            // 3'b011 : led_dot_row <= led_dot_data1[7 : 0];
            // 3'b100 : led_dot_row <= led_dot_data2[31:24];
            // 3'b101 : led_dot_row <= led_dot_data2[23:16];
            // 3'b110 : led_dot_row <= led_dot_data2[15: 8];
            // 3'b111 : led_dot_row <= led_dot_data2[7 : 0];
        endcase
    end
end

always @(posedge clk)
begin
    if ( !resetn )
    begin
        num_a_g <= 7'b0000000;
    end
    else
    begin
        case ( scan_data )
            4'd0 : num_a_g <= 7'b1111110;   //0
            4'd1 : num_a_g <= 7'b0110000;   //1
            4'd2 : num_a_g <= 7'b1101101;   //2
            4'd3 : num_a_g <= 7'b1111001;   //3
            4'd4 : num_a_g <= 7'b0110011;   //4
            4'd5 : num_a_g <= 7'b1011011;   //5
            4'd6 : num_a_g <= 7'b1011111;   //6
            4'd7 : num_a_g <= 7'b1110000;   //7
            4'd8 : num_a_g <= 7'b1111111;   //8
            4'd9 : num_a_g <= 7'b1111011;   //9
            4'd10: num_a_g <= 7'b1110111;   //a
            4'd11: num_a_g <= 7'b0011111;   //b
            4'd12: num_a_g <= 7'b1001110;   //c
            4'd13: num_a_g <= 7'b0111101;   //d
            4'd14: num_a_g <= 7'b1001111;   //e
            4'd15: num_a_g <= 7'b1000111;   //f
        endcase
    end
end
//----------------------------{digital number}end------------------------//

//----------------------------{LCD}----------------------------------//

    // lcd_data
    reg[4:0] display_name_reg;
    assign display_name[15: 8] = {4'b0011,3'b000,display_name_reg[4]};
    assign display_name[7 : 0] = {4'b0011,display_name_reg[3:0]};
    //assign display_name[15:0] = display_name_reg;
    wire is_display_name;
    assign is_display_name = conf_we & (conf_addr[15:0] == `LCD_ADDR);
    always @ ( posedge clk ) begin
    if(!resetn) begin
    display_name_reg  <= 0;
    end
    if(is_display_name) begin
    display_name_reg <= conf_wdata[15:0];
    end
    end

    // lcd_cs;

    /*
    reg lcd_cs;
    assign lcd1_cs = lcd_cs;
    wire is_lcd_cs;
    assign is_lcd_cs = conf_we & (conf_addr[15:0] == `LCD_CS_ADDR);
    always @ ( posedge clk ) begin
    if(!resetn) begin
    lcd_cs <= 0;
    end
    if(is_lcd_cs) begin
    lcd_cs <= conf_wdata[0];
    end
    end
    */

    // lcd_rs

    reg [5:0] display_number_reg;
    //assign display_number = display_number_reg;
    wire is_display_number;
    assign is_display_number = conf_we & (conf_addr[15:0] == `LCD_RS_ADDR);
    always @ ( posedge clk ) begin
    if(!resetn) begin
    display_number_reg <= 0;
    end
    if(is_display_number) begin
    display_number_reg <= conf_wdata[5:0];
    end
    end


    // lcd_wr
    reg [31:0]display_value_reg;
    assign display_value= display_value_reg;
    wire is_display_value;
    assign is_display_value = conf_we & (conf_addr[15:0] == `LCD_WR_ADDR);
    always @ ( posedge clk ) begin
    if(!resetn) begin
    display_value_reg <= 0;
    end
    if(is_display_value) begin
    display_value_reg <= conf_wdata;
    end
    end


    // lcd_rd
    reg display_valid_reg;
    assign display_valid = display_valid_reg & (display_number == display_number_reg);
    wire is_display_valid;
    assign is_display_valid = conf_we & (conf_addr[15:0] == `LCD_RD_ADDR);
    always @ ( posedge clk ) begin
    if(!resetn) begin
    display_valid_reg <= 0;
    end
    if(is_display_valid) begin
    display_valid_reg <= conf_wdata[0];
    end
    end

    /*
    // lcd_sda
    reg lcd_sda;
    assign lcd1_sda = lcd_sda;
    wire is_lcd_sda;
    assign is_lcd_sda = conf_we & (conf_addr[15:0] == `LCD_SDA_ADDR);
    always @ ( posedge clk ) begin
    if(!resetn) begin
    lcd_sda <= 0;
    end
    if(is_lcd_sda) begin
    lcd_sda <= conf_wdata[0];
    end
    end*/

endmodule
