`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/07/02 16:14:12
// Design Name: 
// Module Name: MUL_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/cpu.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/global_config.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/isa.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/nettype.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/stddef.h"

/********* Internal define ************/
`define GLOBAL_DATA_W		32
`define PIPELINE			16
`define TMP_DATAWIDTH		64
`define SHIFT_BIT			63:32

module MUL_tb(

    );

	reg             clk;
	reg             reset;
	reg             stall;
	reg             flush;
	reg             CE_in;
	reg             ex_valid_ns;
	reg             ex_allin;
	reg    [`GLOBAL_DATA_W - 1 : 0]          mulx;
	reg    [`GLOBAL_DATA_W - 1 : 0]          muly;
	reg    [`AluOpBus]				         is_op;
	wire   [`GLOBAL_DATA_W - 1 : 0]         mul_hi;
	wire   [`GLOBAL_DATA_W - 1 : 0]         mul_lo;
	wire                                    CE_out;
	
	MUL uut (
	.clk             (clk),
	.reset           (reset),
	.stall           (stall),
	.flush           (flush),
	.CE_in           (CE_in),
	.ex_valid_ns     (ex_valid_ns),
	.ex_allin        (ex_allin),
	.mulx            (mulx),
	.muly            (muly),
	.is_op           (is_op),
	.mul_hi          (mul_hi),
	.mul_lo          (mul_lo),
    .CE_out          (CE_out)
	);
	
	parameter				 STEP = 2; // 10 M
	
	// clk 
	initial begin
	#0 begin
	   clk <= `ENABLE;
	   end
	   end
	
    always # (STEP / 2) begin
		clk <= ~clk;
	end

    initial begin 
    #0 begin
       reset = 0;
       stall = 0;
       flush = 0;
       CE_in = 0;
       ex_valid_ns = 0;
       ex_allin    = 0;
       end
    #STEP begin
       CE_in = 1;
       reset = 1;
       mulx  = 32'd10;
       muly  = 32'd20;
       is_op = `INSN_MULT;
       end
     #(STEP*8) begin
       ex_valid_ns = 1;
       ex_allin    = 1;
       CE_in = 1;
       reset = 1;
       mulx  = 32'd20;
       muly  = 32'd20;
       is_op = `INSN_MULT;
       end
     #STEP begin
       ex_valid_ns = 0;
       ex_allin    = 0;
       CE_in = 0;
       reset = 1;
       mulx  = 32'd0;
       muly  = 32'd0;
       is_op = `INSN_NOP;
       end
    /* #(STEP*6) begin
       CE_in = 1;
       mulx  = 32'd20;
       muly  = 32'd20;
       is_op = `INSN_MULT;
       end
     #STEP begin
       CE_in = 0;
       mulx  = 32'd0;
       muly  = 32'd0;
       is_op = `INSN_ADD;
       end
     #(STEP*6) begin
       CE_in = 1;
       mulx  = 32'd30;
       muly  = 32'd20;
       is_op = `INSN_MULT;
       end
     #STEP begin
       CE_in = 1;
       mulx  = 32'd40;
       muly  = 32'd20;
       is_op = `INSN_MULT;
       end*/
    end
    
endmodule
