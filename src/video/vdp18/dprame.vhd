-------------------------------------------------------------------------------
-- $Id: dprame.vhd,v 1.1 2006/02/23 21:46:45 arnim Exp $
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dprame is
	generic (
		addr_width_g : integer := 8;
		data_width_g : integer := 8
	);
	port (
		clock_master_i	: in  std_logic;
		clock_a_en_i	: in  std_logic;
		we_i			: in  std_logic;
		addr_a_i		: in  std_logic_vector(addr_width_g-1 downto 0);
		data_a_i		: in  std_logic_vector(data_width_g-1 downto 0);
		clock_b_en_i	: in  std_logic;
		addr_b_i		: in  std_logic_vector(addr_width_g-1 downto 0);
		data_b_o		: out std_logic_vector(data_width_g-1 downto 0)
	);
end entity;

library ieee;
use ieee.numeric_std.all;

architecture rtl of dprame is

	type   ram_t	is array (natural range 2**addr_width_g-1 downto 0) of std_logic_vector(data_width_g-1 downto 0);
	signal ram_q	: ram_t;

begin

	mem_a: process (clock_master_i, clock_a_en_i)
		variable read_addr_v	: unsigned(addr_width_g-1 downto 0);
	begin
		if rising_edge(clock_master_i) and clock_a_en_i = '1' then
			read_addr_v := unsigned(addr_a_i);
			if we_i = '1' then
				ram_q(to_integer(read_addr_v)) <= data_a_i;
			end if;
		end if;
	end process mem_a;

	mem_b: process (clock_master_i, clock_b_en_i)
		variable read_addr_v	: unsigned(addr_width_g-1 downto 0);
	begin
		if rising_edge(clock_master_i) and clock_b_en_i = '1' then
			read_addr_v := unsigned(addr_b_i);
			data_b_o <= ram_q(to_integer(read_addr_v));
		end if;
	end process mem_b;

end architecture;
