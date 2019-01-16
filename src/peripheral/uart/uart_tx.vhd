-------------------------------------------------------------------------------
--
-- Copyright (c) 2019, Fabio Belavenuto (belavenuto@gmail.com)
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

entity uart_tx is
	port (
		clock_i		: in  std_logic;
		reset_i		: in  std_logic;
		baud_i		: in  std_logic_vector(7 downto 0);
		char_len_i	: in  std_logic_vector(1 downto 0);
		stop_bits_i	: in  std_logic_vector(1 downto 0);
		parity_i		: in  std_logic_vector(1 downto 0);
		data_i		: in  std_logic_vector(7 downto 0);
		tx_empty_i	: in  std_logic;
		fifo_rd_o	: out std_logic;
		txd_o			: out std_logic
	);
end entity;

architecture xmit of uart_tx is

	type state_t is (stIdle, stLoad, stLoad2, stStart, stData, stParity);
	signal state_s			: state_t;
	signal baudr_cnt_q	: integer range 0 to 256;
	signal max_cnt_s		: integer range 0 to 256;
	signal mcnt_rel_s		: integer range 0 to 256;
	signal bit_cnt_q		: integer range 0 to 9;
	signal bitmax_s		: unsigned(3 downto 0);
	signal bitmask_s		: std_logic_vector(2 downto 0);
	signal shift_q			: std_logic_vector(8 downto 0);
	signal parity_q		: std_logic;

begin

	bitmask_s	<= "111"		when char_len_i = "00"	else		-- 5 bits
						"110"		when char_len_i = "01"	else		-- 6 bits
						"100"		when char_len_i = "10"	else		-- 7 bits
						"000";												-- 8 bits

	bitmax_s		<= to_unsigned(5, 4) + unsigned(char_len_i) + unsigned(stop_bits_i);
	max_cnt_s	<= to_integer(unsigned(baud_i));

	-- Main process
	process(clock_i)
	begin
		if rising_edge(clock_i) then

			if reset_i = '1' then
				baudr_cnt_q <= 0;
				shift_q		<= (others => '1');
				bit_cnt_q	<= 0;
				state_s		<= stIdle;
				mcnt_rel_s	<= 0;
			else

				fifo_rd_o	<= '0';

				case state_s is

					when stIdle =>
						if tx_empty_i = '0' then
							fifo_rd_o	<= '1';
							state_s		<= stLoad;
						end if;

					when stLoad =>
						baudr_cnt_q	<= mcnt_rel_s;
						bit_cnt_q	<= 0;
						parity_q		<= '0';
						state_s		<= stLoad2;

					when stLoad2 =>
						shift_q(8 downto 6)	<= data_i(7 downto 5) or bitmask_s;		-- Add stop bits
						shift_q(5 downto 0)	<= data_i(4 downto 0) & '0';				-- Start bit
						state_s		<= stStart;

					when stStart =>
						if baudr_cnt_q = max_cnt_s then
							baudr_cnt_q <= 0;
							shift_q	<= '1' & shift_q(8 downto 1);							-- '1' is stop bit
							state_s		<= stData;
						else
							baudr_cnt_q <= baudr_cnt_q + 1;
						end if;

					when stData =>
						if baudr_cnt_q = max_cnt_s then
							baudr_cnt_q <= 0;
							if parity_i /= "00" then
								parity_q <= parity_q xor shift_q(0);						-- update Parity bit
							end if;
							shift_q	<= '1' & shift_q(8 downto 1);							-- '1' is stop bit
							if bit_cnt_q = bitmax_s then
								mcnt_rel_s	<= 0;
								if tx_empty_i = '0' then
									mcnt_rel_s <= 3;
								end if;
								if parity_i /= "00" then
									shift_q(0)	<= parity_q xor parity_i(1);				-- Send parity bit
									state_s		<= stParity;
								else
									state_s		<= stIdle;
								end if;
							else
								bit_cnt_q <= bit_cnt_q + 1;
							end if;
						else
							baudr_cnt_q <= baudr_cnt_q + 1;
						end if;

					when stParity =>
						if baudr_cnt_q = max_cnt_s then
							baudr_cnt_q <= 0;
							state_s	<= stIdle;
						else
							bit_cnt_q <= bit_cnt_q + 1;
						end if;

				end case;
			end if;
		end if;
	end process;

	txd_o 		<= shift_q(0);

end architecture;