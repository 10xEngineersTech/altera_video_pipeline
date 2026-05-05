	component pl_sys is
		port (
			clk_clk              : in  std_logic                     := 'X'; -- clk
			axi4s_vid_out_tdata  : out std_logic_vector(23 downto 0);        -- tdata
			axi4s_vid_out_tvalid : out std_logic;                            -- tvalid
			axi4s_vid_out_tready : in  std_logic                     := 'X'; -- tready
			axi4s_vid_out_tlast  : out std_logic;                            -- tlast
			axi4s_vid_out_tuser  : out std_logic_vector(2 downto 0);         -- tuser
			reset_reset          : in  std_logic                     := 'X'  -- reset
		);
	end component pl_sys;

	u0 : component pl_sys
		port map (
			clk_clk              => CONNECTED_TO_clk_clk,              --           clk.clk
			axi4s_vid_out_tdata  => CONNECTED_TO_axi4s_vid_out_tdata,  -- axi4s_vid_out.tdata
			axi4s_vid_out_tvalid => CONNECTED_TO_axi4s_vid_out_tvalid, --              .tvalid
			axi4s_vid_out_tready => CONNECTED_TO_axi4s_vid_out_tready, --              .tready
			axi4s_vid_out_tlast  => CONNECTED_TO_axi4s_vid_out_tlast,  --              .tlast
			axi4s_vid_out_tuser  => CONNECTED_TO_axi4s_vid_out_tuser,  --              .tuser
			reset_reset          => CONNECTED_TO_reset_reset           --         reset.reset
		);

