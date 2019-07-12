`timescale 1ns / 1ps
/*
 -- ============================================================================
 -- FILE NAME	: ex_stage.v
 -- DESCRIPTION : include FU_selector.v
                          ALU0.v  ALU1.v
                          MUL.v
                          DIV.v
                          ex_reg.v
                          based on the 《CPU自制入门》at present
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by		Comment
 -- 1.0.0	  2019/06/03  Biang			Biang
 -- ============================================================================
*/
/**********      Common header file      **********/
`include "cpu.h"
`include "global_config.h"
`include "isa.h"
`include "nettype.h"
`include "stddef.h"

/*********       ISA      define       ************/
`define ISA_EXC_ERET               5'h0d
/*********       Internal define        ************/
`define WordAddrBus_2way			63:0
`define WordAddrBus_way0           31:0
`define WordAddrBus_way1          63:32
`define AluOpBus_2way              11:0
`define AluOpBus_way0               5:0
`define AluOpBus_way1              11:6
`define WordDataBus_2way           63:0
`define WordDataBus_way0           31:0
`define WordDataBus_way1          63:32
`define DestAddr                    4:0
`define DestAddr_2way               9:0
`define DestAddr_way0               4:0
`define DestAddr_way1               9:5
`define isbrflag_2way               1:0
`define MemOpBus_2way               3:0
`define CtrlOpBus_2way              3:0
`define RegAddrBus_2way             9:0
`define IsaExpBus_2way              9:0
`define IsaExpBus_way0              4:0
`define IsaExpBus_way1              9:5
`define UnCache2WayBus		         1:0 
`define UnCacheCheckWay0	       31:16
`define UnCacheCheckWay1	       63:48
`define DestValid_2way              1:0
`define FUen                        3:0
`define FUen_MUL                    2
`define FUen_DIV                    3
`define BranchCond_2Way             1:0    
`define En2Bus                      1:0
`define PtabaddrBus_2way		     9:0
`define PtabdataBus_2way		   128:0
`define PtabdataBus_way0		    63:0
`define PtabdataBus_way1		  127:64
`define Ptabnextpc_way0	        31:0
`define Ptabnextpc_way1	        95:64

//input is_alu_op has Source Register
//`define RSisopWay0    (is_alu_op[`AluOpBus_way0] == `INSN_ADD || is_alu_op[`AluOpBus_way0] == `INSN_ADDI || is_alu_op[`AluOpBus_way0] == `INSN_ADDU || is_alu_op[`AluOpBus_way0] == `INSN_ADDIU || is_alu_op[`AluOpBus_way0] == `INSN_SUB || is_alu_op[`AluOpBus_way0] == `INSN_SUBU || is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU || is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU || is_alu_op[`AluOpBus_way0] == `INSN_SLT || is_alu_op[`AluOpBus_way0] == `INSN_SLTI || is_alu_op[`AluOpBus_way0] == `INSN_SLTU || is_alu_op[`AluOpBus_way0] == `INSN_SLTIU || is_alu_op[`AluOpBus_way0] == `INSN_AND || is_alu_op[`AluOpBus_way0] == `INSN_ANDI || is_alu_op[`AluOpBus_way0] == `INSN_NOR || is_alu_op[`AluOpBus_way0] == `INSN_OR || is_alu_op[`AluOpBus_way0] == `INSN_ORI || is_alu_op[`AluOpBus_way0] == `INSN_XOR || is_alu_op[`AluOpBus_way0] == `INSN_XORI || is_alu_op[`AluOpBus_way0] == `INSN_SLLV || is_alu_op[`AluOpBus_way0] == `INSN_SLL || is_alu_op[`AluOpBus_way0] == `INSN_SRAV || is_alu_op[`AluOpBus_way0] == `INSN_SRA || is_alu_op[`AluOpBus_way0] == `INSN_SRLV  || is_alu_op[`AluOpBus_way0] == `INSN_SRL || is_alu_op[`AluOpBus_way0] == `INSN_BEQ || is_alu_op[`AluOpBus_way0] == `INSN_BNE || is_alu_op[`AluOpBus_way0] == `INSN_BGEZ || is_alu_op[`AluOpBus_way0] == `INSN_BGTZ || is_alu_op[`AluOpBus_way0] == `INSN_BLEZ || is_alu_op[`AluOpBus_way0] == `INSN_BLTZ || is_alu_op[`AluOpBus_way0] == `INSN_BGEZAL || is_alu_op[`AluOpBus_way0] == `INSN_BLTZAL || is_alu_op[`AluOpBus_way0] == `INSN_JR || is_alu_op[`AluOpBus_way0] == `INSN_JALR || is_alu_op[`AluOpBus_way0] == `INSN_MTHI || is_alu_op[`AluOpBus_way0] == `INSN_MTLO || is_alu_op[`AluOpBus_way0] == `INSN_LB || is_alu_op[`AluOpBus_way0] == `INSN_LBU || is_alu_op[`AluOpBus_way0] == `INSN_LH || is_alu_op[`AluOpBus_way0] == `INSN_LHU || is_alu_op[`AluOpBus_way0] == `INSN_LW || is_alu_op[`AluOpBus_way0] == `INSN_SB || is_alu_op[`AluOpBus_way0] == `INSN_SH || is_alu_op[`AluOpBus_way0] == `INSN_SW || is_alu_op[`AluOpBus_way0] == `INSN_MTC0)
//`define RTisopWay0    (is_alu_op[`AluOpBus_way0] == `INSN_ADD || is_alu_op[`AluOpBus_way0] == `INSN_ADDU || is_alu_op[`AluOpBus_way0] == `INSN_SUB || is_alu_op[`AluOpBus_way0] == `INSN_SUBU || is_alu_op[`AluOpBus_way0] == `INSN_MULT || is_alu_op[`AluOpBus_way0] == `INSN_MULTU || is_alu_op[`AluOpBus_way0] == `INSN_DIV || is_alu_op[`AluOpBus_way0] == `INSN_DIVU || is_alu_op[`AluOpBus_way0] == `INSN_SLT || is_alu_op[`AluOpBus_way0] == `INSN_SLTU || is_alu_op[`AluOpBus_way0] == `INSN_AND || is_alu_op[`AluOpBus_way0] == `INSN_NOR || is_alu_op[`AluOpBus_way0] == `INSN_OR || is_alu_op[`AluOpBus_way0] == `INSN_XOR || is_alu_op[`AluOpBus_way0] == `INSN_SLLV || is_alu_op[`AluOpBus_way0] == `INSN_SRAV || is_alu_op[`AluOpBus_way0] == `INSN_SRLV || is_alu_op[`AluOpBus_way0] == `INSN_BEQ || is_alu_op[`AluOpBus_way0] == `INSN_BNE || is_alu_op[`AluOpBus_way0] == `INSN_SB || is_alu_op[`AluOpBus_way0] == `INSN_SH || is_alu_op[`AluOpBus_way0] == `INSN_SW)

`define RSaluopWay0    (ALU0_op == `INSN_ADD || ALU0_op == `INSN_ADDI || ALU0_op == `INSN_ADDU || ALU0_op == `INSN_ADDIU || ALU0_op == `INSN_SUB || ALU0_op == `INSN_SUBU || ALU0_op == `INSN_MULT || ALU0_op == `INSN_MULTU || ALU0_op == `INSN_DIV || ALU0_op == `INSN_DIVU || ALU0_op == `INSN_SLT || ALU0_op == `INSN_SLTI || ALU0_op == `INSN_SLTU || ALU0_op == `INSN_SLTIU || ALU0_op == `INSN_AND || ALU0_op == `INSN_ANDI || ALU0_op == `INSN_NOR || ALU0_op == `INSN_OR || ALU0_op == `INSN_ORI || ALU0_op == `INSN_XOR || ALU0_op == `INSN_XORI || ALU0_op == `INSN_SLLV || ALU0_op == `INSN_SLL || ALU0_op == `INSN_SRAV || ALU0_op == `INSN_SRA || ALU0_op == `INSN_SRLV  || ALU0_op == `INSN_SRL || ALU0_op == `INSN_BEQ || ALU0_op == `INSN_BNE || ALU0_op == `INSN_BGEZ || ALU0_op == `INSN_BGTZ || ALU0_op == `INSN_BLEZ || ALU0_op == `INSN_BLTZ || ALU0_op == `INSN_BGEZAL || ALU0_op == `INSN_BLTZAL || ALU0_op == `INSN_JR || ALU0_op == `INSN_JALR || ALU0_op == `INSN_MTHI || ALU0_op == `INSN_MTLO || ALU0_op == `INSN_LB || ALU0_op == `INSN_LBU || ALU0_op == `INSN_LH || ALU0_op == `INSN_LHU || ALU0_op == `INSN_LW || ALU0_op == `INSN_SB || ALU0_op == `INSN_SH || ALU0_op == `INSN_SW || ALU0_op == `INSN_MTC0)
`define RTaluopWay0    (ALU0_op == `INSN_ADD || ALU0_op == `INSN_ADDU || ALU0_op == `INSN_SUB || ALU0_op == `INSN_SUBU || ALU0_op == `INSN_MULT || ALU0_op == `INSN_MULTU || ALU0_op == `INSN_DIV || ALU0_op == `INSN_DIVU || ALU0_op == `INSN_SLT || ALU0_op == `INSN_SLTU || ALU0_op == `INSN_AND || ALU0_op == `INSN_NOR || ALU0_op == `INSN_OR || ALU0_op == `INSN_XOR || ALU0_op == `INSN_SLLV || ALU0_op == `INSN_SRAV || ALU0_op == `INSN_SRLV || ALU0_op == `INSN_BEQ || ALU0_op == `INSN_BNE || ALU0_op == `INSN_SB || ALU0_op == `INSN_SH || ALU0_op == `INSN_SW)

