`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/30 22:02:57
// Design Name: 
// Module Name: divider_unsigned_tb
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

module DIV_tb(

    );

	reg             clk;
	reg             reset;
	reg             stall;
	reg             flush;
	reg             CE_in;
    reg             ex_valid_ns;
	reg             ex_allin;
	reg    [`WordDataBus]                    dividend_in;
	reg    [`WordDataBus]                    divisor_in;
	reg    [`AluOpBus]			             is_op;
	wire   [`WordDataBus]                   quotient_out;
	wire   [`WordDataBus]                    remainder_out;
	wire                                     CE_out;
	
	DIV uut (
	.clk             (clk),
	.reset           (reset),
	.stall           (stall),
	.flush           (flush),
	.CE_in           (CE_in),
    .ex_valid_ns     (ex_valid_ns),
	.ex_allin        (ex_allin),
	.dividend_in     (dividend_in),
	.divisor_in      (divisor_in),
	.is_op           (is_op),
	.quotient_out        (quotient_out),
	.remainder_out       (remainder_out),
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
    reset  =  1'b0;
    flush  =  1'b0;
    stall  =  1'b0;
    CE_in  =  1'b0;
    ex_valid_ns = 1;
    ex_allin    = 1;
    dividend_in = 32'b0;
    divisor_in  = 32'b0;
    is_op  = `INSN_NOP;
    end
    #STEP begin
    reset  =  1'b1;
    CE_in  =  1'b1;
    dividend_in = 32'd6;
    divisor_in  = 32'd2;
    is_op  = `INSN_DIV;
    end
    #(STEP*16) begin
    ex_valid_ns = 1;
    ex_allin    = 1;
    reset  =  1'b1;
    CE_in  =  1'b1;
    dividend_in = 32'd8;
    divisor_in  = 32'd2;
    is_op  = `INSN_DIV;
    end
    #STEP begin
    ex_valid_ns = 1;
    ex_allin    = 1;
    end
    #(STEP*15) begin
    ex_valid_ns = 1;
    ex_allin    = 1;
    end
   /* #(STEP*16) begin
    reset  =  1'b1;
    CE_in  =  1'b0;
    dividend_in = 32'b0;
    divisor_in  = 32'b0;
    is_op  = `INSN_NOP;
    end
    #STEP begin
    reset  =  1'b1;
    CE_in  =  1'b1;
    dividend_in = 32'd10;
    divisor_in  = 32'd2;
    is_op  = `INSN_DIV;
    end
    #STEP begin
    reset  =  1'b1;
    CE_in  =  1'b1;
    dividend_in = 32'd11;
    divisor_in  = 32'd2;
    is_op  = `INSN_DIV;
    end*/
    end
endmodule
