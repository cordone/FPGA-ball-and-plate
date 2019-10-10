`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2018 01:34:40 PM
// Design Name: 
// Module Name: leg_calc
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


module leg_calc(
    input clock,
    input signed [7:0] plate_angle_x,
    input signed [7:0] plate_angle_y,
    output reg [50:0]leg_vector //3*(16bits + sign bit)
    );
    
    parameter [7:0] p_one = 0;
    parameter [7:0] p_two = 0;
    parameter [7:0] p_three = 0;
    
    parameter [7:0] b_one = 0;
    parameter [7:0] b_two = 0;
    parameter [7:0] b_three = 0;
    
    parameter [7:0] h = 0;
    
    reg signed [7:0] t_a_p, t_m_p; //degree
    reg signed [16:0] cos_t,sin_t,cos_p,sin_p,cos_t_m_p,sin_t_m_p,cos_t_a_p,sin_t_a_p; //16 bits for 0.00001 precision
    reg signed [16:0] diff_c,diff_s,add_c,add_s;
    reg signed [16:0] l_one_one,l_one_two,l_one_three,l_two_one,l_two_two,l_three_three,l_three_one,l_three_two,l_three_three;
    
    always @(posedge clock) begin
        t_a_p <= plate_angle_x + plate_angle_y;
        t_m_p <= plate_angle_x - plate_angle_y;
        
        diff_c <= cos_t_m_p - cos_t_a_p;
        diff_s <= sin_t_a_p - sin_t_a_p;
        add_c <= cos_t_a_p + cos_t_m_p;
        add_s <= sin_t_a_p + sin_t_a_p;
    
        l_one_one <= cos_t * p_one;
        l_one_two <= p_two * diff_c / 2;
        l_one_three <= p_three * add_s / 2;
        
        l_two_one <= cos_p * p_two;
        l_two_two <= sin_p * p_three;
        
        l_three_one <= sin_t * p_one;
        l_three_two <= p_two * diff_s / 2;
        l_three_three <= p_three * add_c / 2;
    
        leg_vector[16:0] <= l_one_one + l_one_two + l_one_three - b_one; //x-component
        leg_vector[33:17] <= l_two_one - l_two_two - b_two; //y-component
        leg_vector[50:34] <= h - l_three_one + l_three_two + l_three_three - b_three; //z-component
    end
endmodule
