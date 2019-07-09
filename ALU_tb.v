`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/25 23:53:06
// Design Name: 
// Module Name: ALU_tb
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
module ALU_tb(

    );

`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/cpu.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/global_config.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/isa.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/nettype.h"
`include "E:/verilog project/SYSU_1_Xiao_Jia_Le/SYSU_1_Xiao_Jia_Le/soc_axi_func/rtl/myCPU/header/stddef.h"
    reg clk;
    
	reg [`WordDataBus] scr0_data;
	reg [`WordDataBus] scr1_data;
	reg [`WordDataBus] imme;
	reg [`WordDataBus] pc;
	reg [`AluOpBus]	    op;	  
	reg [`WordDataBus] cp0_data;
	reg                ptab_direction;
	reg [`WordAddrBus] ptab_data;
	reg [`WordDataBus] hi;
	reg [`WordDataBus] lo;
	
	wire                 branchcond;
	wire                 bp_result;
	wire [`WordDataBus]  out;
	wire [`WordDataBus]  out_wr;
	wire				  fu_ov;  

	ALU0 uut (
		.scr0_data      (scr0_data),
	    .scr1_data      (scr1_data ),
	    .imme           (imme ),
	    .pc             (pc),
	    .op	            (op),
	    .cp0_data       (cp0_data),
	    .ptab_direction (ptab_direction),
	    .ptab_data      (ptab_data),
	    .hi             (hi),
	    .lo             (lo),
	    .branchcond     (branchcond),
	    .bp_result      (bp_result),
	    .out	        (out),
	    .out_wr	        (out_wr),
	    .fu_ov          (fu_ov)
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
    
    //assignment
    initial begin 
    #0 begin
    scr0_data = 32'b0;
    scr1_data = 32'b0;
    imme      = 32'b0;
    pc        = 32'b0;
    op        = `INSN_NOP;
    cp0_data  = 32'b0;
    ptab_direction = 1'b0;
    ptab_data = 32'b0;
    hi        = 32'b0;
    lo        = 32'b0;
    end
    # STEP begin //INSN_ADD
    scr0_data = 32'hffffffff;
    scr1_data = 32'h23;
    imme      = 32'b0;
    pc        = 32'b0;
    op        = `INSN_ADD;
    cp0_data  = 32'b0;
    ptab_direction = 1'b0;
    ptab_data = 32'b0;
    hi        = 32'b0;
    lo        = 32'b0;
    end
    # STEP begin
    end
    # STEP begin
    end
    end
    
	

endmodule
