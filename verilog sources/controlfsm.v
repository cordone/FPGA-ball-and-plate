`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2018 01:28:26 PM
// Design Name: 
// Module Name: controlFSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Toggles between manual and feedback control modes.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module controlFSM(
    input wire sysClk,
    input wire ctrlClk,
    input wire [11:0] x_joy, y_joy, x_fb, y_fb,
    input wire manual,
    output reg signed [12:0] Rx, // x-axis tilt command from controller
    output reg signed [12:0] Ry
    );
    
    wire [11:0] x, y;
    assign x = (manual) ? x_joy : x_fb;
    assign y = (manual) ? y_joy : y_fb;
    
    // Map joystick to some angle range.
    localparam [12:0] 
        FIFTEEN = 13'b000_0001010101,
        NFIFTEEN = 13'b111_1110101011,
        THIRTY = 13'b000_0010101010;
        
    // POSITION FEEDBACK CONTROLLER
    wire signed [27:0] x_p, y_p;
    assign x_p = (THIRTY) * x;
    assign y_p = (THIRTY) * y;
    
    always @(posedge sysClk) begin
        if (ctrlClk) begin
            Ry <= {x_p[27], x_p[23:12]} + NFIFTEEN; // Wired backwards.
            Rx <= FIFTEEN - {y_p[27], y_p[23:12]}; 
        end
    end
    
endmodule
