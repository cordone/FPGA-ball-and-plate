`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2018 03:16:37 PM
// Design Name: 
// Module Name: stage1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Compute L, M, and N. 3 clock cycle input-output latency.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stage1(
        input wire clock,
        input wire rst,
        input wire enable,
        input wire signed [8:0] lx,
        input wire signed [8:0] ly,
        input wire [7:0] lz,
        output reg [15:0] L,
        output reg [13:0] M,
        output reg signed [14:0] N,
        output reg valid
        );
                    
        parameter BETA = 90;
        //beta = 90 90 330 330 210 210
        //cos(beta) = 0 0.8660254 -0.8660254
        //sin(beta) = 1 -0.5 -0.5 
        parameter offset = 16'd13775; // s^2 - a^2 = 120^2 - 25^2 = 13775

        ///////////////////////
        // ACCEPT NEW INPUT DATA
        ///////////////////////
        // Use temporary working set to ignore values changing outside module.
        reg signed [8:0] lx0, ly0;
        reg [7:0] lz0;
        wire [15:0] L0;
        wire [13:0] M0; // 14 bits necessary to hold 50 * 256
        wire signed [14:0] N0;
        
        // PULSE-TO-LEVEL ENABLE
        reg running;
        
        always @(posedge clock) begin
            if (rst) begin
                lx0 <= 0;
                ly0 <= 0;
                lz0 <= 0;
                running <= 0;
            end else begin
                if (ready) begin
                    running <= 0;
                end else if (enable) begin
                    lx0 <= lx;
                    ly0 <= ly;
                    lz0 <= lz;
                    running <= 1;
                end
            end
        end  
        
        ///////////////////////
        // CALCULATE L
        ///////////////////////
        wire [15:0] slx, sly, slz; // 8 + 8 bits
        
        square sqX(.CLK(clock),
                    .A(lx0),
                    .B(lx0),
                    .CE(running),
                    .SCLR(rst),
                    .P(slx));
        
        square sqY(.CLK(clock),
                    .A(ly0),
                    .B(ly0),
                    .CE(running),
                    .SCLR(rst),
                    .P(sly));
                    
        // Unsigned here because lz is always non-negative.
        square_unsigned sqZ(.CLK(clock),
                            .A(lz0),
                            .B(lz0),
                            .CE(running),
                            .SCLR(rst),
                            .P(slz)); 
        
        assign L0 = (slx + sly + slz) - offset;
        
        ///////////////////////
        // CALCULATE M
        ///////////////////////
        
        // M <= 2a * lz = 50 * lz
        const_mul_m m_mul(.CLK(clock),
                        .A(lz0),
                        .CE(running),
                        .SCLR(rst),
                        .P(M0));
                
        ///////////////////////
        // CALCULATE N
        ///////////////////////
        wire signed [13:0] n1, n2;
        
        generate
            if ((BETA == 330) || (BETA == 210)) begin
               // n1 <= 2a * cos(beta) * lx
               const_mul_n n_a_mul(.CLK(clock),
                                   .A(lx0),
                                   .CE(running),
                                   .SCLR(rst),
                                   .P(n1));
               
               // n2 <= 2a * sin(beta) * ly
               const_mul_n_b n_b_mul(.CLK(clock),
                                   .A(ly0),
                                   .CE(running),
                                   .SCLR(rst),
                                   .P(n2));
               
            end else if (BETA == 90) begin
               // n1 <= 2a * cos(90) * lx = 0
               assign n1 = 0;
               // n2 <= 2a * sin(beta) * ly
               const_mul_n_b_90 n_b_mul(.CLK(clock),
                                       .A(ly0),
                                       .CE(running),
                                       .SCLR(rst),
                                       .P(n2));
            end 
        endgenerate
    
        assign N0 = (BETA == 330) ? n1 - n2 : (BETA == 90) ?  n2 : (BETA == 210) ? -n1 - n2 : 0;
  
        ///////////////////////
        // OUTPUT DATA
        ///////////////////////
        reg [1:0] counter = 0;
        wire ready;
        assign ready = (running && (counter == 3)); // 3 CLOCK CYCLE LATENCY FROM INPUT TO NEW L0, M0, N0

        // COUNTING LOGIC
        always @(posedge clock) begin
            if (rst) begin
                counter <= 0;
            end else if (running) begin
                counter <= (counter == 3) ? 0 : counter + 1;
            end  
        end
        
        // UPDATE LOGIC
        always @(posedge clock) begin
            if (rst) begin
                L <= 0;
                M <= 0;
                N <= 0;
                valid <= 0;
            end else if (ready) begin
                L <= L0;
                M <= M0;
                N <= N0;
                valid <= 1;
            end else begin
                valid <= 0;
            end
        end
   
endmodule
