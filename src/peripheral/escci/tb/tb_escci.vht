--
-- Copyright (c) 2016 - Fabio Belavenuto
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end tb;

architecture testbench of tb is

	-- test target
	component escci
	port(
		clock_i		: in  std_logic;
		clock_en_i	: in  std_logic;
		reset_i		: in  std_logic;
		--
		addr_i		: in  std_logic_vector(15 downto 0);
		data_i		: in  std_logic_vector( 7 downto 0);
		data_o		: out std_logic_vector( 7 downto 0);
		cs_i			: in  std_logic;
		rd_i			: in  std_logic;
		wr_i			: in  std_logic;
		--
		ram_addr_o	: out std_logic_vector(18 downto 0);	-- 512KB
		ram_data_i	: in  std_logic_vector( 7 downto 0);
		ram_ce_o		: out std_logic;
		ram_oe_o		: out std_logic;
		ram_we_o		: out std_logic;
		--
		map_type_i	: in  std_logic_vector( 1 downto 0);  -- "-0" : SCC+, "01" : ASC8K, "11" : ASC16K
		--
		wave_o		: out std_logic_vector(14 downto 0)
	);
	end component;

	signal tb_end			: std_logic;
	signal clock_s		: std_logic;
	signal clock_en_s	: std_logic;
	signal reset_s		: std_logic;
	signal addr_s		: std_logic_vector(15 downto 0);
	signal data_i_s		: std_logic_vector( 7 downto 0);
	signal data_o_s		: std_logic_vector( 7 downto 0);
	signal cs_s			: std_logic;
	signal rd_s			: std_logic;
	signal wr_s			: std_logic;
	signal ram_addr_s	: std_logic_vector(18 downto 0);	-- 512KB
	signal ram_data_s	: std_logic_vector( 7 downto 0);
	signal ram_ce_s		: std_logic;
	signal ram_oe_s		: std_logic;
	signal ram_we_s		: std_logic;
	signal map_type_s	: std_logic_vector( 1 downto 0);  -- "-0" : SCC+, "01" : ASC8K, "11" : ASC16K
	signal wave_s		: std_logic_vector(14 downto 0);

begin

	--  instance
	u_target: escci
	port map(
		clock_i			=> clock_s,
		clock_en_i	=> clock_en_s,
		reset_i		=> reset_s,
		--
		addr_i		=> addr_s,
		data_i		=> data_i_s,
		data_o		=> data_o_s,
		cs_i			=> cs_s,
		rd_i			=> rd_s,
		wr_i			=> wr_s,
		--
		ram_addr_o	=> ram_addr_s,
		ram_data_i	=> ram_data_s,
		ram_ce_o		=> ram_ce_s,
		ram_oe_o		=> ram_oe_s,
		ram_we_o		=> ram_we_s,
		--
		map_type_i	=> map_type_s,
		--
		wave_o		=> wave_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 23.280418648974914278006471677019 ns;
		clock_s <= '1';
		wait for 23.280418648974914278006471677019 ns;
	end process;

	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_en_s <= '1';
		wait for 23.280418648974914278006471677019 ns;
		clock_en_s <= '0';
		for i in 0 to 10 loop
			wait for 23.280418648974914278006471677019 ns;
		end loop;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		map_type_s	<= "00";
		addr_s		<= (others => '0');
		data_i_s	<= (others => '0');
		cs_s		<= '0';
		rd_s		<= '0';
		wr_s		<= '0';
		ram_data_s	<= (others => '0');		

		-- reset
		reset_s	<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s	<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 1 us;

		-- Set bank2 to 0x3F (select SCC)
		addr_s		<= X"9000";
		data_i_s	<= X"3F";
		wait until( rising_edge(clock_s) );
		cs_s		<= '1';
		wr_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		wr_s		<= '0';
		addr_s		<= X"0000";
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Write 0xAA to 0x9800
		addr_s		<= X"9800";
		data_i_s	<= X"AA";
		wait until( rising_edge(clock_s) );
		cs_s		<= '1';
		wr_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		wait until( rising_edge(clock_s) );
		wr_s		<= '0';
		addr_s		<= X"0000";
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Read from 0x9C00
		addr_s		<= X"9C00";
		cs_s		<= '1';
		rd_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		rd_s		<= '0';
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Write 0x55 to 0x986F
		addr_s		<= X"986F";
		data_i_s	<= X"55";
		wait until( rising_edge(clock_s) );
		cs_s		<= '1';
		wr_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		wr_s		<= '0';
		addr_s		<= X"0000";
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Set bank3 to 0x80 (select SCC+)
		addr_s		<= X"B000";
		data_i_s	<= X"80";
		wait until( rising_edge(clock_s) );
		cs_s		<= '1';
		wr_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		wr_s		<= '0';
		addr_s		<= X"0000";
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Write 0x20 to 0xBFFE (bit 5=1 => mode SCC+)
		addr_s		<= X"BFFE";
		data_i_s	<= X"20";
		wait until( rising_edge(clock_s) );
		cs_s		<= '1';
		wr_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		wr_s		<= '0';
		addr_s		<= X"0000";
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Read from 0xB86F
		addr_s		<= X"B86F";
		cs_s		<= '1';
		rd_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		rd_s		<= '0';
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- Read from 0xB88F
		addr_s		<= X"B88F";
		cs_s		<= '1';
		rd_s		<= '1';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		rd_s		<= '0';
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
