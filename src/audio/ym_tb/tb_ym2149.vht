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
	component YM2149
	port(
		clock_i				: in  std_logic;
		clock_en_i			: in  std_logic;
		reset_i				: in  std_logic;
		sel_n_i				: in  std_logic;								-- 1 = AY-3-8912 compatibility
		ayymmode_i			: in  std_logic;								-- 0 = YM, 1 = AY
		-- data bus
		data_i				: in  std_logic_vector(7 downto 0);
		data_o				: out std_logic_vector(7 downto 0);
		-- control
		a9_l_i				: in  std_logic;
		a8_i					: in  std_logic;
		bdir_i				: in  std_logic;
		bc1_i					: in  std_logic;
		bc2_i					: in  std_logic;
		-- I/O ports
		port_a_i				: in  std_logic_vector(7 downto 0);
		port_a_o				: out std_logic_vector(7 downto 0);
		port_b_i				: in  std_logic_vector(7 downto 0);
		port_b_o				: out std_logic_vector(7 downto 0);
		-- audio channels out
		audio_ch_a_o		: out std_logic_vector(7 downto 0);
		audio_ch_b_o		: out std_logic_vector(7 downto 0);
		audio_ch_c_o		: out std_logic_vector(7 downto 0);
		audio_ch_mix_o		: out unsigned(7 downto 0)		-- mixed audio
	);
	end component;

	signal tb_end			: std_logic;
	signal clock_s			: std_logic;
	signal clock_en_s		: std_logic;
	signal reset_s			: std_logic;
	signal data_i_s			: std_logic_vector(7 downto 0);
	signal data_o_s			: std_logic_vector(7 downto 0);
	signal bdir_s			: std_logic;
	signal bc1_s			: std_logic;
	signal audio_s			: unsigned(7 downto 0);

	-- BDIR BC1  Action
	--  0    0    Nothing
	--  0    1    Read data
	--  1    0    Write data
	--  1    1    Write Addr
	procedure write_p(
		register_i		: in  std_logic_vector( 7 downto 0);
		value_i			: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal bdir_s	: out std_logic;
		signal bc1_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);
		data_i_s	<= register_i;
		bdir_s		<= '1';
		bc1_s		<= '1';
		wait until rising_edge(clock_en_s);
		bdir_s		<= '0';
		bc1_s		<= '0';
		wait until rising_edge(clock_en_s);
		data_i_s	<= value_i;
		bdir_s		<= '1';
		bc1_s		<= '0';
		wait until rising_edge(clock_en_s);
		bdir_s		<= '0';
		bc1_s		<= '0';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
	end procedure;

begin

	--  instance
	u_target: YM2149
	port map(
		clock_i				=> clock_s,
		clock_en_i			=> clock_en_s,
		reset_i				=> reset_s,
		sel_n_i				=> '0',
		ayymmode_i			=> '0',
		-- data bus
		data_i				=> data_i_s,
		data_o				=> data_o_s,
		-- control
		a9_l_i				=> '0',
		a8_i				=> '1',
		bdir_i				=> bdir_s,
		bc1_i				=> bc1_s,
		bc2_i				=> '1',
		-- I/O ports
		port_a_i			=> (others => '0'),
		port_a_o			=> open,
		port_b_i			=> (others => '0'),
		port_b_o			=> open,
		-- audio channels out
		audio_ch_a_o		=> open,
		audio_ch_b_o		=> open,
		audio_ch_c_o		=> open,
		audio_ch_mix_o		=> audio_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '1';
		wait for 23.280418648974914278006471677019 ns;		-- 21.477
		clock_s <= '0';
		wait for 23.280418648974914278006471677019 ns;
	end process;

	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_en_s <= '1';
		wait for 23.280418648974914278006471677019 * 2 ns;		-- enable 3.57
		clock_en_s <= '0';
		for i in 0 to 9 loop
			wait for 23.280418648974914278006471677019 ns;
		end loop;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		data_i_s	<= (others => '0');
		bdir_s		<= '0';
		bc1_s		<= '0';

		-- reset
		reset_s	<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s	<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 1 us;
		wait until( rising_edge(clock_s) );

		-- Put data
--		write_p(X"00", X"5D", data_i_s, bdir_s, bc1_s);
--		write_p(X"01", X"0D", data_i_s, bdir_s, bc1_s);
--		write_p(X"07", X"3E", data_i_s, bdir_s, bc1_s);
--		write_p(X"08", X"0F", data_i_s, bdir_s, bc1_s);

		write_p(X"00", X"00", data_i_s, bdir_s, bc1_s);
		write_p(X"01", X"08", data_i_s, bdir_s, bc1_s);
		write_p(X"07", X"3E", data_i_s, bdir_s, bc1_s);
		write_p(X"08", X"0F", data_i_s, bdir_s, bc1_s);

		wait for 100 ms;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
