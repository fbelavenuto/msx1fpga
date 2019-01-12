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

entity UART_transmitter is
	port (
		reset_n_i	: in  std_logic;
		clock_i		: in  std_logic;
		baudclk_i	: in  std_logic;
		data_i		: in  std_logic_vector(7 downto 0);
		char_len_i	: in  std_logic_vector(1 downto 0);
		stop_bits_i	: in  std_logic_vector(1 downto 0);
		tx_empty_i	: in  std_logic;
		clr_txe_o	: out std_logic;
		tx_ready_o	: out std_logic;
		txd_o			: out std_logic
	);
end UART_Transmitter;

architecture xmit of UART_transmitter is

	type state_t is (IDLE, SYNCH, TDATA);
	signal state_s			: state_t;
	signal nextstate_s	: state_t;
	signal tsr_q			: std_logic_vector(8 downto 0); -- Transmit Shift Register
	signal bitcount_q		: integer range 0 to 9; -- counts number of bits sent
	signal bitmax_s		: unsigned(3 downto 0);
	signal inc_s			: std_logic;
	signal clr_s			: std_logic;
	signal load_tsr_s		: std_logic;
	signal shift_tsr_s	: std_logic;
	signal start_s			: std_logic;
	signal bclk_rising_s	: std_logic;
	signal bclk_dlayed_s	: std_logic;

begin

	txd_o 		<= tsr_q(0);
	clr_txe_o	<= start_s;
	tx_ready_o	<= '0'	when state_s /= IDLE or load_tsr_s = '1'	else '1';

	bclk_rising_s	<= baudclk_i and (not bclk_dlayed_s); -- indicates the rising edge of bit clock
	bitmax_s			<= to_unsigned(5, 4) + unsigned(char_len_i) + unsigned(stop_bits_i);

	Xmit_Control: process(state_s, tx_empty_i, bitcount_q, bclk_rising_s, bitmax_s)
	begin
		inc_s			<= '0';
		clr_s			<= '0';
		load_tsr_s	<= '0';
		shift_tsr_s	<= '0';
		start_s		<= '0';
		-- reset control signals
		case state_s is
			when IDLE =>
				if tx_empty_i = '0' then
					load_tsr_s <= '1';
					nextstate_s <= SYNCH;
				else
					nextstate_s <= IDLE;
				end if;

		when SYNCH =>								-- synchronize with the bit clock
			if bclk_rising_s = '1' then
				start_s		<= '1';
				nextstate_s <= TDATA;
			else
				nextstate_s <= SYNCH;
			end if;

		when TDATA =>
			if bclk_rising_s = '0' then
				nextstate_s <= TDATA;
			elsif bitcount_q /= bitmax_s then
				shift_tsr_s	<= '1';
				inc_s			<= '1';
				nextstate_s	<= TDATA;
			else
				clr_s			<= '1';
				nextstate_s	<= IDLE;
			end if;
		end case;
	end process;

	Xmit_update: process (reset_n_i, clock_i)
	begin
		if reset_n_i = '0' then
			tsr_q				<= (others => '1');
			state_s			<= IDLE;
			bitcount_q		<= 0;
			bclk_dlayed_s	<= '0';
		elsif rising_edge(clock_i) then
			state_s <= nextstate_s;
			
			if clr_s = '1' then
				bitcount_q <= 0;
			elsif inc_s = '1' then
				bitcount_q <= bitcount_q + 1;
			end if;
			
			if load_tsr_s = '1' then
				tsr_q <= data_i & '1';
			end if;
			
			if start_s = '1' then
				tsr_q(0) <= '0';
			end if;
			
			if shift_tsr_s = '1' then
				tsr_q <= '1' & tsr_q(8 downto 1);
			end if; -- shift out one bit
			
			bclk_dlayed_s <= baudclk_i;		-- Bclk delayed by 1 sysclk

		end if;
	end process;

end architecture;