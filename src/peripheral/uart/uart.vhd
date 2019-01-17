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
-- Register map:
-- 0 = MODE (W) / Status (R)
--  Mode:
--    b7-b5 = reserved (write 0 to compatibility)
--    b4-b3 = Char data size (00 = 5 bits, 01 = 6 bits, 10 = 7 bits, 11 = 8 bits)
--    b2    = Stop bits (0 = 1 stop bit, 1 = 2 stop bits)
--    b1-b0 = Parity (00 = none, 01 = even, 1x = odd)
-- Status:
--    b7 = /DSR pin
--    b6 = reserved (always 0)
--    b5 = 1 if IRQ TX Empty
--    b4 = 1 if IRQ RX not Empty
--    b3 = TX FIFO Empty
--    b2 = TX FIFO Full
--    b1 = RX FIFO Empty
--    b0 = RX FIFO Full
-- 1 = CTRL
--    b7 = INT enabled (1 = Generate IRQs)
--    b6 = TX INT enabled (1 = enabled)
--    b5 = RX INT enabled (1 = enabled)
--    b4-b1 = reserved (write 0 to compatibility / always 0)
--    b0 = /DTR pin (out)
-- 2 = TX BAUD LSB
--   b7-b0 = LSB value
-- 3 = TX BAUD MSB
--   b7-b3 = not used (write 0 to compatibility)
--   b2-b0 = MSB value
-- 4 = RX BAUD LSB
--   b7-b0 = LSB value
-- 5 = RX BAUD MSB
--   b7-b3 = not used (write 0 to compatibility)
--   b2-b0 = MSB value
-- 6 = Clear IRQ Flags (W)
--   Write any value to clear IRQ flags
-- 7 = Data

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity uart is
	port (
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
		dtr_n_o		: out std_logic
	);
end entity;

architecture Behavior of uart is

	signal last_read_s		: std_logic;
	signal last_write_s		: std_logic;
	signal access_s			: std_logic;
	signal aread_s				: std_logic;
	signal awrite_s			: std_logic;

	signal mode_r				: std_logic_vector( 7 downto 0)	:= (others => '0');
	alias  char_len_a			: std_logic_vector( 1 downto 0)	is mode_r(4 downto 3);
	alias  stop_bits_a		: std_logic								is mode_r(2);
	alias  parity_a			: std_logic_vector( 1 downto 0)	is mode_r(1 downto 0);

	signal ctrl_r				: std_logic_vector( 7 downto 0);
	alias  irq_en_a			: std_logic								is ctrl_r(7);
	alias  irq_tx_a			: std_logic								is ctrl_r(6);
	alias  irq_rx_a			: std_logic								is ctrl_r(5);
	alias  dtr_n_a				: std_logic								is ctrl_r(0);

	signal baudtx_r			: std_logic_vector(10 downto 0);
	signal baudrx_r			: std_logic_vector(10 downto 0);
	signal status_s			: std_logic_vector( 7 downto 0);
	signal irq_tx_q			: std_logic;
	signal irq_rx_q			: std_logic;

	signal txfifo_wr_s		: std_logic								:= '0';
	signal txfifo_rd_s		: std_logic								:= '0';
	signal txfifo_data_s		: std_logic_vector(7 downto 0);
	signal txfifo_empty_s	: std_logic;
	signal txfifo_full_s		: std_logic;
	signal last_txempty_s	: std_logic;

	signal rxfifo_wr_s		: std_logic								:= '0';
	signal rxfifo_rd_s		: std_logic								:= '0';
	signal rxfifo_data_s		: std_logic_vector(7 downto 0);
	signal rxfifo_empty_s	: std_logic;
	signal rxfifo_full_s		: std_logic;
	signal last_rxempty_s	: std_logic;

