`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2018 03:00:55 PM
// Design Name: 
// Module Name: bubble_display
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


module bubble_display(
    input [10:0] x,
    input [9:0] y,
    input [10:0] hcount,    // pixel number on current line
    input [9:0] vcount,     // line number
    output reg [11:0] pixel_value
    );
    
    parameter RADIUS = 20;
    parameter RADIUS_SQ = 400;
    parameter EXT_RADIUS_SQ = 625;
    parameter circle_error = 40;
    parameter COLOR = {4'b1111,0};
    parameter center_h = 512;
    parameter center_w = 384;
    
    reg [10:0] deltax,delta_rx;    // pixel number on current line
    reg [9:0] deltay,delta_ry;
    reg [21:0] distance;
    reg border,box_border,circle_border;
    
    always @(*) begin
        
        deltax = (hcount > (x+center_h+RADIUS)) ? (hcount-(x+center_h+RADIUS)) : ((x+center_h+RADIUS)-hcount);
        deltay = (vcount > (y+center_w+RADIUS)) ? (vcount-(y+center_w+RADIUS)) : ((y+center_w+RADIUS)-vcount);
        
        delta_rx = (hcount > center_h) ? (hcount-center_h) : (center_h-hcount);
        delta_ry = (vcount > center_w) ? (vcount-center_w) : (center_w-vcount);
        
        if(deltax*deltax+deltay*deltay <= RADIUS_SQ) begin
            pixel_value = COLOR;
        end
        else begin
            distance = delta_rx*delta_rx+delta_ry*delta_ry;
            circle_border = distance <= EXT_RADIUS_SQ + circle_error && distance >= EXT_RADIUS_SQ - circle_error;
            box_border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767 | hcount == 512 | vcount == 384);
            border = circle_border | box_border;
            pixel_value = {12{border}};
        end
    end
    
endmodule
