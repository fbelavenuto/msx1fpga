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
	signal data_i_s			: std_logic_vector(7 downto 0);
	signal data_o_s			: std_logic_vector(7 downto 0);
	signal addr_s			: std_logic_vector(1 downto 0);
	signal req_s			: std_logic;
	signal cs_n_s			: std_logic;
	signal rd_n_s			: std_logic;
	signal wr_n_s			: std_logic;
	signal audio_s			: unsigned(7 downto 0);

	procedure write_p(
		register_i		: in  std_logic_vector( 7 downto 0);
		value_i			: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector( 1 downto 0);
		signal req_s	: out std_logic;
		signal cs_n_s	: out std_logic;
		signal wr_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);

		-- write register address
		addr_s		<= "00";
		data_i_s	<= register_i;
		wr_n_s		<= '0';
		cs_n_s		<= '0';
		wait until rising_edge(clock_s);
		req_s		<= '1';
		wait until rising_edge(clock_s);
		req_s		<= '0';
		wait until rising_edge(clock_s);
		cs_n_s		<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_s);

		-- write to registers
		addr_s		<= "01";
		data_i_s	<= value_i;
		wr_n_s		<= '0';
		cs_n_s		<= '0';
		wait until rising_edge(clock_s);
		req_s		<= '1';
		wait until rising_edge(clock_s);
		req_s		<= '0';
		wait until rising_edge(clock_s);
		cs_n_s		<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_s);
	end procedure;

	procedure read_p(
		register_i		: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector( 1 downto 0);
		signal req_s	: out std_logic;
		signal cs_n_s	: out std_logic;
		signal wr_n_s	: out std_logic;
		signal rd_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_s);

		-- write register address
		addr_s		<= "00";
		data_i_s	<= register_i;
		wr_n_s		<= '0';
		cs_n_s		<= '0';
		wait until rising_edge(clock_s);
		req_s		<= '1';
		wait until rising_edge(clock_s);
		req_s		<= '0';
		wait until rising_edge(clock_s);
		cs_n_s		<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_s);
		-- read from registers
		addr_s		<= "10";
		rd_n_s		<= '0';
		cs_n_s		<= '0';
		wait until rising_edge(clock_s);
		req_s		<= '1';
		wait until rising_edge(clock_s);
		req_s		<= '0';
		wait until rising_edge(clock_s);
		cs_n_s		<= '1';
		rd_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_s);
	end procedure;

begin

	--  instance
	u_target: entity work.YM2149s
	port map(
		clock_master_i		=> clock_s,
		clock_en_i			=> clock_en_s,
		reset_i				=> reset_s,
		ayymmode_i			=> '0',
		-- data bus
		data_i				=> data_i_s,
		data_o				=> data_o_s,
		-- control
		addr_i				=> addr_s,
		req_i				=> req_s,
		cs_n_i				=> cs_n_s,
		rd_n_i				=> rd_n_s,
		wr_n_i				=> wr_n_s,
		-- I/O ports
		port_a_i			=> X"5A",
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
	clock_gen: process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '1';
		wait for 25 ns;
		clock_s <= '0';
		wait for 25 ns;
	end process;

	-- clock enable
	clock_en: process (clock_s)
		variable cnt1_q	: unsigned(1 downto 0)	:= (others => '0');
	begin
		if rising_edge(clock_s) then
			clock_en_s <= '0';
			if cnt1_q = 0 then
				clock_en_s <= '1';
				cnt1_q := "11";
			else
				cnt1_q := cnt1_q - 1;
			end if;
		end if;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	testbench: process
	begin
		-- init
		addr_s		<= (others => '0');
		data_i_s	<= (others => '0');
		cs_n_s		<= '1';
		req_s		<= '0';
		rd_n_s		<= '1';
		wr_n_s		<= '1';

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
--		write_p(X"00", X"5D", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
--		write_p(X"01", X"0D", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
--		write_p(X"07", X"3E", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
--		write_p(X"08", X"0F", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);

		write_p(X"00", X"00", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
		write_p(X"01", X"08", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
		write_p(X"07", X"3E", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);
		write_p(X"08", X"0F", data_i_s, addr_s, req_s, cs_n_s, wr_n_s);

		wait for 1 us;

		read_p(X"01", data_i_s, addr_s, req_s, cs_n_s, wr_n_s, rd_n_s);
		read_p(X"0E", data_i_s, addr_s, req_s, cs_n_s, wr_n_s, rd_n_s);

		wait for 27 ms;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
