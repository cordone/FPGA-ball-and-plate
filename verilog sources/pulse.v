module pulse #(DIVIDER = 65000)(
    input wire clock,
    input wire enable,
    input wire reset,
    output wire p
    );

    reg [32:0] counter;
    always @(posedge clock or posedge reset)
    begin
        if (reset) begin
            counter <= 0;
        end else if (enable) begin
            counter <= (counter == DIVIDER - 1) ? 0 : counter + 1;
        end
    end

    assign p = ((counter < DIVIDER - 1) &&  (counter >= DIVIDER - 10));

endmodule