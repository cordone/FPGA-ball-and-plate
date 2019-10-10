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
    input ctrl_clock,
    input [11:0] desired_pos,
    input [11:0] actual_pos,
    output reg [11:0] angle,
    output reg valid
    );
    //0.159154943
    //parameters for lqr control
//    parameter freq = 1000; //clock freq of 1kHz
//    parameter k_1 = 326; //1*(2^10 / pi)
//    parameter k_2 = 326;
//    parameter k_r = 326;
    parameter angle_offset = 0;
    
    //prepare registers
    //reg [12:0] prev_pos = 12'd2048;
    //reg signed [11:0] delta_pos = 0;
    //reg signed [24:0] velocity = 0;
    
    //wires for multiplications
    wire [22:0] kpos, kr;
    wire signed [24:0] out;
    
    //counter to seperate multiplication
    //reg [1:0] quarter_divider = 0;
    wire done;
    reg [1:0] counter;
    reg enable; 
       
    //mult_vel kvel_calc (.CLK(clock),.A(delta_pos),.P(kvel)); // delta_pos * freq = 1000 * k_2 = 326
    mult_gen_0 kpos_calc (.CLK(clock),.A(actual_pos),.CE(enable),.P(kpos)); // actual_pos * k_1 = 326
    mult_gen_0 kr_calc (.CLK(clock),.A(desired_pos),.CE(enable),.P(kr)); // desired_pos * k_3 = 326
    
    always @(posedge clock) begin
        if (done) begin
            enable <= 0;
        end else if (ctrl_clock && ~enable) begin
            enable <= 1;
        end
    end
        
    always @(posedge clock) begin
        if (ctrl_clock || done) begin
            counter <= 0;
        end else begin
            counter <= (counter == 3) ? 0 : counter + 1;
        end
    end
    
    assign done = (counter == 3);
    assign out = kpos - kr;
    
    always @(posedge clock) angle <= out[23:12] + 12'd2048;
    always @(posedge clock) valid <= done;
    
endmodule
