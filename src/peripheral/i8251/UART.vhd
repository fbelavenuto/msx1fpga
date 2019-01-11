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
--
-- RX not totally implemented yet, need much tests!

library ieee;
use ieee.std_logic_1164.all;

entity UART is
	port (
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
end entity;

architecture Behavior of UART is

	signal last_cs1_s		: std_logic;
	signal last_cs2_s		: std_logic;
	signal baudclk_s		: std_logic;

	signal regidx_q		: std_logic								:= '0';
	signal mode_r			: std_logic_vector(7 downto 0);
	signal ctrl_r			: std_logic_vector(7 downto 0);
	alias  stop_bits_a	: std_logic_vector(1 downto 0) is mode_r(7 downto 6);
	alias  parity_a		: std_logic_vector(1 downto 0) is mode_r(5 downto 4);
	alias  char_len_a		: std_logic_vector(1 downto 0) is mode_r(3 downto 2);
	alias  baud_sel_a		: std_logic_vector(1 downto 0) is mode_r(1 downto 0);
	alias  huntmode_a		: std_logic is ctrl_r(7);
	alias  softreset_a	: std_logic is ctrl_r(6);
	alias  rts_a			: std_logic is ctrl_r(5);
	alias  reseterr_a		: std_logic is ctrl_r(4);
	alias  sendbreak_a	: std_logic is ctrl_r(3);
	alias  rx_en_a			: std_logic is ctrl_r(2);
	alias  dtr_a			: std_logic is ctrl_r(1);
	alias  tx_en_a			: std_logic is ctrl_r(0);

	signal access_s		: std_logic;
	signal dataread_s		: std_logic;
	signal datawrite_s	: std_logic;
	signal ctrlwrite_s	: std_logic;

	signal status_s		: std_logic_vector(7 downto 0);	-- Status Register

	signal tx_data_s		: std_logic_vector(7 downto 0);
	signal tx_empty_s		: std_logic;
	signal clr_txe_s		: std_logic;
	signal tx_ready_s		: std_logic;

	signal rx_data_q		: std_logic_vector(7 downto 0); -- Receive Data Register
	signal rx_ready_s		: std_logic;
	signal set_rdy_s		: std_logic;
	signal set_oe_s		: std_logic;
	signal set_fe_s		: std_logic;
	signal set_pe_s		: std_logic;
	signal clr_reserr_s	: std_logic;
	signal parity_err_s	: std_logic;
	signal overrun_err_s	: std_logic;
	signal frame_err_s	: std_logic;

begin

	CLKDIV: entity work.clk_divider
	port map (
		clock_i		=> clock_c_i,
		reset_n_i	=> reset_n_i,
		baudsel_i	=> baud_sel_a,
		baudclk_o	=> baudclk_s
	);

	XMIT: entity work.UART_transmitter
	port map (
		reset_n_i	=> reset_n_i,
		clock_i		=> clock_c_i,
		baudclk_i	=> baudclk_s,
		data_i		=> tx_data_s,
		char_len_i	=> char_len_a,
		stop_bits_i	=> stop_bits_a,
		tx_empty_i	=> tx_empty_s,
		tx_ready_o	=> tx_ready_s,
		clr_txe_o	=> clr_txe_s,
		txd_o			=> txd_o
	);

	RCVR: entity work.UART_Receiver
	port map (
		reset_n_i	=> reset_n_i,
		clock_i		=> clock_c_i,
		baudclk_i	=> baudclk_s,
		enable_i		=> rx_en_a,
		rdr_o			=> rx_data_q,
		ready_i		=> rx_ready_s,
		set_ready_o	=> set_rdy_s,
		set_pe_o		=> set_pe_s,
		set_oe_o		=> set_oe_s,
		set_fe_o		=> set_fe_s,
		rx_i			=> rxd_i
	);

	-- Bus Interface
	access_s		<= '1'	when cs_n_i = '0' and (rd_n_i = '0' or wr_n_i = '0')	else '0';
	dataread_s	<= '1'	when cs_n_i = '0' and rd_n_i = '0' and addr_i = '0'	else '0';
	datawrite_s	<= '1'	when cs_n_i = '0' and wr_n_i = '0' and addr_i = '0'	else '0';
	ctrlwrite_s	<= '1'	when cs_n_i = '0' and wr_n_i = '0' and addr_i = '1'	else '0';

	-- Write semi-asynchronous
	process (reset_n_i, softreset_a, clock_i)
	begin
		if reset_n_i = '0' or softreset_a = '1' then
			mode_r	<= (others => '0');
			ctrl_r	<= (others => '0');
			regidx_q	<= '0';
		elsif rising_edge(clock_i) then

			if clr_reserr_s = '1' then
				reseterr_a <= '0';
			end if;

			if last_cs1_s = '0' and ctrlwrite_s = '1' then
				if regidx_q = '0' then
					regidx_q <= '1';
					mode_r	<= data_i;
				else
					ctrl_r	<= data_i;
				end if;
			end if;

			last_cs1_s <= ctrlwrite_s;
		end if;
	end process;

	-- TX control
	process (reset_n_i, clock_i)
	begin
		if reset_n_i = '0' then
			tx_empty_s	<= '1';
		elsif rising_edge(clock_i) then

			if clr_txe_s = '1' then
				tx_empty_s	<= '1';
			end if;

			if last_cs2_s = '0' and datawrite_s = '1' and cts_n_i = '0' then
				tx_empty_s	<= '0';
				tx_data_s	<= data_i;
			end if;

			last_cs2_s	<= datawrite_s;

		end if;
	end process;

	-- RX Control
	process (reset_n_i, dataread_s, clock_i)
	begin
		if reset_n_i = '0' then
			rx_ready_s		<= '0';
			overrun_err_s	<= '0';
			frame_err_s		<= '0';
			parity_err_s	<= '0';
		elsif rising_edge(clock_i) then

			if dataread_s = '1' then
				rx_ready_s	<= '0';
			elsif set_rdy_s = '1' then
				rx_ready_s	<= '1';
			end if;

			clr_reserr_s	<= '0';

			if reseterr_a = '1' then
				clr_reserr_s	<= '1';
				overrun_err_s	<= '0';
				frame_err_s		<= '0';
				parity_err_s	<= '0';
			else
				if set_oe_s = '1' then
					overrun_err_s	<= '1';
				end if;
				if set_fe_s = '1' then
					frame_err_s		<= '1';
				end if;
				if set_pe_s = '1' then
					parity_err_s	<= '1';
				end if;
			end if;

		end if;
	end process;

	--
	rts_n_o	<= rts_a;
	dtr_n_o	<= dtr_a;
	rx_rdy_o	<= rx_ready_s and rx_en_a;

	status_s	<= dsr_n_i & "0" & frame_err_s & overrun_err_s & parity_err_s & tx_empty_s & rx_ready_s & tx_ready_s;

	data_o	<= (others => '1')	when access_s = '0' or rd_n_i = '1'	else
					rx_data_q			when addr_i = '0'		else
					status_s;

end architecture;