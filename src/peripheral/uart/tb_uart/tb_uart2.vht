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
	component uart
	port(
		clock_i		: in  std_logic;
		reset_i		: in  std_logic;
		addr_i		: in  std_logic_vector(2 downto 0);
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		has_data_o	: out std_logic;
		cs_i			: in  std_logic;
		rd_i			: in  std_logic;
		wr_i			: in  std_logic;
		int_n_o		: out std_logic;
		--
		rxd_i			: in  std_logic;
		txd_o			: out std_logic;
		cts_n_i		: in  std_logic;
		rts_n_o		: out std_logic;
		dsr_n_i		: in  std_logic;
		dtr_n_o		: out std_logic;
		dcd_i			: in  std_logic;
		ri_i			: in  std_logic
	);
	end component;


	signal tb_end		: std_logic := '0';

	signal clock_cpu_s	: std_logic;

	signal wait_n_s		: std_logic								:= '1';
	signal clock_s			: std_logic;
	signal reset_s			: std_logic;
	signal addr_s			: std_logic_vector( 2 downto 0);
	signal data_i_s		: std_logic_vector( 7 downto 0);
	signal data_o_s		: std_logic_vector( 7 downto 0);
	signal hd_s				: std_logic;
	signal cs_s				: std_logic;
	signal rd_s				: std_logic;
	signal wr_s				: std_logic;
	signal int_n_s			: std_logic;
	signal txd_s			: std_logic;
	signal rts_n_s			: std_logic;
	signal dtr_n_s			: std_logic;
	signal dcd_s			: std_logic;
	signal ri_s				: std_logic;

	procedure z80_io_read(
		addr_i				: in  std_logic_vector( 2 downto 0);
		signal addr_s		: out std_logic_vector( 2 downto 0);
		signal data_o_s	: in  std_logic_vector( 7 downto 0);
		signal cs_s			: out std_logic;
		signal rd_s			: out std_logic
	) is begin
		wait until clock_cpu_s = '1';		-- 1.0
		rd_s		<= '0';
		addr_s	<= addr_i;
		wait until clock_cpu_s = '1';		-- 1.2
		cs_s		<= '1';
		rd_s		<= '1';
		wait until clock_cpu_s = '0';		-- 1.3
		wait until clock_cpu_s = '0';		-- 2.1
		wait until clock_cpu_s = '1';		-- 3.0
		while wait_n_s = '0' loop
			wait until clock_cpu_s = '0';	-- x.1
		end loop;
		wait until clock_cpu_s = '0';		-- 3.1
		cs_s		<= '0';
		rd_s		<= '0';
		wait until clock_cpu_s = '1';		-- 4.0 (proximo)
		addr_s	<= (others => '0');
	end;

	procedure z80_io_write(
		addr_i				: in  std_logic_vector( 2 downto 0);
		data_i				: in  std_logic_vector( 7 downto 0);
		signal addr_s		: out std_logic_vector( 2 downto 0);
		signal data_i_s	: out std_logic_vector( 7 downto 0);
		signal cs_s			: out std_logic;
		signal wr_s			: out std_logic
	) is begin
		wait until clock_cpu_s = '1';		-- 1.0
		wr_s		<= '0';		
		addr_s	<= addr_i;
		data_i_s	<= (others => 'Z');
		wait until clock_cpu_s = '1';		-- 1.2
		data_i_s	<= data_i;
		cs_s		<= '1';
		wr_s		<= '1';
		wait until clock_cpu_s = '0';		-- 1.3
		wait until clock_cpu_s = '0';		-- 2.1
		wait until clock_cpu_s = '1';		-- 3.0
		while wait_n_s = '0' loop
			wait until clock_cpu_s = '0';	-- x.1
		end loop;
		wait until clock_cpu_s = '0';		-- 3.1
		cs_s		<= '0';
		wr_s		<= '0';
		wait until clock_cpu_s = '1';		-- 4.0 (proximo)
		addr_s	<= (others => '0');
		data_i_s	<= (others => 'Z');
	end;

	constant clock21_period_c	: time	:= 46.66 ns;
	constant clock8_period_c	: time	:= 125 ns;
	constant clock7_period_c	: time	:= 139.68 ns;
	constant clock4_period_c	: time	:= 250 ns;
	constant clock3_period_c	: time	:= 279.35 ns;

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
		wait for clock21_period_c / 2;
		clock_s <= '1';
		wait for clock21_period_c / 2;
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
	u_target: uart
	port map (
		clock_i		=> clock_s,
		reset_i		=> reset_s,
		addr_i		=> addr_s,
		data_i		=> data_i_s,
		data_o		=> data_o_s,
		has_data_o	=> hd_s,
		cs_i			=> cs_s,
		rd_i			=> rd_s,
		wr_i			=> wr_s,
		int_n_o		=> int_n_s,
		--
		rxd_i			=> txd_s,
		txd_o			=> txd_s,
		cts_n_i		=> '0',
		rts_n_o		=> rts_n_s,
		dsr_n_i		=> '0',
		dtr_n_o		=> dtr_n_s,
		dcd_i			=> dcd_s,
		ri_i			=> ri_s
	);

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		reset_s		<= '1';
		addr_s		<= (others => '0');
		data_i_s		<= (others => 'Z');
		cs_s			<= '0';
		rd_s			<= '0';
		wr_s			<= '0';
		dcd_s			<= '0';
		ri_s			<= '0';

		wait for 4 us;

		reset_s		<= '0';

		wait for 4 us;

--		-- I/O write (Mode REG: no HW flux, 8 bits, 1 stop, no parity)
--		z80_io_write("000", X"18", addr_s, data_i_s, cs_s, wr_s);
--		-- I/O write (Mode REG: no HW flux, 8 bits, 1 stop, parity even)
--		z80_io_write("000", X"19", addr_s, data_i_s, cs_s, wr_s);
--		-- I/O write (Mode REG: no HW flux, 8 bits, 1 stop, parity odd)
--		z80_io_write("000", X"1A", addr_s, data_i_s, cs_s, wr_s);

		-- I/O write (Mode REG: no HW flux, 5 bits, 2 stop, no parity)
		z80_io_write("000", X"00", addr_s, data_i_s, cs_s, wr_s);

		-- I/O write (Ctrl REG: DSR=0, No IRQs)
		z80_io_write("001", X"00", addr_s, data_i_s, cs_s, wr_s);

		-- I/O write (TX BAUD rate LSB) 21429000 / 115200 = 186
		z80_io_write("010", X"BA", addr_s, data_i_s, cs_s, wr_s);

		-- I/O write (TX BAUD rate MSB)
		z80_io_write("011", X"00", addr_s, data_i_s, cs_s, wr_s);

		-- I/O write (RX BAUD rate LSB)
		z80_io_write("100", X"BA", addr_s, data_i_s, cs_s, wr_s);

		-- I/O write (RX BAUD rate MSB)
		z80_io_write("101", X"00", addr_s, data_i_s, cs_s, wr_s);

		wait for 1 us;

		for i in 0 to 31 loop
			-- I/O write (Data write)
			z80_io_write("111", std_logic_vector(to_unsigned(i, 8)), addr_s, data_i_s, cs_s, wr_s);

		end loop;

		-- I/O read (Status)
		z80_io_read("000",         addr_s, data_o_s, cs_s, rd_s);

		wait for 3 ms;

		-- I/O read (Status)
		z80_io_read("000",         addr_s, data_o_s, cs_s, rd_s);

		for i in 0 to 31 loop
			-- I/O read (Data)
			z80_io_read("111",         addr_s, data_o_s, cs_s, rd_s);
		end loop;

		wait for 1 ms;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
