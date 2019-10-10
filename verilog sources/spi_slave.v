`default_nettype wire
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2018 09:08:27 PM
// Design Name: 
// Module Name: spi_slave
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

// for SPI MODE 3
module spi_slave( input clk,            // FPGA system clock (must be several times faster as SCLK, e.g. 50MHz)
                  input rst,            // FPGA user reset button
                  input SS,             // SPI slave select
                  input SCLK,           // SPI clock (e.g. 1 MHz)
                  input MOSI,           // SPI master out, slave in
                  output MISO,          // SPI master in, slave out
                  output reg [11:0] x, y,
                  output reg [7:0] touched,
                  output validOut
                  ); 
						
   wire rx_valid;
   wire [7:0] rx;
   reg [7:0] tx;
   
   reg [31:0] dataIn;
   reg [31:0] dataOut = 32'hBA11C0DE;

   reg [1:0] byteCount = 2'b0; // 0...3

   // bits <> bytes
   spi_byte_if spi( .clk(clk),
                .rst(rst),
                .SCLK    (SCLK),
                .MOSI    (MOSI),
                .SS      (SS),
                .MISO    (MISO),
                .rx_valid (rx_valid),
                .rx      (rx),
                .tx      (tx)
                );
	
	always @(posedge clk) begin
	   if ( rst ) begin
	       dataIn <= 0;
	       byteCount <= 0;
	   end else begin
	       if ( rx_valid ) begin
               dataIn <= { rx, dataIn[31:8] };
               byteCount <= byteCount + 1;
           end	       
	   end
	end
	
  assign validOut = ( byteCount == 2'b0 );
  
  // Partition the data
  always @(posedge clk) begin
      if ( validOut ) begin
          x <= dataIn[31:20];
          y <= dataIn[19:8];
          touched <= dataIn[7:0];
      end
  end
  
  always @(posedge clk) begin
      case ( byteCount )
          default : tx <= dataOut[7:0];
          2'b01 : tx <= dataOut[15:8];
          2'b10 : tx <= dataOut[23:16];
          2'b11 : tx <= dataOut[31:24];
      endcase
  end

endmodule