	component system_intel_vvp_protocol_conv_1 is
		port (
			main_clock_clk       : in  std_logic                     := 'X';             -- clk
			main_reset_reset     : in  std_logic                     := 'X';             -- reset
			axi4s_vid_in_tdata   : in  std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			axi4s_vid_in_tvalid  : in  std_logic                     := 'X';             -- tvalid
			axi4s_vid_in_tready  : out std_logic;                                        -- tready
			axi4s_vid_in_tlast   : in  std_logic                     := 'X';             -- tlast
			axi4s_vid_in_tuser   : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			axi4s_vid_out_tdata  : out std_logic_vector(23 downto 0);                    -- tdata
			axi4s_vid_out_tvalid : out std_logic;                                        -- tvalid
			axi4s_vid_out_tready : in  std_logic                     := 'X';             -- tready
			axi4s_vid_out_tlast  : out std_logic;                                        -- tlast
			axi4s_vid_out_tuser  : out std_logic_vector(2 downto 0)                      -- tuser
		);
	end component system_intel_vvp_protocol_conv_1;

	u0 : component system_intel_vvp_protocol_conv_1
		port map (
			main_clock_clk       => CONNECTED_TO_main_clock_clk,       --    main_clock.clk
			main_reset_reset     => CONNECTED_TO_main_reset_reset,     --    main_reset.reset
			axi4s_vid_in_tdata   => CONNECTED_TO_axi4s_vid_in_tdata,   --  axi4s_vid_in.tdata
			axi4s_vid_in_tvalid  => CONNECTED_TO_axi4s_vid_in_tvalid,  --              .tvalid
			axi4s_vid_in_tready  => CONNECTED_TO_axi4s_vid_in_tready,  --              .tready
			axi4s_vid_in_tlast   => CONNECTED_TO_axi4s_vid_in_tlast,   --              .tlast
			axi4s_vid_in_tuser   => CONNECTED_TO_axi4s_vid_in_tuser,   --              .tuser
			axi4s_vid_out_tdata  => CONNECTED_TO_axi4s_vid_out_tdata,  -- axi4s_vid_out.tdata
			axi4s_vid_out_tvalid => CONNECTED_TO_axi4s_vid_out_tvalid, --              .tvalid
			axi4s_vid_out_tready => CONNECTED_TO_axi4s_vid_out_tready, --              .tready
			axi4s_vid_out_tlast  => CONNECTED_TO_axi4s_vid_out_tlast,  --              .tlast
			axi4s_vid_out_tuser  => CONNECTED_TO_axi4s_vid_out_tuser   --              .tuser
		);

