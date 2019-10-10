`timescale 1ns / 1ps

module ball_position_controller_tb;
	reg clock, enable;
	reg [11:0] actual, desired;
	wire [11:0] out;
	wire valid;
	
    ball_position_controller2 uut(.clock(clock),
                                .slow_clock(enable),
                                .desired_pos(desired),
                                .actual_pos(actual),
                                .command(out),
                                .o_val(valid));
	    
    always #10 clock <= ~clock;
    
    initial begin
        clock = 0;
        enable = 0;
        actual = 0;
        desired = 0;
        #50
        enable = 1;
        #5
        enable = 0;
        #50        
        actual = 12'd1314;
        desired = 12'd2048;
        #5
        enable = 1;
        #5
        enable = 0;
    end

endmodule
