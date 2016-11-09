--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity romnextor is
	port (
		reset_i		: in  std_logic;
		clock_i		: in  std_logic;
		enable_i		: in  std_logic;
		addr_i		: in  std_logic_vector(15 downto 0);
		data_i		: in  std_logic_vector( 7 downto 0);
		sltsl_n_i	: in  std_logic;
		rd_n_i		: in  std_logic;
		wr_n_i		: in  std_logic;
		--
		rom_cs_o		: out std_logic;
		rom_page_o	: out std_logic_vector( 2 downto 0)
	);
end entity;

architecture Behavior of romnextor is

	signal rom_page_s	: std_logic_vector(2 downto 0);
	signal rom_cs_s	: std_logic;

begin

	-- Writes
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
			rom_page_s	<= (others => '0');
		elsif falling_edge(clock_i) then
			if enable_i = '1' then
				if sltsl_n_i = '0' and wr_n_i = '0' and addr_i = X"6000" then
					rom_page_s <= data_i(2 downto 0);
				end if;
			end if;
		end if;
	end process;

	rom_page_o <= rom_page_s;

	rom_cs_s <=	'0' when enable_i = '0'																		else
					'1' when sltsl_n_i = '0' and rd_n_i = '0' and addr_i(15 downto 14) = "01"	else
					'1' when sltsl_n_i = '0' and rd_n_i = '0' and addr_i(15 downto 14) = "10"	else
					'0';

	rom_cs_o <= rom_cs_s;

end architecture;