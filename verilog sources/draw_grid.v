`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2018 06:20:50 PM
// Design Name: 
// Module Name: draw_grid
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


module draw_grid (
    input [10:0] hcount,    // pixel number on current line
    input [9:0] vcount,     // line number
    output reg [11:0] pixel_value);
    
    localparam G_RADIUS1_SQ = 16129;
    localparam G_RADIUS2_SQ = 65025;
    localparam G_RADIUS3_SQ = 146689;
     
    localparam thick1 = 200;
    localparam thick2 = 400;
    localparam thick3 = 800;
         
    localparam center_h = 511;
    localparam center_v = 383;
     
    reg [10:0] delta_rx;    // pixel number on current line
    reg [9:0] delta_ry;
    reg [21:0] distance;
    reg image, grid, circle1, circle2, circle3;
    
    always @(*) begin
        delta_rx = (hcount > center_h) ? (hcount-center_h) : (center_h-hcount);
        delta_ry = (vcount > center_v) ? (vcount-center_v) : (center_v-vcount);
        distance = delta_rx * delta_rx + delta_ry * delta_ry;
         
        circle1 = ((distance <= G_RADIUS1_SQ + thick1) && (distance >= G_RADIUS1_SQ - thick1));
        circle2 = ((distance <= G_RADIUS2_SQ + thick2) && (distance >= G_RADIUS2_SQ - thick2));
        circle3 = ((distance <= G_RADIUS3_SQ + thick3) && (distance >= G_RADIUS3_SQ - thick3));
    
        grid = ( hcount == 0 | hcount == 127 | hcount == 255 | hcount == 383 | hcount == 511 |
         hcount == 639 | hcount == 767 | hcount == 895 | hcount == 1023 |vcount == 0 |
         vcount == 127 | vcount == 255 | vcount == 383 | vcount == 511 | vcount == 639 | vcount == 767);
        
        image = grid | circle1 | circle2 | circle3;
        pixel_value = {12{image}};
     end
     
endmodule
