	component pipeline is
		port (
			clock_in_in_clk_clk                                         : in  std_logic                     := 'X';             -- clk
			intel_vvp_clipper_0_axi4s_vid_in_tdata                      : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_clipper_0_axi4s_vid_in_tvalid                     : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_clipper_0_axi4s_vid_in_tready                     : out std_logic;                                        -- tready
			intel_vvp_clipper_0_axi4s_vid_in_tlast                      : in  std_logic                     := 'X';             -- tlast
			intel_vvp_clipper_0_axi4s_vid_in_tuser                      : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_clipper_0_axi4s_vid_out_tdata                     : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_clipper_0_axi4s_vid_out_tvalid                    : out std_logic;                                        -- tvalid
			intel_vvp_clipper_0_axi4s_vid_out_tready                    : in  std_logic                     := 'X';             -- tready
			intel_vvp_clipper_0_axi4s_vid_out_tlast                     : out std_logic;                                        -- tlast
			intel_vvp_clipper_0_axi4s_vid_out_tuser                     : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_crs_0_axi4s_vid_in_tdata                          : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_crs_0_axi4s_vid_in_tvalid                         : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_crs_0_axi4s_vid_in_tready                         : out std_logic;                                        -- tready
			intel_vvp_crs_0_axi4s_vid_in_tlast                          : in  std_logic                     := 'X';             -- tlast
			intel_vvp_crs_0_axi4s_vid_in_tuser                          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_crs_0_axi4s_vid_out_tdata                         : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_crs_0_axi4s_vid_out_tvalid                        : out std_logic;                                        -- tvalid
			intel_vvp_crs_0_axi4s_vid_out_tready                        : in  std_logic                     := 'X';             -- tready
			intel_vvp_crs_0_axi4s_vid_out_tlast                         : out std_logic;                                        -- tlast
			intel_vvp_crs_0_axi4s_vid_out_tuser                         : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_csc_0_axi4s_vid_in_tdata                          : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_csc_0_axi4s_vid_in_tvalid                         : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_csc_0_axi4s_vid_in_tready                         : out std_logic;                                        -- tready
			intel_vvp_csc_0_axi4s_vid_in_tlast                          : in  std_logic                     := 'X';             -- tlast
			intel_vvp_csc_0_axi4s_vid_in_tuser                          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_csc_0_axi4s_vid_out_tdata                         : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_csc_0_axi4s_vid_out_tvalid                        : out std_logic;                                        -- tvalid
			intel_vvp_csc_0_axi4s_vid_out_tready                        : in  std_logic                     := 'X';             -- tready
			intel_vvp_csc_0_axi4s_vid_out_tlast                         : out std_logic;                                        -- tlast
			intel_vvp_csc_0_axi4s_vid_out_tuser                         : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_dil_0_axi4s_vid_in_tdata                          : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_dil_0_axi4s_vid_in_tvalid                         : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_dil_0_axi4s_vid_in_tready                         : out std_logic;                                        -- tready
			intel_vvp_dil_0_axi4s_vid_in_tlast                          : in  std_logic                     := 'X';             -- tlast
			intel_vvp_dil_0_axi4s_vid_in_tuser                          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_dil_0_axi4s_vid_out_tdata                         : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_dil_0_axi4s_vid_out_tvalid                        : out std_logic;                                        -- tvalid
			intel_vvp_dil_0_axi4s_vid_out_tready                        : in  std_logic                     := 'X';             -- tready
			intel_vvp_dil_0_axi4s_vid_out_tlast                         : out std_logic;                                        -- tlast
			intel_vvp_dil_0_axi4s_vid_out_tuser                         : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_protocol_conv_0_axi4s_vid_in_tdata                : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid               : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_protocol_conv_0_axi4s_vid_in_tready               : out std_logic;                                        -- tready
			intel_vvp_protocol_conv_0_axi4s_vid_in_tlast                : in  std_logic                     := 'X';             -- tlast
			intel_vvp_protocol_conv_0_axi4s_vid_in_tuser                : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_protocol_conv_0_axi4s_vid_out_tdata               : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid              : out std_logic;                                        -- tvalid
			intel_vvp_protocol_conv_0_axi4s_vid_out_tready              : in  std_logic                     := 'X';             -- tready
			intel_vvp_protocol_conv_0_axi4s_vid_out_tlast               : out std_logic;                                        -- tlast
			intel_vvp_protocol_conv_0_axi4s_vid_out_tuser               : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_protocol_conv_1_axi4s_vid_in_tdata                : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_protocol_conv_1_axi4s_vid_in_tvalid               : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_protocol_conv_1_axi4s_vid_in_tready               : out std_logic;                                        -- tready
			intel_vvp_protocol_conv_1_axi4s_vid_in_tlast                : in  std_logic                     := 'X';             -- tlast
			intel_vvp_protocol_conv_1_axi4s_vid_in_tuser                : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_protocol_conv_1_axi4s_vid_out_tdata               : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_protocol_conv_1_axi4s_vid_out_tvalid              : out std_logic;                                        -- tvalid
			intel_vvp_protocol_conv_1_axi4s_vid_out_tready              : in  std_logic                     := 'X';             -- tready
			intel_vvp_protocol_conv_1_axi4s_vid_out_tlast               : out std_logic;                                        -- tlast
			intel_vvp_protocol_conv_1_axi4s_vid_out_tuser               : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_protocol_conv_1_av_mm_control_agent_address       : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			intel_vvp_protocol_conv_1_av_mm_control_agent_write         : in  std_logic                     := 'X';             -- write
			intel_vvp_protocol_conv_1_av_mm_control_agent_byteenable    : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			intel_vvp_protocol_conv_1_av_mm_control_agent_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			intel_vvp_protocol_conv_1_av_mm_control_agent_read          : in  std_logic                     := 'X';             -- read
			intel_vvp_protocol_conv_1_av_mm_control_agent_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			intel_vvp_protocol_conv_1_av_mm_control_agent_readdatavalid : out std_logic;                                        -- readdatavalid
			intel_vvp_protocol_conv_1_av_mm_control_agent_waitrequest   : out std_logic;                                        -- waitrequest
			intel_vvp_scaler_0_axi4s_vid_in_tdata                       : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_scaler_0_axi4s_vid_in_tvalid                      : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_scaler_0_axi4s_vid_in_tready                      : out std_logic;                                        -- tready
			intel_vvp_scaler_0_axi4s_vid_in_tlast                       : in  std_logic                     := 'X';             -- tlast
			intel_vvp_scaler_0_axi4s_vid_in_tuser                       : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_scaler_0_axi4s_vid_out_tdata                      : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_scaler_0_axi4s_vid_out_tvalid                     : out std_logic;                                        -- tvalid
			intel_vvp_scaler_0_axi4s_vid_out_tready                     : in  std_logic                     := 'X';             -- tready
			intel_vvp_scaler_0_axi4s_vid_out_tlast                      : out std_logic;                                        -- tlast
			intel_vvp_scaler_0_axi4s_vid_out_tuser                      : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_tpg_0_axi4s_vid_out_tdata                         : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_tpg_0_axi4s_vid_out_tvalid                        : out std_logic;                                        -- tvalid
			intel_vvp_tpg_0_axi4s_vid_out_tready                        : in  std_logic                     := 'X';             -- tready
			intel_vvp_tpg_0_axi4s_vid_out_tlast                         : out std_logic;                                        -- tlast
			intel_vvp_tpg_0_axi4s_vid_out_tuser                         : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_tpg_0_av_mm_control_agent_address                 : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			intel_vvp_tpg_0_av_mm_control_agent_write                   : in  std_logic                     := 'X';             -- write
			intel_vvp_tpg_0_av_mm_control_agent_byteenable              : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			intel_vvp_tpg_0_av_mm_control_agent_writedata               : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			intel_vvp_tpg_0_av_mm_control_agent_read                    : in  std_logic                     := 'X';             -- read
			intel_vvp_tpg_0_av_mm_control_agent_readdata                : out std_logic_vector(31 downto 0);                    -- readdata
			intel_vvp_tpg_0_av_mm_control_agent_readdatavalid           : out std_logic;                                        -- readdatavalid
			intel_vvp_tpg_0_av_mm_control_agent_waitrequest             : out std_logic;                                        -- waitrequest
			intel_vvp_vfb_0_axi4s_vid_in_tdata                          : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_vfb_0_axi4s_vid_in_tvalid                         : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_vfb_0_axi4s_vid_in_tready                         : out std_logic;                                        -- tready
			intel_vvp_vfb_0_axi4s_vid_in_tlast                          : in  std_logic                     := 'X';             -- tlast
			intel_vvp_vfb_0_axi4s_vid_in_tuser                          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_vfb_0_axi4s_vid_out_tdata                         : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_vfb_0_axi4s_vid_out_tvalid                        : out std_logic;                                        -- tvalid
			intel_vvp_vfb_0_axi4s_vid_out_tready                        : in  std_logic                     := 'X';             -- tready
			intel_vvp_vfb_0_axi4s_vid_out_tlast                         : out std_logic;                                        -- tlast
			intel_vvp_vfb_0_axi4s_vid_out_tuser                         : out std_logic_vector(2 downto 0);                     -- tuser
			lite_to_full_converter_axi4s_vid_in_tdata                   : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			lite_to_full_converter_axi4s_vid_in_tvalid                  : in  std_logic                     := 'X';             -- tvalid
			lite_to_full_converter_axi4s_vid_in_tready                  : out std_logic;                                        -- tready
			lite_to_full_converter_axi4s_vid_in_tlast                   : in  std_logic                     := 'X';             -- tlast
			lite_to_full_converter_axi4s_vid_in_tuser                   : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			lite_to_full_converter_axi4s_vid_out_tdata                  : out std_logic_vector(23 downto 0);                    -- tdata
			lite_to_full_converter_axi4s_vid_out_tvalid                 : out std_logic;                                        -- tvalid
			lite_to_full_converter_axi4s_vid_out_tready                 : in  std_logic                     := 'X';             -- tready
			lite_to_full_converter_axi4s_vid_out_tlast                  : out std_logic;                                        -- tlast
			lite_to_full_converter_axi4s_vid_out_tuser                  : out std_logic_vector(2 downto 0);                     -- tuser
			mm_bridge_0_s0_waitrequest                                  : out std_logic;                                        -- waitrequest
			mm_bridge_0_s0_readdata                                     : out std_logic_vector(31 downto 0);                    -- readdata
			mm_bridge_0_s0_readdatavalid                                : out std_logic;                                        -- readdatavalid
			mm_bridge_0_s0_burstcount                                   : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			mm_bridge_0_s0_writedata                                    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			mm_bridge_0_s0_address                                      : in  std_logic_vector(12 downto 0) := (others => 'X'); -- address
			mm_bridge_0_s0_write                                        : in  std_logic                     := 'X';             -- write
			mm_bridge_0_s0_read                                         : in  std_logic                     := 'X';             -- read
			mm_bridge_0_s0_byteenable                                   : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			mm_bridge_0_s0_debugaccess                                  : in  std_logic                     := 'X';             -- debugaccess
			reset_in_in_reset_reset                                     : in  std_logic                     := 'X'              -- reset
		);
	end component pipeline;

	u0 : component pipeline
		port map (
			clock_in_in_clk_clk                                         => CONNECTED_TO_clock_in_in_clk_clk,                                         --                               clock_in_in_clk.clk
			intel_vvp_clipper_0_axi4s_vid_in_tdata                      => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_in_tdata,                      --              intel_vvp_clipper_0_axi4s_vid_in.tdata
			intel_vvp_clipper_0_axi4s_vid_in_tvalid                     => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_in_tvalid,                     --                                              .tvalid
			intel_vvp_clipper_0_axi4s_vid_in_tready                     => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_in_tready,                     --                                              .tready
			intel_vvp_clipper_0_axi4s_vid_in_tlast                      => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_in_tlast,                      --                                              .tlast
			intel_vvp_clipper_0_axi4s_vid_in_tuser                      => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_in_tuser,                      --                                              .tuser
			intel_vvp_clipper_0_axi4s_vid_out_tdata                     => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_out_tdata,                     --             intel_vvp_clipper_0_axi4s_vid_out.tdata
			intel_vvp_clipper_0_axi4s_vid_out_tvalid                    => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_out_tvalid,                    --                                              .tvalid
			intel_vvp_clipper_0_axi4s_vid_out_tready                    => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_out_tready,                    --                                              .tready
			intel_vvp_clipper_0_axi4s_vid_out_tlast                     => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_out_tlast,                     --                                              .tlast
			intel_vvp_clipper_0_axi4s_vid_out_tuser                     => CONNECTED_TO_intel_vvp_clipper_0_axi4s_vid_out_tuser,                     --                                              .tuser
			intel_vvp_crs_0_axi4s_vid_in_tdata                          => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tdata,                          --                  intel_vvp_crs_0_axi4s_vid_in.tdata
			intel_vvp_crs_0_axi4s_vid_in_tvalid                         => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tvalid,                         --                                              .tvalid
			intel_vvp_crs_0_axi4s_vid_in_tready                         => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tready,                         --                                              .tready
			intel_vvp_crs_0_axi4s_vid_in_tlast                          => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tlast,                          --                                              .tlast
			intel_vvp_crs_0_axi4s_vid_in_tuser                          => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tuser,                          --                                              .tuser
			intel_vvp_crs_0_axi4s_vid_out_tdata                         => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tdata,                         --                 intel_vvp_crs_0_axi4s_vid_out.tdata
			intel_vvp_crs_0_axi4s_vid_out_tvalid                        => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tvalid,                        --                                              .tvalid
			intel_vvp_crs_0_axi4s_vid_out_tready                        => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tready,                        --                                              .tready
			intel_vvp_crs_0_axi4s_vid_out_tlast                         => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tlast,                         --                                              .tlast
			intel_vvp_crs_0_axi4s_vid_out_tuser                         => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tuser,                         --                                              .tuser
			intel_vvp_csc_0_axi4s_vid_in_tdata                          => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_in_tdata,                          --                  intel_vvp_csc_0_axi4s_vid_in.tdata
			intel_vvp_csc_0_axi4s_vid_in_tvalid                         => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_in_tvalid,                         --                                              .tvalid
			intel_vvp_csc_0_axi4s_vid_in_tready                         => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_in_tready,                         --                                              .tready
			intel_vvp_csc_0_axi4s_vid_in_tlast                          => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_in_tlast,                          --                                              .tlast
			intel_vvp_csc_0_axi4s_vid_in_tuser                          => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_in_tuser,                          --                                              .tuser
			intel_vvp_csc_0_axi4s_vid_out_tdata                         => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_out_tdata,                         --                 intel_vvp_csc_0_axi4s_vid_out.tdata
			intel_vvp_csc_0_axi4s_vid_out_tvalid                        => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_out_tvalid,                        --                                              .tvalid
			intel_vvp_csc_0_axi4s_vid_out_tready                        => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_out_tready,                        --                                              .tready
			intel_vvp_csc_0_axi4s_vid_out_tlast                         => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_out_tlast,                         --                                              .tlast
			intel_vvp_csc_0_axi4s_vid_out_tuser                         => CONNECTED_TO_intel_vvp_csc_0_axi4s_vid_out_tuser,                         --                                              .tuser
			intel_vvp_dil_0_axi4s_vid_in_tdata                          => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_in_tdata,                          --                  intel_vvp_dil_0_axi4s_vid_in.tdata
			intel_vvp_dil_0_axi4s_vid_in_tvalid                         => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_in_tvalid,                         --                                              .tvalid
			intel_vvp_dil_0_axi4s_vid_in_tready                         => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_in_tready,                         --                                              .tready
			intel_vvp_dil_0_axi4s_vid_in_tlast                          => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_in_tlast,                          --                                              .tlast
			intel_vvp_dil_0_axi4s_vid_in_tuser                          => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_in_tuser,                          --                                              .tuser
			intel_vvp_dil_0_axi4s_vid_out_tdata                         => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_out_tdata,                         --                 intel_vvp_dil_0_axi4s_vid_out.tdata
			intel_vvp_dil_0_axi4s_vid_out_tvalid                        => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_out_tvalid,                        --                                              .tvalid
			intel_vvp_dil_0_axi4s_vid_out_tready                        => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_out_tready,                        --                                              .tready
			intel_vvp_dil_0_axi4s_vid_out_tlast                         => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_out_tlast,                         --                                              .tlast
			intel_vvp_dil_0_axi4s_vid_out_tuser                         => CONNECTED_TO_intel_vvp_dil_0_axi4s_vid_out_tuser,                         --                                              .tuser
			intel_vvp_protocol_conv_0_axi4s_vid_in_tdata                => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_in_tdata,                --        intel_vvp_protocol_conv_0_axi4s_vid_in.tdata
			intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid               => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_in_tvalid,               --                                              .tvalid
			intel_vvp_protocol_conv_0_axi4s_vid_in_tready               => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_in_tready,               --                                              .tready
			intel_vvp_protocol_conv_0_axi4s_vid_in_tlast                => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_in_tlast,                --                                              .tlast
			intel_vvp_protocol_conv_0_axi4s_vid_in_tuser                => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_in_tuser,                --                                              .tuser
			intel_vvp_protocol_conv_0_axi4s_vid_out_tdata               => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_out_tdata,               --       intel_vvp_protocol_conv_0_axi4s_vid_out.tdata
			intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid              => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_out_tvalid,              --                                              .tvalid
			intel_vvp_protocol_conv_0_axi4s_vid_out_tready              => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_out_tready,              --                                              .tready
			intel_vvp_protocol_conv_0_axi4s_vid_out_tlast               => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_out_tlast,               --                                              .tlast
			intel_vvp_protocol_conv_0_axi4s_vid_out_tuser               => CONNECTED_TO_intel_vvp_protocol_conv_0_axi4s_vid_out_tuser,               --                                              .tuser
			intel_vvp_protocol_conv_1_axi4s_vid_in_tdata                => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_in_tdata,                --        intel_vvp_protocol_conv_1_axi4s_vid_in.tdata
			intel_vvp_protocol_conv_1_axi4s_vid_in_tvalid               => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_in_tvalid,               --                                              .tvalid
			intel_vvp_protocol_conv_1_axi4s_vid_in_tready               => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_in_tready,               --                                              .tready
			intel_vvp_protocol_conv_1_axi4s_vid_in_tlast                => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_in_tlast,                --                                              .tlast
			intel_vvp_protocol_conv_1_axi4s_vid_in_tuser                => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_in_tuser,                --                                              .tuser
			intel_vvp_protocol_conv_1_axi4s_vid_out_tdata               => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_out_tdata,               --       intel_vvp_protocol_conv_1_axi4s_vid_out.tdata
			intel_vvp_protocol_conv_1_axi4s_vid_out_tvalid              => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_out_tvalid,              --                                              .tvalid
			intel_vvp_protocol_conv_1_axi4s_vid_out_tready              => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_out_tready,              --                                              .tready
			intel_vvp_protocol_conv_1_axi4s_vid_out_tlast               => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_out_tlast,               --                                              .tlast
			intel_vvp_protocol_conv_1_axi4s_vid_out_tuser               => CONNECTED_TO_intel_vvp_protocol_conv_1_axi4s_vid_out_tuser,               --                                              .tuser
			intel_vvp_protocol_conv_1_av_mm_control_agent_address       => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_address,       -- intel_vvp_protocol_conv_1_av_mm_control_agent.address
			intel_vvp_protocol_conv_1_av_mm_control_agent_write         => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_write,         --                                              .write
			intel_vvp_protocol_conv_1_av_mm_control_agent_byteenable    => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_byteenable,    --                                              .byteenable
			intel_vvp_protocol_conv_1_av_mm_control_agent_writedata     => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_writedata,     --                                              .writedata
			intel_vvp_protocol_conv_1_av_mm_control_agent_read          => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_read,          --                                              .read
			intel_vvp_protocol_conv_1_av_mm_control_agent_readdata      => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_readdata,      --                                              .readdata
			intel_vvp_protocol_conv_1_av_mm_control_agent_readdatavalid => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_readdatavalid, --                                              .readdatavalid
			intel_vvp_protocol_conv_1_av_mm_control_agent_waitrequest   => CONNECTED_TO_intel_vvp_protocol_conv_1_av_mm_control_agent_waitrequest,   --                                              .waitrequest
			intel_vvp_scaler_0_axi4s_vid_in_tdata                       => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_in_tdata,                       --               intel_vvp_scaler_0_axi4s_vid_in.tdata
			intel_vvp_scaler_0_axi4s_vid_in_tvalid                      => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_in_tvalid,                      --                                              .tvalid
			intel_vvp_scaler_0_axi4s_vid_in_tready                      => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_in_tready,                      --                                              .tready
			intel_vvp_scaler_0_axi4s_vid_in_tlast                       => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_in_tlast,                       --                                              .tlast
			intel_vvp_scaler_0_axi4s_vid_in_tuser                       => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_in_tuser,                       --                                              .tuser
			intel_vvp_scaler_0_axi4s_vid_out_tdata                      => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tdata,                      --              intel_vvp_scaler_0_axi4s_vid_out.tdata
			intel_vvp_scaler_0_axi4s_vid_out_tvalid                     => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tvalid,                     --                                              .tvalid
			intel_vvp_scaler_0_axi4s_vid_out_tready                     => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tready,                     --                                              .tready
			intel_vvp_scaler_0_axi4s_vid_out_tlast                      => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tlast,                      --                                              .tlast
			intel_vvp_scaler_0_axi4s_vid_out_tuser                      => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tuser,                      --                                              .tuser
			intel_vvp_tpg_0_axi4s_vid_out_tdata                         => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tdata,                         --                 intel_vvp_tpg_0_axi4s_vid_out.tdata
			intel_vvp_tpg_0_axi4s_vid_out_tvalid                        => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tvalid,                        --                                              .tvalid
			intel_vvp_tpg_0_axi4s_vid_out_tready                        => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tready,                        --                                              .tready
			intel_vvp_tpg_0_axi4s_vid_out_tlast                         => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tlast,                         --                                              .tlast
			intel_vvp_tpg_0_axi4s_vid_out_tuser                         => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tuser,                         --                                              .tuser
			intel_vvp_tpg_0_av_mm_control_agent_address                 => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_address,                 --           intel_vvp_tpg_0_av_mm_control_agent.address
			intel_vvp_tpg_0_av_mm_control_agent_write                   => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_write,                   --                                              .write
			intel_vvp_tpg_0_av_mm_control_agent_byteenable              => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_byteenable,              --                                              .byteenable
			intel_vvp_tpg_0_av_mm_control_agent_writedata               => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_writedata,               --                                              .writedata
			intel_vvp_tpg_0_av_mm_control_agent_read                    => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_read,                    --                                              .read
			intel_vvp_tpg_0_av_mm_control_agent_readdata                => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_readdata,                --                                              .readdata
			intel_vvp_tpg_0_av_mm_control_agent_readdatavalid           => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_readdatavalid,           --                                              .readdatavalid
			intel_vvp_tpg_0_av_mm_control_agent_waitrequest             => CONNECTED_TO_intel_vvp_tpg_0_av_mm_control_agent_waitrequest,             --                                              .waitrequest
			intel_vvp_vfb_0_axi4s_vid_in_tdata                          => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_in_tdata,                          --                  intel_vvp_vfb_0_axi4s_vid_in.tdata
			intel_vvp_vfb_0_axi4s_vid_in_tvalid                         => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_in_tvalid,                         --                                              .tvalid
			intel_vvp_vfb_0_axi4s_vid_in_tready                         => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_in_tready,                         --                                              .tready
			intel_vvp_vfb_0_axi4s_vid_in_tlast                          => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_in_tlast,                          --                                              .tlast
			intel_vvp_vfb_0_axi4s_vid_in_tuser                          => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_in_tuser,                          --                                              .tuser
			intel_vvp_vfb_0_axi4s_vid_out_tdata                         => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_out_tdata,                         --                 intel_vvp_vfb_0_axi4s_vid_out.tdata
			intel_vvp_vfb_0_axi4s_vid_out_tvalid                        => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_out_tvalid,                        --                                              .tvalid
			intel_vvp_vfb_0_axi4s_vid_out_tready                        => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_out_tready,                        --                                              .tready
			intel_vvp_vfb_0_axi4s_vid_out_tlast                         => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_out_tlast,                         --                                              .tlast
			intel_vvp_vfb_0_axi4s_vid_out_tuser                         => CONNECTED_TO_intel_vvp_vfb_0_axi4s_vid_out_tuser,                         --                                              .tuser
			lite_to_full_converter_axi4s_vid_in_tdata                   => CONNECTED_TO_lite_to_full_converter_axi4s_vid_in_tdata,                   --           lite_to_full_converter_axi4s_vid_in.tdata
			lite_to_full_converter_axi4s_vid_in_tvalid                  => CONNECTED_TO_lite_to_full_converter_axi4s_vid_in_tvalid,                  --                                              .tvalid
			lite_to_full_converter_axi4s_vid_in_tready                  => CONNECTED_TO_lite_to_full_converter_axi4s_vid_in_tready,                  --                                              .tready
			lite_to_full_converter_axi4s_vid_in_tlast                   => CONNECTED_TO_lite_to_full_converter_axi4s_vid_in_tlast,                   --                                              .tlast
			lite_to_full_converter_axi4s_vid_in_tuser                   => CONNECTED_TO_lite_to_full_converter_axi4s_vid_in_tuser,                   --                                              .tuser
			lite_to_full_converter_axi4s_vid_out_tdata                  => CONNECTED_TO_lite_to_full_converter_axi4s_vid_out_tdata,                  --          lite_to_full_converter_axi4s_vid_out.tdata
			lite_to_full_converter_axi4s_vid_out_tvalid                 => CONNECTED_TO_lite_to_full_converter_axi4s_vid_out_tvalid,                 --                                              .tvalid
			lite_to_full_converter_axi4s_vid_out_tready                 => CONNECTED_TO_lite_to_full_converter_axi4s_vid_out_tready,                 --                                              .tready
			lite_to_full_converter_axi4s_vid_out_tlast                  => CONNECTED_TO_lite_to_full_converter_axi4s_vid_out_tlast,                  --                                              .tlast
			lite_to_full_converter_axi4s_vid_out_tuser                  => CONNECTED_TO_lite_to_full_converter_axi4s_vid_out_tuser,                  --                                              .tuser
			mm_bridge_0_s0_waitrequest                                  => CONNECTED_TO_mm_bridge_0_s0_waitrequest,                                  --                                mm_bridge_0_s0.waitrequest
			mm_bridge_0_s0_readdata                                     => CONNECTED_TO_mm_bridge_0_s0_readdata,                                     --                                              .readdata
			mm_bridge_0_s0_readdatavalid                                => CONNECTED_TO_mm_bridge_0_s0_readdatavalid,                                --                                              .readdatavalid
			mm_bridge_0_s0_burstcount                                   => CONNECTED_TO_mm_bridge_0_s0_burstcount,                                   --                                              .burstcount
			mm_bridge_0_s0_writedata                                    => CONNECTED_TO_mm_bridge_0_s0_writedata,                                    --                                              .writedata
			mm_bridge_0_s0_address                                      => CONNECTED_TO_mm_bridge_0_s0_address,                                      --                                              .address
			mm_bridge_0_s0_write                                        => CONNECTED_TO_mm_bridge_0_s0_write,                                        --                                              .write
			mm_bridge_0_s0_read                                         => CONNECTED_TO_mm_bridge_0_s0_read,                                         --                                              .read
			mm_bridge_0_s0_byteenable                                   => CONNECTED_TO_mm_bridge_0_s0_byteenable,                                   --                                              .byteenable
			mm_bridge_0_s0_debugaccess                                  => CONNECTED_TO_mm_bridge_0_s0_debugaccess,                                  --                                              .debugaccess
			reset_in_in_reset_reset                                     => CONNECTED_TO_reset_in_in_reset_reset                                      --                             reset_in_in_reset.reset
		);

