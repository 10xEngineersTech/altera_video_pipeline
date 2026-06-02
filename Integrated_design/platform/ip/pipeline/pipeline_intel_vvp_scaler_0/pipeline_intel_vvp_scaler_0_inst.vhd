	component pipeline_intel_vvp_scaler_0 is
		port (
			main_clock_clk                    : in  std_logic                     := 'X';             -- clk
			main_reset_reset                  : in  std_logic                     := 'X';             -- reset
			axi4s_vid_in_tdata                : in  std_logic_vector(15 downto 0) := (others => 'X'); -- tdata
			axi4s_vid_in_tvalid               : in  std_logic                     := 'X';             -- tvalid
			axi4s_vid_in_tready               : out std_logic;                                        -- tready
			axi4s_vid_in_tlast                : in  std_logic                     := 'X';             -- tlast
			axi4s_vid_in_tuser                : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- tuser
			axi4s_vid_out_tdata               : out std_logic_vector(15 downto 0);                    -- tdata
			axi4s_vid_out_tvalid              : out std_logic;                                        -- tvalid
			axi4s_vid_out_tready              : in  std_logic                     := 'X';             -- tready
			axi4s_vid_out_tlast               : out std_logic;                                        -- tlast
			axi4s_vid_out_tuser               : out std_logic_vector(1 downto 0);                     -- tuser
			av_mm_control_agent_address       : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			av_mm_control_agent_write         : in  std_logic                     := 'X';             -- write
			av_mm_control_agent_byteenable    : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			av_mm_control_agent_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			av_mm_control_agent_read          : in  std_logic                     := 'X';             -- read
			av_mm_control_agent_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			av_mm_control_agent_readdatavalid : out std_logic;                                        -- readdatavalid
			av_mm_control_agent_waitrequest   : out std_logic                                         -- waitrequest
		);
	end component pipeline_intel_vvp_scaler_0;

	u0 : component pipeline_intel_vvp_scaler_0
		port map (
			main_clock_clk                    => CONNECTED_TO_main_clock_clk,                    --          main_clock.clk
			main_reset_reset                  => CONNECTED_TO_main_reset_reset,                  --          main_reset.reset
			axi4s_vid_in_tdata                => CONNECTED_TO_axi4s_vid_in_tdata,                --        axi4s_vid_in.tdata
			axi4s_vid_in_tvalid               => CONNECTED_TO_axi4s_vid_in_tvalid,               --                    .tvalid
			axi4s_vid_in_tready               => CONNECTED_TO_axi4s_vid_in_tready,               --                    .tready
			axi4s_vid_in_tlast                => CONNECTED_TO_axi4s_vid_in_tlast,                --                    .tlast
			axi4s_vid_in_tuser                => CONNECTED_TO_axi4s_vid_in_tuser,                --                    .tuser
			axi4s_vid_out_tdata               => CONNECTED_TO_axi4s_vid_out_tdata,               --       axi4s_vid_out.tdata
			axi4s_vid_out_tvalid              => CONNECTED_TO_axi4s_vid_out_tvalid,              --                    .tvalid
			axi4s_vid_out_tready              => CONNECTED_TO_axi4s_vid_out_tready,              --                    .tready
			axi4s_vid_out_tlast               => CONNECTED_TO_axi4s_vid_out_tlast,               --                    .tlast
			axi4s_vid_out_tuser               => CONNECTED_TO_axi4s_vid_out_tuser,               --                    .tuser
			av_mm_control_agent_address       => CONNECTED_TO_av_mm_control_agent_address,       -- av_mm_control_agent.address
			av_mm_control_agent_write         => CONNECTED_TO_av_mm_control_agent_write,         --                    .write
			av_mm_control_agent_byteenable    => CONNECTED_TO_av_mm_control_agent_byteenable,    --                    .byteenable
			av_mm_control_agent_writedata     => CONNECTED_TO_av_mm_control_agent_writedata,     --                    .writedata
			av_mm_control_agent_read          => CONNECTED_TO_av_mm_control_agent_read,          --                    .read
			av_mm_control_agent_readdata      => CONNECTED_TO_av_mm_control_agent_readdata,      --                    .readdata
			av_mm_control_agent_readdatavalid => CONNECTED_TO_av_mm_control_agent_readdatavalid, --                    .readdatavalid
			av_mm_control_agent_waitrequest   => CONNECTED_TO_av_mm_control_agent_waitrequest    --                    .waitrequest
		);

