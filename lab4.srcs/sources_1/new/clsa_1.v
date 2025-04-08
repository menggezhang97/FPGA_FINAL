//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2025 08:14:09 PM
// Design Name: 
// Module Name: clsa_1
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

`timescale 1ns / 1ps

module clsa_1 #(
    parameter SECTION_WIDTH = 32  // Must be 32 for 4x8 config
)(
    input  wire [SECTION_WIDTH-1:0] iA,
    input  wire [SECTION_WIDTH-1:0] iB,
    input  wire                     iCin,
    output wire [SECTION_WIDTH-1:0] oSum,
    output wire                     oCout
);

    // Fix RCA width and number of segments
    localparam RCA_WIDTH = 8;
    localparam NUM_RCA   = 4;

    wire [SECTION_WIDTH-1:0] sum_0;
    wire [SECTION_WIDTH-1:0] sum_1;
    wire [NUM_RCA:0] carry_0;
    wire [NUM_RCA:0] carry_1;
    
    assign carry_0[0] = 1'b0;
    assign carry_1[0] = 1'b1;

    genvar i;
    generate
        for (i = 0; i < NUM_RCA; i = i + 1) begin : clsa_loop
            localparam SLICE_WIDTH = RCA_WIDTH;

            wire [SLICE_WIDTH-1:0] a_chunk = iA[i*RCA_WIDTH +: SLICE_WIDTH];
            wire [SLICE_WIDTH-1:0] b_chunk = iB[i*RCA_WIDTH +: SLICE_WIDTH];

            wire [SLICE_WIDTH-1:0] s0, s1;
            wire c0, c1;

            ripple_carry_adder_Nb #(.ADDER_WIDTH(SLICE_WIDTH)) rca0 (
                .iA(a_chunk),
                .iB(b_chunk),
                .iCarry(carry_0[i]),
                .oSum(s0),
                .oCarry(c0)
            );

            ripple_carry_adder_Nb #(.ADDER_WIDTH(SLICE_WIDTH)) rca1 (
                .iA(a_chunk),
                .iB(b_chunk),
                .iCarry(carry_1[i]),
                .oSum(s1),
                .oCarry(c1)
            );

            assign sum_0[i*RCA_WIDTH +: SLICE_WIDTH] = s0;
            assign sum_1[i*RCA_WIDTH +: SLICE_WIDTH] = s1;
            assign carry_0[i+1] = c0;
            assign carry_1[i+1] = c1;
        end
    endgenerate

    assign oSum  = (iCin == 1'b0) ? sum_0 : sum_1;
    assign oCout = (iCin == 1'b0) ? carry_0[NUM_RCA] : carry_1[NUM_RCA];

endmodule

