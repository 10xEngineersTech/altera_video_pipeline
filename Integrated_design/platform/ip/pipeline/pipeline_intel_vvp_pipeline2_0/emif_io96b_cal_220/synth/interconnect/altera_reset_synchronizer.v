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

    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

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
`pragma questa_oem_00 "3wrV9vxkV6cm3KZuU0YmrpECz0gO85cpwPAwvoDmqQfm97s5UZmfYguhz8/428PUc52yhrNL2DIcflQpOkDgIHixsN/qQIr1Yl8RrFxWUW9+BWG4mgSfzo8rnvUQWJayS2cUu9k11ZYcmdN3LHF6s1KoNJ9JXlORxyEgsglhkdhkf1ALusfEVuG233HcW8M7RNXR6hb8GxDqWtwlLRj1qCOttHqbLRcgsbfjrMDR1Fht4277Y+91VJnUrh/5hrFqOADwKRqiLsdt/cqGLEzhQQcrWmg51Yy5mXnSiw6FfImIkgD8Ck/ZT4cliEkfBJ8MvlFHiucF4gjdNZhvvfZU3j81OpYa3tPH5H2W4J0+SkdP2DPeAapjXi9YkQVQjsI0v4dbWpeIG8fZzNZQb9r7IdLCqtnNFCmiFw1vqqzdGnE27id82+iufRydCYAVk76+AWQbaZyosgkUXLqY4VRCSoh4OJxErbAAjmhklcR3qbZtNBCdqCF9bqryWupZkMpklXsfe5G7KRiw8bMAjFvuAkGQdFiOzIojPkWtODBv1c3i4gjsuZE3PgHhRr39wn7obP7Zbf3zLQj/+o5QqVZOBuvsEIcRop+a6TucmMyF05/Unhp5C8/X3pneoq2+xZlVNyoTAWvXxsJsJerJ6mVoXwgs0Z3s450Mwxyi5f58hSPcUlD0U5YH1oljVxcbGyTA/kGzhItzAQlqjUK8Y6PiM7sgNM8c2LCi+syVlvevi00Di4+5Yflxzgid71tikJyvSLR2JIWvDyEwfW1F979kr7GG6qPKwZe6wFqkahaYAqD1kRkCW5dk+TcXzoc1iadVqlx0CgQIAleg7RoO0x/ejjgjSGMJ+kMMBQjDfpp8ulvK+sQlLhAx4dAtyXhMd1yE2XZo2y0Cet2gTSahyRCLfrD8ATSo+QfCgxeAyrOgC1PLuBivxvInziHwS9gnXV4igXcvshPg1Ix27cLQaYhmSMa44reiY9GfUxWuPfMvegh30ope1L7aenwCK7bSPmwX"
`endif
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwK7ZdpvuN5w+BZFqj+rtF7eUZNStWAn49OYVPs3jh1FQtzkybBcqV5OgINFDtt6iex+nf/j5UhHIWCPOMBvdkd1ocN3IVm01L4whQRB3QsSp0jDTRddbar1KB96uC+1vTptLVlQl+r7M7LUWkBdtejafojTCwGmZu/p1v1ZPZFf895hp3CF3UtsPfWEIxFxpFllFs9AbotC3Z90FpFsSb/kTSLh61ycZGYTPNLHx6d70alWXbZbrGxvEBn6LRvj8wj/sAp4guY0p8gvdMXcAjCdy4jaHwjMhd9kGIGgiXRDAmDsRtLC3zoOcy2jRO7AJJ2l1jiGiW0YisG31yiEDn7nVS+8w4o3IRhCJ4OOcTKtsb0cVxM+/EXF6KjF4PqsnhsmLeI1oOGBF9brcGhPpXElSEc/dUlVTyniXwSyX7cqDq80Mpm5geNV9tDrOCFCsZ6WL5F+7LFcLOiAiQKb7SwbLGsQhS112Swd94rVSeahB8WB3QrrbDnhNXF/E5PyOnFPwKDqA0E3MTxB1p3nyhHgQtUKbApOhcFFcWcZGxa4HzQx0wpQIt6dgp/rx8Yhr7Z5RmapctrtO6r+CU3y8Xvl4x/34YG3N14m4neQAv0A8Wdy0R6gY0EyrjaYu7tgKcFJHlkR5VaNPFZwf431Cxog9DtO/QGCyPibFU1bKNeOnNaAoeL3RPDY8j6p8vSkyzM9Ck3jt//tC83sSMpxt3sKWJXHhBfNPOdpbVlo4JgqrBm7wnwvspspv0cI5odUMHDATgaB46nZzBw8leBcP2cV"
`endif