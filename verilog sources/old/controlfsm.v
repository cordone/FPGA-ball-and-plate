`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2018 01:28:26 PM
// Design Name: 
// Module Name: controlfsm
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


module controlfsm(
    input clock,
    input [23:0] manual, //input from joystick
    input [23:0] touchpanel, //input from touchpanel
    input mode_switch,
    input [9:0] ball_pos_control_angle_x, //input from Ball Position Controller
    input [9:0] ball_pos_control_angle_y, //input from Ball Position Controller
    input [71:0] servo_angles, //input from Plate Pose Controller
    output reg [11:0] ball_pos_x, //output to Ball Position Controller
    output reg [11:0] ball_pos_y, //output to Ball Position Controller
    output [11:0] des_ball_pos_x, //output to Ball Position Controller
    output [11:0] des_ball_pos_y, //output to Ball Position Controller
    output reg [11:0] plate_angle_x, //output to Plate Pose Controller
    output reg [11:0] plate_angle_y, //output to Plate Pose Controller
    output reg [71:0] pwm_angles //output to PWM interface
    );
    
    parameter manual_mode = 1'b0;
    parameter feedback_mode = 1'b1;
    
    parameter origin_x = 12'd2048;
    parameter origin_y = 12'd2048;
    
    assign des_ball_pos_x = origin_x;
    assign des_ball_pos_y = origin_y;
    
    always @(posedge clock) begin
        case(mode_switch)
            manual_mode: begin
                //take manual input(in our case joystick) and convert it into plate pitch and roll for the Plate Pose Controller
                plate_angle_x <= manual[11:4];
                plate_angle_y <= manual[23:16];
            end
            feedback_mode: begin
                //take input from touchpanel and give it to Ball Position Controller
                ball_pos_x <= touchpanel[11:4];
                ball_pos_y <= touchpanel[23:16];
                
                //take input from Ball Position Controller and pass it to Plate Pose Controller
                plate_angle_x <= ball_pos_control_angle_x;
                plate_angle_y <= ball_pos_control_angle_y;
            end
        endcase
        //Give input from Plate Pose Controller directly to servo pwm interface
        pwm_angles <= servo_angles;
    end
    
endmodule
