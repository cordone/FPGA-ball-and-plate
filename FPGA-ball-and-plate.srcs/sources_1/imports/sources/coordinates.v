`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2018 04:50:13 PM
// Design Name: 
// Module Name: coordinates
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

module coordinates(
    input clk,
    input rst,
    input serialIn, // MCU TX or MOSI
    input serialClk,
    output reg [11:0] x, y, // coordinates
    output reg touched, // object detected on plate
    output dataValid // current values from same sample
    );
    
    reg [2:0] bitCount; // 0...7
    reg [1:0] bytesRead; // 0...3
    reg [31:0] data;
    
    //Look for 1 ? 0 transition for the beginning of start bit. 
    //If sampling at 16x, the middle of the start bit should be 8 sampling clocks from the falling edge. 
    //Each subsequent data bit can then be sampled every 16th rising clock edge. 
    //Check format (start, data, parity, stop bits) before accepting data.
        
    // Shift data in
	always @(posedge clk) begin
        if ( rst ) begin
            touched <= 0;
            bitCount <= 0;
            bytesRead <= 0;
            
        end else if ( serialClk ) begin
            data <= {serialIn, data[30:0]}; // Shift in LSB-first.
            bitCount <= bitCount + 1;
            if ( bitCount == 3'h7 ) begin
                bytesRead <= bytesRead + 1; 
                bitCount <= 0;
            end
        end
    end
   
    // Data becomes valid once we've read all the 32 bits.
    assign dataValid = ( bytesRead == 2'h3 && bitCount == 3'h7 );
    
    // Partition the data
    always @(posedge clk) begin
        if ( dataValid ) begin
            x <= data[31:20];
            y <= data[19:8];
            touched <= data[0];
        end
    end
endmodule