begin

	-- FIFOs
	txfifo : entity work.fifo
	generic map (
		DATA_WIDTH_G	=> 8,
		FIFO_DEPTH_G	=> 32
	)
	port map (
		clock_i		=> clock_i,
		reset_i		=> reset_i,
		write_en_i	=> txfifo_wr_s,
		data_i		=> data_i,
		read_en_i	=> txfifo_rd_s,
		data_o		=> txfifo_data_s,
		empty_o		=> txfifo_empty_s,
		full_o		=> txfifo_full_s
	);

	rxfifo : entity work.fifo
	generic map (
		DATA_WIDTH_G	=> 8,
		FIFO_DEPTH_G	=> 32
	)
	port map (
		clock_i		=> clock_i,
		reset_i		=> reset_i,
		write_en_i	=> rxfifo_wr_s,
		data_i		=> data_i,
		read_en_i	=> rxfifo_rd_s,
		data_o		=> rxfifo_data_s,
		empty_o		=> rxfifo_empty_s,
		full_o		=> rxfifo_full_s
	);

	-- TX
	tx: entity work.uart_tx
	port map (
		clock_i		=> clock_i,
		reset_i		=> reset_i,
		baud_i		=> baudtx_r,
		char_len_i	=> char_len_a,
		stop_bits_i	=> stop_bits_a,
		parity_i		=> parity_a,
		data_i		=> txfifo_data_s,
		tx_empty_i	=> txfifo_empty_s,
		fifo_rd_o	=> txfifo_rd_s,
		cts_n_i		=> cts_n_i,
		txd_o			=> txd_o
	);

	-- Bus Interface
	access_s	<= '1'	when cs_i = '1' and (rd_i = '1' or wr_i = '1')		else '0';
	aread_s	<= '1'	when cs_i = '1' and rd_i = '1' 							else '0';
	awrite_s	<= '1'	when cs_i = '1' and wr_i = '1' 							else '0';


	-- Write registers
	process (clock_i)
	begin
		if rising_edge(clock_i) then

			txfifo_wr_s	<= '0';
			rxfifo_rd_s	<= '0';

			if reset_i = '1' then
				mode_r	<= (others => '0');
				ctrl_r	<= (others => '0');
				baudtx_r	<= (others => '0');
				baudrx_r	<= (others => '0');
				irq_tx_q	<= '0';
				irq_rx_q	<= '0';

			elsif last_write_s = '0' and awrite_s = '1' then		-- Rising
				case addr_i is
					when "000" =>													-- Register 0 = MODE
						mode_r	<= data_i;

					when "001" =>													-- Register 1 = CTRL
						ctrl_r	<= data_i;

					when "010" =>													-- Register 2 = TX Baud LSB
						baudtx_r(7 downto 0)	<= data_i;

					when "011" =>													-- Register 3 = TX Baud MSB
						baudtx_r(10 downto 8)	<= data_i(2 downto 0);

					when "100" =>													-- Register 4 = RX Baud LSB
						baudrx_r(7 downto 0)	<= data_i;

					when "101" =>													-- Register 5 = RX Baud MSB
						baudrx_r(10 downto 8)	<= data_i(2 downto 0);

					when "110" =>													-- Register 6 = clear IRQ flags
						irq_tx_q	<= '0';
						irq_rx_q	<= '0';
						
					when others =>
						txfifo_wr_s	<= '1';

				end case;

			elsif last_read_s = '0' and aread_s = '1' then		-- Rising
				if addr_i = "111" then
					rxfifo_rd_s	<= '1';
				end if;
			elsif last_txempty_s = '0' and txfifo_empty_s = '1' then		-- TX FIFO empty
				irq_tx_q <= '1';
			elsif last_rxempty_s = '1' and rxfifo_empty_s = '0' then		-- RX FIFO not empty
				irq_rx_q <= '1';
			end if;

			last_read_s		<= aread_s;
			last_write_s	<= awrite_s;
			last_txempty_s	<= txfifo_empty_s;
			last_rxempty_s <= rxfifo_empty_s;

		end if;
	end process;

	rts_n_o	<= rxfifo_full_s;
	dtr_n_o	<= dtr_n_a;

	-- IRQ
	int_n_o	<= not( (irq_en_a and (irq_tx_a and irq_tx_q))	or
						  (irq_en_a and (irq_rx_a and irq_rx_q)));

	-- Status byte
	status_s	<= dsr_n_i & "0" & irq_tx_q & irq_rx_q & txfifo_empty_s & txfifo_full_s & rxfifo_empty_s & rxfifo_full_s;

	data_o	<= (others => '1')						when access_s = '0' or rd_i = '0'	else
					status_s									when addr_i = "000"						else
					ctrl_r									when addr_i = "001"						else
					baudtx_r(7 downto 0)					when addr_i = "010"						else
					"00000" & baudtx_r(10 downto 8)	when addr_i = "011"						else
					baudrx_r(7 downto 0)					when addr_i = "100"						else
					"00000" & baudrx_r(10 downto 8)	when addr_i = "101"						else
					(others => '0')						when addr_i = "110"						else			-- unused
					rxfifo_data_s;

	has_data_o	<= access_s and rd_i;

end architecture;