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


module ALU_with_clk (
    //global signal
    input wire                 clk,
    input wire                 reset,
    input wire                 flush,
    //alu data in
	input  wire [`WordDataBus] scr0_data,  
	input  wire [`WordDataBus] scr1_data,
	input  wire [`WordDataBus] imme,
	input  wire [`WordDataBus] pc,
	input  wire [`AluOpBus]	    op,	  
	input  wire [`WordDataBus] cp0_data,
	input  wire                ptab_direction,
	input  wire [`WordAddrBus] ptab_data,
	input  wire [`WordDataBus] hi,
	input  wire [`WordDataBus] lo,
	//handshake signal
	input  wire                ex_valid_ns,
	input  wire                wb_allin,
	//alu data out             
	output reg                 branchcond,
	output reg                 bp_result,
	output reg	 [`WordDataBus] out,
	output reg	 [`WordDataBus] out_wr,	  
	output reg				    fu_ov	  
    );

/**********      Local definition      **********/ 
    `define        sa         4:0
    `define PtabAddrValid	   4
    `define Byte              7:0
    `define Halfword          15:0
/**********      Internal signal      **********/ 
    wire signed [`WordDataBus] s_scr0_data = $signed(scr0_data); 
	wire signed [`WordDataBus] s_scr1_data = $signed(scr1_data); 
	wire signed [`WordDataBus] s_imme      = $signed(imme);
	wire signed [`WordDataBus] s_out       = $signed(out);  
   // reg                      fu_ov;
    
    always @ (posedge clk) begin
         if (reset == `RESET_ENABLE || flush == `ENABLE) begin
         branchcond       <=  1'b0;
         bp_result        <=  1'b0;
         out              <= 32'b0;
         out_wr           <= 32'b0;
         fu_ov            <=  1'b0;
         end
         else if (ex_valid_ns && wb_allin) begin
         //Initialization
         branchcond       <=  1'b0;
         bp_result        <=  1'b0;
         out              <= 32'b0;
         out_wr           <= 32'b0;
         fu_ov            <=  1'b0;
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
					if (scr0_data == scr1_data) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end	
					
					`INSN_BNE: begin
					if (scr0_data != scr1_data) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BGEZ: begin
					if (scr0_data[`WORD_MSB] == 1'b0) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BGTZ: begin
					if (scr0_data[`WORD_MSB] == 1'b0 && scr0_data != 0 ) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BLEZ: begin
					if (scr0_data[`WORD_MSB] == 1'b1 || scr0_data == 0 ) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BLTZ: begin
					if (scr0_data[`WORD_MSB] == 1'b1) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BGEZAL: begin
					if (scr0_data[`WORD_MSB] == 1'b0) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BGEZAL: begin
					if (scr0_data[`WORD_MSB] == 1'b0) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_BLTZAL: begin
					if (scr0_data[`WORD_MSB] == 1'b1) begin
					 branchcond <= 1'b1; 
					 if(ptab_direction == `ENABLE) begin
						  out_wr <= ptab_data;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;// 1 means bp right, 0 means bp error
				     end
					 else begin
						  out_wr <= pc + imme + 32'h4;
						  out <= pc + 32'd8;
						  bp_result <= 1'b0;
				     end
					end
					else begin 
					 branchcond <= 1'b0; 
					 if(ptab_direction == `ENABLE) begin
					      out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
				     else begin
				          out_wr <= pc + 32'd8;
						  out <= pc + 32'd8;
						  bp_result <= 1'b1;
				     end
					end
					end
					
					`INSN_J: begin
					 branchcond <= 1'b1; 
					 if (ptab_direction == `ENABLE) begin
					 out_wr <= ptab_data;
				     out <= pc + 32'd8;
				     bp_result <= 1'b1;
					 end
					 else begin
					 out_wr <= imme;
					 out <= pc +32'd8;
					 bp_result <= 1'b0;
					 end
					end
					
					`INSN_JAL: begin
					 branchcond <= 1'b1; 
					 if (ptab_direction == `ENABLE) begin
					 out_wr <= ptab_data;
				     out <= pc + 32'd8;
				     bp_result <= 1'b1;
					 end
					 else begin
					 out_wr <= imme;
					 out <= pc +32'd8;
					 bp_result <= 1'b0;
					 end
					end
					
					`INSN_JR: begin
					 branchcond <= 1'b1; 
					 if (ptab_direction == `ENABLE) begin
					 out_wr <= ptab_data;
				     out <= pc + 32'd8;
				     bp_result <= 1'b1;
					 end
					 else begin
					 out_wr <= scr0_data;
					 out <= pc +32'd8;
					 bp_result <= 1'b0;
					 end
					end
					
					`INSN_JALR: begin
					 branchcond <= 1'b1; 
					 if (ptab_direction == `ENABLE) begin
					 out_wr <= ptab_data;
				     out <= pc + 32'd8;
				     bp_result <= 1'b1;
					 end
					 else begin
					 out_wr <= scr0_data;
					 out <= pc +32'd8;
					 bp_result <= 1'b0;
					 end
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
                        out_wr <= cp0_data;
						branchcond <= 1'b1;
					end
					
					default: begin
					branchcond <= 1'b0;
                    bp_result  <= 1'b0;
                    out <= 32'b0;
                    out_wr <= 32'b0;
                    fu_ov  <= 1'b0;
					end
		endcase
		end
		else begin
		//keep
		end			
	 end
endmodule
