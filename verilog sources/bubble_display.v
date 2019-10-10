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


module bubble_display #(parameter RADIUS = 2, RADIUS_SQ = 4, COLOR = 12'hF00)(
    input [10:0] x,
    input [9:0] y,
    input [10:0] hcount,    // pixel number on current line
    input [9:0] vcount,     // line number
    output reg [11:0] pixel_value
    );
        
    reg [10:0] delta_x;   // pixel number on current line
    reg [9:0] delta_y;
        
    always @(*) begin
        delta_x = (hcount > (x+RADIUS)) ? (hcount-(x+RADIUS)) : ((x+RADIUS)-hcount);
        delta_y = (vcount > (y+RADIUS)) ? (vcount-(y+RADIUS)) : ((y+RADIUS)-vcount);
        
        if( delta_x * delta_x + delta_y * delta_y <= RADIUS_SQ ) begin
            pixel_value = COLOR;
        end else begin
            pixel_value = 0;
        end
    end
    
endmodule
