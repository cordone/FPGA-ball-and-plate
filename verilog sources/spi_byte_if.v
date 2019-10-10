`default_nettype wire
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2018 09:08:27 PM
// Design Name: 
// Module Name: spi_byte_if
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

module spi_byte_if(input clk,
               input rst,
               input SCLK,        // SPI clock
               input SS,          // SPI slave select
               input MOSI,        // SPI master out, slave in
               output MISO,       // SPI slave in, master out
               output rx_valid,    // BYTE received is valid
               output reg [7:0] rx, // BYTE received
               input [7:0] tx );  // BYTE to transmit

    // synchronize SCLK to FPGA domain clock using a two-stage shift-register
    // (bit [0] takes the hit of timing errors)
    reg [2:0] SCLKr;  always @(posedge clk) SCLKr <= { SCLKr[1:0], SCLK };
    wire SCLK_rising  = ( SCLKr[2:1] == 2'b01 );
    wire SCLK_falling = ( SCLKr[2:1] == 2'b10 );

    reg [2:0] SSr;  always @(posedge clk) SSr <= { SSr[1:0], SS };  
    wire SS_falling = ( SSr[2:1] == 2'b10 ); // message start
    wire SS_rising  = ( SSr[2:1] == 2'b01 ); // message end
    wire SS_active  = ~SSr[1];  // synchronous version of ~SS input (active LOW)
    
    reg [1:0] MOSIr;  always @(posedge clk) MOSIr <= { MOSIr[0], MOSI };
    wire MOSI_data = MOSIr[1];     // synchronous version of MOSI input
    
    reg [2:0] bit_count;  // count corresponds to bit count
    reg MISOr = 1'bx;
    
    reg rx_avail = 1'b0; // byte received?
    
    reg [7:0] SPDR;

    // next state logic 
    wire [7:0] rx_next; // Just renaming the shift register.
    assign rx_next = {SPDR[6:0], MOSI_data};
    
    // current state logic
    always @(posedge clk)
        if( rst ) begin
            bit_count <= 3'd0;
            
        end else if ( SS_active ) begin
            if ( SS_falling ) begin // Comms (re)activated, Reset counter.
                bit_count <= 3'd0;
            end
            if ( SCLK_rising ) begin // 
                bit_count <= bit_count + 3'd1;
            end
        end
            
    // transceiver logic
    always @(posedge clk) begin
        if( rst ) begin
            rx <= 8'hxx;
            rx_avail <= 1'b0;
            
        end else if ( SS_active ) begin
            if ( SS_falling ) begin // Comms (re)activated.
                rx_avail <= 1'b0;
            end 
            
            if ( SCLK_rising ) begin // Input data on rising SCLK edge.
                if ( bit_count == 3'd7 ) begin
                    rx_avail <= 1'b1; // byte received
                    rx <= rx_next; // make it available next cycle
                end else begin
                    rx_avail <= 1'b0;
                    SPDR <= rx_next;
                end
            end

            if ( SCLK_falling ) begin // Output data on falling SCLK edge.
                if ( bit_count == 3'd0 ) begin 
                    SPDR <= tx;
                    MISOr <= tx[7];
                end else begin
                    MISOr <= SPDR[7];
                end
            end
        end
    end

    assign MISO = SS_active ? MISOr : 1'bz;  // Send tx data MSB first, Tri-state when SS inactive.
    
    // Mark byte as valid for 1 cycle after available rising edge.
    reg [2:0] rx_avail_history; always @(posedge clk) rx_avail_history <= { rx_avail_history[1:0], rx_avail };  
    assign rx_valid = ( rx_avail_history[2:1] == 2'b01 );

endmodule