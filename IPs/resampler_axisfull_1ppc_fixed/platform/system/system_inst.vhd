	component system is
		port (
			clk_clk                              : in  std_logic                     := 'X';             -- clk
			intel_vvp_crs_0_axi4s_vid_in_tdata   : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			intel_vvp_crs_0_axi4s_vid_in_tvalid  : in  std_logic                     := 'X';             -- tvalid
			intel_vvp_crs_0_axi4s_vid_in_tready  : out std_logic;                                        -- tready
			intel_vvp_crs_0_axi4s_vid_in_tlast   : in  std_logic                     := 'X';             -- tlast
			intel_vvp_crs_0_axi4s_vid_in_tuser   : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			intel_vvp_crs_0_axi4s_vid_out_tdata  : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_crs_0_axi4s_vid_out_tvalid : out std_logic;                                        -- tvalid
			intel_vvp_crs_0_axi4s_vid_out_tready : in  std_logic                     := 'X';             -- tready
			intel_vvp_crs_0_axi4s_vid_out_tlast  : out std_logic;                                        -- tlast
			intel_vvp_crs_0_axi4s_vid_out_tuser  : out std_logic_vector(2 downto 0);                     -- tuser
			intel_vvp_tpg_0_axi4s_vid_out_tdata  : out std_logic_vector(23 downto 0);                    -- tdata
			intel_vvp_tpg_0_axi4s_vid_out_tvalid : out std_logic;                                        -- tvalid
			intel_vvp_tpg_0_axi4s_vid_out_tready : in  std_logic                     := 'X';             -- tready
			intel_vvp_tpg_0_axi4s_vid_out_tlast  : out std_logic;                                        -- tlast
			intel_vvp_tpg_0_axi4s_vid_out_tuser  : out std_logic_vector(2 downto 0);                     -- tuser
			reset_reset                          : in  std_logic                     := 'X'              -- reset
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                              => CONNECTED_TO_clk_clk,                              --                           clk.clk
			intel_vvp_crs_0_axi4s_vid_in_tdata   => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tdata,   --  intel_vvp_crs_0_axi4s_vid_in.tdata
			intel_vvp_crs_0_axi4s_vid_in_tvalid  => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tvalid,  --                              .tvalid
			intel_vvp_crs_0_axi4s_vid_in_tready  => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tready,  --                              .tready
			intel_vvp_crs_0_axi4s_vid_in_tlast   => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tlast,   --                              .tlast
			intel_vvp_crs_0_axi4s_vid_in_tuser   => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_in_tuser,   --                              .tuser
			intel_vvp_crs_0_axi4s_vid_out_tdata  => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tdata,  -- intel_vvp_crs_0_axi4s_vid_out.tdata
			intel_vvp_crs_0_axi4s_vid_out_tvalid => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tvalid, --                              .tvalid
			intel_vvp_crs_0_axi4s_vid_out_tready => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tready, --                              .tready
			intel_vvp_crs_0_axi4s_vid_out_tlast  => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tlast,  --                              .tlast
			intel_vvp_crs_0_axi4s_vid_out_tuser  => CONNECTED_TO_intel_vvp_crs_0_axi4s_vid_out_tuser,  --                              .tuser
			intel_vvp_tpg_0_axi4s_vid_out_tdata  => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tdata,  -- intel_vvp_tpg_0_axi4s_vid_out.tdata
			intel_vvp_tpg_0_axi4s_vid_out_tvalid => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tvalid, --                              .tvalid
			intel_vvp_tpg_0_axi4s_vid_out_tready => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tready, --                              .tready
			intel_vvp_tpg_0_axi4s_vid_out_tlast  => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tlast,  --                              .tlast
			intel_vvp_tpg_0_axi4s_vid_out_tuser  => CONNECTED_TO_intel_vvp_tpg_0_axi4s_vid_out_tuser,  --                              .tuser
			reset_reset                          => CONNECTED_TO_reset_reset                           --                         reset.reset
		);

