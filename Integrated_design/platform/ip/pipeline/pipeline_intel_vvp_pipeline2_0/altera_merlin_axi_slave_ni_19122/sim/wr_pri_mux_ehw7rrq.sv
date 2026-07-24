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


`timescale 1ps/1ps

// priority mux
// in0 has highest priority
// in7 has lowest priority
// shift_occured - used to adjust index-out in case when pipeline is enabled
// and now the index needs to be updated since data/(hence compare output was
// shifted

module wr_pri_mux_ehw7rrq (
input in0,
input in1,
input in2,
input in3,
input in4,
input in5,
input in6,
input in7,
input in8,
input in9,
input in10,
input in11,
input in12,
input in13,
input in14,
input in15,
input [16-1:0] clr, 
input [16-1:0] shift_index_out, 
output logic sel,
output logic [4-1:0] sel_index
);

always @ * begin
    if (in0 && !clr[0]) begin
        sel = in0;
        sel_index=0;
    end
 else if (in1 && !clr[1]) begin
        sel = in1;
        sel_index=1-shift_index_out[1];
    end
 else if (in2 && !clr[2]) begin
        sel = in2;
        sel_index=2-shift_index_out[2];
    end
 else if (in3 && !clr[3]) begin
        sel = in3;
        sel_index=3-shift_index_out[3];
    end
 else if (in4 && !clr[4]) begin
        sel = in4;
        sel_index=4-shift_index_out[4];
    end
 else if (in5 && !clr[5]) begin
        sel = in5;
        sel_index=5-shift_index_out[5];
    end
 else if (in6 && !clr[6]) begin
        sel = in6;
        sel_index=6-shift_index_out[6];
    end
 else if (in7 && !clr[7]) begin
        sel = in7;
        sel_index=7-shift_index_out[7];
    end
 else if (in8 && !clr[8]) begin
        sel = in8;
        sel_index=8-shift_index_out[8];
    end
 else if (in9 && !clr[9]) begin
        sel = in9;
        sel_index=9-shift_index_out[9];
    end
 else if (in10 && !clr[10]) begin
        sel = in10;
        sel_index=10-shift_index_out[10];
    end
 else if (in11 && !clr[11]) begin
        sel = in11;
        sel_index=11-shift_index_out[11];
    end
 else if (in12 && !clr[12]) begin
        sel = in12;
        sel_index=12-shift_index_out[12];
    end
 else if (in13 && !clr[13]) begin
        sel = in13;
        sel_index=13-shift_index_out[13];
    end
 else if (in14 && !clr[14]) begin
        sel = in14;
        sel_index=14-shift_index_out[14];
    end
else begin
        sel = in15;
        sel_index=15-shift_index_out[15];
    end
end

endmodule

