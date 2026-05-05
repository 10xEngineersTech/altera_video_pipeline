	component system is
		port (
			alt_vip_cl_crs_0_dout_data          : out std_logic_vector(47 downto 0);        -- data
			alt_vip_cl_crs_0_dout_valid         : out std_logic;                            -- valid
			alt_vip_cl_crs_0_dout_startofpacket : out std_logic;                            -- startofpacket
			alt_vip_cl_crs_0_dout_endofpacket   : out std_logic;                            -- endofpacket
			alt_vip_cl_crs_0_dout_empty         : out std_logic_vector(2 downto 0);         -- empty
			alt_vip_cl_crs_0_dout_ready         : in  std_logic                     := 'X'; -- ready
			clk_clk                             : in  std_logic                     := 'X'; -- clk
			reset_reset                         : in  std_logic                     := 'X'  -- reset
		);
	end component system;

	u0 : component system
		port map (
			alt_vip_cl_crs_0_dout_data          => CONNECTED_TO_alt_vip_cl_crs_0_dout_data,          -- alt_vip_cl_crs_0_dout.data
			alt_vip_cl_crs_0_dout_valid         => CONNECTED_TO_alt_vip_cl_crs_0_dout_valid,         --                      .valid
			alt_vip_cl_crs_0_dout_startofpacket => CONNECTED_TO_alt_vip_cl_crs_0_dout_startofpacket, --                      .startofpacket
			alt_vip_cl_crs_0_dout_endofpacket   => CONNECTED_TO_alt_vip_cl_crs_0_dout_endofpacket,   --                      .endofpacket
			alt_vip_cl_crs_0_dout_empty         => CONNECTED_TO_alt_vip_cl_crs_0_dout_empty,         --                      .empty
			alt_vip_cl_crs_0_dout_ready         => CONNECTED_TO_alt_vip_cl_crs_0_dout_ready,         --                      .ready
			clk_clk                             => CONNECTED_TO_clk_clk,                             --                   clk.clk
			reset_reset                         => CONNECTED_TO_reset_reset                          --                 reset.reset
		);

