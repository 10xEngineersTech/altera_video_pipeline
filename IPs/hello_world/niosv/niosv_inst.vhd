	component niosv is
		port (
			clk_clk                                 : in  std_logic                     := 'X'; -- clk
			intel_vvp_scaler_0_axi4s_vid_out_tdata  : out std_logic_vector(23 downto 0);        -- tdata
			intel_vvp_scaler_0_axi4s_vid_out_tvalid : out std_logic;                            -- tvalid
			intel_vvp_scaler_0_axi4s_vid_out_tready : in  std_logic                     := 'X'; -- tready
			intel_vvp_scaler_0_axi4s_vid_out_tlast  : out std_logic;                            -- tlast
			intel_vvp_scaler_0_axi4s_vid_out_tuser  : out std_logic_vector(2 downto 0)          -- tuser
		);
	end component niosv;

	u0 : component niosv
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                              clk.clk
			intel_vvp_scaler_0_axi4s_vid_out_tdata  => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tdata,  -- intel_vvp_scaler_0_axi4s_vid_out.tdata
			intel_vvp_scaler_0_axi4s_vid_out_tvalid => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tvalid, --                                 .tvalid
			intel_vvp_scaler_0_axi4s_vid_out_tready => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tready, --                                 .tready
			intel_vvp_scaler_0_axi4s_vid_out_tlast  => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tlast,  --                                 .tlast
			intel_vvp_scaler_0_axi4s_vid_out_tuser  => CONNECTED_TO_intel_vvp_scaler_0_axi4s_vid_out_tuser   --                                 .tuser
		);

