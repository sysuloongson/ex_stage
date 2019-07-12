`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 15:24:57
// Design Name: 
// Module Name: ALU0
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

`define DestAddr           4:0
`define PtabdataBus       63:0
`define Ptabnextpc        31:0
`define IsaExpBus          4:0
`define BranchOp (op == `INSN_BEQ || op == `INSN_BNE || op == `INSN_BLEZ || op == `INSN_BLTZ || op == `INSN_BLTZAL || op == `INSN_BGEZAL || op == `INSN_BGTZ || op == `INSN_BGEZ || op == `INSN_J || op == `INSN_JAL || op == `INSN_JR || op == `INSN_JALR || op == `INSN_ERET)

module ALU_with_clk (
    //global signal
    input wire                 clk,
    input wire                 reset,
    input wire                 flush,
    //CE
    //input wire                 CE_in,
    //output reg                 CE_out,
    //alu data in
	input  wire [`WordDataBus]   scr0_data,  
	input  wire [`WordDataBus]   scr1_data,
	input  wire [`DestAddr]      dest_addr,
	input  wire [`WordDataBus]   imme,
	input  wire [`WordDataBus]   pc,
	input  wire [`AluOpBus]	      op,	  
	input  wire [`WordDataBus] cp0_data,
	input  wire                ptab_direction,
	input  wire [`PtabdataBus] ptab_data,
	input  wire [`WordDataBus] hi,
	input  wire [`WordDataBus] lo,
	input  wire [`IsaExpBus]   exp_code_in,
	//handshake signal
	input  wire                ex_valid_ns,
	input  wire                wb_allin,
	//alu data out             
	output reg  [`DestAddr]    alu_dest_addr,
	output reg  [`WordDataBus] alu_pc,
	output reg  [`AluOpBus]	    alu_op,
	output reg                 branchcond,
	output reg                 bp_result,
	output reg	 [`WordDataBus] out,
	output reg	 [`WordDataBus] out_wr,	  
	output reg				    fu_ov,	  
	output reg   [`IsaExpBus]  exp_code_out
    );

