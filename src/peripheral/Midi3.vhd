
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Midi3 is
	port (
		clocksys_i		: in    std_logic;
		clock_8m_i		: in    std_logic;
		reset_n_i		: in    std_logic;
		addr_i			: in    std_logic_vector(2 downto 0);
		data_i			: in    std_logic_vector(7 downto 0);
		data_o			: out   std_logic_vector(7 downto 0);
		has_data_o		: out   std_logic;
		cs_n_i			: in    std_logic;
		wr_n_i			: in    std_logic;
		rd_n_i			: in    std_logic;
		int_n_o			: out   std_logic;
		-- UART
		rxd_i				: in    std_logic;
		txd_o				: out   std_logic;
		-- Debug
		D_out0_o			: out   std_logic;
		D_out2_o			: out   std_logic
	);
end entity;

architecture Behavior of Midi3 is

	signal busdir_s		: std_logic;
	signal i8251_cs_n_s	: std_logic;
	signal i8253_cs_n_s	: std_logic;
	signal ffint_cs_n_s	: std_logic;
	signal ffint_wr_s		: std_logic;
	signal ffint_q			: std_logic;
	signal ffint_n_s		: std_logic;
	signal databd_s		: std_logic_vector(7 downto 0);
	signal clock_4m_s		: std_logic;
	signal out0_s			: std_logic;
	signal out2_s			: std_logic;
	signal rts_s			: std_logic;
	signal dtr_s			: std_logic;

begin

	process(reset_n_i, clock_8m_i)
	begin
		if reset_n_i = '0' then
			clock_4m_s	<= '0';
		elsif rising_edge(clock_8m_i) then
			clock_4m_s <= not clock_4m_s;
		end if;
	end process;

	i8251_cs_n_s	<= '0'	when cs_n_i = '0' and addr_i(2 downto 1) = "00"		else '1';
	ffint_cs_n_s	<= '0'	when cs_n_i = '0' and addr_i(2 downto 1) = "01"		else '1';
	i8253_cs_n_s	<= '0'	when cs_n_i = '0' and addr_i(2)			  = '1'		else '1';

	busdir_s	<= '0'	when rd_n_i = '0' and (i8251_cs_n_s = '0' or ffint_cs_n_s = '0' or i8253_cs_n_s = '0')	else '1';

	databd_s		<= data_i	when busdir_s = '1'	else (others => 'Z');
	data_o		<= databd_s	when busdir_s = '0'	else (others => '1');
	has_data_o	<= not busdir_s;

	tmr: entity work.timer
	port map (
		clock_i		=> clocksys_i,
		reset_n_i	=> reset_n_i,
		addr_i		=> addr_i(1 downto 0),
		data_io		=> databd_s,
		cs_n_i		=> i8253_cs_n_s,
		rd_n_i		=> rd_n_i,
		wr_n_i		=> wr_n_i,
		-- counter 0
		clk0_i		=> clock_4m_s,
		gate0_i		=> '1',
		out0_o		=> out0_s,
		-- counter 1
		clk1_i		=> out2_s,
		gate1_i		=> '0',
		out1_o		=> open,
		-- counter 2
		clk2_i		=> clock_4m_s,
		gate2_i		=> '1',
		out2_o		=> out2_s
	);

	serial: entity work.UART
	port map (
		clock_sys_i	=> clocksys_i,
		clock_i		=> out0_s,
		reset_n_i	=> reset_n_i,
		addr_i		=> addr_i(0),
		data_io		=> databd_s,
		cs_n_i		=> i8251_cs_n_s,
		rd_n_i		=> rd_n_i,
		wr_n_i		=> wr_n_i,
		rxd_i			=> rxd_i,
		txd_o			=> txd_o,
		dsr_n_i		=> ffint_n_s,
		cts_n_i		=> '0',
		rts_n_o		=> rts_s,
		dtr_n_o		=> dtr_s
	);

	ffint_wr_s	<= '1'	when ffint_cs_n_s = '0' and wr_n_i = '0'	else '0';

	process (reset_n_i, ffint_wr_s, out2_s)
	begin
		if reset_n_i = '0' or ffint_wr_s = '1'	then
			ffint_q	<= '1';
		elsif rising_edge(out2_s) then
			ffint_q	<= '0';
		end if;

	end process;

	ffint_n_s	<= not ffint_q;
	int_n_o	<= ffint_q or not dtr_s;

	-- Debug
	D_out0_o		<= out0_s;
	D_out2_o		<= out2_s;

end architecture;
