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








`timescale 1 ns / 1 ns

module altera_reset_controller
#(
    parameter NUM_RESET_INPUTS              = 6,
    parameter USE_RESET_REQUEST_IN0 = 0,
    parameter USE_RESET_REQUEST_IN1 = 0,
    parameter USE_RESET_REQUEST_IN2 = 0,
    parameter USE_RESET_REQUEST_IN3 = 0,
    parameter USE_RESET_REQUEST_IN4 = 0,
    parameter USE_RESET_REQUEST_IN5 = 0,
    parameter USE_RESET_REQUEST_IN6 = 0,
    parameter USE_RESET_REQUEST_IN7 = 0,
    parameter USE_RESET_REQUEST_IN8 = 0,
    parameter USE_RESET_REQUEST_IN9 = 0,
    parameter USE_RESET_REQUEST_IN10 = 0,
    parameter USE_RESET_REQUEST_IN11 = 0,
    parameter USE_RESET_REQUEST_IN12 = 0,
    parameter USE_RESET_REQUEST_IN13 = 0,
    parameter USE_RESET_REQUEST_IN14 = 0,
    parameter USE_RESET_REQUEST_IN15 = 0,
    parameter OUTPUT_RESET_SYNC_EDGES       = "deassert",
    parameter SYNC_DEPTH                    = 2,
    parameter RESET_REQUEST_PRESENT         = 0,
    parameter RESET_REQ_WAIT_TIME           = 3,
    parameter MIN_RST_ASSERTION_TIME        = 11,
    parameter RESET_REQ_EARLY_DSRT_TIME     = 4,
    parameter ADAPT_RESET_REQUEST          = 0
)
(
    input reset_in0,
    input reset_in1,
    input reset_in2,
    input reset_in3,
    input reset_in4,
    input reset_in5,
    input reset_in6,
    input reset_in7,
    input reset_in8,
    input reset_in9,
    input reset_in10,
    input reset_in11,
    input reset_in12,
    input reset_in13,
    input reset_in14,
    input reset_in15,
    input reset_req_in0,
    input reset_req_in1,
    input reset_req_in2,
    input reset_req_in3,
    input reset_req_in4,
    input reset_req_in5,
    input reset_req_in6,
    input reset_req_in7,
    input reset_req_in8,
    input reset_req_in9,
    input reset_req_in10,
    input reset_req_in11,
    input reset_req_in12,
    input reset_req_in13,
    input reset_req_in14,
    input reset_req_in15,


    input  clk,
    output reg reset_out,
    output reg reset_req
);

   localparam ASYNC_RESET = (OUTPUT_RESET_SYNC_EDGES == "deassert");

   localparam MIN_METASTABLE = 3;
   localparam RSTREQ_ASRT_SYNC_TAP = MIN_METASTABLE + RESET_REQ_WAIT_TIME;

   localparam LARGER = RESET_REQ_WAIT_TIME > RESET_REQ_EARLY_DSRT_TIME ? RESET_REQ_WAIT_TIME : RESET_REQ_EARLY_DSRT_TIME;

   localparam ASSERTION_CHAIN_LENGTH =  (MIN_METASTABLE > LARGER) ? 
                                            MIN_RST_ASSERTION_TIME + 1 :
                                        (
                                        (MIN_RST_ASSERTION_TIME > LARGER)? 
                                            MIN_RST_ASSERTION_TIME + (LARGER - MIN_METASTABLE + 1) + 1 :
                                            MIN_RST_ASSERTION_TIME + RESET_REQ_EARLY_DSRT_TIME + RESET_REQ_WAIT_TIME - MIN_METASTABLE + 2
                                        );

   localparam RESET_REQ_DRST_TAP = RESET_REQ_EARLY_DSRT_TIME + 1;

   wire merged_reset;
   wire merged_reset_req_in;
   wire reset_out_pre;
   wire reset_req_pre;

   (*preserve*) reg  [RSTREQ_ASRT_SYNC_TAP: 0]  altera_reset_synchronizer_int_chain;
   reg [ASSERTION_CHAIN_LENGTH-1: 0]            r_sync_rst_chain;
   reg                                          r_sync_rst;
   reg                                          r_early_rst;

    assign merged_reset = (  
                              reset_in0 | 
                              reset_in1 | 
                              reset_in2 | 
                              reset_in3 | 
                              reset_in4 | 
                              reset_in5 | 
                              reset_in6 | 
                              reset_in7 | 
                              reset_in8 | 
                              reset_in9 | 
                              reset_in10 | 
                              reset_in11 | 
                              reset_in12 | 
                              reset_in13 | 
                              reset_in14 | 
                              reset_in15
                          );

    assign merged_reset_req_in = (
                              ( (USE_RESET_REQUEST_IN0 == 1) ? reset_req_in0 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN1 == 1) ? reset_req_in1 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN2 == 1) ? reset_req_in2 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN3 == 1) ? reset_req_in3 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN4 == 1) ? reset_req_in4 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN5 == 1) ? reset_req_in5 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN6 == 1) ? reset_req_in6 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN7 == 1) ? reset_req_in7 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN8 == 1) ? reset_req_in8 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN9 == 1) ? reset_req_in9 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN10 == 1) ? reset_req_in10 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN11 == 1) ? reset_req_in11 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN12 == 1) ? reset_req_in12 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN13 == 1) ? reset_req_in13 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN14 == 1) ? reset_req_in14 : 1'b0)  |
                              ( (USE_RESET_REQUEST_IN15 == 1) ? reset_req_in15 : 1'b0) 
                            );


    generate if (OUTPUT_RESET_SYNC_EDGES == "none" && (RESET_REQUEST_PRESENT==0)) begin

        assign reset_out_pre = merged_reset;
        assign reset_req_pre = merged_reset_req_in;

    end else begin

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH),
            .ASYNC_RESET(RESET_REQUEST_PRESENT? 1'b1 : ASYNC_RESET)
        )
        alt_rst_sync_uq1
        (
            .clk        (clk),
            .reset_in   (merged_reset),
            .reset_out  (reset_out_pre)
        );

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH),
            .ASYNC_RESET(0)
        )
        alt_rst_req_sync_uq1
        (
            .clk        (clk),
            .reset_in   (merged_reset_req_in),
            .reset_out  (reset_req_pre)
        );

    end
    endgenerate

    generate if ( ( (RESET_REQUEST_PRESENT == 0) && (ADAPT_RESET_REQUEST==0) )|
                  ( (ADAPT_RESET_REQUEST == 1) && (OUTPUT_RESET_SYNC_EDGES != "deassert") ) ) begin
        always @* begin
            reset_out = reset_out_pre;
            reset_req = reset_req_pre;
        end
    end else if ( (RESET_REQUEST_PRESENT == 0) && (ADAPT_RESET_REQUEST==1) ) begin

        wire reset_out_pre2;

        altera_reset_synchronizer
        #(
            .DEPTH      (SYNC_DEPTH+1),
            .ASYNC_RESET(0)
        )
        alt_rst_sync_uq2
        (
            .clk        (clk),
            .reset_in   (reset_out_pre),
            .reset_out  (reset_out_pre2)
        );

        always @* begin
            reset_out = reset_out_pre2;
            reset_req = reset_req_pre;
        end

    end
    else begin

    // synthesis translate_off
    initial
    begin
        altera_reset_synchronizer_int_chain <= {RSTREQ_ASRT_SYNC_TAP{1'b1}};
    end

    initial
    begin
        r_sync_rst_chain <= {ASSERTION_CHAIN_LENGTH{1'b1}};
    end
    // synthesis translate_on

    always @(posedge clk)
    begin
        altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP:0] <= 
            {altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP-1:0], reset_out_pre}; 
    end

    always @(posedge clk)
    begin
        if (altera_reset_synchronizer_int_chain[MIN_METASTABLE-1] == 1'b1)
        begin
            r_sync_rst_chain <= {ASSERTION_CHAIN_LENGTH{1'b1}};
    end
    else
    begin
        r_sync_rst_chain <= {1'b0, r_sync_rst_chain[ASSERTION_CHAIN_LENGTH-1:1]};
    end
    end


    always @(posedge clk)
    begin
        case ({altera_reset_synchronizer_int_chain[RSTREQ_ASRT_SYNC_TAP], r_sync_rst_chain[1], r_sync_rst})
            3'b000:   r_sync_rst <= 1'b0; 
            3'b001:   r_sync_rst <= 1'b0;
            3'b010:   r_sync_rst <= 1'b0;
            3'b011:   r_sync_rst <= 1'b1;
            3'b100:   r_sync_rst <= 1'b1; 
            3'b101:   r_sync_rst <= 1'b1;
            3'b110:   r_sync_rst <= 1'b1;
            3'b111:   r_sync_rst <= 1'b1; 
            default:  r_sync_rst <= 1'b1;
        endcase

        case ({r_sync_rst_chain[1], r_sync_rst_chain[RESET_REQ_DRST_TAP] | reset_req_pre})
            2'b00:   r_early_rst <= 1'b0; 
            2'b01:   r_early_rst <= 1'b1; 
            2'b10:   r_early_rst <= 1'b0; 
            2'b11:   r_early_rst <= 1'b1; 
            default: r_early_rst <= 1'b1;
        endcase
    end

    always @* begin
        reset_out = r_sync_rst;
        reset_req = r_early_rst;
    end

    end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1FjQ5TwTkkYxaDN9I9CSPzuDTd87Wnu0FwZHNbtwNNuU3y829+BCYy2eudOAj1LWYek3IiZRMRvE61afAkXZzSUJjtlCTKElF7lmX5q6u3zedoC9dYFN1+Rt02eFjYzM9Bzt/+NtaFeknqOY6CycMNjwwcturqyn7znp12BJqJJH51UHxUijPYYyq3gGxCHQTMgvzTMZJdTVrGOoUivoFsuhS2AnfhiPAfJ9AH9UGEV//IIA3dEeQlfx4uN+B0dpHY8ynv3gWDslyARveYyWKPYt7f9Bbm+In6XhtNJzGB4NgK1r587QyTYEFe5iBrf4t7Yp01VB1dnCKf1sRIHep3Mm6CVw3Uy1C//6M43ZMLxNNHMZU7kYSP/OOp1jkUBJY/AzWYIg+UgIwtNBFY4KM3gR9ftS54h7uG/m3Sfxo4VTVLu+a1HIQSd88DkCRAnqUdKgWd/tEACVq2s1AZLMz6erv7a3TMGu9nyXITksC8zZBIVZyFBNEpDPRaVBN8WZLTvsPYe6BozsaSm8mxdVF5tLRUBg98Zsw3j8t/p5JBLWWSLtTqaXM+7GKkRQuw5DWz76iz9X8UlCxLe1J26xrbt+NYdV3hxVvj9enTfoljNeAYy9z1DB4yKDAVS09NG2cy21sAnZQ3+5zrgl+xcfW1XHFwAuKz94Hral9cNZZx7XBLlp0GzQlkflbPl6bM0Pjkeqf7oxH6Cog7iOqPAMpqQCaCwiOVNFvcZPQW3EBvyrS9hnp+SuQz95h1PkELOMA6xGO89XouFv5/aGb9tOkCM0"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwLCM0fCn049H9Gm4HAT4oET3BMxj4toWoTTyWoHANPQ3tLFZyV/X8jmk88f9Gdw2CdxWRFdaBmOy1PSAIAOY0H4WSuZ9QJZJ8mrZEVahSj3BOP+MSv1cX9lseOK3hlu8MG7fXF+JsGh9aLKv5uGcmhRYd7YHmaDyOfTFv8ZdnvEQuzHHCneL2MISwJhRnexf5SJhKJPGjvo842uRaQiQshSgri7Nrk7WENaIu/OfqTvcyEk/GGFpsdUDvpq8VJRe4g+Nh9YPRESic5Mud9ZrHuHDOBiIc8PyleGAm+w2Pk5TUnlMTFqXKWJ+nL3nPPsq1/VKHY0TcLgbmacGpVpydzTfJyu9AXxQfjk75OByBQZVOhBDWLckp62f09gq+ujgClIDDxdGlPuU8FNllFg0irS1zn/tf2RogrQTmfhwDFM0gmEVYZ5ikglOFmaJi60GWQFYyDaSP/qnavvzYHNzQUEg1B9+/O1NVXsACBV7nv6Jz6lppCL0Hv2kgWaS0B7H8rDWu9WqV9c1uISvjIvPMXMtTgMJF1hr0MNHnmnakb5p077dkvqvNczgZrrwxXJOxBpRGhEOcmofrJ2Rm9xAZNJPKh17QhHx82DHTbmCJIck/NcUfghQum9NnVigRROOptXV411qNHgzreK4/f4PhwnErp3CdlJ2ecusV4rNV4LeACpFpxVbxgz0ijxp7b75UZ6ufehQzsfs9KNSyg9XcECCcz5MfXx2NnLaF4pTyhvi7KFKcJpUtLjdo3pzFYwwxp/HXLiDkVov+9wLNJnv+mZ"
`endif