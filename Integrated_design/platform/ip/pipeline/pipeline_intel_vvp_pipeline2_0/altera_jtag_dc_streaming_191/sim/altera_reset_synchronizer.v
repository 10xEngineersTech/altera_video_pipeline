// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/25.1.1/ip/iconnect/merlin/altera_reset_controller/altera_reset_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2025/04/24 $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "wQtgtvKqJWgrzDkwk9GAB3thpTs1dbdVeXyagZEhYTY0TMU8uc8IINKw+JyOf/7B8h8x4eAHQa1nQuclXFA1+de6umTnjzgDN7g0Vp7/b+0JZRjeFjZ29eSUCyTa4mf28hxqY5qEFP2+jg3PI70fs5Wkg+PZ005d8LkvRNfNZpGJPIH6A/rnn76qg5DXUAcXqp/MHAFYqQimdC2Ohgkg3svZ3yq0mcf7iSWH62kEwyfWTOV2P4c839frnzqSSiW0dMqt1JFldYYu4dnMc3XyeFK4byIef58wJZFYnQON8fFWhy828pCgyAF2hawwhqBs1TvMvDxR26ds877ija637mxrM9eNPeU6YZHw9vuAE7s3YDhD+jSrEBElyDznpJAJsVJh/eSSA/rUZruvuo4wtMm841e0qYFE2uFTYe4i6hoqYdOTjuZ19lMhF5b06vJIPVvan5eKYzAbbrGg6rS6GVbSnx0c8zISPnpjbU8HNsQH6+diVseRLxBftrRnpvSxTm+EH0uinHYngyoy8Gh1DmympQJ7Plq8Ql7/+DP0CTttvB6HKxs0JLlyMForY2+pJYOmt/QSqksmi6U7yuEYFeRkpIuuMzeLmpTRF1EDbRv/Zqihian/mKxM2reDagM24YiW1Hu/JR3KkfxpzbkKeqXIvTODl9Z/CmqMuZBjYYcxKPvbvHScbbZ5bCcQBFzegBcwK+6CWfFFxRHSmeGf7gjuyskxKScu5fW3k+tOQlFN2ldEi8ddDduLhQ6G3QW/GYX0YEXpVzYXUF6hP+mpnhVg70RwWOI5vMhysTCU58JpwejNbEsgUCDJNpoLO30UushZGvWfnx5reZnEaGKV3dTN3HiW3exJoYfv0p38DIHvay4f3ktSz2yYX1JgfAe22KiSjTF0cWdF6ZchvGFJdpB3xcopsRUCr7k2PSPj2Ax7klZLedde2122bklXUOUQWbua6BiRYEvE1Jivhbmc/GNl7F+fsqgQUWGRW1lzCxrX/Rm3bxnpbz3OOjZsb5P5"
`endif