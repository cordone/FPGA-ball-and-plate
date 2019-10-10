`default_nettype wire
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Updated 8/12/2018 V2.lab5c
// Create Date: 10/1/2015 V1.0
// Design Name:
// Module Name: main
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


module main(
   input CLK100MHZ,
   input vauxp2,
   input vauxn2,
   input vauxp3,
   input vauxn3,
   input vauxp10,
   input vauxn10,
   input vauxp11,
   input vauxn11,
   input vp_in,
   input vn_in,
   input [15:0] SW,
   input BTNC, BTNU, BTNL, BTNR, BTND,
   output [3:0] VGA_R,
   output [3:0] VGA_B,
   output [3:0] VGA_G,
   input [7:0] JB, // TOUCH PANEL SPI
   output [7:0] JC, // SERVO PWM
   output VGA_HS,
   output VGA_VS,
   output LED16_B, LED16_G, LED16_R,
   output LED17_B, LED17_G, LED17_R,
   output [15:0] LED,
   output [7:0] SEG,  // segments A-G (0-6), DP (7)
   output [7:0] AN    // Display 0-7
   );

// create 25mhz system clock for 640 x 480 VGA timing - in xvga.v
//    wire clock_25mhz;
//    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));


// create 65mhz system clock for 1024 x 768 XVGA timing
    clk_wiz_0_clk_wiz clkdivider(.clk_in1(CLK100MHZ), .clk_out1(clock_65mhz));

//  instantiate 7-segment display;
    reg [31:0] data;
    wire [6:0] segments;
    display_8hex display(.clk(clock_65mhz),.data(data), .seg(segments), .strobe(AN));
    assign SEG[6:0] = segments;
    assign SEG[7] = 1'b1;

//  setup reset buttons and synchronize the switches    
    wire dBTNU, dBTNL, dBTNR, dBTND, dBTNC, rst;
    debounce dbU(.reset(0), .clock(clock_65mhz), .noisy(BTNU), .clean(dBTNU));
    debounce dbL(.reset(0), .clock(clock_65mhz), .noisy(BTNL), .clean(dBTNL));
    debounce dbR(.reset(0), .clock(clock_65mhz), .noisy(BTNR), .clean(dBTNR));
    debounce dbD(.reset(0), .clock(clock_65mhz), .noisy(BTND), .clean(dBTND));
    debounce dbC(.reset(0), .clock(clock_65mhz), .noisy(BTNC), .clean(dBTNC));
    
    assign rst = dBTNL && dBTNR;
    
    wire [15:0] SSW;
    synchronize synSW0(.clk(clock_65mhz), .in(SW[0]), .out(SSW[0]));
    synchronize synSW1(.clk(clock_65mhz), .in(SW[1]), .out(SSW[1]));
    synchronize synSW2(.clk(clock_65mhz), .in(SW[2]), .out(SSW[2]));
    synchronize synSW3(.clk(clock_65mhz), .in(SW[3]), .out(SSW[3]));
    synchronize synSW4(.clk(clock_65mhz), .in(SW[4]), .out(SSW[4]));
    synchronize synSW5(.clk(clock_65mhz), .in(SW[5]), .out(SSW[5]));
    synchronize synSW6(.clk(clock_65mhz), .in(SW[6]), .out(SSW[6]));
    synchronize synSW7(.clk(clock_65mhz), .in(SW[7]), .out(SSW[7]));
    synchronize synSW8(.clk(clock_65mhz), .in(SW[8]), .out(SSW[8]));
    synchronize synSW9(.clk(clock_65mhz), .in(SW[9]), .out(SSW[9]));
    synchronize synSW10(.clk(clock_65mhz), .in(SW[10]), .out(SSW[10]));
    synchronize synSW11(.clk(clock_65mhz), .in(SW[11]), .out(SSW[11]));
    synchronize synSW12(.clk(clock_65mhz), .in(SW[12]), .out(SSW[12]));
    synchronize synSW13(.clk(clock_65mhz), .in(SW[13]), .out(SSW[13]));
    synchronize synSW14(.clk(clock_65mhz), .in(SW[14]), .out(SSW[14]));
    synchronize synSW15(.clk(clock_65mhz), .in(SW[15]), .out(SSW[15]));

//
//////////////////////////////////////////////////////////////////////////////////
//  Initial Definitions    
    assign LED = SW;
    assign LED16_R = BTNL;                  // left button -> red led
    assign LED16_G = BTNC;                  // center button -> green led
    assign LED16_B = BTNR;                  // right button -> blue led
    assign LED17_R = BTNL;
    assign LED17_G = BTNC;
//    assign LED17_B = BTNR;


//
//////////////////////////////////////////////////////////////////////////////////
//  Touch panel SPI slave

    wire SS = JB[0];
    wire MOSI = JB[1];
    wire MISO = JB[2];
    wire SCLK = JB[3];
    wire [11:0] x_touch, y_touch;
    wire [7:0] byte3;
    wire touched;
    wire spiValid;
    
    spi_slave touch(.clk(clock_65mhz),
                    .rst(reset),
                    .SS(SS),
                    .SCLK(SCLK),
                    .MOSI(MOSI),
                    .MISO(MISO),
                    .x(x_touch),
                    .y(y_touch),
                    .touched(byte3),
                    .validOut(spiValid));
                    
    assign touched = byte3[0];
//
//////////////////////////////////////////////////////////////////////////////////
//  Joystick

    wire xadc_en;
    wire ready;
    wire [6:0] Xaddr, Yaddr;
    assign Xaddr = 8'h1b;
    assign Yaddr = 8'h1a;
    reg [6:0] address_in = 8'h1b;
    wire [15:0] xadc_data;      
    reg [11:0] x_joy, y_joy;
    
    xadc_joystick xadc (.daddr_in(address_in),
                       .dclk_in(clock_65mhz),
                       .den_in(xadc_en),
                       .di_in(0),
                       .dwe_in(0),
                       .busy_out(),
                       .vauxp10(vauxp10),
                       .vauxn10(vauxn10),
                       .vauxp11(vauxp11),
                       .vauxn11(vauxn11),
                       .vn_in(vn_in),
                       .vp_in(vp_in),
                       .alarm_out(),
                       .do_out(xadc_data),
                       .reset_in(0),
                       .eoc_out(xadc_en),
                       .eos_out(),
                       .channel_out(),
                       .drdy_out(ready));
    
    // Divide the clock by some ratio
    reg [31:0] counter;
    always @(posedge clock_65mhz or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            counter <= (counter == 65000 - 1) ? 0 : counter + 1;
        end
    end
    
    reg clk_div;    
    always @(posedge clock_65mhz or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
        end else begin
            if (counter == 65000 - 1) begin
                clk_div <= ~clk_div;
            end else begin
                clk_div <= clk_div;
            end
        end
    end
    
    // Alternate between updating X and Y.
    always @(posedge clock_65mhz or posedge rst) begin
        if (rst) begin
            x_joy <= 0;
            y_joy <= 0;
            address_in <= Xaddr;
        end else if (ready) begin
            if (clk_div) begin
                x_joy <= xadc_data[15:4] - 12'd8;
                address_in <= Yaddr;
            end else begin
                y_joy <= xadc_data[15:4] + 12'd24;
                address_in <= Xaddr;
            end
        end
    end
    
//////////////////////////////////////////////////////////////////////////////////
//  Debug inputs on 7 segment display.
    
    always @(posedge clock_65mhz) begin
        case (SSW[14])
            0 : data <= {4'b0, x_joy, 4'b0, y_joy};
            1 : data <= {3'b0, Rx, 3'b0, Ry};
        endcase
    end
//
//////////////////////////////////////////////////////////////////////////////////
//  CONTROL SYSTEM

    // Mode Toggle
    wire enable, manual;
    assign enable = SSW[15];
    assign manual = SSW[14];
    
    // 1Khz periodic pulse.
    wire ctrl_1khz;
    assign LED17_B = ctrl_1khz;

    pulse ctrlFreq(.clock(clock_65mhz),
                 .enable(enable),
                 .reset(rst),
                 .p(ctrl_1khz));
    
    wire [11:0] x_fb, y_fb;
    wire signed [12:0] Rx, Ry;    
    
    // CONTROL FSM
    controlFSM(.sysClk(clock_65mhz),
                .ctrlClk(ctrl_1khz),
                .manual(manual),
                .x_joy(x_joy),
                .y_joy(y_joy),
                .x_fb(x_fb),
                .y_fb(y_fb),
                .Rx(Rx),
                .Ry(Ry));
                
    reg [13:0] Kp, Kd;
    
    // TUNE GAINS
    always @(posedge clock_65mhz or posedge rst) begin
        if (rst) begin
            Kp <= 14'd6000;
            Kd <= 14'd4000;
        end else begin
            if (dBTNL) begin
                Kp <= SSW[13:0];
            end else if (dBTNR) begin
                Kd <= SSW[13:0];
            end
        end
    end
        
    // POSITION FEEDBACK CONTROLLER
    ball_position_controller2 FBX (.clock(clock_65mhz),
                                .slow_clock(ctrl_1khz),
                                .desired_pos(12'd2048),
                                .actual_pos(x_touch),
                                .command(x_fb),
                                .o_val());
                                
    
    ball_position_controller2 FBY (.clock(clock_65mhz),
                                .slow_clock(ctrl_1khz),
                                .desired_pos(12'd2048),
                                .actual_pos(y_touch),
                                .command(y_fb),
                                .o_val());
   
                              
    // INVERSE KINEMATICS
    wire [11:0] angle1, angle2, angle3, angle4, angle5, angle6;
    
    poseSIX invKin(.clock(clock_65mhz),
             .validIn(ctrl_1khz),
             .reset(rst),
             .Rx(Rx),
             .Ry(Ry),
             .angle1(angle1),
             .angle2(angle2),
             .angle3(angle3),
             .angle4(angle4),
             .angle5(angle5),
             .angle6(angle6));

//  
//////////////////////////////////////////////////////////////////////////////////
// PWM Output
   wire pwm1, pwm2, pwm3, pwm4, pwm5, pwm6;
   
   assign JC[0] = pwm1;
   assign JC[1] = pwm2;
   assign JC[2] = pwm3;
   assign JC[3] = pwm4;
   assign JC[4] = pwm5;
   assign JC[5] = pwm6;
   
   servoPWM #(.SERVOMIN(521), .SERVOMAX(2363), .REVERSED(0))
       servo1PWM(.clock(clock_65mhz),
       .enable(enable),
       .reset(1'b0),
       .angle(angle1),
       .pwm(pwm1));
       
   servoPWM #(.SERVOMIN(720), .SERVOMAX(2582), .REVERSED(1)) // 175, 635
       servo2PWM(.clock(clock_65mhz),
       .enable(enable),
       .reset(1'b0),
       .angle(angle2),
       .pwm(pwm2));
       
   servoPWM #(.SERVOMIN(608), .SERVOMAX(2470), .REVERSED(0))
        servo3PWM(.clock(clock_65mhz),
        .enable(enable),
        .reset(1'b0),
        .angle(angle3),
        .pwm(pwm3));
        
    servoPWM #(.SERVOMIN(548), .SERVOMAX(2345), .REVERSED(1))
        servo4PWM(.clock(clock_65mhz),
        .enable(enable),
        .reset(1'b0),
        .angle(angle4),
        .pwm(pwm4));
        
    servoPWM #(.SERVOMIN(517), .SERVOMAX(2396), .REVERSED(0))
        servo5PWM(.clock(clock_65mhz),
        .enable(enable),
        .reset(1'b0),
        .angle(angle5),
        .pwm(pwm5));
        
    servoPWM #(.SERVOMIN(617), .SERVOMAX(2463), .REVERSED(1))
        servo6PWM(.clock(clock_65mhz),
        .enable(enable),
        .reset(rst),
        .angle(angle6),
        .pwm(pwm6));
//  
//////////////////////////////////////////////////////////////////////////////////
//  sample Verilog to generate color bars or border

    wire [10:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, at_display_area;
    xvga xvga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.blank(blank));
    wire [11:0] rgb;   // rgb is 12 bits

    wire border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767 |
                   hcount == 512 | vcount == 384);
                   
    wire [23:0] pixel;
////
////  XVGA display

    reg [10:0] x_touch_disp, x_user_disp;
    reg [9:0] y_touch_disp, y_user_disp;
    wire [11:0] ball, setpoint, grid, image;
     
    // BALL POSITION
    bubble_display #(.COLOR(12'h0F0)) 
        DISPLAY_BALL(.x(x_touch_disp),
                      .y(y_touch_disp),
                      .hcount(hcount),
                      .vcount(vcount),
                      .pixel_value(ball));
                      
    // Map x reading from 0-4095 to 0-1023    
    // Map y reading from 0-4095 to 0-767
    wire [17:0] temp1 = (3 * y_touch) << 4;
    always @(posedge clock_65mhz) begin
        if (spiValid) begin
            x_touch_disp <= (touched) ? x_touch[11:2] : 11'd511;
            y_touch_disp <= (touched) ? 10'd767 - temp1[17:8] : 10'd383;
        end
    end

    // SETPOINT POSITION    
    bubble_display #(.COLOR(12'hF00))
        DISPLAY_SETPOINT(.x(x_user_disp),
                      .y(y_user_disp),
                      .hcount(hcount),
                      .vcount(vcount),
                      .pixel_value(setpoint));  
                                        
    // Map x reading from 0-4095 to 0-1023    
    // Map y reading from 0-4095 to 0-767        
    wire [17:0] temp2 = (3 * y_joy) << 4;
    always @(posedge clock_65mhz) begin
        if (ready) begin
            x_user_disp <=  x_joy[11:2];
            y_user_disp <=  10'd767 - temp2[17:8];
        end
    end
    
    // BACKGROUND GRID             
    draw_grid DISPLAY_GRID(.hcount(hcount),
                    .vcount(vcount),
                    .pixel_value(grid));
    
    // Lump together into a single image.           
    assign image = grid | ball | setpoint;  
    
    assign rgb = {12{image}}; // : {{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};
//
//////////////////////////////////////////////////////////////////////////////////
// the following lines are required for the Nexys4 VGA circuit
    assign VGA_R = ~blank ? rgb[11:8]: 0;
    assign VGA_G = ~blank ? rgb[7:4] : 0;
    assign VGA_B = ~blank ? rgb[3:0] : 0;

    synchronize syn1 (.clk(clock_65mhz), .in(hsync), .out(hsync2));
    synchronize syn2 (.clk(clock_65mhz), .in(vsync), .out(vsync2));

    assign VGA_HS = ~hsync2;
    assign VGA_VS = ~vsync2;

endmodule

module synchronize #(parameter NSYNC = 3)  // number of sync flops.  must be >= 2
                   (input wire clk, in,
                    output reg out);

  reg [NSYNC-2:0] sync;

  always @ (posedge clk)
  begin
    {out, sync} <= {sync[NSYNC-2:0], in};
  end
endmodule
