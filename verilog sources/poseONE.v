`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: poseONE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Run the inverse kinematic equations of Stewart platform to get
// 				a new angle for a single servo.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module poseONE #(parameter BETA = 90)(
	input wire clock,
	input wire validIn,
	input wire reset,
	input wire signed [17:0] bx, by, bz,
	input wire signed [17:0] px, py, pz,
	input wire signed [12:0] Rx, Ry,
	output wire signed [16:0] LUTin,
	output wire signed [12:0] atan,
	output wire validOut
	);
	
	// Default height.
	localparam signed [17:0] h0 = 18'b01110101_0000000000; // 117 in Q7.10 fixed point representaton

	wire signed [17:0] R11, R12, R13, R21, R22, R23, R31, R32, R33;
	wire signed [36:0] dpX, dpY, dpZ;
	wire signed [17:0] qx, qy, qz;

	wire rotValid, dpValid, angleValid;

    // The dot products are 36 bit sums of Q7.10 and Q1.14 (sign extended to Q3.14)
    assign qx = dpX[31:14];
    assign qy = dpY[31:14];
    assign qz = dpZ[31:14];

    // Need an extra bit to avoid underflow / overflow.
    wire signed [18:0] lx0, ly0, lz0;
    
    assign lx0 = qx - bx;
    assign ly0 = qy - by;
    assign lz0 = h0 + (qz - bz);

    reg signed [8:0] lx, ly, lz;
	always @(posedge clock) begin
		if (reset) begin
			lx <= 0;
			ly <= 0;
			lz <= h0 >>> 10;
		end else begin
			lx <= lx0 >>> 10; // round to int
			ly <= ly0 >>> 10;
			lz <= lz0 >>> 10;
		end
	end

    reg legValid;
    always @(posedge clock) legValid <= dpValid; // To line up with lx, ly, and lz.

	Rmatrix Rxy(.clock(clock),
			.validIn(validIn),
			.reset(reset),
			.Rx(Rx),
			.Ry(Ry),
			.R11(R11),
			.R12(R12),
			.R13(R13),
			.R21(R21),
			.R22(R22),
			.R23(R23),
			.R31(R31),
			.R32(R32),
			.R33(R33),
			.validOut(rotValid));
			
	dp_3x1 dotX(.clock(clock),
			.validIn(rotValid),
			.reset(reset),
			.A1(R11),
			.A2(R12),
			.A3(R13),
			.B1(px),
			.B2(py),
			.B3(pz),
			.dp(dpX),
			.validOut(dpValid));

	dp_3x1 dotY(.clock(clock),
			.validIn(rotValid),
			.reset(reset),
			.A1(R21),
			.A2(R22),
			.A3(R23),
			.B1(px),
			.B2(py),
			.B3(pz),
			.dp(dpY),
			.validOut());

	dp_3x1 dotZ(.clock(clock),
			.validIn(rotValid),
			.reset(reset),
			.A1(R31),
			.A2(R32),
			.A3(R33),
			.B1(px),
			.B2(py),
			.B3(pz),
			.dp(dpZ),
			.validOut());

	servo_angle_gen #(.BETA(BETA))
		alpha(.clock(clock),
			.validIn(legValid),
			.reset(reset),
			.lx(lx),
			.ly(ly),
			.lz(lz),
			.LUTin(LUTin),
			.atan(atan),
			.validOut(validOut));

endmodule