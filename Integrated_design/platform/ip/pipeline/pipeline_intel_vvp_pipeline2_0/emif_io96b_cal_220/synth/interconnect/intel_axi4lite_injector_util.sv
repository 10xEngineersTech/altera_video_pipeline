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





module intel_axi4lite_injector_util_add_a_b_s0_s1 #(
    parameter SIZE = 5
)(
    input [SIZE-1:0] a,
    input [SIZE-1:0] b,
    input s0,
    input s1,
    output [SIZE-1:0] out
);
wire [SIZE:0] left;
wire [SIZE:0] right;
wire temp;
    
assign left = {a ^ b, s0};
assign right = {a[SIZE-2:0] & b[SIZE-2:0], s1, s0};
assign {out, temp} = left + right;  

endmodule


module intel_axi4lite_injector_util_binary_to_gray #(
    parameter WIDTH = 5
) (
    input clock,
    input aclr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

always @(posedge clock or posedge aclr) begin
    if (aclr)
        dout <= 0;
    else
        dout <= din ^ (din >> 1);
end

endmodule


module intel_axi4lite_injector_util_gray_to_binary #(
    parameter WIDTH = 5
) (
    input clock,
    input aclr,
    input [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

wire [WIDTH-1:0] dout_w;

genvar i;
generate
    for (i = 0; i < WIDTH; i=i+1) begin : loop
        assign dout_w[i] = ^(din[WIDTH-1:i]);
    end
endgenerate

always @(posedge clock or posedge aclr) begin
    if (aclr)
        dout <= 0;
    else
        dout <= dout_w;
end

endmodule


(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module intel_axi4lite_injector_util_generic_mlab_sc #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter FAMILY = "Other" 
)(
    input clk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

genvar i;
generate
if (FAMILY == "S10") begin    
    reg [WIDTH-1:0] wdata_hipi;
    always @(posedge clk) wdata_hipi <= din;
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = clk; 
        wire rclk_w = clk; 
        fourteennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on           

            .portabyteenamasks(1'b1),
            .portadatain(wdata_hipi[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
end else if (FAMILY == "Agilex") begin    
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = clk; 
        wire rclk_w = clk; 
        tennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on       

            .portabyteenamasks(1'b1),
            .portadatain(din[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
    
end else begin

    localparam DEPTH = 1 << ADDR_WIDTH;
    (* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    reg [WIDTH-1:0] dout_r;
    always @(posedge clk) begin
        if (we)
            mem[waddr] <= din;
        if (re)
            dout_r <= mem[raddr];
    end
    assign dout = dout_r;

end
endgenerate    

endmodule


(* altera_attribute = "-name SYNCHRONIZER_IDENTIFICATION OFF" *)
module intel_axi4lite_injector_util_generic_mlab_dc #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 5,
    parameter FAMILY = "Other" 
)(
    input rclk,
    input wclk,
    input [WIDTH-1:0] din,
    input [ADDR_WIDTH-1:0] waddr,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] raddr,
    output [WIDTH-1:0] dout
);

genvar i;
generate
if (FAMILY == "S10") begin    
    reg [WIDTH-1:0] wdata_hipi;
    always @(posedge wclk) wdata_hipi <= din;
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = wclk; 
        wire rclk_w = rclk; 
        fourteennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on       

            .portabyteenamasks(1'b1),
            .portadatain(wdata_hipi[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
end else if (FAMILY == "Agilex") begin    
        
    for (i=0; i<WIDTH; i=i+1)  begin : ml
        wire wclk_w = wclk; 
        wire rclk_w = rclk; 
        (* altera_attribute = "-name MESSAGE_DISABLE 14320" *)
        tennm_mlab_cell lrm (
            .clk0(wclk_w),
            .ena0(we),
            .clk1(rclk_w),
            .ena1(re),
                
            // synthesis translate_off
            .clr(1'b0),
            .devclrn(1'b1),
            .devpor(1'b1),
            // synthesis translate_on       

            .portabyteenamasks(1'b1),
            .portadatain(din[i]),
            .portaaddr(waddr),
            .portbaddr(raddr),
            .portbdataout(dout[i])          
        );

        defparam lrm .mixed_port_feed_through_mode = "dont_care";
        defparam lrm .logical_ram_name = "lrm";
        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
        defparam lrm .logical_ram_width = WIDTH;
        defparam lrm .first_address = 0;
        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
        defparam lrm .first_bit_number = i;
        defparam lrm .data_width = 1;
        defparam lrm .address_width = ADDR_WIDTH;
        defparam lrm .port_b_data_out_clock = "clock1";
    end
    
    
end else begin

    localparam DEPTH = 1 << ADDR_WIDTH;
    (* ramstyle = "mlab" *) reg [WIDTH-1:0] mem[0:DEPTH-1];

    reg [WIDTH-1:0] dout_r;
    always @(posedge wclk) begin
        if (we)
            mem[waddr] <= din;
    end
    always @(posedge rclk) begin
        if (re)
            dout_r <= mem[raddr];
    end
    assign dout = dout_r;

end
endgenerate    

endmodule


module intel_axi4lite_injector_util_synchronizer_ff_r2 #(
    parameter WIDTH = 8
)(
    input din_clk,
    input din_aclr,
    input [WIDTH-1:0] din,
    input dout_clk,
    input dout_aclr,
    output [WIDTH-1:0] dout
);

localparam MULTI = "-name SDC_STATEMENT \"set_multicycle_path -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]] 2\" ";
localparam FPATH = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]]\" ";
localparam FHOLD = "-name SDC_STATEMENT \"set_false_path -hold -to [get_keepers *synchronizer_ff_r2*ff_meta\[*\]]\" ";

reg [WIDTH-1:0] ff_launch = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge din_clk or posedge din_aclr) begin
    if (din_aclr)
        ff_launch <= 0;
    else
        ff_launch <= din;
end

localparam SDC = {MULTI,";",FHOLD};
(* altera_attribute = SDC *)
reg [WIDTH-1:0] ff_meta = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge dout_clk or posedge dout_aclr) begin
    if (dout_aclr)    
        ff_meta <= 0;
    else
        ff_meta <= ff_launch;
end

reg [WIDTH-1:0] ff_sync = {WIDTH {1'b0}} /* synthesis preserve dont_replicate */;
always @(posedge dout_clk or posedge dout_aclr) begin
    if (dout_aclr)
        ff_sync <= 0;
    else
        ff_sync <= ff_meta;
end

assign dout = ff_sync;
endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "nNPtlHlx3HIQvFi5kGFaFEv434zybsjKFqGY4gnVq1vPKQyJAgyqhj0Qps8Y5SMqnY/rmFr10ZlnY7K43WYa1ZVC+cdJieNxPggttn/sUMPURkHAk4o0I5L+OR2kgBteL0Dd3EyNh517zusdnGPEsxN3a61RkbW1OI34pEcphpyWH0OEbRnyPhqeSvzjM2xadNbwFbx9Ug9tCOtBVjGLEh376xHCIHG4yrFayiK02Swu1E1ADA7XPJup6ebeeWWMcLI52htq9mK9wxLRLr1Rtl/MwY9BPuOImXUhH72P9/R6cbQ1aCxFgWwpeFJLdwzL7a+4s+rG4gUMfReNBQRNEkHyrzx7LQX9ok+FmKU0Qi7awIgVe80Jz4M77ljO/naTeys2BXpOv4Q68KyUr9RZXiIAyC+8ro/o00ba7zKlpCo/VQYkddHmPzsbfxdN+16lU6nE7sKo1le8vwhB32SRrE3V0p0ifeXoCF/BxTfDG6SG7uswXRt1HjIhMVgcesvUdwxOBHlvpJOcrp0U5BJSiwIJLTxBYMVCPZbgmP0aLB4fbIzUFwvwW/lEScAmXhsPFuuCE9JCe+vQdY4yIRBOgTb9Ov2oHvBwM0We9RiEhpkwipUX4EbIpAlizvOxTaaOV0lZkKgp2PsUJDJMJIuv7NjUS7DklvMYd3Yj662Hhpd7gNHJE18OoVkpOuSWS1JRk7ERCZV1e9TCvN6RF3JbRU2KM8WXpAPB/3EnUT6iQG2KUHT4Sig1kMJ+4Q81TSTYiWbIC+2N2VBPqkv1v8tNEKo/u65glg3NfZnpOU78WNIHwFsESBj7ua8d4Tcmaiq+lXrfsSqfjydMcFBMzenPjTt0DTp0XS/lQ7ful3/5eS/OS0S15bcOLZvJEHG8ksKzBuKtz0BeE3H6uPyDfsM84M9QKREefySNXm9Zdx0/xISsSBP6T7Oced/LFl77V2zs3oLHp3S4daVe1A09TpKx5a1k+uw99B4D5j8SryXS2plUC3hAG3tT6n/i9sc2s7lJ"
`endif