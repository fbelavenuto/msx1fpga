-------------------------------------------------------------------------------
--
-- 
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
	component UART
	port(
		clock_i		: in  std_logic;
		clock_c_i	: in  std_logic;
		reset_n_i	: in  std_logic;
		addr_i		: in  std_logic;
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		cs_n_i		: in  std_logic;
		rd_n_i		: in  std_logic;
		wr_n_i		: in  std_logic;
		rxd_i			: in  std_logic;
		txd_o			: out std_logic;
		dsr_n_i		: in  std_logic;
		cts_n_i		: in  std_logic;
		rts_n_o		: out std_logic;
		dtr_n_o		: out std_logic;
		rx_rdy_o		: out std_logic
	);
	end component;


	signal tb_end		: std_logic := '0';

	signal clock_cpu_s	: std_logic;

	signal wait_n_s		: std_logic								:= '1';
	signal clock_s			: std_logic;
	signal clock_c_s		: std_logic;
	signal reset_n_s		: std_logic;
	signal addr_s			: std_logic;
	signal data_s			: std_logic_vector( 7 downto 0);
	signal data_o_s		: std_logic_vector( 7 downto 0);
	signal cs_n_s			: std_logic;
	signal rd_n_s			: std_logic;
	signal wr_n_s			: std_logic;
	signal rxd_s			: std_logic;
	signal txd_s			: std_logic;
	signal rts_n_s			: std_logic;
	signal dtr_n_s			: std_logic;

	procedure z80_io_read(
		addr_i				: in  std_logic;
		signal addr_s		: out std_logic;
		signal data_s		: in  std_logic_vector( 7 downto 0);
		signal cs_n_s		: out std_logic;
		signal rd_n_s		: out std_logic
	) is begin
		wait until clock_cpu_s = '1';		-- 1.0
		rd_n_s	<= '1';
		addr_s	<= addr_i;
		wait until clock_cpu_s = '1';		-- 1.2
		cs_n_s	<= '0';
		rd_n_s	<= '0';
		wait until clock_cpu_s = '0';		-- 1.3
		wait until clock_cpu_s = '0';		-- 2.1
		wait until clock_cpu_s = '1';		-- 3.0
		while wait_n_s = '0' loop
			wait until clock_cpu_s = '0';	-- x.1
		end loop;
		wait until clock_cpu_s = '0';		-- 3.1
		cs_n_s	<= '1';
		rd_n_s	<= '1';
		wait until clock_cpu_s = '1';		-- 4.0 (proximo)
		addr_s	<= '0';
	end;

	procedure z80_io_write(
		addr_i				: in  std_logic;
		data_i				: in  std_logic_vector( 7 downto 0);
		signal addr_s		: out std_logic;
		signal data_s		: out std_logic_vector( 7 downto 0);
		signal cs_n_s		: out std_logic;
		signal wr_n_s		: out std_logic
	) is begin
		wait until clock_cpu_s = '1';		-- 1.0
		wr_n_s	<= '1';		
		addr_s	<= addr_i;
		data_s	<= (others => 'Z');
		wait until clock_cpu_s = '1';		-- 1.2
		data_s	<= data_i;
		cs_n_s	<= '0';
		wr_n_s	<= '0';
		wait until clock_cpu_s = '0';		-- 1.3
		wait until clock_cpu_s = '0';		-- 2.1
		wait until clock_cpu_s = '1';		-- 3.0
		while wait_n_s = '0' loop
			wait until clock_cpu_s = '0';	-- x.1
		end loop;
		wait until clock_cpu_s = '0';		-- 3.1
		cs_n_s	<= '1';
		wr_n_s	<= '1';
		wait until clock_cpu_s = '1';		-- 4.0 (proximo)
		addr_s	<= '0';
		data_s	<= (others => 'Z');
	end;

	constant clock25_period_c	: time	:= 40.00 ns;
	constant clock10_period_c	: time	:= 93.34 ns;
	constant clock8_period_c	: time	:= 125 ns;
	constant clock7_period_c	: time	:= 139.68 ns;
	constant clock4_period_c	: time	:= 250 ns;
	constant clock3_period_c	: time	:= 279.35 ns;
	constant clock500k_period_c: time	:= 2 us;

begin

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for clock8_period_c / 2;
		clock_s <= '1';
		wait for clock8_period_c / 2;
	end process;

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_c_s <= '0';
		wait for clock500k_period_c / 2;
		clock_c_s <= '1';
		wait for clock500k_period_c / 2;
	end process;

	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_cpu_s <= '0';
		wait for clock3_period_c / 2;
		clock_cpu_s <= '1';
		wait for clock3_period_c / 2;
	end process;


	-- Instance
	u_target: UART
	port map (
		clock_i		=> clock_s,
		clock_c_i	=> clock_c_s,
		reset_n_i	=> reset_n_s,
		addr_i		=> addr_s,
		data_i		=> data_s,
		data_o		=> data_o_s,
		cs_n_i		=> cs_n_s,
		rd_n_i		=> rd_n_s,
		wr_n_i		=> wr_n_s,
		rxd_i			=> rxd_s,
		txd_o			=> txd_s,
		dsr_n_i		=> '0',
		cts_n_i		=> '0',
		rts_n_o		=> rts_n_s,
		dtr_n_o		=> dtr_n_s
	);

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		reset_n_s	<= '0';
		addr_s		<= '0';
		data_s		<= (others => 'Z');
		cs_n_s		<= '1';
		rd_n_s		<= '1';
		wr_n_s		<= '1';
		rxd_s			<= '1';

		wait for 4 us;

		reset_n_s	<= '1';

		wait for 4 us;

		-- I/O write port #01 value #00
		z80_io_write('1', X"00", addr_s, data_s, cs_n_s, wr_n_s);

		-- I/O write port #01 value #00
		z80_io_write('1', X"00", addr_s, data_s, cs_n_s, wr_n_s);

		-- I/O write port #01 value #40	-- Soft Reset
		z80_io_write('1', X"40", addr_s, data_s, cs_n_s, wr_n_s);

		-- I/O write port #01 value #4E	-- 1 stop bit, no parity, 8 chars, /16 baud
		z80_io_write('1', X"4E", addr_s, data_s, cs_n_s, wr_n_s);

		wait for 1 us;

		-- I/O write port #01 value #03	-- TX enable, DTR=1
		z80_io_write('1', X"03", addr_s, data_s, cs_n_s, wr_n_s);

		wait for 1 us;

		-- I/O read port #01
		z80_io_read('0',         addr_s, data_s, cs_n_s, rd_n_s);

		wait for 1 us;

		-- I/O write port #00 value #55
		z80_io_write('0', X"55", addr_s, data_s, cs_n_s, wr_n_s);

		wait for 1 us;

		-- I/O read port #01
		z80_io_read('1',         addr_s, data_s, cs_n_s, rd_n_s);

		wait for 100 us;

		-- I/O write port #00 value #AA
		z80_io_write('0', X"AA", addr_s, data_s, cs_n_s, wr_n_s);

		wait for 1 us;

		-- I/O read port #01
		z80_io_read('1',         addr_s, data_s, cs_n_s, rd_n_s);

		wait for 1 ms;

		-- I/O read port #01
		z80_io_read('1',         addr_s, data_s, cs_n_s, rd_n_s);

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
