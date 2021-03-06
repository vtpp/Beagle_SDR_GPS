/*
--------------------------------------------------------------------------------
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.
You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
Boston, MA  02110-1301, USA.
--------------------------------------------------------------------------------
*/

// Copyright (c) 2014 John Seamons, ZL/KF6VO


// fixme: I can't remember the difference between cic_prune.v & cic_prune_var.v
// something about pre-shifting the input data?

//
// implements 10-bit fixed (0-1024) and 5/11-bit 2**n variable decimation (R)
//
// NB: when variable decimation is specified by .DECIMATION(<0) then .GROWTH() must
// specify for the largest expected decimation.
//
// Fixed differential delay (D) = 1
//

`include "kiwi.vh"

module cic_prune_var (
	input wire clock,
	input wire reset,
	input wire [MD-1:0] decimation,
	input wire in_strobe,
	output reg out_strobe,
	input wire signed [IN_WIDTH-1:0] in_data,
	output reg signed [OUT_WIDTH-1:0] out_data
	);

// design parameters
parameter INCLUDE = "required";
parameter STAGES = "required";
parameter DECIMATION = "required";  
parameter IN_WIDTH = "required";
parameter GROWTH = "required";
parameter OUT_WIDTH = "required";

localparam ACC_WIDTH = IN_WIDTH + GROWTH;

localparam MD = 14;		// assumes excess counter bits get optimized away

reg [MD-1:0] sample_no;
initial sample_no = {MD{1'b0}};
wire [MD-1:0] decim;

generate
	if (DECIMATION < 0) begin assign decim = decimation; end	// variable
	if (DECIMATION > 0) begin assign decim = DECIMATION; end	// fixed
endgenerate

always @(posedge clock)
  if (in_strobe)
    begin
    if (sample_no == (decim-1))
      begin
      sample_no <= 0;
      out_strobe <= 1;
      end
    else
      begin
      sample_no <= sample_no + 1'b1;
      out_strobe <= 0;
      end
    end
  else
    out_strobe <= 0;

reg signed [ACC_WIDTH-1:0] in;
wire signed [OUT_WIDTH-1:0] out;

generate
	if (INCLUDE == "cic_wf1.vh") begin : wf1 `include "cic_wf1.vh" end
endgenerate

	localparam GROWTH_R2	= STAGES * clog2(2);
	localparam GROWTH_R4	= STAGES * clog2(4);
	localparam GROWTH_R8	= STAGES * clog2(8);
	localparam GROWTH_R16	= STAGES * clog2(16);
	localparam GROWTH_R32	= STAGES * clog2(32);
	localparam GROWTH_R64	= STAGES * clog2(64);
	localparam GROWTH_R128	= STAGES * clog2(128);
	localparam GROWTH_R256	= STAGES * clog2(256);
	localparam GROWTH_R512	= STAGES * clog2(512);
	localparam GROWTH_R1024	= STAGES * clog2(1024);
	localparam GROWTH_R2048	= STAGES * clog2(2048);
	
	localparam ACC_R2		= IN_WIDTH + GROWTH_R2;
	localparam ACC_R4		= IN_WIDTH + GROWTH_R4;
	localparam ACC_R8		= IN_WIDTH + GROWTH_R8;
	localparam ACC_R16		= IN_WIDTH + GROWTH_R16;
	localparam ACC_R32		= IN_WIDTH + GROWTH_R32;
	localparam ACC_R64		= IN_WIDTH + GROWTH_R64;
	localparam ACC_R128		= IN_WIDTH + GROWTH_R128;
	localparam ACC_R256		= IN_WIDTH + GROWTH_R256;
	localparam ACC_R512		= IN_WIDTH + GROWTH_R512;
	localparam ACC_R1024	= IN_WIDTH + GROWTH_R1024;
	localparam ACC_R2048	= IN_WIDTH + GROWTH_R2048;
	
generate
	if (DECIMATION == -32)
	begin
	
	always @(posedge clock)
		case (decim)
			   1: in <= in_data;
			   2: in <= in_data << (ACC_WIDTH - ACC_R2);
			   4: in <= in_data << (ACC_WIDTH - ACC_R4);
			   8: in <= in_data << (ACC_WIDTH - ACC_R8);
			  16: in <= in_data << (ACC_WIDTH - ACC_R16);
			  32: in <= in_data << (ACC_WIDTH - ACC_R32);
		endcase
	end
endgenerate

generate
	if (DECIMATION == -2048)
	begin
	
	always @(posedge clock)
		case (decim)
			   1: in <= in_data;
			   2: in <= in_data << (ACC_WIDTH - ACC_R2);
			   4: in <= in_data << (ACC_WIDTH - ACC_R4);
			   8: in <= in_data << (ACC_WIDTH - ACC_R8);
			  16: in <= in_data << (ACC_WIDTH - ACC_R16);
			  32: in <= in_data << (ACC_WIDTH - ACC_R32);
			  64: in <= in_data << (ACC_WIDTH - ACC_R64);
			 128: in <= in_data << (ACC_WIDTH - ACC_R128);
			 256: in <= in_data << (ACC_WIDTH - ACC_R256);
			 512: in <= in_data << (ACC_WIDTH - ACC_R512);
			1024: in <= in_data << (ACC_WIDTH - ACC_R1024);
			2048: in <= in_data << (ACC_WIDTH - ACC_R2048);
		endcase
	end
endgenerate

generate
	if (DECIMATION > 0)
	begin

	always @(posedge clock)
		in <= in_data;	// will sign-extend since both declared signed
	end
endgenerate

generate
	if (DECIMATION < 0)
	begin
		always @(posedge clock)
			if (out_strobe)
				if (decim == 1)
					out_data <= in[IN_WIDTH-1 -:OUT_WIDTH];
				else
					out_data <= out;
	end
endgenerate

generate
	if (DECIMATION > 0)
	begin
		always @(posedge clock)
			if (out_strobe) out_data <= out;
	end
endgenerate
	
endmodule
