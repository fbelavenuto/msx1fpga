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
	signal clock_s		: std_logic;
	signal clock_en_s	: std_logic;
	signal reset_s		: std_logic;
	signal addr_s		: std_logic;
	signal data_i_s		: std_logic_vector( 7 downto 0);
	signal cs_n_s		: std_logic;
	signal wr_n_s		: std_logic;
	signal wait_s		: std_logic;
	signal melody_s		: signed(12 downto 0);
	signal rythm_s		: signed(12 downto 0);

	procedure write_p(
		register_i		: in  std_logic_vector( 7 downto 0);
		value_i			: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic;
		signal cs_n_s	: out std_logic;
		signal wr_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);

		-- write register address
		addr_s		<= '0';
		data_i_s	<= register_i;
		wr_n_s		<= '0';
		cs_n_s		<= '0';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		cs_n_s		<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_s);

		-- write to registers
		addr_s		<= '1';
		data_i_s	<= value_i;
		wr_n_s		<= '0';
		cs_n_s		<= '0';
		wait until rising_edge(clock_en_s);
		if wait_s = '1' then
			wait until wait_s = '0';
		end if;
		wait until rising_edge(clock_en_s);
		cs_n_s		<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_s);
	end procedure;

begin

	--  instance
	u_target: entity work.opll
	port map(
		clock_i		=> clock_s,
		clock_en_i	=> clock_en_s,
		reset_i		=> reset_s,
		data_i		=> data_i_s,
		addr_i		=> addr_s,
		cs_n_i      => cs_n_s,
		we_n_i		=> wr_n_s,
		wait_o		=> wait_s,
		melody_o	=> melody_s,
		rythm_o		=> rythm_s
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
		addr_s		<= '0';
		data_i_s	<= (others => '0');
		cs_n_s		<= '1';
		wr_n_s		<= '1';

		-- reset
		reset_s	<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s	<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 10 us;

		write_p(X"10", X"A2", data_i_s, addr_s, cs_n_s, wr_n_s);
		wait for 15 us;
		write_p(X"20", X"95", data_i_s, addr_s, cs_n_s, wr_n_s);
		wait for 10 us;

		wait for 50 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
