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

	signal tb_end		: std_logic;
	signal reset_s		: std_logic;
	signal clock_s		: std_logic;
	signal addr_s		: std_logic_vector(15 downto 0);
	signal data_i_s		: std_logic_vector(7 downto 0);
	signal data_o_s		: std_logic_vector(7 downto 0);
	signal has_data_s	: std_logic;
	signal req_s		: std_logic;
	signal sltsl_n_s	: std_logic;
	signal wr_n_s		: std_logic;
	signal rd_n_s		: std_logic;
	signal expsltsl_n_s	: std_logic_vector(3 downto 0);

	procedure write_p(
		addr_i			: in  std_logic_vector(15 downto 0);
		value_i			: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector(15 downto 0);
		signal req_s	: out std_logic;
		signal sltsl_n_s: out std_logic;
		signal wr_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
		addr_s		<= addr_i;
		data_i_s	<= value_i;
		wr_n_s		<= '0';
		sltsl_n_s	<= '0';
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
		req_s		<= '1';
		wait until rising_edge(clock_s);
		req_s		<= '0';
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
		sltsl_n_s	<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
	end procedure;

	procedure read_p(
		addr_i			: in  std_logic_vector(15 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector(15 downto 0);
		signal req_s	: out std_logic;
		signal sltsl_n_s: out std_logic;
		signal rd_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
		addr_s		<= addr_i;
		rd_n_s		<= '0';
		sltsl_n_s	<= '0';
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
		req_s		<= '1';
		wait until rising_edge(clock_s);
		req_s		<= '0';
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
		sltsl_n_s	<= '1';
		rd_n_s		<= '1';
		wait until rising_edge(clock_s);
		wait until rising_edge(clock_s);
	end procedure;

begin

	--  instance
	u_target: entity work.exp_slot
	port map(
		reset_i			=> reset_s,
		clock_i			=> clock_s,
		ipl_en_i		=> '0',
		addr_i			=> addr_s,
		data_i			=> data_i_s,
		data_o			=> data_o_s,
		has_data_o		=> has_data_s,
		req_i			=> req_s,
		sltsl_n_i		=> sltsl_n_s,
		wr_n_i			=> wr_n_s,
		rd_n_i			=> rd_n_s,
		-- 
		expsltsl_n_o	=> expsltsl_n_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	clock_gen: process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 25 ns;
		clock_s <= '1';
		wait for 25 ns;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	testbench: process
	begin
		-- init
		addr_s			<= (others => '0');
		data_i_s		<= (others => '0');
		req_s			<= '0';
		sltsl_n_s		<= '1';
		wr_n_s			<= '1';
		rd_n_s			<= '1';

		-- reset
		reset_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		write_p(X"FFFF", X"1B", data_i_s, addr_s, req_s, sltsl_n_s, wr_n_s);	-- 00 01 10 11
		wait for 400 ns;
		read_p(X"FFFF",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"1000",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"5500",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"9876",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"DAD0",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		write_p(X"FFFF", X"E4", data_i_s, addr_s, req_s, sltsl_n_s, wr_n_s);	-- 11 10 01 00
		wait for 400 ns;
		read_p(X"FFFF",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"1000",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"5500",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"9876",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 400 ns;
		read_p(X"DAD0",         data_i_s, addr_s, req_s, sltsl_n_s, rd_n_s);
		wait for 1 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
