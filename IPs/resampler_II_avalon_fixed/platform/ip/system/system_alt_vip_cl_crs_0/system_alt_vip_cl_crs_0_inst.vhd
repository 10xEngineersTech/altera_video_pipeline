	component system_alt_vip_cl_crs_0 is
		port (
			main_clock         : in  std_logic                     := 'X';             -- clk
			main_reset         : in  std_logic                     := 'X';             -- reset
			din_data           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			din_valid          : in  std_logic                     := 'X';             -- valid
			din_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			din_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			din_empty          : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- empty
			din_ready          : out std_logic;                                        -- ready
			dout_data          : out std_logic_vector(47 downto 0);                    -- data
			dout_valid         : out std_logic;                                        -- valid
			dout_startofpacket : out std_logic;                                        -- startofpacket
			dout_endofpacket   : out std_logic;                                        -- endofpacket
			dout_empty         : out std_logic_vector(2 downto 0);                     -- empty
			dout_ready         : in  std_logic                     := 'X'              -- ready
		);
	end component system_alt_vip_cl_crs_0;

	u0 : component system_alt_vip_cl_crs_0
		port map (
			main_clock         => CONNECTED_TO_main_clock,         -- main_clock.clk
			main_reset         => CONNECTED_TO_main_reset,         -- main_reset.reset
			din_data           => CONNECTED_TO_din_data,           --        din.data
			din_valid          => CONNECTED_TO_din_valid,          --           .valid
			din_startofpacket  => CONNECTED_TO_din_startofpacket,  --           .startofpacket
			din_endofpacket    => CONNECTED_TO_din_endofpacket,    --           .endofpacket
			din_empty          => CONNECTED_TO_din_empty,          --           .empty
			din_ready          => CONNECTED_TO_din_ready,          --           .ready
			dout_data          => CONNECTED_TO_dout_data,          --       dout.data
			dout_valid         => CONNECTED_TO_dout_valid,         --           .valid
			dout_startofpacket => CONNECTED_TO_dout_startofpacket, --           .startofpacket
			dout_endofpacket   => CONNECTED_TO_dout_endofpacket,   --           .endofpacket
			dout_empty         => CONNECTED_TO_dout_empty,         --           .empty
			dout_ready         => CONNECTED_TO_dout_ready          --           .ready
		);

