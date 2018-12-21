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
-- MIDI UART TX interface
-- Custom by FBLabs
-- Ports:
-- 0 = Control (W) / Status (R)
--     b7 = Int enable / Int flag
--     
-- 1 = Data (W)
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity midiIntf is
	port (
		clock_i			: in    std_logic;
		reset_i			: in    std_logic;
		addr_i			: in    std_logic;
		cs_n_i			: in    std_logic;
		wr_n_i			: in    std_logic;
		rd_n_i			: in    std_logic;
		data_i			: in    std_logic_vector(7 downto 0);
		data_o			: out   std_logic_vector(7 downto 0);
		has_data_o		: out   std_logic;
		-- Outs
		int_n_o			: out   std_logic;
		wait_n_o			: out   std_logic;
		tx_o				: out   std_logic
	);
end entity;

architecture rtl of midiIntf is

	signal enable_s		: std_logic;
	signal port0_r_s		: std_logic;
	signal status_s		: std_logic_vector( 7 downto 0);
	signal int_en_q		: std_logic;
	signal int_n_s			: std_logic;
	signal wait_n_s		: std_logic;
	signal baudr_cnt_q	: unsigned(10 downto 0);
	signal baudr_clk_s	: std_logic;
	signal intcnt_q		: unsigned(15 downto 0);
	signal bitcnt_s		: unsigned( 3 downto 0);
	signal shift_q			: std_logic_vector( 7 downto 0);

begin

	enable_s		<= '1' when cs_n_i = '0' and (wr_n_i = '0' or rd_n_i = '0')	else '0';

	port0_r_s	<= '1' when enable_s = '1' and addr_i = '0' and rd_n_i = '0'	else '0';

	-- Port reading
	has_data_o	<= port0_r_s;

	data_o <=	status_s	when port0_r_s = '1'										else
					(others => '1');

	status_s <= not int_n_s & "000000" & int_en_q;

	-- Control port
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
			int_en_q <= '0';
		elsif rising_edge(clock_i) then
			if enable_s = '1' and addr_i = '0' and wr_n_i = '0'  then
				int_en_q	<= data_i(0);
			end if;
		end if;
	end process;

	-- Interrupt count and int flag clear
	process (reset_i, clock_i)
		variable edge_v	: std_logic_vector(1 downto 0);
	begin
		if reset_i = '1' or int_en_q = '0' then
			intcnt_q	<= (others => '0');
			int_n_s	<= '1';
		elsif rising_edge(clock_i) then
			if intcnt_q = 40000 then
				intcnt_q <= (others => '0');
				int_n_s <= '0';
			else
				intcnt_q <= intcnt_q + 1;
			end if;
			edge_v := edge_v(0) & port0_r_s;
			if edge_v = "10" then
				int_n_s <= '1';
			end if;
		end if;
	end process;

	-- Baud Rate generator
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
		elsif rising_edge(clock_i) then
		end if;
	end process;

	-- Serial TX
	process(reset_i, clock_i)
		variable edge_v	: std_logic_vector(1 downto 0);
		variable wr_v		: std_logic;
	begin		
		if reset_i = '1' then
			baudr_cnt_q <= (others => '0');
			shift_q		<= (others => '1');
			bitcnt_s		<= (others => '0');
			tx_o			<= '1';
			wait_n_s		<= '1';
		elsif rising_edge(clock_i) then
			baudr_clk_s	<= '0';
			edge_v := edge_v(0) & (enable_s and addr_i and not wr_n_i);
			if edge_v = "01" then
				wr_v := '1';
				if bitcnt_s = 0 then
					baudr_cnt_q <= (others => '0');
					baudr_clk_s	<= '1';
				else
					wait_n_s	<= '0';
				end if;
			end if;

			if baudr_cnt_q = 128 then
				baudr_cnt_q <= (others => '0');
				baudr_clk_s	<= '1';
			else
				baudr_cnt_q <= baudr_cnt_q + 1;
			end if;

			if baudr_clk_s = '1' then
				case bitcnt_s is
					when "0000" =>
						-- Idle - check for a bus access
						if wr_v = '1' then
							shift_q	<= data_i;
							tx_o		<= '0';						-- Start bit
							bitcnt_s	<= bitcnt_s + 1;
							wr_v		:= '0';
							wait_n_s	<= '1';
						end if;
					when	"0001" | "0010" | "0011" | "0100" | 
							"0101" | "0110" | "0111" | "1000" =>
						tx_o		<= shift_q(0);
						shift_q	<= '1' & shift_q(7 downto 1);
						bitcnt_s <= bitcnt_s + 1;
					when "1001" =>
						tx_o		<= '1';							-- Stop bit
						bitcnt_s	<= (others => '0');
					when others =>
						null;
				end case;
			end if;
		end if;
	end process;

	int_n_o	<= int_n_s;
	wait_n_o	<= wait_n_s;

end architecture;
