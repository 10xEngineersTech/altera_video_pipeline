	component pipeline_intel_vvp_pipeline2_0 is
		port (
			clk_clk                          : in    std_logic                     := 'X';             -- clk
			reset_reset                      : in    std_logic                     := 'X';             -- reset
			s0_waitrequest                   : out   std_logic;                                        -- waitrequest
			s0_readdata                      : out   std_logic_vector(31 downto 0);                    -- readdata
			s0_readdatavalid                 : out   std_logic;                                        -- readdatavalid
			s0_burstcount                    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			s0_writedata                     : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			s0_address                       : in    std_logic_vector(27 downto 0) := (others => 'X'); -- address
			s0_write                         : in    std_logic                     := 'X';             -- write
			s0_read                          : in    std_logic                     := 'X';             -- read
			s0_byteenable                    : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			s0_debugaccess                   : in    std_logic                     := 'X';             -- debugaccess
			s_axis_video_in_tdata            : in    std_logic_vector(23 downto 0) := (others => 'X'); -- tdata
			s_axis_video_in_tvalid           : in    std_logic                     := 'X';             -- tvalid
			s_axis_video_in_tready           : out   std_logic;                                        -- tready
			s_axis_video_in_tlast            : in    std_logic                     := 'X';             -- tlast
			s_axis_video_in_tuser            : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- tuser
			m_axis_video_out_tdata           : out   std_logic_vector(23 downto 0);                    -- tdata
			m_axis_video_out_tvalid          : out   std_logic;                                        -- tvalid
			m_axis_video_out_tready          : in    std_logic                     := 'X';             -- tready
			m_axis_video_out_tlast           : out   std_logic;                                        -- tlast
			m_axis_video_out_tuser           : out   std_logic_vector(2 downto 0);                     -- tuser
			frc_emif_mem_mem_cke             : out   std_logic_vector(0 downto 0);                     -- mem_cke
			frc_emif_mem_mem_odt             : out   std_logic_vector(0 downto 0);                     -- mem_odt
			frc_emif_mem_mem_cs_n            : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			frc_emif_mem_mem_a               : out   std_logic_vector(16 downto 0);                    -- mem_a
			frc_emif_mem_mem_ba              : out   std_logic_vector(1 downto 0);                     -- mem_ba
			frc_emif_mem_mem_bg              : out   std_logic_vector(0 downto 0);                     -- mem_bg
			frc_emif_mem_mem_act_n           : out   std_logic;                                        -- mem_act_n
			frc_emif_mem_mem_par             : out   std_logic;                                        -- mem_par
			frc_emif_mem_mem_dq              : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			frc_emif_mem_mem_dqs_t           : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_t
			frc_emif_mem_mem_dqs_c           : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_c
			frc_emif_mem_mem_alert_n         : in    std_logic                     := 'X';             -- mem_alert_n
			frc_emif_mem_ck_mem_ck_t         : out   std_logic_vector(0 downto 0);                     -- mem_ck_t
			frc_emif_mem_ck_mem_ck_c         : out   std_logic_vector(0 downto 0);                     -- mem_ck_c
			frc_emif_mem_reset_n_mem_reset_n : out   std_logic;                                        -- mem_reset_n
			frc_emif_oct_oct_rzqin           : in    std_logic                     := 'X';             -- oct_rzqin
			frc_emif_ref_clk_clk             : in    std_logic                     := 'X'              -- clk
		);
	end component pipeline_intel_vvp_pipeline2_0;

	u0 : component pipeline_intel_vvp_pipeline2_0
		port map (
			clk_clk                          => CONNECTED_TO_clk_clk,                          --                  clk.clk
			reset_reset                      => CONNECTED_TO_reset_reset,                      --                reset.reset
			s0_waitrequest                   => CONNECTED_TO_s0_waitrequest,                   --                   s0.waitrequest
			s0_readdata                      => CONNECTED_TO_s0_readdata,                      --                     .readdata
			s0_readdatavalid                 => CONNECTED_TO_s0_readdatavalid,                 --                     .readdatavalid
			s0_burstcount                    => CONNECTED_TO_s0_burstcount,                    --                     .burstcount
			s0_writedata                     => CONNECTED_TO_s0_writedata,                     --                     .writedata
			s0_address                       => CONNECTED_TO_s0_address,                       --                     .address
			s0_write                         => CONNECTED_TO_s0_write,                         --                     .write
			s0_read                          => CONNECTED_TO_s0_read,                          --                     .read
			s0_byteenable                    => CONNECTED_TO_s0_byteenable,                    --                     .byteenable
			s0_debugaccess                   => CONNECTED_TO_s0_debugaccess,                   --                     .debugaccess
			s_axis_video_in_tdata            => CONNECTED_TO_s_axis_video_in_tdata,            --      s_axis_video_in.tdata
			s_axis_video_in_tvalid           => CONNECTED_TO_s_axis_video_in_tvalid,           --                     .tvalid
			s_axis_video_in_tready           => CONNECTED_TO_s_axis_video_in_tready,           --                     .tready
			s_axis_video_in_tlast            => CONNECTED_TO_s_axis_video_in_tlast,            --                     .tlast
			s_axis_video_in_tuser            => CONNECTED_TO_s_axis_video_in_tuser,            --                     .tuser
			m_axis_video_out_tdata           => CONNECTED_TO_m_axis_video_out_tdata,           --     m_axis_video_out.tdata
			m_axis_video_out_tvalid          => CONNECTED_TO_m_axis_video_out_tvalid,          --                     .tvalid
			m_axis_video_out_tready          => CONNECTED_TO_m_axis_video_out_tready,          --                     .tready
			m_axis_video_out_tlast           => CONNECTED_TO_m_axis_video_out_tlast,           --                     .tlast
			m_axis_video_out_tuser           => CONNECTED_TO_m_axis_video_out_tuser,           --                     .tuser
			frc_emif_mem_mem_cke             => CONNECTED_TO_frc_emif_mem_mem_cke,             --         frc_emif_mem.mem_cke
			frc_emif_mem_mem_odt             => CONNECTED_TO_frc_emif_mem_mem_odt,             --                     .mem_odt
			frc_emif_mem_mem_cs_n            => CONNECTED_TO_frc_emif_mem_mem_cs_n,            --                     .mem_cs_n
			frc_emif_mem_mem_a               => CONNECTED_TO_frc_emif_mem_mem_a,               --                     .mem_a
			frc_emif_mem_mem_ba              => CONNECTED_TO_frc_emif_mem_mem_ba,              --                     .mem_ba
			frc_emif_mem_mem_bg              => CONNECTED_TO_frc_emif_mem_mem_bg,              --                     .mem_bg
			frc_emif_mem_mem_act_n           => CONNECTED_TO_frc_emif_mem_mem_act_n,           --                     .mem_act_n
			frc_emif_mem_mem_par             => CONNECTED_TO_frc_emif_mem_mem_par,             --                     .mem_par
			frc_emif_mem_mem_dq              => CONNECTED_TO_frc_emif_mem_mem_dq,              --                     .mem_dq
			frc_emif_mem_mem_dqs_t           => CONNECTED_TO_frc_emif_mem_mem_dqs_t,           --                     .mem_dqs_t
			frc_emif_mem_mem_dqs_c           => CONNECTED_TO_frc_emif_mem_mem_dqs_c,           --                     .mem_dqs_c
			frc_emif_mem_mem_alert_n         => CONNECTED_TO_frc_emif_mem_mem_alert_n,         --                     .mem_alert_n
			frc_emif_mem_ck_mem_ck_t         => CONNECTED_TO_frc_emif_mem_ck_mem_ck_t,         --      frc_emif_mem_ck.mem_ck_t
			frc_emif_mem_ck_mem_ck_c         => CONNECTED_TO_frc_emif_mem_ck_mem_ck_c,         --                     .mem_ck_c
			frc_emif_mem_reset_n_mem_reset_n => CONNECTED_TO_frc_emif_mem_reset_n_mem_reset_n, -- frc_emif_mem_reset_n.mem_reset_n
			frc_emif_oct_oct_rzqin           => CONNECTED_TO_frc_emif_oct_oct_rzqin,           --         frc_emif_oct.oct_rzqin
			frc_emif_ref_clk_clk             => CONNECTED_TO_frc_emif_ref_clk_clk              --     frc_emif_ref_clk.clk
		);

