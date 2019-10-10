`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: poseSIX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Run six poseONE modules in parallel.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module poseSIX(
	input wire clock,
	input wire validIn,
	input wire reset,
	input wire signed [12:0] Rx, Ry,
	output reg [11:0] angle1, angle2, angle3, angle4, angle5, angle6
	);
	
    wire angleValid;
	
    // Default angle.
    localparam a0 = 12'd2200;

    // In the paper, the calculated servo angle was referenced from the horizontal.
    // Our servos swing from 0 to 180 where zero points straight up, so we need to add 90deg to the calculate angle.    
    localparam signed [12:0] offset = 12'd2048;
    
    wire signed [12:0] asin;
    wire signed [12:0] atan1, atan2, atan3, atan4, atan5, atan6;
    reg signed [16:0] LUTin;
    wire signed [16:0] LUT1, LUT2, LUT3, LUT4, LUT5, LUT6;

  	// BASE JOINT COORDINATES
   	// 1: {'x': -33.5, 'y': +73.0, 'z': 0}
   	// 2: {'x': +33.5, 'y': +73.0, 'z': 0}
  	// 3: {'x': +80.0, 'y': -7.50, 'z': 0}
  	// 4: {'x': +46.5, 'y': -65.5, 'z': 0}
  	// 5: {'x': -46.5, 'y': -65.5, 'z': 0}
  	// 6: {'x': -80.0, 'y': -7.50, 'z': 0}
   	// PLATE JOINT COORDINATES
  	// 1: {'x': -43.1, 'y': +39.3, 'z': 0}
  	// 2: {'x': +43.1, 'y': +39.3, 'z': 0}
  	// 3: {'x': +55.6, 'y': +17.7, 'z': 0}
  	// 4: {'x': +12.5, 'y': -57.0, 'z': 0}
  	// 5: {'x': -12.5, 'y': -57.0, 'z': 0}
  	// 6: {'x': -55.6, 'y': +17.7, 'z': 0}

   	localparam [17:0]
  	bx1 = 18'b11011110_1000000000, by1 = 18'b01001001_0000000000, bz1 = 18'b00000000_0000000000,
   	bx2 = 18'b00100001_1000000000, by2 = 18'b01001001_0000000000, bz2 = 18'b00000000_0000000000,
   	bx3 = 18'b01010000_0000000000, by3 = 18'b11111000_1000000000, bz3 = 18'b00000000_0000000000,
   	bx4 = 18'b00101110_1000000000, by4 = 18'b10111110_1000000000, bz4 = 18'b00000000_0000000000,
   	bx5 = 18'b11010001_1000000000, by5 = 18'b10111110_1000000000, bz5 = 18'b00000000_0000000000,
   	bx6 = 18'b10110000_0000000000, by6 = 18'b11111000_1000000000, bz6 = 18'b00000000_0000000000,
   	px1 = 18'b11010100_1110011001, py1 = 18'b00100111_0100110011, pz1 = 18'b00000000_0000000000,
   	px2 = 18'b00101011_0001100110, py2 = 18'b00100111_0100110011, pz2 = 18'b00000000_0000000000,
   	px3 = 18'b00110111_1001100110, py3 = 18'b00010001_1011001100, pz3 = 18'b00000000_0000000000,
   	px4 = 18'b00001100_1000000000, py4 = 18'b11000111_0000000000, pz4 = 18'b00000000_0000000000,
   	px5 = 18'b11110011_1000000000, py5 = 18'b11000111_0000000000, pz5 = 18'b00000000_0000000000,
  	px6 = 18'b11001000_0110011001, py6 = 18'b00010001_1011001100, pz6 = 18'b00000000_0000000000;

   	// BETA = 90 90 330 330 210 210
  	poseONE #(.BETA(90))
  		servo1(.clock(clock),
  			.validIn(validIn),
  			.reset(reset),
  			.bx(bx1),.by(by1),.bz(bz1),
  			.px(px1),.py(py1),.pz(pz1),
  			.Rx(Rx),.Ry(Ry),
  			.LUTin(LUT1),
  			.atan(atan1),
  			.validOut(angleValid));

  	poseONE #(.BETA(90))
  		servo2(.clock(clock),
  			.validIn(validIn),
  			.reset(reset),
  			.bx(bx2),.by(by2),.bz(bz2),
  			.px(px2),.py(py2),.pz(pz2),
  			.Rx(Rx),.Ry(Ry),
  			.LUTin(LUT2),
  			.atan(atan2),
  			.validOut());

  	poseONE #(.BETA(330))
  		servo3(.clock(clock),
  			.validIn(validIn),
  			.reset(reset),
  			.bx(bx3),.by(by3),.bz(bz3),
  			.px(px3),.py(py3),.pz(pz3),
  			.Rx(Rx),.Ry(Ry),
  			.LUTin(LUT3),
  			.atan(atan3),
  			.validOut());

  	poseONE #(.BETA(330))
  		servo4(.clock(clock),
  			.validIn(validIn),
  			.reset(reset),
  			.bx(bx4),.by(by4),.bz(bz4),
  			.px(px4),.py(py4),.pz(pz4),
  			.Rx(Rx),.Ry(Ry),
  			.LUTin(LUT4),
  			.atan(atan4),
  			.validOut());

  	poseONE #(.BETA(210))
  		servo5(.clock(clock),
  			.validIn(validIn),
  			.reset(reset),
  			.bx(bx5),.by(by5),.bz(bz5),
  			.px(px5),.py(py5),.pz(pz5),
  			.Rx(Rx),.Ry(Ry),
  			.LUTin(LUT5),
  			.atan(atan5),
  			.validOut());

  	poseONE #(.BETA(210))
  		servo6(.clock(clock),
  			.validIn(validIn),
  			.reset(reset),
  			.bx(bx6),.by(by6),.bz(bz6),
  			.px(px6),.py(py6),.pz(pz6),
  			.Rx(Rx),.Ry(Ry),
  			.LUTin(LUT6),
  			.atan(atan6),
  			.validOut());
        
    // Now, do the arcsin lookup.
    sintable arcsin(.i_clk(clock),
                   .i_reset(reset),
                   .i_ce(1'b1),
                   .i_aux(),
                   .i_phase(LUTin),
                   .o_val(asin),
                   .o_aux(),
                   .o_en());
    
    // PULSE-TO-LEVEL ENABLE
    reg LUTenable;
    always @(posedge clock or posedge reset)
    begin
       if (reset) begin
           LUTenable <= 0;
       end else begin
           if (counter == 7) begin
               LUTenable <= 0;
           end else if (angleValid && ~LUTenable) begin
               LUTenable <= 1;
           end
       end
    end
   
    reg [3:0] counter;
    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            counter <= 0;
        end else if (LUTenable) begin
            counter <= (counter == 7) ? 0 : counter + 1;
        end
    end
    
    // Needed to hold signed sum.
    wire signed [12:0] alpha1, alpha2, alpha3, alpha4, alpha5, alpha6;
    assign alpha1 = asin - atan1;
    assign alpha2 = asin - atan2;
    assign alpha3 = asin - atan3;
    assign alpha4 = asin - atan4;
    assign alpha5 = asin - atan5;
    assign alpha6 = asin - atan6;
   
    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            LUTin <= 0;
            angle1 <= a0;
            angle2 <= a0;
            angle3 <= a0;
            angle4 <= a0;
            angle5 <= a0;
            angle6 <= a0;
        end else if (LUTenable) begin
            case (counter)
                0: begin 
                    LUTin <= LUT1;
                   end
                1: begin
                    LUTin <= LUT2;
                   end
                2: begin
                    LUTin <= LUT3; 
                    angle1 <= offset + alpha1;
                   end
                3: begin
                    LUTin <= LUT4;
                    angle2 <= offset + alpha2;
                   end
                4: begin
                    LUTin <= LUT5;
                    angle3 <= offset + alpha3;
                   end
                5: begin
                    LUTin <= LUT6;
                    angle4 <= offset + alpha4;
                   end
                6: begin
                    LUTin <= 0;
                    angle5 <= offset + alpha5;
                   end
                7: begin
                    LUTin <= 0;
                    angle6 <= offset + alpha6;
                   end
            endcase
        end
    end
    
endmodule