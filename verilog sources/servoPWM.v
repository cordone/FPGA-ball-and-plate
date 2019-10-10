`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: servoPWM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Produces PWM signal according to 12-bit angle command.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module servoPWM(
    input wire clock,
    input wire enable,
    input wire reset,
    input wire [11:0] angle,
    output wire pwm
    );

//    parameter SERVOMIN = 150; // aka 0
//    parameter SERVOMAX = 550; // aka 180 
//    localparam DIVIDER = 265; // 4096 ticks per ~60Hz period
 
    // By default, one PWM period is 4096 ticks.
    // Alternatively, you can use exact milliseconds by changing DIVIDER and tickCounter appropriately.
    // Calibrating may be easier one way or the other.

    parameter SERVOMIN = 500; // (us)
    parameter SERVOMAX = 2600; // (us)
    localparam DIVIDER = 65; // Set to achieve 1MHz (1us)
    parameter REVERSED = 0; // Does the servo horn swing around the left?

    // Rescale the angle command into the proper range.
    wire [11:0] command, reverse_command;
    wire [32:0] prod;
    assign prod = (SERVOMAX - SERVOMIN) * angle;
    assign command = SERVOMIN + (prod >> 12);
    assign reverse_command = SERVOMAX - (prod >> 12);

    // COUNT CLOCK CYCLES
    reg [13:0] counter;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else if (enable) begin
            if (counter == DIVIDER - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
    
    // COUNT PWM PERIOD
//    reg [11:0] tickCounter;
    reg [13:0] tickCounter; // Default period is 16384 us, but it could be anything between 40-200Hz.
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            tickCounter <= 0;
        end else if (enable) begin
            if (counter == DIVIDER - 1) begin 
                tickCounter <= tickCounter + 1;
            end
        end
    end

    assign pwm = (REVERSED) ? (tickCounter < reverse_command) : (tickCounter < command);

endmodule