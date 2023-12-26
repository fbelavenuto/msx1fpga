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

	signal tb_end			: std_logic;
	signal clock_s			: std_logic;
	signal clock_en_s		: std_logic;
	signal reset_s			: std_logic;
	signal addr_s			: std_logic_vector(15 downto 0);
	signal data_i_s			: std_logic_vector( 7 downto 0);
	signal data_o_s			: std_logic_vector( 7 downto 0);
	signal req_s			: std_logic;
	signal cs_n_s			: std_logic;
	signal rd_n_s			: std_logic;
	signal wr_n_s			: std_logic;
	signal ram_addr_s		: std_logic_vector(19 downto 0);	-- 1MB
	signal ram_data_s		: std_logic_vector( 7 downto 0);
	signal ram_ce_n_s		: std_logic;
	signal ram_oe_n_s		: std_logic;
	signal ram_we_n_s		: std_logic;
	signal map_type_s		: std_logic_vector( 1 downto 0);  -- "-0" : SCC+, "01" : ASC8K, "11" : ASC16K
	signal wave_s			: signed(14 downto 0);

	procedure write_p(
		address_i		: in  std_logic_vector(15 downto 0);
		value_i			: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector(15 downto 0);
		signal req_s	: out std_logic;
		signal cs_n_s	: out std_logic;
		signal wr_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);
		addr_s		<= address_i;
		data_i_s	<= value_i;
		wait until( rising_edge(clock_s) );
		cs_n_s		<= '0';
		wr_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		req_s		<= '1';
		wait until( rising_edge(clock_s) );
		req_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		cs_n_s		<= '1';
		wr_n_s		<= '1';
		addr_s		<= X"0000";
		for i in 0 to 3 loop
			wait until( rising_edge(clock_s) );
		end loop;
	end procedure;

	procedure read_p(
		address_i		: in  std_logic_vector(15 downto 0);
		signal addr_s	: out std_logic_vector(15 downto 0);
		signal req_s	: out std_logic;
		signal cs_n_s	: out std_logic;
		signal rd_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);
		addr_s		<= address_i;
		wait until( rising_edge(clock_s) );
		cs_n_s		<= '0';
		rd_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		req_s		<= '1';
		wait until( rising_edge(clock_s) );
		req_s		<= '0';
		wait until( rising_edge(clock_s) );
		cs_n_s		<= '1';
		rd_n_s		<= '1';
		addr_s		<= X"0000";
		for i in 0 to 3 loop
			wait until( rising_edge(clock_s) );
		end loop;
	end procedure;

begin

	--  instance
	u_target: entity work.escci
	port map(
		clock_i		=> clock_s,
		clock_en_i	=> clock_en_s,
		reset_i		=> reset_s,
		--
		addr_i		=> addr_s,
		data_i		=> data_i_s,
		data_o		=> data_o_s,
		req_i		=> req_s,
		cs_n_i		=> cs_n_s,
		rd_n_i		=> rd_n_s,
		wr_n_i		=> wr_n_s,
		--
		ram_addr_o	=> ram_addr_s,
		ram_data_i	=> ram_data_s,
		ram_ce_n_o	=> ram_ce_n_s,
		ram_oe_n_o	=> ram_oe_n_s,
		ram_we_n_o	=> ram_we_n_s,
		--
		map_type_i	=> map_type_s,
		--
		wave_o		=> wave_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	clkgen: process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 25 ns;
		clock_s <= '1';
		wait for 25 ns;
	end process;

	-- clock enable
	clk_en: process (reset_s, clock_s)
		variable cnt_v	: unsigned(2 downto 0);
	begin
		if reset_s = '1' then
			cnt_v := (others => '0');
		elsif rising_edge(clock_s) then
			clock_en_s	<= '0';
			if cnt_v = 0 then
				cnt_v := "111";
				clock_en_s	<= '1';
			else
				cnt_v := cnt_v - 1;
			end if;
		end if;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	testbench: process
	begin
		-- init
		map_type_s	<= "00";
		addr_s		<= (others => '0');
		data_i_s	<= (others => '0');
		cs_n_s		<= '1';
		rd_n_s		<= '1';
		wr_n_s		<= '1';
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
		write_p(X"9000", X"3F", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
		-- Write 0xAA to 0x9800
		write_p(X"9800", X"AA", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);

		-- Read from 0x9C00
		read_p(X"9c00", addr_s, req_s, cs_n_s, rd_n_s);

		-- Write 0x55 to 0x986F
		write_p(X"986F", X"55", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);

		-- Set bank3 to 0x80 (select SCC+)
		write_p(X"B000", X"80", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);

		-- Write 0x20 to 0xBFFE (bit 5=1 => mode SCC+)
		write_p(X"BFFE", X"20", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);

		-- Read from 0xB86F
		read_p(X"B86F", addr_s, req_s, cs_n_s, rd_n_s);

		-- Read from 0xB88F
		read_p(X"B88F", addr_s, req_s, cs_n_s, rd_n_s);

		wait for 1 us;
	
		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
