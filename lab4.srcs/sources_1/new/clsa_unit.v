`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2025 08:32:14 PM
// Design Name: 
// Module Name: clsa_unit
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


module clsa_unit #(
    parameter SLICE_WIDTH = 8
)(
    input  wire [SLICE_WIDTH-1:0] iA,
    input  wire [SLICE_WIDTH-1:0] iB,
    input  wire                   iSelector,  // selector: use carry_0 path or carry_1 path
    output wire [SLICE_WIDTH-1:0] oSum,
    output wire                   oCout
);

    wire [SLICE_WIDTH-1:0] sum_0, sum_1;
    wire carry_0, carry_1;

    ripple_carry_adder_Nb #(.ADDER_WIDTH(SLICE_WIDTH)) rca0 (
        .iA(iA),
        .iB(iB),
        .iCarry(1'b0),
        .oSum(sum_0),
        .oCarry(carry_0)
    );

    ripple_carry_adder_Nb #(.ADDER_WIDTH(SLICE_WIDTH)) rca1 (
        .iA(iA),
        .iB(iB),
        .iCarry(1'b1),
        .oSum(sum_1),
        .oCarry(carry_1)
    );

    assign oSum  = (iSelector == 1'b0) ? sum_0 : sum_1;
    assign oCout = (iSelector == 1'b0) ? carry_0 : carry_1;

endmodule

