`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2018 05:09:53 PM
// Design Name: 
// Module Name: angle_tb
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


module angle_tb;
    reg clock, validIn, reset;
    reg signed [8:0] lx90, lx330, lx210, ly90, ly330, ly210, lz90, lz330, lz210;
    wire [11:0] angle90, angle210, angle330;
    wire valid90, valid210, valid330;

    servo_angle_gen #(.BETA(90)) uut_90(.clock(clock),
                                        .validIn(validIn),
                                        .reset(reset),
                                        .lx(lx90),
                                        .ly(ly90),
                                        .lz(lz90),
                                        .angle(angle90),
                                        .validOut(valid90));

    servo_angle_gen #(.BETA(210)) uut_210(.clock(clock),
                                        .validIn(validIn),
                                        .reset(reset),
                                        .lx(lx210),
                                        .ly(ly210),
                                        .lz(lz210),
                                        .angle(angle210),
                                        .validOut(valid210));

    servo_angle_gen #(.BETA(330)) uut_330(.clock(clock),
                                        .validIn(validIn),
                                        .reset(reset),
                                        .lx(lx330),
                                        .ly(ly330),
                                        .lz(lz330),
                                        .angle(angle330),
                                        .validOut(valid330));
    
    always #5 clock <= ~clock;
    
    initial begin
        validIn = 0;
        reset = 0;
        clock = 0;
        #5;
        // LOAD VALUES
        lx90 = -9'd9;
        ly90 = -9'd34;
        lz90 = 9'd117;
        lx330 = -9'd24;
        ly330 = 9'd26;
        lz330 = 9'd117;        
        lx210 = 9'd34;
        ly210 = 9'd9;
        lz210 = 9'd117;
        #10;
        // RESET STAGE
        reset = 1;
        #5
        reset = 0;
        #5
        // PULSE validIn
        validIn = 1;
        #3;
        validIn = 0;
        #10;
        clock = 0;
        #500;     
    end
    
endmodule
