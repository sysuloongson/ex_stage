`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 09:03:36
// Design Name: 
// Module Name: FU_selector
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

/**********      Common header file      **********/
`include "cpu.h"
`include "global_config.h"
`include "isa.h"
`include "nettype.h"
`include "stddef.h"

/*********       Internal define        ************/
`define AluOpBus_2way              11:0
`define AluOpBus_way0               5:0
`define AluOpBus_way1              11:6
`define FUen                        3:0

//`define All_INSN_MUL              (`INSN_MULT || `INSN_MULTU)
//`define All_INSN_DIV              (`INSN_DIV || `INSN_DIVU)

module FU_selector(

input   wire    [`AluOpBus_2way]	                        is_alu_op,

output  reg    [`FUen]                                    FU_en,
output  reg                                               FU_ctrl //  0 -> way0 == ALU0||MUL  way1 == ALU1||DIV          1 ->way0 ==ALU0||DIV  way1 == ALU1||MUL
    );

    always @(*) begin
	   if ((is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU) && (is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU) ) begin // way0 == MUL  way1 == DIV
		   FU_en = 4'b1100;
		   FU_ctrl = 1'b0;
		   end
		   else if ((is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU) && (is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU) ) begin // way0 == DIV  way1 == MUL
		   FU_en = 4'b1100;
		   FU_ctrl = 1'b1;
		   end
		   else if (is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU) begin // way0 == DIV way1 == ALU1
		   FU_en = 4'b1010;
		   FU_ctrl = 1'b1; 
		   end
		   else if (is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU) begin // way0 == ALU0 way1 == DIV
		   FU_en = 4'b1001;
		   FU_ctrl = 1'b0; 
		   end
		   else if (is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU) begin // way0 == MUL way1 == ALU1
		   FU_en = 4'b0110;
		   FU_ctrl = 1'b0; 
		   end
		   else if (is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU) begin // way0 == MUL way1 == ALU1
		   FU_en = 4'b0110;
		   FU_ctrl = 1'b0; 
		   end
		   else if (is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU) begin // way0 == ALU0 way1 == DIV
		   FU_en = 4'b0101;
		   FU_ctrl = 1'b1; 
		   end
		   else begin //way0 == ALU0 way1 == ALU1
		   FU_en = 4'b0011;
		   FU_ctrl = 1'b0;
		   end
		   
    end
		
endmodule
