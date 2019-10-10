`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2018 02:24:18 PM
// Design Name: 
// Module Name: ball_position_controller
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


module ball_position_controller(
    input clock,
    input signed [12:0] desired_pos,
    input signed [12:0] actual_pos,
    output reg signed [10:0] angle
    );
    
    //parameters for lqr control
//    parameter freq = 1000; //clock freq of 1kHz
//    parameter k_1 = 326; //1*(2^10 / pi)
//    parameter k_2 = 326;
//    parameter k_r = 326;
    parameter angle_offset = 85;
    
    //prepare registers
    reg signed [12:0] prev_pos = 0;
    reg signed [12:0] delta_pos = 0;
    //reg signed [24:0] velocity = 0;
    
    //wires for multiplications
    wire signed [12:0] kpos,kvel,kr;
    
    //counter to seperate multiplication
    //reg [1:0] quarter_divider = 0;
    
    mult_vel kvel_calc (.CLK(clock),.A(delta_pos),.P(kvel)); // delta_pos * freq = 1000 * k_2 = 326
    mult_gen_0 kpos_calc (.CLK(clock),.A(actual_pos),.P(kpos)); // actual_pos * k_1 = 326
    mult_gen_0 kr_calc (.CLK(clock),.A(desired_pos),.P(kr)); // desired_pos * k_3 = 326
    
    always @(posedge clock) begin
        //quarter_divider <= quarter_divider + 1;
        prev_pos <= actual_pos;
        delta_pos <= actual_pos - prev_pos; 
        angle <= kpos + kvel + kr + angle_offset;
    end
    
//    always @(posedge quarter_divider[1]) begin
//        velocity <= 4*freq*delta_pos;
//        kpos <= k_1*actual_pos;
//        kvel <= k_2*velocity;
//        kr <= k_r*desired_pos;
//    end
endmodule
