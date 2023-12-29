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
	signal addr_s			: std_logic_vector(18 downto 0);	-- 512K
	signal data_i_s			: std_logic_vector( 7 downto 0);
	signal data_o_s			: std_logic_vector( 7 downto 0);
	signal ce_n_s			: std_logic;
	signal oe_n_s			: std_logic;
	signal we_n_s			: std_logic;
	signal sram_addr_s		: std_logic_vector(17 downto 0);
	signal sram_data_io_s	: std_logic_vector(15 downto 0);
	signal sram_ub_n_s		: std_logic;
	signal sram_lb_n_s		: std_logic;
	signal sram_ce_n_s		: std_logic;
	signal sram_oe_n_s		: std_logic;
	signal sram_we_n_s		: std_logic;

begin

	--  instance
	u_target: entity work.spSRAM_25616
	port map(
		clk_i			=> clock_s,
		sync_addr_i		=> addr_s,
		sync_ce_n_i		=> ce_n_s,
		sync_oe_n_i		=> oe_n_s,
		sync_we_n_i		=> we_n_s,
		sync_data_i		=> data_i_s,
		sync_data_o		=> data_o_s,
		-- Output to SRAM in board
		sram_addr_o		=> sram_addr_s,
		sram_data_io	=> sram_data_io_s,
		sram_ub_n_o		=> sram_ub_n_s,
		sram_lb_n_o		=> sram_lb_n_s,
		sram_ce_n_o		=> sram_ce_n_s,
		sram_oe_n_o		=> sram_oe_n_s,
		sram_we_n_o		=> sram_we_n_s
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

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	testbench: process
	begin
		-- init
		sram_data_io_s	<= (others => 'Z');
		addr_s		<= (others => '0');
		data_i_s	<= (others => '0');
		ce_n_s		<= '1';
		oe_n_s		<= '1';
		we_n_s		<= '1';

		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		-- write data
		addr_s		<= "010" & X"1234";
		data_i_s	<= X"A5";
		wait until( rising_edge(clock_s) );
		ce_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		we_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		we_n_s		<= '1';
		ce_n_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		-- read data
		addr_s		<= "010" & X"1234";
		sram_data_io_s	<= X"9876";
		wait until( rising_edge(clock_s) );
		ce_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		oe_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		oe_n_s		<= '1';
		ce_n_s		<= '1';
		sram_data_io_s	<= (others => 'Z');
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
	
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
