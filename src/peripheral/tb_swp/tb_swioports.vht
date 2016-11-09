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
	component swioports
	port(
		reset_i		: in  std_logic;
		clock_i		: in  std_logic;
		addr_i		: in  std_logic_vector(7 downto 0);
		cs_i			: in  std_logic;
		rd_i			: in  std_logic;
		wr_i			: in  std_logic;
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		has_data_o	: out std_logic;
		--
		hw_id_i		: in  std_logic_vector(7 downto 0);
		hw_txt_i		: in  string;
		mapp_type_o	: out std_logic_vector(1 downto 0)
	);
	end component;

	signal tb_end			: std_logic;
	signal reset_s		: std_logic;
	signal clock_s		: std_logic;
	signal addr_s		: std_logic_vector( 7 downto 0);
	signal data_i_s		: std_logic_vector( 7 downto 0);
	signal data_o_s		: std_logic_vector( 7 downto 0);
	signal has_data_s	: std_logic;
	signal cs_s			: std_logic;
	signal rd_s			: std_logic;
	signal wr_s			: std_logic;
	signal mapp_type_s	: std_logic_vector( 1 downto 0);

begin

	--  instance
	u_target: swioports
	port map(
		reset_i		=> reset_s,
		clock_i			=> clock_s,
		addr_i		=> addr_s,
		cs_i			=> cs_s,
		rd_i			=> rd_s,
		wr_i			=> wr_s,
		data_i		=> data_i_s,
		data_o		=> data_o_s,
		has_data_o	=> has_data_s,
		--
		hw_id_i		=> "00000001",
		hw_txt_i		=> "DE1",
		mapp_type_o	=> mapp_type_s

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
		wait for 23.280418648974914278006471677019 ns;		-- 21 MHz
		clock_s <= '1';
		wait for 23.280418648974914278006471677019 ns;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		addr_s		<= (others => '0');
		data_i_s	<= (others => '0');
		cs_s		<= '0';
		rd_s		<= '0';
		wr_s		<= '0';

		-- reset
		reset_s	<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s	<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 1 us;

		-- I/O Write:
		addr_s		<= X"40";
		data_i_s	<= X"55";
		cs_s		<= '1';
		wr_s		<= '1';
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;
		cs_s		<= '0';
		wr_s		<= '0';
		wait until( rising_edge(clock_s) );
		addr_s		<= X"00";
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;

		-- I/O Read:
		addr_s		<= X"49";
		cs_s		<= '1';
		rd_s		<= '1';
		for i in 0 to 5 loop
			wait until( rising_edge(clock_s) );
		end loop;
		addr_s		<= X"00";
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		cs_s		<= '0';
		rd_s		<= '0';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;


		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
