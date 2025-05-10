`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2025 12:43:15 PM
// Design Name: 
// Module Name: clsa_dynamic
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


module clsa_dynamic #(
    parameter SECTION_WIDTH = 32
)(
    input  wire [SECTION_WIDTH-1:0] iA,
    input  wire [SECTION_WIDTH-1:0] iB,
    input  wire                     iCin,
    output wire [SECTION_WIDTH-1:0] oSum,
    output wire                     oCout
);

    // Integer square root
    function integer int_sqrt;
        input integer val;
        integer i;
        begin
            int_sqrt = 0;
            for (i = 0; i*i <= val; i = i + 1)
                int_sqrt = i;
        end
    endfunction

    // Block size selection: try sqrt(N), fallback to sqrt(2N)
    function integer get_optimal_block_size;
        input integer section_width;
        integer sqrt1, sqrt2;
        begin
            sqrt1 = int_sqrt(section_width);
            if (section_width % sqrt1 == 0)
                get_optimal_block_size = sqrt1;
            else begin
                sqrt2 = int_sqrt(section_width * 2);
                if (section_width % sqrt2 == 0)
                    get_optimal_block_size = sqrt2;
                else begin
                    $display("ERROR: SECTION_WIDTH=%0d is not divisible by sqrt or sqrt(2N)", section_width);
                    $finish;
                end
            end
        end
    endfunction

    localparam RCA_WIDTH = get_optimal_block_size(SECTION_WIDTH);
    localparam NUM_RCA   = SECTION_WIDTH / RCA_WIDTH;

    wire [NUM_RCA:0] carry_chain;
    assign carry_chain[0] = iCin;

    genvar i;
    generate
        for (i = 0; i < NUM_RCA; i = i + 1) begin : gen_clsa_units
            wire [RCA_WIDTH-1:0] a_chunk = iA[i*RCA_WIDTH +: RCA_WIDTH];
            wire [RCA_WIDTH-1:0] b_chunk = iB[i*RCA_WIDTH +: RCA_WIDTH];
            wire [RCA_WIDTH-1:0] sum_chunk;
            wire carry_out;

            clsa_unit #(.SLICE_WIDTH(RCA_WIDTH)) u_clsa_unit (
                .iA(a_chunk),
                .iB(b_chunk),
                .iSelector(carry_chain[i]),
                .oSum(sum_chunk),
                .oCout(carry_out)
            );

            assign oSum[i*RCA_WIDTH +: RCA_WIDTH] = sum_chunk;
            assign carry_chain[i+1] = carry_out;
        end
    endgenerate

    assign oCout = carry_chain[NUM_RCA];

endmodule
