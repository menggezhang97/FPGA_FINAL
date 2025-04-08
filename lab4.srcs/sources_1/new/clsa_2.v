`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2025 08:10:12 PM
// Design Name: 
// Module Name: clsa_2
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


module clsa_2 #(
    parameter SECTION_WIDTH = 32  // Must be 32 for 2+5*6
)(
    input  wire [SECTION_WIDTH-1:0] iA,
    input  wire [SECTION_WIDTH-1:0] iB,
    input  wire                     iCin,
    output wire [SECTION_WIDTH-1:0] oSum,
    output wire                     oCout
);

    wire [6:0] carry;  // 6 boundaries, carry[0] = iCin, carry[6] = oCout
    assign carry[0] = iCin;

    // Slice 0: 2-bit RCA
    clsa_unit #(.SLICE_WIDTH(2)) unit0 (
        .iA(iA[1:0]),
        .iB(iB[1:0]),
        .iSelector(carry[0]),
        .oSum(oSum[1:0]),
        .oCout(carry[1])
    );

    // Slice 1: 6-bit RCA
    clsa_unit #(.SLICE_WIDTH(6)) unit1 (
        .iA(iA[7:2]),
        .iB(iB[7:2]),
        .iSelector(carry[1]),
        .oSum(oSum[7:2]),
        .oCout(carry[2])
    );

    // Slice 2
    clsa_unit #(.SLICE_WIDTH(6)) unit2 (
        .iA(iA[13:8]),
        .iB(iB[13:8]),
        .iSelector(carry[2]),
        .oSum(oSum[13:8]),
        .oCout(carry[3])
    );

    // Slice 3
    clsa_unit #(.SLICE_WIDTH(6)) unit3 (
        .iA(iA[19:14]),
        .iB(iB[19:14]),
        .iSelector(carry[3]),
        .oSum(oSum[19:14]),
        .oCout(carry[4])
    );

    // Slice 4
    clsa_unit #(.SLICE_WIDTH(6)) unit4 (
        .iA(iA[25:20]),
        .iB(iB[25:20]),
        .iSelector(carry[4]),
        .oSum(oSum[25:20]),
        .oCout(carry[5])
    );

    // Slice 5
    clsa_unit #(.SLICE_WIDTH(6)) unit5 (
        .iA(iA[31:26]),
        .iB(iB[31:26]),
        .iSelector(carry[5]),
        .oSum(oSum[31:26]),
        .oCout(carry[6])
    );

    assign oCout = carry[6];

endmodule
