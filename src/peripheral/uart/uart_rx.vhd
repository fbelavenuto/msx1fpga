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

entity uart_rx is
	port(
		reset_n_i	: in  std_logic;
		clock_i		: in  std_logic;
		baudclk_i	: in  std_logic;
		enable_i		: in  std_logic;
		rdr_o			: out std_logic_vector(7 downto 0);
		ready_i		: in  std_logic;
		set_ready_o	: out std_logic;
		set_pe_o		: out std_logic;
		set_oe_o		: out std_logic;
		set_fe_o		: out std_logic;
		rx_i			: in  std_logic
	);
end entity;

architecture rcvr of uart_rx is

	type stateType_t is (IDLE, START_DETECTED, RECV_DATA);
	signal state_s				: stateType_t;
	signal nextstate_s		: stateType_t;
	signal rsr_r				: std_logic_vector (7 downto 0);		-- receive shift register
	signal ct1_q				: integer range 0 to 8;		-- counts number of bits read
	signal inc1_s				: std_logic;
	signal inc2_s				: std_logic;
	signal clr1_s				: std_logic;
	signal clr2_s				: std_logic;
	signal shift_rsr_s		: std_logic;
	signal load_rdr_s			: std_logic;
	signal bclk_dlayed_s		: std_logic;
	signal bclk_rising_s		: std_logic;

begin

	bclk_rising_s <= baudclk_i and (not bclk_dlayed_s);

	-- indicates the rising edge of bitX8 clock
	Rcvr_Control: process(state_s, rx_i, enable_i, ready_i, ct1_q, bclk_rising_s)
	begin
		-- reset control signals
		inc1_s		<= '0';
		clr1_s		<= '0';
		shift_rsr_s	<= '0';
		load_rdr_s	<= '0';
		set_ready_o	<= '0';
		set_oe_o		<= '0';
		set_fe_o		<= '0';
		set_pe_o		<= '0';	-- not implemented yet
		case state_s is
			when IDLE =>
				if rx_i = '0' and enable_i = '1' then
					nextstate_s <= START_DETECTED;
				else
					nextstate_s <= IDLE;
				end if;

			when START_DETECTED =>
				if bclk_rising_s = '0' then
					nextstate_s	<= START_DETECTED;
				elsif rx_i = '1' then
					clr1_s		<= '1';
					nextstate_s	<= IDLE;
				else
					clr1_s		<= '1';
					nextstate_s	<= RECV_DATA;
				end if;

			when RECV_DATA =>
				if bclk_rising_s = '0' then
					nextstate_s		<= RECV_DATA;
				else
					if ct1_q /= 8 then					-- wait for 8 clock cycles
						shift_rsr_s	<= '1';
						inc1_s		<= '1';
						nextstate_s	<= RECV_DATA;
					else
						nextstate_s	<= IDLE;
						set_ready_o <= '1';
						clr1_s		<= '1';
						if ready_i = '1' then		-- If there is a byte without read,
							set_oe_o <= '1';			-- set Overrun Error
						elsif rx_i = '0' then
							set_fe_o <= '1';			-- No Stop Bit, set Framming Error
						else
							load_rdr_s <= '1';		-- load recv data register
						end if;
					end if;
				end if;
			end case;
	end process;

	Rcvr_update: process (reset_n_i, clock_i)
	begin
		if (reset_n_i = '0') then
			state_s			<= IDLE;
			bclk_dlayed_s	<= '0';
			ct1_q				<= 0;
			rdr_o				<= (others => '1');
		elsif rising_edge(clock_i) then

			state_s	<= nextstate_s;

			if clr1_s = '1' then
				ct1_q <= 0;
			elsif inc1_s = '1' then
				ct1_q <= ct1_q + 1;
			end if;

			if shift_rsr_s = '1' then
				rsr_r <= rx_i & rsr_r(7 downto 1);
			end if;

			-- update shift reg.
			if load_rdr_s = '1' then
				rdr_o <= rsr_r;
			end if;

			bclk_dlayed_s <= baudclk_i;				-- baud clock delayed by 1 sysclk

		end if;
	end process;

end rcvr;