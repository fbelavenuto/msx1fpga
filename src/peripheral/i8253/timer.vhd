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
-- Based on timer8253.v from Next186 project
-- http://opencores.org/project,next186
-- Author: Nicolae Dumitrache
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	port (
		clock_i		: in  std_logic;							-- >= Z80 Clock
		reset_n_i	: in  std_logic;
		addr_i		: in  std_logic_vector(1 downto 0);
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		cs_n_i		: in  std_logic;
		rd_n_i		: in  std_logic;
		wr_n_i		: in  std_logic;
		-- counter 0
		clk0_i		: in  std_logic;
		out0_o		: out std_logic;
		-- counter 1
		clk1_i		: in  std_logic;
		out1_o		: out std_logic;
		-- counter 2
		clk2_i		: in  std_logic;
		out2_o		: out std_logic;
		-- Debug
		D_latch0_o	: out std_logic
	);
end entity;

architecture behavior of timer is

	signal access_s			: std_logic;
	signal write_s				: std_logic;
	signal port_a0_s			: std_logic;
	signal port_a1_s			: std_logic;
	signal port_a2_s			: std_logic;
	signal port_a3_s			: std_logic;
	signal cmd0_s				: std_logic;
	signal cmd1_s				: std_logic;
	signal cmd2_s				: std_logic;

	signal cnt0_cs_s			: std_logic;
	signal cnt1_cs_s			: std_logic;
	signal cnt2_cs_s			: std_logic;
	signal cnt0_data_from_s	: std_logic_vector(7 downto 0);
	signal cnt1_data_from_s	: std_logic_vector(7 downto 0);
	signal cnt2_data_from_s	: std_logic_vector(7 downto 0);

begin

	-- Bus Interface
	write_s		<= not wr_n_i;
	access_s		<= '1'	when cs_n_i = '0' and (rd_n_i = '0' or wr_n_i = '0')	else '0';
	port_a0_s	<= '1'	when addr_i = "00"	else '0';
	port_a1_s	<= '1'	when addr_i = "01"	else '0';
	port_a2_s	<= '1'	when addr_i = "10"	else '0';
	port_a3_s	<= '1'	when addr_i = "11"	else '0';

	cmd0_s		<= '1'	when port_a3_s = '1' and data_i(7 downto 6) = "00"	else '0';
	cmd1_s		<= '1'	when port_a3_s = '1' and data_i(7 downto 6) = "01"	else '0';
	cmd2_s		<= '1'	when port_a3_s = '1' and data_i(7 downto 6) = "10"	else '0';

	cnt0_cs_s	<= '1'	when access_s = '1' and (port_a0_s = '1' or cmd0_s = '1')	else '0';
	cnt1_cs_s	<= '1'	when access_s = '1' and (port_a1_s = '1' or cmd1_s = '1')	else '0';
	cnt2_cs_s	<= '1'	when access_s = '1' and (port_a2_s = '1' or cmd2_s = '1')	else '0';

	-- Counters
	cnt0: entity work.counter
	port map (
		clock_i		=> clock_i,
		reset_n_i	=> reset_n_i,
		data_i		=> data_i,
		data_o		=> cnt0_data_from_s,
		cs_i			=> cnt0_cs_s,
		wr_i			=> write_s,
		cmd_i			=> cmd0_s,
		clock_c_i	=> clk0_i,
		out_o			=> out0_o,
		-- Debug
		D_latch_o	=> D_latch0_o
	);

	cnt1: entity work.counter
	port map (
		clock_i		=> clock_i,
		reset_n_i	=> reset_n_i,
		data_i		=> data_i,
		data_o		=> cnt1_data_from_s,
		cs_i			=> cnt1_cs_s,
		wr_i			=> write_s,
		cmd_i			=> cmd1_s,
		clock_c_i	=> clk1_i,
		out_o			=> out1_o
	);

	cnt2: entity work.counter
	port map (
		clock_i		=> clock_i,
		reset_n_i	=> reset_n_i,
		data_i		=> data_i,
		data_o		=> cnt2_data_from_s,
		cs_i			=> cnt2_cs_s,
		wr_i			=> write_s,
		cmd_i			=> cmd2_s,
		clock_c_i	=> clk2_i,
		out_o			=> out2_o
	);

	data_o	<= (others => '1')	when rd_n_i = '1'	else
					cnt0_data_from_s	when port_a0_s = '1' or cmd0_s = '1'	else
					cnt1_data_from_s	when port_a1_s = '1' or cmd1_s = '1'	else
					cnt2_data_from_s;

end architecture;