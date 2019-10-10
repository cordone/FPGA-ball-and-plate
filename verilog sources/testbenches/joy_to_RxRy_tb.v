`timescale 1ns / 1ps

module joy_to_RxRy_tb;
    reg clock;
    reg [11:0] x_joy, y_joy;
                 
    // CONTROL FSM
    localparam [12:0] 
        FIFTEEN = 13'b000_0001010101,
        NFIFTEEN = 13'b111_1110101011,
        THIRTY = 13'b000_0010101010;
        
    // POSITION FEEDBACK CONTROLLER
    reg signed [12:0] Rx, Ry;    
    wire signed [27:0] x_p, y_p;
    assign x_p = (THIRTY) * x_joy;
    assign y_p = (THIRTY) * y_joy;
    
    always @(posedge clock) begin
        Rx <= {x_p[27], x_p[23:12]} + NFIFTEEN;
        Ry <= {y_p[27], y_p[23:12]} + NFIFTEEN; 
    end
    
    always #10 clock <= ~clock;
    
    initial begin
        clock = 0;
        x_joy = 0;
        y_joy = 0;
        #50
        x_joy = 12'd4095;
        y_joy = 12'd0;
    end

endmodule
