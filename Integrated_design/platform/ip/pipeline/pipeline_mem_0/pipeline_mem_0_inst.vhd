	component pipeline_mem_0 is
		port (
			mem_cke_0     : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_cke
			mem_odt_0     : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_odt
			mem_cs_n_0    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_cs_n
			mem_a_0       : in    std_logic_vector(16 downto 0) := (others => 'X'); -- mem_a
			mem_ba_0      : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- mem_ba
			mem_bg_0      : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_bg
			mem_act_n_0   : in    std_logic                     := 'X';             -- mem_act_n
			mem_par_0     : in    std_logic                     := 'X';             -- mem_par
			mem_dq_0      : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			mem_dqs_t_0   : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_t
			mem_dqs_c_0   : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_c
			mem_alert_n_0 : out   std_logic;                                        -- mem_alert_n
			mem_ck_t_0    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_ck_t
			mem_ck_c_0    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- mem_ck_c
			mem_reset_n_0 : in    std_logic                     := 'X';             -- mem_reset_n
			oct_rzqin_0   : out   std_logic                                         -- oct_rzqin
		);
	end component pipeline_mem_0;

	u0 : component pipeline_mem_0
		port map (
			mem_cke_0     => CONNECTED_TO_mem_cke_0,     --       mem_0.mem_cke
			mem_odt_0     => CONNECTED_TO_mem_odt_0,     --            .mem_odt
			mem_cs_n_0    => CONNECTED_TO_mem_cs_n_0,    --            .mem_cs_n
			mem_a_0       => CONNECTED_TO_mem_a_0,       --            .mem_a
			mem_ba_0      => CONNECTED_TO_mem_ba_0,      --            .mem_ba
			mem_bg_0      => CONNECTED_TO_mem_bg_0,      --            .mem_bg
			mem_act_n_0   => CONNECTED_TO_mem_act_n_0,   --            .mem_act_n
			mem_par_0     => CONNECTED_TO_mem_par_0,     --            .mem_par
			mem_dq_0      => CONNECTED_TO_mem_dq_0,      --            .mem_dq
			mem_dqs_t_0   => CONNECTED_TO_mem_dqs_t_0,   --            .mem_dqs_t
			mem_dqs_c_0   => CONNECTED_TO_mem_dqs_c_0,   --            .mem_dqs_c
			mem_alert_n_0 => CONNECTED_TO_mem_alert_n_0, --            .mem_alert_n
			mem_ck_t_0    => CONNECTED_TO_mem_ck_t_0,    --    mem_ck_0.mem_ck_t
			mem_ck_c_0    => CONNECTED_TO_mem_ck_c_0,    --            .mem_ck_c
			mem_reset_n_0 => CONNECTED_TO_mem_reset_n_0, -- mem_reset_n.mem_reset_n
			oct_rzqin_0   => CONNECTED_TO_oct_rzqin_0    --       oct_0.oct_rzqin
		);

