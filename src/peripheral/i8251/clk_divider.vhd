
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; -- use '+' operator, CONV_INTEGER func.

entity clk_divider is
	port(
		clock_i		: in  std_logic;
		reset_n_i	: in  std_logic;
		baudsel_i	: in  std_logic_vector(1 downto 0);
		baudclk_o	: out std_logic
	);
end entity;

architecture baudgen of clk_divider is

	signal counter_q		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal clock_out_s	: std_logic;

begin

	-- Coouter used to divide clock
	process (reset_n_i, clock_i)
	begin
		if reset_n_i = '0' then
			counter_q	<= (others => '0');
		elsif rising_edge(clock_i) then
			counter_q	<= counter_q + 1;
		end if;
	end process;

	-- select baud rate
	clock_out_s	<= clock_i			when baudsel_i = "00"	else		-- Sync Mode (not implemented)
						clock_i			when baudsel_i = "01"	else		-- / 1
						counter_q(3)	when baudsel_i = "10"	else		-- / 16
						counter_q(5);												-- / 64


	baudclk_o	<= clock_out_s;

end architecture;