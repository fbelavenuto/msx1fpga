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
	signal clock_en_s	: std_logic							:= '0';
	signal addr_s		: std_logic_vector(15 downto 0);
	signal sltsl_n_s	: std_logic;
	signal wr_n_s		: std_logic;
	signal rd_n_s		: std_logic;
	signal data_i_s		: std_logic_vector( 7 downto 0);
	signal data_o_s		: std_logic_vector( 7 downto 0);
	signal wait_n_s		: std_logic;

	signal rom_cs_n_s	: std_logic;
	signal rom_wr_n_s	: std_logic;
	signal rom_page_s	: std_logic_vector( 2 downto 0);

	signal spi_cs_n_s	: std_logic_vector( 2 downto 0);
	signal spi_sclk_s	: std_logic;
	signal spi_mosi_s	: std_logic;
	signal spi_miso_s	: std_logic;
	signal sd_wp_s		: std_logic;
	signal sd_pres_n_s	: std_logic;
	signal spi_has_data_s	: std_logic;

	procedure write_p(
		addr_i			: in  std_logic_vector(15 downto 0);
		value_i			: in  std_logic_vector( 7 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector(15 downto 0);
		signal sltsl_n_s: out std_logic;
		signal wr_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		addr_s		<= addr_i;
		data_i_s	<= value_i;
		wr_n_s		<= '0';
		sltsl_n_s	<= '0';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		if wait_n_s = '0' then
			wait until wait_n_s = '1';
			wait until rising_edge(clock_en_s);
			wait until rising_edge(clock_en_s);
			wait until rising_edge(clock_en_s);
			wait until rising_edge(clock_en_s);
		end if;
		wait until rising_edge(clock_en_s);
		sltsl_n_s	<= '1';
		wr_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
	end procedure;

	procedure read_p(
		addr_i			: in  std_logic_vector(15 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal addr_s	: out std_logic_vector(15 downto 0);
		signal sltsl_n_s: out std_logic;
		signal rd_n_s	: out std_logic
	) is
	begin
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		addr_s		<= addr_i;
		rd_n_s		<= '0';
		sltsl_n_s	<= '0';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
		if wait_n_s = '0' then
			wait until wait_n_s = '1';
			wait until rising_edge(clock_en_s);
			wait until rising_edge(clock_en_s);
			wait until rising_edge(clock_en_s);
			wait until rising_edge(clock_en_s);
		end if;
		wait until rising_edge(clock_en_s);
		sltsl_n_s	<= '1';
		rd_n_s		<= '1';
		wait until rising_edge(clock_en_s);
		wait until rising_edge(clock_en_s);
	end procedure;

begin

	--  instance
	u_target: entity work.msxsd
	port map(
		enable_i		=> '1',
		reset_i			=> reset_s,
		clock_i			=> clock_s,
		clock_en_i		=> clock_en_s,
		addr_i			=> addr_s,
		data_i			=> data_i_s,
		data_o			=> data_o_s,
		sltsl_n_i		=> sltsl_n_s,
		wr_n_i			=> wr_n_s,
		rd_n_i			=> rd_n_s,
		spi_has_data_o	=> spi_has_data_s,
		wait_n_o		=> wait_n_s,
		-- Memory
		rom_cs_n_o		=> rom_cs_n_s,
		rom_wr_n_o		=> rom_wr_n_s,
		rom_page_o		=> rom_page_s,
		-- SD card interface
		spi_cs_n_o		=> spi_cs_n_s,
		spi_sclk_o		=> spi_sclk_s,
		spi_mosi_o		=> spi_mosi_s,
		spi_miso_i		=> spi_miso_s,
		sd_wp_i			=> sd_wp_s,
		sd_pres_n_i		=> sd_pres_n_s
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

	-- clock enable
	clk_en: process (reset_s, clock_s)
		variable cnt_v	: unsigned(2 downto 0)	:= (others => '0');
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

	-- Generate pseudo-random MISO data
	miso_p: process
	begin
		if tb_end = '1' then
			wait;
		end if;
		spi_miso_s	<= '0';
		wait for 279.43 ns;
		spi_miso_s	<= '1';
		wait for 311.87 ns;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	testbench: process
	begin
		-- init
		addr_s			<= X"0000";
		sltsl_n_s		<= '1';
		wr_n_s			<= '1';
		rd_n_s			<= '1';
		data_i_s		<= (others => '0');
		sd_wp_s			<= '0';
		sd_pres_n_s		<= '1';

		-- reset
		reset_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		write_p(X"6000", X"FF", data_i_s, addr_s, sltsl_n_s, wr_n_s);		-- Select page 3
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );

		write_p(X"7B00", X"5A", data_i_s, addr_s, sltsl_n_s, wr_n_s);		-- Send data to SPI data port
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		write_p(X"7EFF", X"A5", data_i_s, addr_s, sltsl_n_s, wr_n_s);		-- Send data to SPI data port
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		wait until( rising_edge(clock_en_s) );
		read_p(X"7CDE", data_i_s,         addr_s, sltsl_n_s, rd_n_s);		-- Read data from SPI data port

		wait for 10 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
