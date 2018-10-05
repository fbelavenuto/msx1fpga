-------------------------------------------------------------------------------
--
-- MSX1 FPGA project
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
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
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end tb;

architecture testbench of tb is

	-- test target
	component i2s_transmitter
	generic (
		mclk_rate		: positive := 24576000;
		sample_rate		: positive := 48000;
		preamble			: integer := 0;				-- 0=Left-justified, 1=I2S
		word_length		: positive := 16
	);
	port (
		clock_i			: in  std_logic;				-- 2x MCLK in
		reset_i			: in  std_logic;
		-- Parallel input
		pcm_l_i			: in  std_logic_vector(word_length - 1 downto 0);
		pcm_r_i			: in  std_logic_vector(word_length - 1 downto 0);

		i2s_mclk_o		: out std_logic;				-- MCLK is generated at half of the CLK input
		i2s_lrclk_o		: out std_logic;				-- LRCLK is equal to the sample rate and is synchronous to MCLK.
		i2s_bclk_o		: out std_logic;
		i2s_d_o			: out std_logic
	);
	end component;

	signal tb_end		: std_logic;
	signal clock_s		: std_logic;
	signal reset_s		: std_logic;
	signal pcm_l_s		: std_logic_vector(15 downto 0);
	signal pcm_r_s		: std_logic_vector(15 downto 0);
	signal i2s_mclk_s	: std_logic;
	signal i2s_lrclk_s	: std_logic;
	signal i2s_bclk_s	: std_logic;
	signal i2s_d_s		: std_logic;

--	constant	mclk_freq_c		: integer := 12288000;
	constant	clk_period_c	: time := 40.69 ns;	-- 24.576

begin

	--  instance
	u_target: i2s_transmitter
	generic map (
		mclk_rate		=> 12288000,
		sample_rate		=> 96000,		-- 96000 * 16 * 2 = 3072000 * 2 => (minimum bclk = 6144000)
		preamble		=> 0,
		word_length		=> 16
	)
	port map(
		clock_i			=> clock_s,
		reset_i			=> reset_s,
		pcm_l_i			=> pcm_l_s,
		pcm_r_i			=> pcm_r_s,
		i2s_mclk_o		=> i2s_mclk_s,
		i2s_lrclk_o		=> i2s_lrclk_s,
		i2s_bclk_o		=> i2s_bclk_s,
		i2s_d_o			=> i2s_d_s
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
		wait for clk_period_c/2;
		clock_s <= '1';
		wait for clk_period_c/2;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		pcm_l_s <= "1100110011110011";
		pcm_r_s <= "0110011001100110";

		-- reset
		reset_s	<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s	<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 10 ms;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
