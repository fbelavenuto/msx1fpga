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
use ieee.numeric_std.all;

entity Midi3 is
	port (
		clock_i			: in  std_logic;							-- 8MHz
		reset_n_i		: in  std_logic;
		addr_i			: in  std_logic_vector(2 downto 0);
		data_i			: in  std_logic_vector(7 downto 0);
		data_o			: out std_logic_vector(7 downto 0);
		has_data_o		: out std_logic;
		cs_n_i			: in  std_logic;
		wr_n_i			: in  std_logic;
		rd_n_i			: in  std_logic;
		int_n_o			: out std_logic;
		-- UART
		rxd_i				: in  std_logic;
		txd_o				: out std_logic;
		-- Debug
		D_out0_o			: out std_logic;
		D_out2_o			: out std_logic;
		D_latch0_o		: out std_logic

	);
end entity;

architecture Behavior of Midi3 is

	signal d_from_tmr_s	: std_logic_vector(7 downto 0);
	signal d_from_uart_s	: std_logic_vector(7 downto 0);
	signal has_data_s		: std_logic;
	signal i8251_cs_n_s	: std_logic;
	signal i8253_cs_n_s	: std_logic;
	signal ffint_cs_n_s	: std_logic;
	signal ffint_wr_s		: std_logic;
	signal ffint_q			: std_logic;
	signal ffint_n_s		: std_logic;
	signal clock_4m_s		: std_logic;
	signal out0_s			: std_logic;
	signal out2_s			: std_logic;
	signal rts_s			: std_logic;
	signal dtr_s			: std_logic;
	signal tx_s				: std_logic;

begin

	process(reset_n_i, clock_i)
	begin
		if reset_n_i = '0' then
			clock_4m_s	<= '0';
		elsif rising_edge(clock_i) then
			clock_4m_s <= not clock_4m_s;
		end if;
	end process;

	i8251_cs_n_s	<= '0'	when cs_n_i = '0' and addr_i(2 downto 1) = "00"		else '1';
	ffint_cs_n_s	<= '0'	when cs_n_i = '0' and addr_i(2 downto 1) = "01"		else '1';
	i8253_cs_n_s	<= '0'	when cs_n_i = '0' and addr_i(2)			  = '1'		else '1';

	has_data_s	<= '1'	when rd_n_i = '0' and (i8251_cs_n_s = '0' or i8253_cs_n_s = '0')	else '0';
	has_data_o	<= has_data_s;

	data_o	<= (others => '1')	when rd_n_i = '1'	else
					d_from_uart_s		when i8251_cs_n_s = '0'	else
					d_from_tmr_s;

	-- i8253
	tmr: entity work.timer
	port map (
		clock_i		=> clock_i,
		reset_n_i	=> reset_n_i,
		addr_i		=> addr_i(1 downto 0),
		data_i		=> data_i,
		data_o		=> d_from_tmr_s,
		cs_n_i		=> i8253_cs_n_s,
		rd_n_i		=> rd_n_i,
		wr_n_i		=> wr_n_i,
		-- counter 0
		clk0_i		=> clock_4m_s,
		out0_o		=> out0_s,
		-- counter 1
		clk1_i		=> out2_s,
		out1_o		=> open,
		-- counter 2
		clk2_i		=> clock_4m_s,
		out2_o		=> out2_s,
		-- Debug
		D_latch0_o	=> D_latch0_o
	);

	serial: entity work.UART
	port map (
		clock_i		=> out0_s,
		reset_n_i	=> reset_n_i,
		addr_i		=> addr_i(0),
		data_i		=> data_i,
		data_o		=> d_from_uart_s,
		cs_n_i		=> i8251_cs_n_s,
		rd_n_i		=> rd_n_i,
		wr_n_i		=> wr_n_i,
		rxd_i			=> rxd_i,
		txd_o			=> tx_s,
		dsr_n_i		=> ffint_n_s,
		cts_n_i		=> '0',
		rts_n_o		=> rts_s,
		dtr_n_o		=> dtr_s
	);

	ffint_wr_s	<= '1'	when ffint_cs_n_s = '0' and wr_n_i = '0'	else '0';

	process (reset_n_i, ffint_wr_s, out2_s)
	begin
		if reset_n_i = '0' or ffint_wr_s = '1'	then
			ffint_q	<= '1';
		elsif rising_edge(out2_s) then
			ffint_q	<= '0';
		end if;

	end process;

	ffint_n_s	<= not ffint_q;
	int_n_o	<= ffint_q or not dtr_s;
	txd_o		<= not tx_s;

	-- Debug
	D_out0_o		<= out0_s;
	D_out2_o		<= out2_s;

end architecture;
