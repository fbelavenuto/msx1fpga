
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	port (
		clock_i		: in    std_logic;
		reset_n_i	: in    std_logic;
		addr_i		: in    std_logic_vector(1 downto 0);
		data_io		: inout std_logic_vector(7 downto 0);
		cs_n_i		: in    std_logic;
		rd_n_i		: in    std_logic;
		wr_n_i		: in    std_logic;
		-- counter 0
		clk0_i		: in    std_logic;
		gate0_i		: in    std_logic;
		out0_o		: out   std_logic;
		-- counter 1
		clk1_i		: in    std_logic;
		gate1_i		: in    std_logic;
		out1_o		: out   std_logic;
		-- counter 2
		clk2_i		: in    std_logic;
		gate2_i		: in    std_logic;
		out2_o		: out   std_logic
	);
end entity;

architecture behavior of timer is

	signal isread_s			: std_logic;
	signal iswrite_s			: std_logic;

	signal cnt0_read_s		: std_logic;
	signal cnt0_write_s		: std_logic;
	signal cnt1_read_s		: std_logic;
	signal cnt1_write_s		: std_logic;
	signal cnt2_read_s		: std_logic;
	signal cnt2_write_s		: std_logic;

	signal ctrl_write_s		: std_logic;

begin

	-- Bus Interface
	isread_s		<= '1'	when cs_n_i = '0' and rd_n_i = '0'	else '0';
	iswrite_s	<= '1'	when cs_n_i = '0' and wr_n_i = '0'	else '0';

	cnt0_read_s		<= '1'	when isread_s  = '1' and addr_i = "00"	else '0';
	cnt0_write_s	<= '1'	when iswrite_s = '1' and addr_i = "00"	else '0';

	cnt1_read_s		<= '1'	when isread_s  = '1' and addr_i = "01"	else '0';
	cnt1_write_s	<= '1'	when iswrite_s = '1' and addr_i = "01"	else '0';

	cnt2_read_s		<= '1'	when isread_s  = '1' and addr_i = "10"	else '0';
	cnt2_write_s	<= '1'	when iswrite_s = '1' and addr_i = "10"	else '0';

	ctrl_write_s	<= '1'	when iswrite_s = '1' and addr_i = "11"	else '0';

	-- Counters
	cnt0: entity work.counter
	port map (
		clocksys_i	=> clock_i,
		reset_n_i	=> reset_n_i,
		addr_i		=> "00",
		data_io		=> data_io,
		read_i		=> cnt0_read_s,
		writec_i		=> cnt0_write_s,
		writer_i		=> ctrl_write_s,
		clock_i		=> clk0_i,
		gate_i		=> gate0_i,
		out_o			=> out0_o
	);

	cnt2: entity work.counter
	port map (
		clocksys_i	=> clock_i,
		reset_n_i	=> reset_n_i,
		addr_i		=> "10",
		data_io		=> data_io,
		read_i		=> cnt2_read_s,
		writec_i		=> cnt2_write_s,
		writer_i		=> ctrl_write_s,
		clock_i		=> clk2_i,
		gate_i		=> gate2_i,
		out_o			=> out2_o
	);

	data_io	<= (others => 'Z');

end architecture;