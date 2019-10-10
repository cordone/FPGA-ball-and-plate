////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	sintable.v
//
// Project:	A series of CORDIC related projects
//
// Purpose:	This is a very simple sinewave table lookup approach
//		approach to generating a sine wave.  It has the lowest latency
//	among all sinewave generation alternatives.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2017-2018, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	sintable(i_clk, i_reset, i_ce, i_aux, i_phase, o_val, o_aux, o_en);
	//
    parameter PW =16; // Number of bits in the input phase
	parameter OW =13; // Number of output bits 12 + sign
	//
    input wire i_clk, i_reset, i_ce;
    input wire signed [16:0] i_phase; // Change made to add sign bit
	output reg signed [(OW-1):0] o_val;
	//
	input wire i_aux;
    output reg o_aux;
    output reg o_en;

	reg [(OW-1):0] tbl [0:((1<<PW)-1)];

	initial	$readmemh("/afs/athena.mit.edu/user/c/o/cordone/Desktop/6.111/FPGA-ball-and-plate/REAL SOURCES/sintable.hex", tbl);

    wire [15:0] posIndex, negIndex;
    assign posIndex = i_phase[15:0];
    assign negIndex = ~i_phase[15:0] + 1;
    
	always @(posedge i_clk) begin
	   if (i_reset) begin
	       o_val <= 0;
           o_aux <= 0;
	   end 
	   else if (i_ce) begin
	       if (i_phase[16]) begin
	           o_val <= {1'b1, (~tbl[negIndex] + 1)};
	       end else begin
	           o_val <= {1'b0, tbl[posIndex]};
           end
	       o_aux <= i_aux;
	       o_en <= 1;
	   end
	   else begin
	       o_en <= 0;
	   end
	end
        
endmodule
