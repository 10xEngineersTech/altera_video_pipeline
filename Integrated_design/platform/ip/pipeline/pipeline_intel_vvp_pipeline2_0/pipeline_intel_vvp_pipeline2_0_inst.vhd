	component pipeline_intel_vvp_pipeline2_0 is
		port (
			clk_clk                 : in  std_logic                     := 'X';             -- clk
			reset_reset             : in  std_logic                     := 'X';             -- reset
			s0_waitrequest          : out std_logic;                                        -- waitrequest
			s0_readdata             : out std_logic_vector(31 downto 0);                    -- readdata
			s0_readdatavalid        : out std_logic;                                        -- readdatavalid
			s0_burstcount           : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			s0_writedata            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			s0_address              : in  std_logic_vector(12 downto 0) := (others => 'X'); -- address
			s0_write                : in  std_logic                     := 'X';             -- write
			s0_read                 : in  std_logic                     := 'X';             -- read
			s0_byteenable           : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			s0_debugaccess          : in  std_logic                     := 'X';             -- debugaccess
			s_axis_video_in_tdata   : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			s_axis_video_in_tvalid  : in  std_logic                     := 'X';             -- tvalid
			s_axis_video_in_tready  : out std_logic;                                        -- tready
			s_axis_video_in_tlast   : in  std_logic                     := 'X';             -- tlast
			s_axis_video_in_tuser   : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			m_axis_video_out_tdata  : out std_logic_vector(15 downto 0);                    -- tdata
			m_axis_video_out_tvalid : out std_logic;                                        -- tvalid
			m_axis_video_out_tready : in  std_logic                     := 'X';             -- tready
			m_axis_video_out_tlast  : out std_logic;                                        -- tlast
			m_axis_video_out_tuser  : out std_logic_vector(1 downto 0)                      -- tuser
		);
	end component pipeline_intel_vvp_pipeline2_0;

	u0 : component pipeline_intel_vvp_pipeline2_0
		port map (
			clk_clk                 => CONNECTED_TO_clk_clk,                 --              clk.clk
			reset_reset             => CONNECTED_TO_reset_reset,             --            reset.reset
			s0_waitrequest          => CONNECTED_TO_s0_waitrequest,          --               s0.waitrequest
			s0_readdata             => CONNECTED_TO_s0_readdata,             --                 .readdata
			s0_readdatavalid        => CONNECTED_TO_s0_readdatavalid,        --                 .readdatavalid
			s0_burstcount           => CONNECTED_TO_s0_burstcount,           --                 .burstcount
			s0_writedata            => CONNECTED_TO_s0_writedata,            --                 .writedata
			s0_address              => CONNECTED_TO_s0_address,              --                 .address
			s0_write                => CONNECTED_TO_s0_write,                --                 .write
			s0_read                 => CONNECTED_TO_s0_read,                 --                 .read
			s0_byteenable           => CONNECTED_TO_s0_byteenable,           --                 .byteenable
			s0_debugaccess          => CONNECTED_TO_s0_debugaccess,          --                 .debugaccess
			s_axis_video_in_tdata   => CONNECTED_TO_s_axis_video_in_tdata,   --  s_axis_video_in.tdata
			s_axis_video_in_tvalid  => CONNECTED_TO_s_axis_video_in_tvalid,  --                 .tvalid
			s_axis_video_in_tready  => CONNECTED_TO_s_axis_video_in_tready,  --                 .tready
			s_axis_video_in_tlast   => CONNECTED_TO_s_axis_video_in_tlast,   --                 .tlast
			s_axis_video_in_tuser   => CONNECTED_TO_s_axis_video_in_tuser,   --                 .tuser
			m_axis_video_out_tdata  => CONNECTED_TO_m_axis_video_out_tdata,  -- m_axis_video_out.tdata
			m_axis_video_out_tvalid => CONNECTED_TO_m_axis_video_out_tvalid, --                 .tvalid
			m_axis_video_out_tready => CONNECTED_TO_m_axis_video_out_tready, --                 .tready
			m_axis_video_out_tlast  => CONNECTED_TO_m_axis_video_out_tlast,  --                 .tlast
			m_axis_video_out_tuser  => CONNECTED_TO_m_axis_video_out_tuser   --                 .tuser
		);