//`define RSisopWay1    (is_alu_op[`AluOpBus_way1] == `INSN_ADD || is_alu_op[`AluOpBus_way1] == `INSN_ADDI || is_alu_op[`AluOpBus_way1] == `INSN_ADDU || is_alu_op[`AluOpBus_way1] == `INSN_ADDIU || is_alu_op[`AluOpBus_way1] == `INSN_SUB || is_alu_op[`AluOpBus_way1] == `INSN_SUBU || is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU || is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU || is_alu_op[`AluOpBus_way1] == `INSN_SLT || is_alu_op[`AluOpBus_way1] == `INSN_SLTI || is_alu_op[`AluOpBus_way1] == `INSN_SLTU || is_alu_op[`AluOpBus_way1] == `INSN_SLTIU || is_alu_op[`AluOpBus_way1] == `INSN_AND || is_alu_op[`AluOpBus_way1] == `INSN_ANDI || is_alu_op[`AluOpBus_way1] == `INSN_NOR || is_alu_op[`AluOpBus_way1] == `INSN_OR || is_alu_op[`AluOpBus_way1] == `INSN_ORI || is_alu_op[`AluOpBus_way1] == `INSN_XOR || is_alu_op[`AluOpBus_way1] == `INSN_XORI || is_alu_op[`AluOpBus_way1] == `INSN_SLLV || is_alu_op[`AluOpBus_way1] == `INSN_SLL || is_alu_op[`AluOpBus_way1] == `INSN_SRAV || is_alu_op[`AluOpBus_way1] == `INSN_SRA || is_alu_op[`AluOpBus_way1] == `INSN_SRLV  || is_alu_op[`AluOpBus_way1] == `INSN_SRL || is_alu_op[`AluOpBus_way1] == `INSN_BEQ || is_alu_op[`AluOpBus_way1] == `INSN_BNE || is_alu_op[`AluOpBus_way1] == `INSN_BGEZ || is_alu_op[`AluOpBus_way1] == `INSN_BGTZ || is_alu_op[`AluOpBus_way1] == `INSN_BLEZ || is_alu_op[`AluOpBus_way1] == `INSN_BLTZ || is_alu_op[`AluOpBus_way1] == `INSN_BGEZAL || is_alu_op[`AluOpBus_way1] == `INSN_BLTZAL || is_alu_op[`AluOpBus_way1] == `INSN_JR || is_alu_op[`AluOpBus_way1] == `INSN_JALR || is_alu_op[`AluOpBus_way1] == `INSN_MTHI || is_alu_op[`AluOpBus_way1] == `INSN_MTLO || is_alu_op[`AluOpBus_way1] == `INSN_LB || is_alu_op[`AluOpBus_way1] == `INSN_LBU || is_alu_op[`AluOpBus_way1] == `INSN_LH || is_alu_op[`AluOpBus_way1] == `INSN_LHU || is_alu_op[`AluOpBus_way1] == `INSN_LW || is_alu_op[`AluOpBus_way1] == `INSN_SB || is_alu_op[`AluOpBus_way1] == `INSN_SH || is_alu_op[`AluOpBus_way1] == `INSN_SW || is_alu_op[`AluOpBus_way1] == `INSN_MTC0)
//`define RTisopWay1    (is_alu_op[`AluOpBus_way1] == `INSN_ADD || is_alu_op[`AluOpBus_way1] == `INSN_ADDU || is_alu_op[`AluOpBus_way1] == `INSN_SUB || is_alu_op[`AluOpBus_way1] == `INSN_SUBU || is_alu_op[`AluOpBus_way1] == `INSN_MULT || is_alu_op[`AluOpBus_way1] == `INSN_MULTU || is_alu_op[`AluOpBus_way1] == `INSN_DIV || is_alu_op[`AluOpBus_way1] == `INSN_DIVU || is_alu_op[`AluOpBus_way1] == `INSN_SLT || is_alu_op[`AluOpBus_way1] == `INSN_SLTU || is_alu_op[`AluOpBus_way1] == `INSN_AND || is_alu_op[`AluOpBus_way1] == `INSN_NOR || is_alu_op[`AluOpBus_way1] == `INSN_OR || is_alu_op[`AluOpBus_way1] == `INSN_XOR || is_alu_op[`AluOpBus_way1] == `INSN_SLLV || is_alu_op[`AluOpBus_way1] == `INSN_SRAV || is_alu_op[`AluOpBus_way1] == `INSN_SRLV || is_alu_op[`AluOpBus_way1] == `INSN_BEQ || is_alu_op[`AluOpBus_way1] == `INSN_BNE || is_alu_op[`AluOpBus_way1] == `INSN_SB || is_alu_op[`AluOpBus_way1] == `INSN_SH || is_alu_op[`AluOpBus_way1] == `INSN_SW)

`define RSaluopWay1    (ALU1_op == `INSN_ADD || ALU1_op == `INSN_ADDI || ALU1_op == `INSN_ADDU || ALU1_op == `INSN_ADDIU || ALU1_op == `INSN_SUB || ALU1_op == `INSN_SUBU || ALU1_op == `INSN_MULT || ALU1_op == `INSN_MULTU || ALU1_op == `INSN_DIV || ALU1_op == `INSN_DIVU || ALU1_op == `INSN_SLT || ALU1_op == `INSN_SLTI || ALU1_op == `INSN_SLTU || ALU1_op == `INSN_SLTIU || ALU1_op == `INSN_AND || ALU1_op == `INSN_ANDI || ALU1_op == `INSN_NOR || ALU1_op == `INSN_OR || ALU1_op == `INSN_ORI || ALU1_op == `INSN_XOR || ALU1_op == `INSN_XORI || ALU1_op == `INSN_SLLV || ALU1_op == `INSN_SLL || ALU1_op == `INSN_SRAV || ALU1_op == `INSN_SRA || ALU1_op == `INSN_SRLV  || ALU1_op == `INSN_SRL || ALU1_op == `INSN_BEQ || ALU1_op == `INSN_BNE || ALU1_op == `INSN_BGEZ || ALU1_op == `INSN_BGTZ || ALU1_op == `INSN_BLEZ || ALU1_op == `INSN_BLTZ || ALU1_op == `INSN_BGEZAL || ALU1_op == `INSN_BLTZAL || ALU1_op == `INSN_JR || ALU1_op == `INSN_JALR || ALU1_op == `INSN_MTHI || ALU1_op == `INSN_MTLO || ALU1_op == `INSN_LB || ALU1_op == `INSN_LBU || ALU1_op == `INSN_LH || ALU1_op == `INSN_LHU || ALU1_op == `INSN_LW || ALU1_op == `INSN_SB || ALU1_op == `INSN_SH || ALU1_op == `INSN_SW || ALU1_op == `INSN_MTC0)
`define RTaluopWay1    (ALU1_op == `INSN_ADD || ALU1_op == `INSN_ADDU || ALU1_op == `INSN_SUB || ALU1_op == `INSN_SUBU || ALU1_op == `INSN_MULT || ALU1_op == `INSN_MULTU || ALU1_op == `INSN_DIV || ALU1_op == `INSN_DIVU || ALU1_op == `INSN_SLT || ALU1_op == `INSN_SLTU || ALU1_op == `INSN_AND || ALU1_op == `INSN_NOR || ALU1_op == `INSN_OR || ALU1_op == `INSN_XOR || ALU1_op == `INSN_SLLV || ALU1_op == `INSN_SRAV || ALU1_op == `INSN_SRLV || ALU1_op == `INSN_BEQ || ALU1_op == `INSN_BNE || ALU1_op == `INSN_SB || ALU1_op == `INSN_SH || ALU1_op == `INSN_SW)

