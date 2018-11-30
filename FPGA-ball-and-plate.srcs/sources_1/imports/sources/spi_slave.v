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
                  output reg touched
                  ); 
						
   wire rx_valid;
   wire [7:0] rx, tx;
   
   wire dataValid;
   reg [2:0] bytesRead; // 0...4
   reg [31:0] data;
       
   // bits <> bytes
   spi_byte_if spi( .clk(clk),
                .rst(rst),
                .SCLK    (SCLK),
                .MOSI    (MOSI),
                .SS      (SS),
                .MISO    (MISO),
                .rx_valid (rx_valid),
                .rx      (rx),
                .tx      (8'hAA)
                );
	
	always @(posedge clk) begin
	   if ( rst ) begin
	       data <= 0;
	       bytesRead <= 0;
	   end else if ( rx_valid ) begin
	       data <= {rx, data[23:0]};
	       bytesRead <= bytesRead + 1;
	       if ( bytesRead == 3'h4 ) begin
	           bytesRead <= 0;
	       end
	   end
	end
	
    assign dataValid = ( bytesRead == 3'h4 );
    
    // Partition the data
    always @(posedge clk) begin
        if ( dataValid ) begin
            x <= data[31:20];
            y <= data[19:8];
            touched <= data[0];
        end
    end

endmodule