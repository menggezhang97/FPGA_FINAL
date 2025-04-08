`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2025 03:35:07 PM
// Design Name: 
// Module Name: carry_select_section_TB
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

module tb_carry_select_section;

    // Parameters
    parameter SECTION_WIDTH = 32;

    // DUT Inputs
    reg  [SECTION_WIDTH-1:0] iA;
    reg  [SECTION_WIDTH-1:0] iB;
    reg                      iCin;

    // DUT Outputs
    wire [SECTION_WIDTH-1:0] oSum;
    wire                     oCout;

    // Reference value
    reg  [SECTION_WIDTH:0]   expected_sum;

    // Instantiate the DUT
    carry_select_section #(
        .SECTION_WIDTH(SECTION_WIDTH)
    ) uut (
        .iA(iA),
        .iB(iB),
        .iCin(iCin),
        .oSum(oSum),
        .oCout(oCout)
    );

    integer i;
    initial begin
        $display("Starting testbench for carry_select_section...");
        
        for (i = 0; i < 100; i = i + 1) begin
            // Generate random inputs
            iA   = $random;
            iB   = $random;
            iCin = $random % 2;

            // Wait for outputs to settle
            #1;

            // Calculate expected value
            expected_sum = iA + iB + iCin;

            // Check result
            if ({oCout, oSum} !== expected_sum) begin
                $display("Test %0d FAILED!", i);
                $display("  iA     = %h", iA);
                $display("  iB     = %h", iB);
                $display("  iCin   = %b", iCin);
                $display("  oSum   = %h", oSum);
                $display("  oCout  = %b", oCout);
                $display("  Expected = %h", expected_sum);
                $stop;
            end else begin
                $display("Test %0d passed.", i);
            end
        end

        $display("All tests passed!");
        $finish;
    end

endmodule