//output ex_op has Destination Register
`define RDexopWay0    (ex_op[`AluOpBus_way0] == `INSN_ADD || ex_op[`AluOpBus_way0] == `INSN_ADDI || ex_op[`AluOpBus_way0] == `INSN_ADDU || ex_op[`AluOpBus_way0] == `INSN_ADDIU || ex_op[`AluOpBus_way0] == `INSN_SUB || ex_op[`AluOpBus_way0] == `INSN_SUBU || ex_op[`AluOpBus_way0] == `INSN_SLT || ex_op[`AluOpBus_way0] == `INSN_SLTI || ex_op[`AluOpBus_way0] == `INSN_SLTU || ex_op[`AluOpBus_way0] == `INSN_SLTIU || ex_op[`AluOpBus_way0] == `INSN_AND || ex_op[`AluOpBus_way0] == `INSN_ANDI || ex_op[`AluOpBus_way0] == `INSN_LUI || ex_op[`AluOpBus_way0] == `INSN_NOR || ex_op[`AluOpBus_way0] == `INSN_OR || ex_op[`AluOpBus_way0] == `INSN_ORI || ex_op[`AluOpBus_way0] == `INSN_XOR || ex_op[`AluOpBus_way0] == `INSN_XORI || ex_op[`AluOpBus_way0] == `INSN_SLLV || ex_op[`AluOpBus_way0] == `INSN_SLL || ex_op[`AluOpBus_way0] == `INSN_SRAV || ex_op[`AluOpBus_way0] == `INSN_SRA || ex_op[`AluOpBus_way0] == `INSN_SRLV || ex_op[`AluOpBus_way0] == `INSN_SRL || ex_op[`AluOpBus_way0] == `INSN_JALR || ex_op[`AluOpBus_way0] == `INSN_MFHI || ex_op[`AluOpBus_way0] == `INSN_MFLO)
`define RDexopWay1    (ex_op[`AluOpBus_way1] == `INSN_ADD || ex_op[`AluOpBus_way1] == `INSN_ADDI || ex_op[`AluOpBus_way1] == `INSN_ADDU || ex_op[`AluOpBus_way1] == `INSN_ADDIU || ex_op[`AluOpBus_way1] == `INSN_SUB || ex_op[`AluOpBus_way1] == `INSN_SUBU || ex_op[`AluOpBus_way1] == `INSN_SLT || ex_op[`AluOpBus_way1] == `INSN_SLTI || ex_op[`AluOpBus_way1] == `INSN_SLTU || ex_op[`AluOpBus_way1] == `INSN_SLTIU || ex_op[`AluOpBus_way1] == `INSN_AND || ex_op[`AluOpBus_way1] == `INSN_ANDI || ex_op[`AluOpBus_way1] == `INSN_LUI || ex_op[`AluOpBus_way1] == `INSN_NOR || ex_op[`AluOpBus_way1] == `INSN_OR || ex_op[`AluOpBus_way1] == `INSN_ORI || ex_op[`AluOpBus_way1] == `INSN_XOR || ex_op[`AluOpBus_way1] == `INSN_XORI || ex_op[`AluOpBus_way1] == `INSN_SLLV || ex_op[`AluOpBus_way1] == `INSN_SLL || ex_op[`AluOpBus_way1] == `INSN_SRAV || ex_op[`AluOpBus_way1] == `INSN_SRA || ex_op[`AluOpBus_way1] == `INSN_SRLV || ex_op[`AluOpBus_way1] == `INSN_SRL || ex_op[`AluOpBus_way1] == `INSN_JALR || ex_op[`AluOpBus_way1] == `INSN_MFHI || ex_op[`AluOpBus_way1] == `INSN_MFLO)
module ex_stage(

/***********     Global Signal         ***********/
	input	wire	clk,
	input	wire	reset,
	input	wire 	stall,
	input	wire 	flush,

/***********     Decoding results after IS     ***********/
	input	wire	[`WordAddrBus_2way]					is_pc,
	//input   wire			                            is_en,
	input   wire    [`AluOpBus_2way]	                        is_alu_op,
	input   wire    [`DestAddr_2way]                          is_scr0_addr,
	input   wire    [`DestAddr_2way]                          is_scr1_addr,
	input	wire	[`DestAddr_2way]		                    is_Dest_out,
	input   wire    [`WordDataBus_2way]                        is_alu_in_0,
	input   wire    [`WordDataBus_2way]                        is_alu_in_1,
	input   wire    [`WordDataBus_2way]                        is_alu_imme,
	//input   wire    [`isbrflag_2way]                           is_br_flag,
	input   wire    [`WordDataBus_2way]                           is_hi,
	input   wire    [`WordDataBus_2way]                           is_lo,
	
	input 	wire 	 [`PtabaddrBus_2way]					    is_ptab_addr,
	input   wire     [`PtabdataBus_2way]                       ptab_data,
	input   wire                                               is_valid_ns,
	
	//input   wire    [`MemOpBus_2way]	                        is_mem_op,      //unknow how to use
	//input   wire    [`WordDataBus_2way]                        is_mem_wr_data,
	
	//input   wire    [`CtrlOpBus_2way]                          is_ctrl_op,
	//input   wire    [`RegAddrBus_2way]                         is_dst_addr,
	//input   wire                                               is_gpr_we_,     //unknow the use
	
	input   wire     [`IsaExpBus_2way]                          is_exp_code,	
	//ex to is
    output  wire                                                ex_allin,
    
/***********            CP0                    ***********/
	input	wire 	[`WordDataBus_2way]	                        cp0_data_in,
	//input	wire	[`WordDataBus_2way]	                        cp0_buffer_data_in,
	//input	wire	[`En2Bus]						            cp0_buffer_data_en,
	
/**********             EX Wb                **********/
    input  wire                                                wb_allin,
    output 	reg 	[`WordDataBus_2way]	                        alu_result,
	output 	reg	    [`WordDataBus_2way]		                    mul_result,
	output  reg   	[`WordDataBus_2way]		                    div_result,
	output 	reg 	[`BranchCond_2Way]				            ex_branchcond,
	output 	reg 	[`BranchCond_2Way]				            ex_bp_result,
	output 	reg 	[`WordDataBus_2way]	                        ex_wr_data,		
	//output  reg                                                ex_en,	    
	//output wire     [`isbrflag_2way]                           ex_br_flag,
	output 	reg 	[`DestAddr_2way]		                    ex_Dest_out,
	output 	wire 	[`DestValid_2way]		                    ex_Dest_valid,
	output  reg     [`WordAddrBus_2way]                        ex_pc,
	output	reg  	[`AluOpBus_2way]				                ex_op,
	output  reg 	[`IsaExpBus_2way]		                    ex_exp_code,
	//output 	reg 	[`OpdEn2Bus]					exe_opd_en,
	//output 	reg 	[`En2Bus]						exe_en,	
	//output wire     [`MemOpBus_2way]                           ex_mem_op,
    //output wire     [`WordDataBus_2way]                        ex_mem_wr_data, 
    //output wire     [`CtrlOpBus_2way]                          ex_ctrl_op,	 
    //output wire     [`RegAddrBus_2way]                         ex_dst_addr,	   
	//output wire                                                ex_gpr_we,	  
	//output wire     [`IsaExpBus_2way]                          ex_exp_code,
	//output wire     [`WordDataBus_2way]                        ex_out,
    output wire                                                ex_valid_ns,
/**********             uncacheable singnal                **********/
	output 	reg 	[`UnCache2WayBus]				uncacheable
    );

/**********            inside signal                **********/
       //FU_selector   
           wire    [`FUen]                          FU_en;
           wire                                     FU_ctrl;
      //input after handshake (is_data → ex_data) 
           reg     [`WordAddrBus_2way]			     FU_pc;
           reg     [`AluOpBus_2way]	                 FU_alu_op;
           reg     [`DestAddr_2way]                 FU_scr0_addr;
           reg     [`DestAddr_2way]                 FU_scr1_addr;       
           reg     [`DestAddr_2way]		            FU_Dest_out;
           reg     [`WordDataBus_2way]              FU_alu_in_0;            
           reg     [`WordDataBus_2way]              FU_alu_in_1;  
           reg     [`WordDataBus_2way]              FU_alu_imme;
           reg     [`WordDataBus_2way]              FU_hi;
           reg     [`WordDataBus_2way]              FU_lo;
           reg     [`PtabaddrBus_2way]			    FU_ptab_addr;
           reg     [`PtabdataBus_2way]			    FU_ptab_data;
           reg     [`IsaExpBus_2way]                FU_exp_code;	
           reg     [`WordDataBus_2way]	            FU_cp0_data_in;
      //Data before bypass    
           reg 		[`WordDataBus_2way]		         alu_in_0;
	       reg 		[`WordDataBus_2way]		         alu_in_1;
	       reg     [`WordDataBus_2way]	             alu_cp0_data;
	       reg     [`WordDataBus_2way]	             alu_hi;
	       reg     [`WordDataBus_2way]	             alu_lo;
	       //reg     [`BranchCond_2Way]				 branchcond;
	   //Data output from FU
	       reg    [`IsaExpBus_2way]                alu_exp_code;
	       reg    [`DestAddr_2way]                 alu_dest_addr;
      //ALU0
           //reg                                      ALU0_CE_in;
          // wire                                     ALU0_CE_out;
           reg     [`WordDataBus]                   ALU0_scr0_data;
	       reg     [`WordDataBus]                   ALU0_scr1_data;
           reg     [`DestAddr]                      ALU0_scr0_addr;
	       reg     [`DestAddr]                      ALU0_scr1_addr; 
	       reg     [`WordDataBus]                   ALU0_imme;
	       reg     [`DestAddr]                      ALU0_dest_in;
	       reg     [`WordDataBus]                   ALU0_pc;
	       reg     [`AluOpBus]	                    ALU0_op;
	       reg     [`WordDataBus]                   ALU0_cp0_data;
	       reg                                      ALU0_ptab_direction;
	       reg     [`PtabdataBus_way0]              ALU0_ptab_data;
	       reg     [`WordDataBus]                   ALU0_hi;
	       reg     [`WordDataBus]                   ALU0_lo;
	       reg     [`IsaExpBus_way0]               ALU0_exp_code_in;
	       wire    [`DestAddr]                     ALU0_dest_out;
	       wire    [`WordDataBus]                  ALU0_pc_out;
	       wire    [`AluOpBus]                     ALU0_op_out;
	       wire    	                                ALU0_br; 
	       wire    	                                ALU0_bp_result;             
	       wire	   [`WordDataBus]                   ALU0_out;	 
	       wire	   [`WordDataBus]                   ALU0_out_wr;	 
	       wire				                        ALU0_of;	  
	       wire   [`IsaExpBus_way0]               ALU0_exp_code_out;
      //ALU1
           //reg                                      ALU1_CE_in;
           //wire                                     ALU1_CE_out;
           reg     [`WordDataBus]                   ALU1_scr0_data;
	       reg     [`WordDataBus]                   ALU1_scr1_data;
           reg     [`DestAddr]                      ALU1_scr0_addr;
	       reg     [`DestAddr]                      ALU1_scr1_addr; 
	       reg     [`DestAddr]                      ALU1_dest_in;
	       reg     [`WordDataBus]                   ALU1_imme;
	       reg     [`WordDataBus]                   ALU1_pc;
	       reg     [`AluOpBus]	                    ALU1_op;
	       reg     [`WordDataBus]                   ALU1_cp0_data;
	       reg                                      ALU1_ptab_direction;
	       reg     [`PtabdataBus_way0]              ALU1_ptab_data;
	       reg     [`WordDataBus]                   ALU1_hi;
	       reg     [`WordDataBus]                   ALU1_lo;
	       reg     [`IsaExpBus_way0]               ALU1_exp_code_in;
	       wire    [`DestAddr]                     ALU1_dest_out;
	       wire    [`WordDataBus]                  ALU1_pc_out;
	       wire    [`AluOpBus]                     ALU1_op_out;
	       wire     	                            ALU1_br; 
	       wire    	                                ALU1_bp_result;    	  
	       wire	   [`WordDataBus]                   ALU1_out;	  
	       wire	   [`WordDataBus]                   ALU1_out_wr;	 
	       wire				                        ALU1_of;	
	       wire    [`IsaExpBus_way0]               ALU1_exp_code_out;  
      //MUL
           reg     [`WordDataBus]                   MUL_mulx;
           reg     [`WordDataBus]                   MUL_muly;
           reg                                      MUL_CE_in;
           reg     [`AluOpBus]	                    MUL_op;   
           wire    [`WordDataBus]                   MUL_mul_hi;
           wire    [`WordDataBus]                   MUL_mul_lo;  
           wire                                     MUL_CE_out;                             
      //DIV
           reg                                      DIV_CE_in;
           reg     [`WordDataBus]                   DIV_dividend_in;
           reg     [`WordDataBus]                   DIV_divisor_in;
           reg     [`AluOpBus]                      DIV_op;
           wire    [`WordDataBus]                   DIV_quotient_out;
           wire    [`WordDataBus]                   DIV_remainder_out;
           wire                                     DIV_CE_out;
     //Handshanke
           reg                                     ex_ready_go;
           reg                                     ex_valid;
/**********             FU_selector instantiation                **********/
	FU_selector FU_selector (
		.is_alu_op      (FU_alu_op),
		.FU_en          (FU_en),
		.FU_ctrl        (FU_ctrl)
	);

/**********             FU instantiation                 **********/
	ALU_with_clk ALU0 (
	    //.CE_in          (ALU0_CE_in),
	   // .CE_out         (ALU0_CE_out),
	    .clk            (clk),
	    .reset          (reset),
	    .flush          (flush),
		.scr0_data      (ALU0_scr0_data),
	    .scr1_data      (ALU0_scr1_data),
	    .dest_addr      (ALU0_dest_in),
	    .imme           (ALU0_imme),
	    .pc             (ALU0_pc),
	    .op	            (ALU0_op),
	    .cp0_data       (ALU0_cp0_data),
	    .ptab_direction (ALU0_ptab_direction),
	    .ptab_data      (ALU0_ptab_data),
	    .hi             (ALU0_hi),
	    .lo             (ALU0_lo),
	    .exp_code_in    (ALU0_exp_code_in),
	    .ex_valid_ns    (ex_valid_ns),
	    .wb_allin       (wb_allin),
	    .alu_dest_addr  (ALU0_dest_out),
	    .alu_pc         (ALU0_pc_out),
	    .alu_op         (ALU0_op_out),
	    .branchcond     (ALU0_br),
	    .bp_result      (ALU0_bp_result),
	    .out	        (ALU0_out),
	    .out_wr	        (ALU0_out_wr),
	    .fu_ov	        (ALU0_of),
	    .exp_code_out   (ALU0_exp_code_out)
	);

	
	ALU_with_clk ALU1 (
	   // .CE_in          (ALU1_CE_in),
	   // .CE_out         (ALU1_CE_out),
		.clk            (clk),
	    .reset          (reset),
	    .flush          (flush),
		.scr0_data      (ALU1_scr0_data),
	    .scr1_data      (ALU1_scr1_data),
	    .dest_addr      (ALU1_dest_in),
	    .imme           (ALU1_imme),
	    .pc             (ALU1_pc),
	    .op	            (ALU1_op),
	    .cp0_data       (ALU1_cp0_data),
	    .ptab_direction (ALU1_ptab_direction),
	    .ptab_data      (ALU1_ptab_data),
	    .hi             (ALU1_hi),
	    .lo             (ALU1_lo),
	    .exp_code_in    (ALU1_exp_code_in),
	    .ex_valid_ns    (ex_valid_ns),
	    .wb_allin       (wb_allin),
	    .alu_dest_addr  (ALU1_dest_out),
	    .alu_pc         (ALU1_pc_out),
	    .alu_op         (ALU1_op_out),
	    .branchcond     (ALU1_br),
	    .bp_result      (ALU1_bp_result),
	    .out	        (ALU1_out),
	    .out_wr	        (ALU1_out_wr),
	    .fu_ov	        (ALU1_of),
	    .exp_code_out    (ALU1_exp_code_out)
	);

	MUL MUL (
		.clk            (clk),
        .reset          (reset), 
        .stall          (stall), 
        .flush          (flush),
        .CE_in          (MUL_CE_in),
        .ex_valid_ns    (ex_valid_ns),
        .wb_allin       (wb_allin),
        .mulx           (MUL_mulx),
        .muly           (MUL_muly),
        .is_op          (MUL_op),
        .mul_hi         (MUL_mul_hi),
        .mul_lo         (MUL_mul_lo),
        .CE_out         (MUL_CE_out)
	);
	
	DIV DIV (
		.clk            (clk),
        .reset          (reset), 
        .stall          (stall), 
        .flush          (flush),
        .CE_in          (DIV_CE_in),
        .ex_valid_ns    (ex_valid_ns),
        .wb_allin       (wb_allin),
        .dividend_in    (DIV_dividend_in),
        .divisor_in     (DIV_divisor_in),
        .is_op          (DIV_op),
        .quotient_out   (DIV_quotient_out),
        .remainder_out  (DIV_remainder_out),
        .CE_out         (DIV_CE_out)
	);
/**********             uncacheable singnal                 **********/   
		//alu0
		always @(*) begin
			if((ex_op[`AluOpBus_way0] == `INSN_LB || ex_op[`AluOpBus_way0] == `INSN_LBU || ex_op[`AluOpBus_way0] == `INSN_LH || ex_op[`AluOpBus_way0] == `INSN_LB || ex_op[`AluOpBus_way0] == `INSN_LHU || ex_op[`AluOpBus_way0] == `INSN_LW || ex_op[`AluOpBus_way0] == `INSN_SB || ex_op[`AluOpBus_way0] == `INSN_SH || ex_op[`AluOpBus_way0] == `INSN_SW) &&
				(alu_result[`UnCacheCheckWay0] == 16'hbfaf)) begin				
				uncacheable[0] = 1'b1;
			end
			else begin
				uncacheable[0] = 1'b0;
			end
		end
		//alu1
		always @(*) begin
			if((ex_op[`AluOpBus_way1] == `INSN_LB || ex_op[`AluOpBus_way1] == `INSN_LBU || ex_op[`AluOpBus_way1] == `INSN_LH || ex_op[`AluOpBus_way1] == `INSN_LB || ex_op[`AluOpBus_way1] == `INSN_LHU || ex_op[`AluOpBus_way1] == `INSN_LW || ex_op[`AluOpBus_way1] == `INSN_SB || ex_op[`AluOpBus_way1] == `INSN_SH || ex_op[`AluOpBus_way1] == `INSN_SW) &&
				(alu_result[`UnCacheCheckWay1] == 16'hbfaf)) begin				
				uncacheable[1] = 1'b1;
			end
			else begin
				uncacheable[1] = 1'b0;
			end
		end
  /**********               input to FU (Ctrl from FU_selector)                  **********/
  //input after handshake (is_data → ex_data) 
  always @( posedge clk) begin
     if (reset == `RESET_ENABLE || flush == `ENABLE) begin
		   FU_pc           <=                   64'b0;
		   FU_alu_op       <=                   12'b0;
		   FU_scr0_addr    <=                   10'b0;
		   FU_scr1_addr    <=                   10'b0;
		   FU_Dest_out     <=                   10'b0;
		   FU_alu_in_0     <=                   64'b0;
		   FU_alu_in_1     <=                   64'b0;
		   FU_alu_imme     <=                   64'b0;
		   FU_hi           <=                   64'b0;
		   FU_lo           <=                   64'b0;
		   FU_ptab_addr    <=                   10'b0;
		   FU_ptab_data    <=                  128'b0;
           FU_exp_code     <=                   10'b0; 
		   FU_cp0_data_in  <=                   64'b0; 
     end
     else if (is_valid_ns && ex_allin) begin
		   FU_pc           <=                   is_pc;
		   FU_alu_op       <=               is_alu_op;
		   FU_scr0_addr    <=            is_scr0_addr;
		   FU_scr1_addr    <=            is_scr1_addr;
		   FU_Dest_out     <=             is_Dest_out;
		   FU_alu_in_0     <=             is_alu_in_0;
		   FU_alu_in_1     <=             is_alu_in_1;
		   FU_alu_imme     <=             is_alu_imme;
		   FU_hi           <=                   is_hi;
		   FU_lo           <=                   is_lo;
		   FU_ptab_addr    <=            is_ptab_addr;
		   FU_ptab_data    <=               ptab_data;
           FU_exp_code     <=             is_exp_code; 
		   FU_cp0_data_in  <=             cp0_data_in; 
     end
 end
 
   //ALU0 and ALU1
  always @(*) begin
     //ALU0
     ALU0_scr0_data = alu_in_0    [`WordDataBus_way0];
     ALU0_scr1_data = alu_in_1    [`WordDataBus_way0];
     ALU0_dest_in   = FU_Dest_out    [`DestAddr_way0];
     ALU0_imme      = FU_alu_imme [`WordDataBus_way0];
     ALU0_pc        = FU_pc       [`WordAddrBus_way0];
     ALU0_op        = FU_alu_op      [`AluOpBus_way0];
     ALU0_cp0_data  = alu_cp0_data[`WordDataBus_way0];
     ALU0_ptab_direction =            FU_ptab_addr[4];
     ALU0_ptab_data = FU_ptab_data[`PtabdataBus_way0];
     ALU0_hi        = alu_hi      [`WordDataBus_way0];
     ALU0_lo        = alu_lo      [`WordDataBus_way0];
     ALU0_exp_code_in = FU_exp_code [`IsaExpBus_way0];
     //ALU1
     ALU1_scr0_data = alu_in_0    [`WordDataBus_way1];
     ALU1_scr1_data = alu_in_1    [`WordDataBus_way1];
     ALU1_dest_in   = FU_Dest_out    [`DestAddr_way1];
     ALU1_imme      = FU_alu_imme [`WordDataBus_way1];
     ALU1_pc        = FU_pc       [`WordAddrBus_way1];
     ALU1_op        = FU_alu_op      [`AluOpBus_way1];
     ALU1_cp0_data  = alu_cp0_data[`WordDataBus_way1];
     ALU1_ptab_direction =            FU_ptab_addr[9];
     ALU1_ptab_data = FU_ptab_data[`PtabdataBus_way1];
     ALU1_hi        = alu_hi      [`WordDataBus_way1];
     ALU1_lo        = alu_lo      [`WordDataBus_way1];
     ALU1_exp_code_in = FU_exp_code [`IsaExpBus_way1];
  end
  
  //FU_ctrl decide MUL and DIV
  always @(*) begin
  if(FU_ctrl) begin
   //MUL
  MUL_CE_in         = FU_en               [`FUen_MUL];
  MUL_mulx          = alu_in_0    [`WordDataBus_way1];       
  MUL_muly          = alu_in_1    [`WordDataBus_way1];
  MUL_op            = FU_alu_op      [`AluOpBus_way1];       
   //DIV
  DIV_CE_in         = FU_en               [`FUen_DIV];
  DIV_dividend_in   = alu_in_0    [`WordDataBus_way0];
  DIV_divisor_in    = alu_in_1    [`WordDataBus_way0];
  DIV_op            = FU_alu_op      [`AluOpBus_way0];
  end
  else begin
    //MUL
  MUL_CE_in         = FU_en               [`FUen_MUL];
  MUL_mulx          = alu_in_0    [`WordDataBus_way0];       
  MUL_muly          = alu_in_1    [`WordDataBus_way0];
  MUL_op            = FU_alu_op      [`AluOpBus_way0];       
   //DIV
  DIV_CE_in         = FU_en               [`FUen_DIV];
  DIV_dividend_in   = alu_in_0    [`WordDataBus_way1];
  DIV_divisor_in    = alu_in_1    [`WordDataBus_way1];
  DIV_op            = FU_alu_op      [`AluOpBus_way1];
  end
  end
  /*always @( posedge clk) begin
     if (reset == `RESET_ENABLE || flush == `ENABLE) begin
     //data
          //ALU0
    // ALU0_CE_in     <=                            1'b0;                     
     ALU0_scr0_data <=                           32'b0;
     ALU0_scr1_data <=                           32'b0;
     ALU0_scr0_addr <=                            5'b0;
     ALU0_scr1_addr <=                            5'b0;
     ALU0_dest_in   <=                            5'b0;
     ALU0_imme      <=                           32'b0;
     ALU0_pc        <=                           32'b0;
     ALU0_op        <=                            6'b0;
     ALU0_cp0_data  <=                           32'b0;
     ALU0_ptab_direction <=                       1'b0;
     ALU0_ptab_data <=                           64'b0;
     ALU0_hi        <=                           32'b0;
     ALU0_lo        <=                           32'b0;
     ALU0_exp_code_in <=                          5'b0;
     //ALU1
     //ALU1_CE_in     <=                            1'b0;       
     ALU1_scr0_data <=                           32'b0;
     ALU1_scr1_data <=                           32'b0;              
     ALU1_scr0_addr <=                            5'b0;
     ALU1_scr1_addr <=                            5'b0;
     ALU1_dest_in   <=                            5'b0;
     ALU1_imme      <=                           32'b0;
     ALU1_pc        <=                           32'b0;
     ALU1_op        <=                            6'b0;
     ALU1_cp0_data  <=                           32'b0;
     ALU1_ptab_direction <=                       1'b0;
     ALU1_ptab_data <=                           64'b0;
     ALU1_hi        <=                           32'b0;
     ALU1_lo        <=                           32'b0;
     ALU1_exp_code_in <=                          5'b0;
     //MUL
     MUL_CE_in         <=                            1'b0;
     MUL_mulx          <=                           32'b0;    
     MUL_muly          <=                           32'b0;    
     MUL_op            <=                            6'b0;       
     //DIV
     DIV_CE_in         <=                            1'b0;
     DIV_dividend_in   <=                           32'b0;    
     DIV_divisor_in    <=                           32'b0;    
     DIV_op            <=                            6'b0;    
     end
     else if(is_valid_ns && ex_allin) begin
     //ALU0
     //ALU0_CE_in     <=                       FU_en [0];              
     ALU0_scr0_data <= alu_in_0    [`WordDataBus_way0];
     ALU0_scr1_data <= alu_in_1    [`WordDataBus_way0];
     ALU0_scr0_addr <= is_scr0_addr   [`DestAddr_way0];
     ALU0_scr1_addr <= is_scr1_addr   [`DestAddr_way0];
     ALU0_dest_in   <= is_Dest_out    [`DestAddr_way0];
     ALU0_imme      <= is_alu_imme [`WordDataBus_way0];
     ALU0_pc        <= is_pc       [`WordAddrBus_way0];
     ALU0_op        <= is_alu_op      [`AluOpBus_way0];
     ALU0_cp0_data  <= alu_cp0_data[`WordDataBus_way0];
     ALU0_ptab_direction <=           is_ptab_addr [4];
     ALU0_ptab_data <= ptab_data   [`PtabdataBus_way0];
     ALU0_hi        <= alu_hi      [`WordDataBus_way0];
     ALU0_lo        <= alu_lo      [`WordDataBus_way0];
     ALU0_exp_code_in <= is_exp_code [`IsaExpBus_way0];
     //ALU1
     //ALU1_CE_in     <=                       FU_en [1];        
     ALU1_scr0_data <= alu_in_0    [`WordDataBus_way1];
     ALU1_scr1_data <= alu_in_1    [`WordDataBus_way1];
     ALU1_scr0_addr <= is_scr0_addr   [`DestAddr_way1];
     ALU1_scr1_addr <= is_scr1_addr   [`DestAddr_way1];
     ALU1_dest_in   <= is_Dest_out    [`DestAddr_way1];
     ALU1_imme      <= is_alu_imme [`WordDataBus_way1];
     ALU1_pc        <= is_pc       [`WordAddrBus_way1];
     ALU1_op        <= is_alu_op      [`AluOpBus_way1];
     ALU1_cp0_data  <= alu_cp0_data[`WordAddrBus_way1];
     ALU1_ptab_direction <=           is_ptab_addr [9];
     ALU1_ptab_data <= ptab_data   [`PtabdataBus_way1];
     ALU1_hi        <= alu_hi      [`WordDataBus_way1];
     ALU1_lo        <= alu_lo      [`WordDataBus_way1];
     ALU1_exp_code_in <= is_exp_code [`IsaExpBus_way1];
       if(FU_ctrl) begin
     //MUL
     MUL_CE_in         <= FU_en               [`FUen_MUL];
     MUL_mulx          <= alu_in_0    [`WordDataBus_way1];       
     MUL_muly          <= alu_in_1    [`WordDataBus_way1];
     MUL_op            <= is_alu_op      [`AluOpBus_way1];       
     //DIV
     DIV_CE_in         <= FU_en               [`FUen_DIV];
     DIV_dividend_in   <= alu_in_0    [`WordDataBus_way0];
     DIV_divisor_in    <= alu_in_1    [`WordDataBus_way0];
     DIV_op            <= is_alu_op      [`AluOpBus_way0];
     end
     else begin
     //MUL
     MUL_CE_in         <= FU_en               [`FUen_MUL];
     MUL_mulx          <= alu_in_0    [`WordDataBus_way0];       
     MUL_muly          <= alu_in_1    [`WordDataBus_way0];
     MUL_op            <= is_alu_op      [`AluOpBus_way0];       
     //DIV
     DIV_CE_in         <= FU_en               [`FUen_DIV];
     DIV_dividend_in   <= alu_in_0    [`WordDataBus_way1];
     DIV_divisor_in    <= alu_in_1    [`WordDataBus_way1];
     DIV_op            <= is_alu_op      [`AluOpBus_way1];
     end
     end
  end*/


 /**********              Output from FU  intput to ex_reg            **********/
 //output with clk
 /*always @(posedge clk or `RESET_EDGE reset) begin
    if (reset == `RESET_ENABLE) begin
		alu_result      <=    64'b0;
        mul_result      <=    64'b0;
        div_result      <=    64'b0;
        ex_branchcond   <=     2'b0;
        ex_bp_result    <=     2'b0;
        ex_wr_data      <=    64'b0;
        ex_Dest_out     <=    16'b0;	
        ex_exp_code     <=    10'b0;	
	end
	else if (ex_valid_ns && wb_allin) begin
        alu_result      <=    {ALU1_out,ALU0_out};
        mul_result      <=    {MUL_mul_hi,MUL_mul_lo};
        div_result      <=    {DIV_quotient_out,DIV_remainder_out};
        ex_branchcond   <=    {ALU1_br,ALU0_br};
        ex_bp_result    <=    {ALU1_bp_result,ALU0_bp_result};
        ex_wr_data      <=    {ALU1_out_wr,ALU0_out_wr};
        ex_Dest_out     <=     alu_dest_addr;
        ex_pc           <=     is_pc;
        ex_op           <=     is_alu_op;
        ex_exp_code     <=     alu_exp_code;
	end 
	else begin
	 //empty
	end
end*/

 //output without clk
 always @(*) begin
        alu_result      =    {ALU1_out,ALU0_out};
        mul_result      =    {MUL_mul_hi,MUL_mul_lo};
        div_result      =    {DIV_quotient_out,DIV_remainder_out};
        ex_branchcond   =    {ALU1_br,ALU0_br};
        ex_bp_result    =    {ALU1_bp_result,ALU0_bp_result};
        ex_wr_data      =    {ALU1_out_wr,ALU0_out_wr};
        ex_Dest_out     =     alu_dest_addr;
        ex_pc           =    {ALU1_pc_out,ALU0_pc_out};//wait
        ex_op           =    {ALU1_op_out,ALU0_op_out};//wait
        ex_exp_code     =     alu_exp_code;
	
end

//ex_Dest_valid
 assign ex_Dest_valid[0] = (`RDexopWay0)? `ENABLE:`DISABLE;
 assign ex_Dest_valid[1] = (`RDexopWay1)? `ENABLE:`DISABLE;
 
//alu_dest_addr       FU_ctrl:  0 -> way0 == ALU0||MUL  way1 == ALU1||DIV          1 ->way0 ==ALU0||DIV  way1 == ALU1||MUL
always @(*) begin
           if(FU_ctrl) begin
           alu_dest_addr[`DestAddr_way0]= (FU_en[`FUen_DIV] == `ENABLE)? 5'b0:ALU0_dest_out;
           alu_dest_addr[`DestAddr_way1]= (FU_en[`FUen_MUL] == `ENABLE)? 5'b0:ALU1_dest_out;
           end
           else begin
           alu_dest_addr[`DestAddr_way0]= (FU_en[`FUen_MUL] == `ENABLE)? 5'b0:ALU0_dest_out;
           alu_dest_addr[`DestAddr_way1]= (FU_en[`FUen_DIV] == `ENABLE)? 5'b0:ALU1_dest_out;
           end
end
 
 /**********              Exp Code                            **********/
 //alu0
 always @(*) begin
 			if (ALU0_of != ALU0_out[`WORD_MSB] &&
					(ALU0_op_out == `INSN_ADD || ALU0_op_out == `INSN_ADDI || ALU0_op_out == `INSN_SUB)
					) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_OV;
			end
			else if (ALU0_op_out == `INSN_BREAK) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_BP;
			end
			else if (ALU0_op_out == `INSN_SYSCALL) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_SYS;
			end
			else if (ALU0_out[`LSB] != 1'b0 && 
							(ALU0_op_out == `INSN_LH || ALU0_op_out == `INSN_LHU)
							) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ADEL;
			end
			else if (ALU0_out[`LSB] != 1'b0 && 
							(ALU0_op_out == `INSN_SH)
							) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ADES;
			end
			else if (ALU0_out[1:0] != 2'b00 && 
							(ALU0_op_out == `INSN_LW)
							) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ADEL;
			end
			else if (ALU0_out[1:0] != 2'b00 && 
							(ALU0_op_out == `INSN_SW)
							) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ADES;
			end
			else if (ALU0_out_wr[1:0] != 2'b00 && (ALU0_op_out == `INSN_JR || ALU0_op_out == `INSN_JALR || ALU0_op_out == `INSN_ERET)) begin
				alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ADEL;
			end
			else if (ALU0_op_out == `INSN_ERET) begin
			    alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ERET;
			end
			else begin
				alu_exp_code[`IsaExpBus_way0] = ALU0_exp_code_out;//wait
			end
 end
  //alu1
 always @(*) begin
 			if (ALU1_of != ALU1_out[`WORD_MSB] &&
					(ALU1_op_out == `INSN_ADD || ALU1_op_out == `INSN_ADDI || ALU1_op_out == `INSN_SUB)
					) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_OV;
			end
			else if (ALU1_op_out == `INSN_BREAK) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_BP;
			end
			else if (ALU1_op_out == `INSN_SYSCALL) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_SYS;
			end
			else if (ALU1_out[`LSB] != 1'b0 && 
							(ALU1_op_out == `INSN_LH || ALU1_op_out == `INSN_LHU)
							) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_ADEL;
			end
			else if (ALU1_out[`LSB] != 1'b0 && 
							(ALU1_op_out == `INSN_SH)
							) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_ADES;
			end
			else if (ALU1_out[1:0] != 2'b00 && 
							(ALU1_op_out == `INSN_LW)
							) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_ADEL;
			end
			else if (ALU1_out[1:0] != 2'b00 && 
							(ALU1_op_out == `INSN_SW)
							) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_ADES;
			end
			else if (ALU1_out_wr[1:0] != 2'b00 && (ALU1_op_out == `INSN_JR || ALU1_op_out == `INSN_JALR || ALU1_op_out == `INSN_ERET)) begin
				alu_exp_code[`IsaExpBus_way1] = `ISA_EXC_ADEL;
			end
			else if (ALU1_op_out == `INSN_ERET) begin
			    alu_exp_code[`IsaExpBus_way0] = `ISA_EXC_ERET;
			end
			else begin
				alu_exp_code[`IsaExpBus_way1] = ALU1_exp_code_out;//wait
			end
 end

 /**********              Bypass Logic                                 **********/
 //way0
		always @(*) begin 	//bypass to rs of way 0
			if (`RSaluopWay0 && `RDexopWay0 && (ALU0_scr0_addr == ex_Dest_out[`DestAddr_way0])) begin
				alu_in_0[`WordDataBus_way0] = alu_result[`WordDataBus_way0];
			end//from alu0
			else if (`RSaluopWay0 && `RDexopWay1 && (ALU0_scr0_addr == ex_Dest_out[`DestAddr_way1])) begin
				alu_in_0[`WordDataBus_way0] = alu_result[`WordDataBus_way1];
			end//from alu1
			else begin
				alu_in_0[`WordDataBus_way0] = FU_alu_in_0[`WordDataBus_way0];
			end
		end
		
		always @(*) begin 	//bypass to rt of way 0
			if (`RTaluopWay0 && `RDexopWay0 && (FU_scr1_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way0])) begin
				alu_in_1[`WordDataBus_way0] = alu_result[`WordDataBus_way0];
			end//from alu0
			else if (`RTaluopWay0 && `RDexopWay1 && (FU_scr1_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way1])) begin
				alu_in_1[`WordDataBus_way0] = alu_result[`WordDataBus_way1];
			end//from alu1
			else begin
				alu_in_1[`WordDataBus_way0] = FU_alu_in_1[`WordDataBus_way0];
			end
		end
		
		always @(*) begin//bypass to HI of way0
			if (FU_alu_op[`AluOpBus_way0] == `INSN_MFHI && (ex_op[`AluOpBus_way0] == `INSN_MULT || ex_op[`AluOpBus_way0] == `INSN_MULTU || ex_op[`AluOpBus_way1] == `INSN_MULT || ex_op[`AluOpBus_way1] == `INSN_MULTU ) ) begin
				alu_hi[`WordDataBus_way0] = mul_result[`WordDataBus_way1];
			end//from MUL_HI
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFHI && (ex_op[`AluOpBus_way0] == `INSN_DIV || ex_op[`AluOpBus_way0] == `INSN_DIVU || ex_op[`AluOpBus_way1] == `INSN_DIV || ex_op[`AluOpBus_way1] == `INSN_DIVU)) begin
				alu_hi[`WordDataBus_way0] = div_result[`WordDataBus_way1];
			end//from DIV_HI
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFHI && ex_op[`AluOpBus_way0] == `INSN_MTHI && (FU_scr0_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way0])) begin
				alu_hi[`WordDataBus_way0] = alu_result[`WordDataBus_way0];
			end//from alu0_HI
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFHI && ex_op[`AluOpBus_way1] == `INSN_MTHI && (FU_scr0_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way1])) begin
				alu_hi[`WordDataBus_way0] = alu_result[`WordDataBus_way1];
			end//from alu1_HI
			else begin
				alu_hi[`WordDataBus_way0] = FU_hi[`WordDataBus_way0];
			end
		end
		always @(*) begin//bypass to LO of way0
			if (FU_alu_op[`AluOpBus_way0] == `INSN_MFLO && (ex_op[`AluOpBus_way0] == `INSN_MULT || ex_op[`AluOpBus_way0] == `INSN_MULTU || ex_op[`AluOpBus_way1] == `INSN_MULT || ex_op[`AluOpBus_way1] == `INSN_MULTU ) ) begin
				alu_lo[`WordDataBus_way0] = mul_result[`WordDataBus_way0];
			end//from MUL_HI
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFLO && (ex_op[`AluOpBus_way0] == `INSN_DIV || ex_op[`AluOpBus_way0] == `INSN_DIVU || ex_op[`AluOpBus_way1] == `INSN_DIV || ex_op[`AluOpBus_way1] == `INSN_DIVU)) begin
				alu_lo[`WordDataBus_way0] = div_result[`WordDataBus_way0];
			end//from DIV_HI
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFLO && ex_op[`AluOpBus_way0] == `INSN_MTLO && (FU_scr0_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way0])) begin
				alu_lo[`WordDataBus_way0] = alu_result[`WordDataBus_way0];
			end//from alu0_LO
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFLO && ex_op[`AluOpBus_way1] == `INSN_MTLO && (FU_scr0_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way1])) begin
				alu_lo[`WordDataBus_way0] = alu_result[`WordDataBus_way1];
			end//from alu1_LO
			else begin
				alu_lo[`WordDataBus_way0] = FU_lo[`WordDataBus_way0];
			end
		end
		
		always @(*) begin//bypass to CP0 of way0
			if (FU_alu_op[`AluOpBus_way0] == `INSN_MFC0 && ex_op[`AluOpBus_way0] == `INSN_MTC0 && (FU_scr0_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way0])) begin
				alu_cp0_data[`WordDataBus_way0] = ex_wr_data[`WordDataBus_way0];
			end//from alu0
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_ERET && ex_op[`AluOpBus_way0] == `INSN_MTC0) begin
				alu_cp0_data[`WordDataBus_way0] = ex_wr_data[`WordDataBus_way0];
			end//from alu0 & ERET
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFC0 && ex_op[`AluOpBus_way1] == `INSN_MTC0 && (FU_scr0_addr[`DestAddr_way0] == ex_Dest_out[`DestAddr_way1])) begin
				alu_cp0_data[`WordDataBus_way0] = ex_wr_data[`WordDataBus_way1];
			end//from alu1
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_ERET && ex_op[`AluOpBus_way1] == `INSN_MTC0) begin
				alu_cp0_data[`WordDataBus_way0] = ex_wr_data[`WordDataBus_way1];
			end//from alu1 & ERET
			else begin
				alu_cp0_data[`WordDataBus_way0] = FU_cp0_data_in[`WordDataBus_way0];
			end
		end
 //way1
 		always @(*) begin 	//bypass to rs of way 1
			if (`RSaluopWay1 && `RDexopWay0 && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way0])) begin
				alu_in_0[`WordDataBus_way1] = alu_result[`WordDataBus_way0];
			end//from alu0
			else if (`RSaluopWay1 && `RDexopWay1 && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way1])) begin
				alu_in_0[`WordDataBus_way1] = alu_result[`WordDataBus_way1];
			end//from alu1
			else begin
				alu_in_0[`WordDataBus_way1] = FU_alu_in_0[`WordDataBus_way1];
			end
		end
		
		always @(*) begin 	//bypass to rt of way 1
			if (`RTaluopWay1 && `RDexopWay0 && (FU_scr1_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way0])) begin
				alu_in_1[`WordDataBus_way1] = alu_result[`WordDataBus_way0];
			end//from alu0
			else if (`RTaluopWay1 && `RDexopWay1 && (FU_scr1_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way1])) begin
				alu_in_1[`WordDataBus_way1] = alu_result[`WordDataBus_way1];
			end//from alu1
			else begin
				alu_in_1[`WordDataBus_way1] = FU_alu_in_1[`WordDataBus_way1];
			end
		end
		
		always @(*) begin//bypass to HI of way1
			if (FU_alu_op[`AluOpBus_way1] == `INSN_MFHI && (ex_op[`AluOpBus_way0] == `INSN_MULT || ex_op[`AluOpBus_way0] == `INSN_MULTU || ex_op[`AluOpBus_way1] == `INSN_MULT || ex_op[`AluOpBus_way1] == `INSN_MULTU ) ) begin
				alu_hi[`WordDataBus_way1] = mul_result[`WordDataBus_way1];
			end//from MUL_HI
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_MFHI && (ex_op[`AluOpBus_way0] == `INSN_DIV || ex_op[`AluOpBus_way0] == `INSN_DIVU || ex_op[`AluOpBus_way1] == `INSN_DIV || ex_op[`AluOpBus_way1] == `INSN_DIVU)) begin
				alu_hi[`WordDataBus_way1] = div_result[`WordDataBus_way1];
			end//from DIV_HI
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_MFHI && ex_op[`AluOpBus_way0] == `INSN_MTHI && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way0])) begin
				alu_hi[`WordDataBus_way1] = alu_result[`WordDataBus_way0];
			end//from alu0_HI
			else if (FU_alu_op[`AluOpBus_way0] == `INSN_MFHI && ex_op[`AluOpBus_way1] == `INSN_MTHI && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way1])) begin
				alu_hi[`WordDataBus_way1] = alu_result[`WordDataBus_way1];
			end//from alu1_HI
			else begin
				alu_hi[`WordDataBus_way1] = FU_hi[`WordDataBus_way1];
			end
		end
		always @(*) begin//bypass to LO of way1
			if (FU_alu_op[`AluOpBus_way1] == `INSN_MFLO && (ex_op[`AluOpBus_way0] == `INSN_MULT || ex_op[`AluOpBus_way0] == `INSN_MULTU || ex_op[`AluOpBus_way1] == `INSN_MULT || ex_op[`AluOpBus_way1] == `INSN_MULTU ) ) begin
				alu_lo[`WordDataBus_way1] = mul_result[`WordDataBus_way0];
			end//from MUL_HI
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_MFLO && (ex_op[`AluOpBus_way0] == `INSN_DIV || ex_op[`AluOpBus_way0] == `INSN_DIVU || ex_op[`AluOpBus_way1] == `INSN_DIV || ex_op[`AluOpBus_way1] == `INSN_DIVU)) begin
				alu_lo[`WordDataBus_way1] = div_result[`WordDataBus_way0];
			end//from DIV_HI
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_MFLO && ex_op[`AluOpBus_way0] == `INSN_MTLO && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way0])) begin
				alu_lo[`WordDataBus_way1] = alu_result[`WordDataBus_way0];
			end//from alu0_LO
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_MFLO && ex_op[`AluOpBus_way1] == `INSN_MTLO && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way1])) begin
				alu_lo[`WordDataBus_way1] = alu_result[`WordDataBus_way1];
			end//from alu1_LO
			else begin
				alu_lo[`WordDataBus_way1] = FU_lo[`WordDataBus_way1];
			end
		end
		
		always @(*) begin//bypass to CP0 of way1
			if (FU_alu_op[`AluOpBus_way1] == `INSN_MFC0 && ex_op[`AluOpBus_way0] == `INSN_MTC0 && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way0])) begin
				alu_cp0_data[`WordDataBus_way1] = ex_wr_data[`WordDataBus_way0];
			end//from alu0
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_ERET && ex_op[`AluOpBus_way0] == `INSN_MTC0) begin
				alu_cp0_data[`WordDataBus_way1] = ex_wr_data[`WordDataBus_way0];
			end//from alu0 & ERET
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_MFC0 && ex_op[`AluOpBus_way1] == `INSN_MTC0 && (FU_scr0_addr[`DestAddr_way1] == ex_Dest_out[`DestAddr_way1])) begin
				alu_cp0_data[`WordDataBus_way1] = ex_wr_data[`WordDataBus_way1];
			end//from alu1
			else if (FU_alu_op[`AluOpBus_way1] == `INSN_ERET && ex_op[`AluOpBus_way1] == `INSN_MTC0) begin
				alu_cp0_data[`WordDataBus_way1] = ex_wr_data[`WordDataBus_way1];
			end//from alu1 & ERET
			else begin
				alu_cp0_data[`WordDataBus_way1] = FU_cp0_data_in[`WordDataBus_way1];
			end
		end
 /**********              Handshake Logic                             **********/
 //ex_ready_go decided by CE_out from MUL/DIV
 always @(*) begin
 case (FU_en) 
 4'b1100:begin
      ex_ready_go = (DIV_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b1010:begin
      ex_ready_go = (DIV_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b1001:begin
      ex_ready_go = (DIV_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b0110:begin
      ex_ready_go = (MUL_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b0101:begin
      ex_ready_go = (MUL_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b1000:begin
      ex_ready_go = (DIV_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b0100:begin
      ex_ready_go = (DIV_CE_out == `ENABLE)? `ENABLE : `DISABLE;
         end
 4'b0011:begin
      ex_ready_go = `ENABLE;
         end
 4'b0001:begin
      ex_ready_go = `ENABLE;
         end
 4'b0010:begin
      ex_ready_go = `ENABLE;
         end
 default:begin
      ex_ready_go = `DISABLE;
         end
 endcase
 end
 
 //ex_valid control signal 
 assign ex_allin = !ex_valid || ex_ready_go && wb_allin;
 assign ex_valid_ns = ex_valid && ex_ready_go;
 
 always @(posedge clk or `RESET_EDGE reset) begin
 	if (reset == `RESET_ENABLE) begin
		ex_valid <= `DISABLE;		
	end
	else if (ex_allin) begin
		ex_valid <= is_valid_ns;
		end
	
 end
 
 /* always @(*) begin
 	if (reset == `RESET_ENABLE) begin
		ex_valid = `DISABLE;		
	end
	else if (ex_allin) begin
		ex_valid = is_valid_ns;
		end
    else begin
        ex_valid = `DISABLE;
	end
 end*/
endmodule
