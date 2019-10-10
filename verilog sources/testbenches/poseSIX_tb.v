module poseSIX_tb;
	reg clock;
	reg validIn;
	reg reset;
	reg signed [12:0] Rx, Ry;
	wire [11:0] angle1, angle2, angle3, angle4, angle5, angle6;
	wire validOut;

	localparam [12:0] 
	ZERO = 13'b000_0000000000, 
	FIFTEEN = 13'b000_0001010101,
	NFIFTEEN = 13'b111_1110101011;

	// BETAS = 90 90 330 330 210 210
	poseSIX uut(.clock(clock),
			.validIn(validIn),
			.reset(reset),
			.Rx(Rx),.Ry(Ry),
			.angle1(angle1),
			.angle2(angle2),
			.angle3(angle3),
			.angle4(angle4),
			.angle5(angle5),
			.angle6(angle6));

	always #5 clock <= ~clock;

    initial begin
        clock = 0;
        validIn = 0;
        reset = 0;
        Rx = ZERO;
        Ry = ZERO;
        #100
        reset = 1;
        #10
        reset = 0;
        Rx = NFIFTEEN;
        Ry = FIFTEEN;
        #5
        validIn = 1;
        #5
        validIn = 0;
        #2000
        Rx = ZERO;
        Ry = ZERO;
        #10
        validIn = 1;
        #5
        validIn = 0;
    end

endmodule
