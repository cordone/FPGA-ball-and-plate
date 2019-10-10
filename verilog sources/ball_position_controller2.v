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


module ball_position_controller2(
    input clock,
    input slow_clock,
    input [11:0] desired_pos,
    input [11:0] actual_pos,
    output wire [11:0] command,
    output reg o_val
    );
    //0.159154943
    //parameters for lqr control
//    parameter freq = 1000; //clock freq of 1kHz
//    parameter k_1 = 326; //1*(2^10 / pi)
//    parameter k_2 = 326;
//    parameter k_r = 326;
    parameter angle_offset = 0;
    
    //prepare registers
    reg [12:0] prev_pos = 12'd2048;
    reg signed [11:0] delta_pos = 0;
    reg signed [24:0] velocity = 0;
    
    //wires for multiplications
    wire [23:0] kpos, kr;
    wire signed [24:0] s_kpos, s_kr;
    wire signed [31:0] kvel;
    reg signed [33:0] out;
    reg signed [12:0] tmp;
    
    //counter to seperate multiplication
    //reg [1:0] quarter_divider = 0;
    reg begin_mul = 0;
    vel_mult kvel_calc (.CLK(clock),.A(delta_pos),.CE(begin_mul),.P(kvel)); // delta_pos * freq = 1000 * k_2 = 326

    mult_gen_0 kpos_calc (.CLK(clock),.A(actual_pos),.CE(begin_mul),.P(kpos)); // actual_pos * k_1 = 326
    mult_gen_0 kr_calc (.CLK(clock),.A(desired_pos),.CE(begin_mul),.P(kr)); // desired_pos * k_3 = 326
    
    reg [2:0] counter = 0;
    
    always @(posedge clock) begin
        case(counter)
            3'b000: begin
                if(slow_clock) begin
                    counter <= 3'b001;
                    prev_pos <= actual_pos;
                    delta_pos <= actual_pos - prev_pos;
                    begin_mul <= 1;
                    o_val <= 0;
                end
                else begin_mul <= 0;
            end
            3'b100: begin
                counter <= counter + 1;
                out <= s_kr - s_kpos - kvel;
            end
            3'b101: begin
                tmp = {out[33:12]};
                counter <= 3'b000;
                o_val <= 1;
            end
            default: counter <= counter + 1;
        endcase
    end
    assign command = tmp + 13'd2048;
    assign s_kpos = {1'b0,kpos};
    assign s_kr = {1'b0,kr};
endmodule