/**********      Local definition      **********/ 
    `define        sa          4:0
    `define PtabAddrValid	      4
    `define Byte               7:0
    `define Halfword          15:0
    `define BpBus              1:0
/**********      Internal signal      **********/ 
    wire signed [`WordDataBus] s_scr0_data = $signed(scr0_data); 
	wire signed [`WordDataBus] s_scr1_data = $signed(scr1_data); 
	wire signed [`WordDataBus] s_imme      = $signed(imme);
	wire signed [`WordDataBus] s_out       = $signed(out);  
	wire        [`BpBus]       bpbus;
	
	assign bpbus = {ptab_direction,branchcond};
   // reg                      fu_ov;
   //CE logic
    //always @ (posedge clk) begin
        // CE_out          <=  CE_in;
    //end
    always @ (posedge clk) begin
         if (reset == `RESET_ENABLE || flush == `ENABLE) begin
         branchcond       <=  1'b0;
         out              <= 32'b0;
         out_wr           <= 32'b0;
         fu_ov            <=  1'b0;
         
         alu_dest_addr    <=   5'b0;
         alu_pc           <=  32'b0;
         alu_op           <=   6'b0;
         exp_code_out     <= `ISA_EXC_NO_EXC;
         end
         else if (ex_valid_ns && wb_allin) begin
         //Initialization
         branchcond       <=  1'b0;
         out              <= 32'b0;
         out_wr           <= 32'b0;
         fu_ov            <=  1'b0;
         //data transfer
         alu_dest_addr    <=   dest_addr;
         alu_pc           <=          pc;
         alu_op           <=          op;
         exp_code_out     <= exp_code_in;
         case (op) 
         //addtion
					`INSN_ADD: begin
						{fu_ov,out} <= {scr0_data[`WORD_MSB],scr0_data} + {scr1_data[`WORD_MSB],scr1_data};
						branchcond  <= 1'b0;
					end
					`INSN_ADDI: begin
						{fu_ov,out} <= {scr0_data[`WORD_MSB],scr0_data} + {imme[`WORD_MSB],imme};
						branchcond  <= 1'b0;
					end
					`INSN_ADDU: begin
						 out        <= scr0_data + scr1_data;
						branchcond = 1'b0;
					end
					`INSN_ADDIU: begin
						out         <= scr0_data + imme;
						branchcond  <= 1'b0;
					end
					
		//subtraction
					`INSN_SUB: begin
						{fu_ov,out}  <= {scr0_data[`WORD_MSB],scr0_data} - {scr1_data[`WORD_MSB],scr1_data};
						branchcond   <= 1'b0;
					end
					`INSN_SUBU: begin
						out          <= scr0_data - scr1_data;
						branchcond   <= 1'b0;
					end
					
		//compare
					`INSN_SLT: begin
						if (s_scr0_data < s_scr1_data) begin
							out        <= 32'd1;
							branchcond <= 1'b0;
						end
						else begin
							out        <= 32'd0;
							branchcond <= 1'b0;
						end
					end
					`INSN_SLTI: begin
						if (s_scr0_data < s_imme) begin
							out        <= 32'd1;
							branchcond <= 1'b0;
						end
						else begin
							out        <= 32'd0;
							branchcond <= 1'b0;
						end
					end
					`INSN_SLTU: begin
						if ({`DISABLE,scr0_data} < {`DISABLE,scr1_data}) begin
							out         <= 32'd1;
							branchcond  <= 1'b0;
						end
						else begin
							out         <= 32'd0;
							branchcond  <= 1'b0;
						end
					end
					`INSN_SLTIU: begin
						if ({`DISABLE,scr0_data} < {`DISABLE,imme}) begin
							out         <= 32'd1;
							branchcond  <= 1'b0;
						end
						else begin
							out         <= 32'd0;
							branchcond  <= 1'b0;
						end
					end	
					
		//logic
					`INSN_AND: begin
						out              <= scr0_data & scr1_data;
						branchcond       <= 1'b0;
					end
					`INSN_ANDI: begin
						out              <= scr0_data & imme;
						branchcond       <= 1'b0;
					end
					`INSN_LUI: begin
						out              <= imme;
						branchcond       <= 1'b0;
					end
					`INSN_NOR: begin
						out              <= ~(scr0_data | scr1_data);
						branchcond       <= 1'b0;
					end
					`INSN_OR: begin
						out              <= scr0_data | scr1_data;
						branchcond       <= 1'b0;
					end
					`INSN_ORI: begin
						out              <= scr0_data | imme;
						branchcond       <= 1'b0;
					end
					`INSN_XOR: begin
						out              <= scr0_data ^ scr1_data;
						branchcond       <= 1'b0;
					end
					`INSN_XORI: begin
						out              <= scr0_data ^ imme;
						branchcond       <= 1'b0;
					end
					
		//shift
					`INSN_SLLV: begin
						out <= scr1_data << scr0_data[`sa];
						branchcond <= 1'b0;
					end
                    `INSN_SLL: begin
						out <= scr0_data << imme[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRAV: begin
						out <= s_scr1_data >>> scr0_data[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRA: begin
						out <= s_scr0_data >>> imme[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRLV: begin
						out <= s_scr1_data >> s_scr0_data[`sa];
						branchcond <= 1'b0;
					end
					`INSN_SRL: begin
						out <= s_scr0_data >> imme[`sa];
						branchcond <= 1'b0;
					end
		//branch
					`INSN_BEQ: begin			
					if((ptab_direction == `DISABLE && scr0_data == scr1_data) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data == scr1_data))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data == scr1_data) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end

					
					`INSN_BNE: begin
					if((ptab_direction == `DISABLE && scr0_data != scr1_data) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data != scr1_data))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data != scr1_data) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BGEZ: begin
				    if((ptab_direction == `DISABLE && scr0_data[`WORD_MSB] == 1'b0) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data[`WORD_MSB] == 1'b0))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BGTZ: begin
				    if((ptab_direction == `DISABLE && scr0_data[`WORD_MSB] == 1'b0 && scr0_data != 0) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data[`WORD_MSB] == 1'b0 && scr0_data != 0))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b0 && scr0_data != 0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BLEZ: begin
				    if((ptab_direction == `DISABLE && (scr0_data[`WORD_MSB] == 1'b1 || scr0_data == 0)) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && (scr0_data[`WORD_MSB] == 1'b1 || scr0_data == 0)))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b1 || scr0_data == 0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BLTZ: begin
				    if((ptab_direction == `DISABLE && scr0_data[`WORD_MSB] == 1'b1) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data[`WORD_MSB] == 1'b1))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b1) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BGEZAL: begin
				    if((ptab_direction == `DISABLE && scr0_data[`WORD_MSB] == 1'b0) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data[`WORD_MSB] == 1'b0))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b0) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_BLTZAL: begin
				    if((ptab_direction == `DISABLE && scr0_data[`WORD_MSB] == 1'b1) || (ptab_data[`PtabdataBus] == (pc[`WordDataBus] + {imme[`WordDataBus], 2'b00}) && `BranchOp && (ptab_direction == `ENABLE && scr0_data[`WORD_MSB] == 1'b1))) begin
					    out_wr <= pc + imme + 32'h4;
					    out <= pc + 32'd8;
					end
					else begin
					 	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
					end
					if(scr0_data[`WORD_MSB] == 1'b1) begin
					    branchcond <= 1'b1;
					end
					else begin
					    branchcond <= 1'b0;
					end
					end
					
					`INSN_J: begin
				    if((ptab_direction == `DISABLE) || (ptab_data[`PtabdataBus] == imme[`WordDataBus] && `BranchOp && ptab_direction == `ENABLE)) begin
				    	out_wr <= imme;
					    out <= pc + 32'd8;
				    end
				    else begin
				    	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
				    end
				    branchcond <= 1'b1; 
				    end
					
					`INSN_JAL: begin
				    if((ptab_direction == `DISABLE) || (ptab_data[`PtabdataBus] == imme[`WordDataBus] && `BranchOp && ptab_direction == `ENABLE)) begin
				    	out_wr <= imme;
					    out <= pc + 32'd8;
				    end
				    else begin
				    	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
				    end
				    branchcond <= 1'b1; 
				    end
					
					`INSN_JR: begin
				    if((ptab_direction == `DISABLE) || (ptab_data[`PtabdataBus] == scr0_data && `BranchOp && ptab_direction == `ENABLE)) begin
				    	out_wr <= scr0_data;
					    out <= pc + 32'd8;
				    end
				    else begin
				    	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
				    end
				    branchcond <= 1'b1; 
				    end
					
					`INSN_JALR: begin
				    if((ptab_direction == `DISABLE) || (ptab_data[`PtabdataBus] == scr0_data && `BranchOp && ptab_direction == `ENABLE)) begin
				    	out_wr <= scr0_data;
					    out <= pc + 32'd8;
				    end
				    else begin
				    	out_wr <= ptab_data[`Ptabnextpc];
					    out <= pc + 32'd8;
				    end
				    branchcond <= 1'b1; 
				    end
					
		//movement
					`INSN_MFHI: begin
						out <= hi;
						branchcond <= 1'b0;
					end
					`INSN_MFLO: begin
						out <= lo;
						branchcond <= 1'b0;
					end
					`INSN_MTHI: begin
						out <= scr0_data;
						branchcond <= 1'b0;
					end
					`INSN_MTLO: begin
						out <= scr0_data;
						branchcond <= 1'b0;
					end
					
		//access memory
					`INSN_LB: begin
						out <= scr0_data + imme;
						branchcond <= 1'b0; 
					end
					`INSN_LBU: begin
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_LH: begin
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_LHU: begin
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_LW: begin
						out <= scr0_data + imme;
						branchcond <= 1'b0;
					end
					`INSN_SB: begin
						out <= scr0_data + imme;
						out_wr <= scr1_data[`Byte];
						branchcond <= 1'b0;
					end
					`INSN_SH: begin
						out <= scr0_data + imme;
						out_wr <= scr1_data[`Halfword];
						branchcond <= 1'b0;
					end
					`INSN_SW: begin
						out <= scr0_data+ imme;
						out_wr <= scr1_data;
						branchcond <= 1'b0;
					end
	    //special
					`INSN_MFC0: begin
						out <= cp0_data;
						branchcond <= 1'b0;
					end
					`INSN_MTC0: begin
						out_wr <= scr0_data;
						branchcond <= 1'b0;
					end
					`INSN_ERET: begin
					if((ptab_direction == `DISABLE) || (ptab_data[`PtabdataBus] == cp0_data && `BranchOp && ptab_direction == `ENABLE)) begin
				    	out_wr <= cp0_data;
				    end
				    else begin
				    	out_wr <= ptab_data[`Ptabnextpc];
				    end
				    branchcond <= 1'b1; 
				    end
				  
					default: begin
                    //keep
					end
		endcase
		end
		else begin
		//keep
		end			
	 end
	 //branch predict logic
	 always @(*) begin
	 case(bpbus) //1 mean bp right, 0 mena bp error
	 2'b00:bp_result = 1'b1;
	 2'b01:bp_result = 1'b0;
	 2'b10:bp_result = 1'b1;
	 2'b11:bp_result = (ptab_data == out && `BranchOp)? 1'b1:1'b0;
	 endcase
	 end
endmodule
