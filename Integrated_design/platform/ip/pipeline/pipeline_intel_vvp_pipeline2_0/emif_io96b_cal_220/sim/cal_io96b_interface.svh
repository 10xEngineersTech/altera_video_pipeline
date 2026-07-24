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


`ifndef CAL_ARCH_FP_INTERFACE

`define CAL_ARCH_FP_INTERFACE 1

// altera message_off 18455
interface AXILITE_BUS #(
  parameter int signed PORT_AXI_AXADDR_WIDTH  = 0,
  parameter int signed PORT_AXI_AXID_WIDTH    = 0,
  parameter int signed PORT_AXI_AXBURST_WIDTH = 0,
  parameter int signed PORT_AXI_AXLEN_WIDTH   = 0,
  parameter int signed PORT_AXI_AXSIZE_WIDTH  = 0,
  parameter int signed PORT_AXI_AXUSER_WIDTH  = 0,
  parameter int signed PORT_AXI_DATA_WIDTH    = 0,
  parameter int signed PORT_AXI_STRB_WIDTH    = 0,
  parameter int signed PORT_AXI_RESP_WIDTH    = 0,
  parameter int signed PORT_AXI_ID_WIDTH      = 0,
  parameter int signed PORT_AXI_USER_WIDTH    = 0,
  parameter int signed PORT_AXI_AXQOS_WIDTH   = 0,
  parameter int signed PORT_AXI_AXCACHE_WIDTH = 0,
  parameter int signed PORT_AXI_AXPROT_WIDTH  = 0
);

typedef logic                              clk_t;
typedef logic                              rst_n_t;
typedef logic [PORT_AXI_AXADDR_WIDTH-1:0]  addr_t;
typedef logic [PORT_AXI_AXID_WIDTH-1:0]    id_t;
typedef logic [PORT_AXI_AXBURST_WIDTH-1:0] burst_t;
typedef logic [PORT_AXI_AXLEN_WIDTH-1:0]   len_t;
typedef logic [PORT_AXI_AXSIZE_WIDTH-1:0]  size_t;
typedef logic [PORT_AXI_AXUSER_WIDTH-1:0]  user_t;
typedef logic [PORT_AXI_DATA_WIDTH-1:0]    data_t;
typedef logic [PORT_AXI_STRB_WIDTH-1:0]    strb_t;
typedef logic [PORT_AXI_RESP_WIDTH-1:0]    resp_t;
typedef logic [PORT_AXI_ID_WIDTH-1:0]      respid_t;
typedef logic [PORT_AXI_USER_WIDTH-1:0]    respuser_t;
typedef logic [PORT_AXI_AXQOS_WIDTH-1:0]   qos_t;
typedef logic [PORT_AXI_AXCACHE_WIDTH-1:0] cache_t;
typedef logic [PORT_AXI_AXPROT_WIDTH-1:0]  prot_t;

clk_t             clk;
rst_n_t           rst_n;

id_t              awid;
addr_t            awaddr;
len_t             awlen;
size_t            awsize;
burst_t           awburst;
logic             awlock;
cache_t           awcache;
prot_t            awprot;
qos_t             awqos;
user_t            awuser;
logic             awvalid;
logic             awready;

data_t            wdata;
strb_t            wstrb;
logic             wlast;
respuser_t        wuser;
logic             wvalid;
logic             wready;

respid_t          bid;
resp_t            bresp;
respuser_t        buser;
logic             bvalid;
logic             bready;

id_t              arid;
addr_t            araddr;
len_t             arlen;
size_t            arsize;
burst_t           arburst;
logic             arlock;
cache_t           arcache;
prot_t            arprot;
qos_t             arqos;
user_t            aruser;
logic             arvalid;
logic             arready;

respid_t          rid;
data_t            rdata;
resp_t            rresp;
logic             rlast;
respuser_t        ruser;
logic             rvalid;
logic             rready;

modport Manager (
   input clk, rst_n,
   output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awuser, awvalid, input awready,
   output wdata, wstrb, wlast, wuser, wvalid, input wready,
   input bid, bresp, buser, bvalid, output bready,
   output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, aruser, arvalid, input arready,
   input rid, rdata, rresp, rlast, ruser, rvalid, output rready
);

modport Subordinate (
   output clk, rst_n,
   input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awuser, awvalid, output awready,
   input wdata, wstrb, wlast, wuser, wvalid, output wready,
   output bid, bresp, buser, bvalid, input bready,
   input arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, aruser, arvalid, output arready,
   output rid, rdata, rresp, rlast, ruser, rvalid, input rready
);

endinterface

`endif 
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "BcKhm8GW0cpHsCa4G/ETpFMsNr62fM+PAUz29Ycpfq3jc/bjNAE5EdpSN6IBYxdzX1TKn5XwmNZpIHq28ZhR8dtiYA3JujkQLepHEAgPb4kI6FhViBdLuWHMO+FW9WwumWeRl6HJXydjQcpk2O8zckSO4/l0Q8bbWSMGG55kEQZjTFXnv4ItQaDgViLzFKr53eXF141vDcnhom3sW4rJ3L/w/vvROJj0pZK07t2TgwKoa146MNy9+UZuVETz9yn1+bOM3f4MR4vGrJC/Wos5wRldctha5ga2wDtLvtwbz/QVEbrCvJtGJWO0QkNo5l/NzRwtQG7sWbpyS6DhC8aGsO8oHHpIY9nJ1lyRDsGYrvVqt80aF5Pwe9ceOvM/iBSvswVrXJ+Xm1uM9IFl2qoICPA1EO4Cr7Y+7uS32v7UMRzpz/mrTYMZUAtq//3phc6zHswcCT7OFFJFC/lhYVh0l5Ll1W0l/SW+SiYoA3wLLbsgICBvWNeEY0AJVDsnft3u3R6YthZFJJjhtSyfN49XWSpH3+djwn4qvse/nIBsqA3FlCHSUC1OnXOdz5lRKXDHMgVUA4+ab0rSvLByZ78DyXqbXOPRFIDH29+0bgnf09PtoJ1QcpgMsAt9EFevmwCpKR9Zu1cpdRne/gQHi+Z8tcHV8ftKx5Em777qEFPQC4rwbPVjA3eU0NRNQ+4tYRvB36tmf/F17vmys7EASewYYSBj6UE/XUyp2qh6BNjDwl3hKIC5US/qu3Ii2hFQJRG3aGRlpBNCwxW8SPfmDv+IQTqxiMEAfX4mFY/hi0fGiM9SZWsOA0sZTVjSJjR0P0rq8lvo0N8hEj+AQeFgvOQdvkG74EYFcNJ7PNiHnLcngxtnQZZvybsFEbUQJEgoF0ImZULQXwKQm/xyNNCv4hN3rjxQgqMZ9jLzOonQNlq0egYxnxxPZ5FiXAwa97fjal4AjZFh3oi7iZk0fv1MJdUaDXjim8jziU8magfG3cdhrk6jy1E6nw0dy1KY8+EG4VVS"
`endif