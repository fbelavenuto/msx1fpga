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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity counter is
	port (
		clock_i		: in  std_logic;
		reset_n_i	: in  std_logic;
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		cs_i			: in  std_logic;
		wr_i			: in  std_logic;
		cmd_i			: in  std_logic;
		clock_c_i	: in  std_logic;
		out_o			: out std_logic;
		-- Debug
		D_latch_o	: out std_logic
	);
end entity;

architecture Behavior of counter is

	signal out_q		: std_logic;
	signal ce_q			: std_logic;
	signal rd_q			: std_logic;
	signal mode_q		: std_logic_vector( 5 downto 0);
	signal value_q		: unsigned(15 downto 0);
	signal initial_q	: std_logic_vector(15 downto 0);
	signal state_q		: std_logic_vector( 1 downto 0);
	signal strobe_q	: std_logic;
	signal latched_q	: std_logic;
	signal newcmd_q	: std_logic;
	signal cnt1_s		: std_logic;
	signal cnt2_s		: std_logic;
	signal clr_ncmd_s	: std_logic;
	signal clr_ce_s	: std_logic;

begin

	cnt1_s	<= '1'	when value_q = 1	else '0';
	cnt2_s	<= '1'	when value_q = 2	else '0';

	-- Write asynchronous
	process (reset_n_i, clr_ncmd_s, clr_ce_s, cs_i)
	begin
		if reset_n_i = '0' then
			state_q		<= (others => '0');
			mode_q		<= (others => '0');
			initial_q	<= (others => '0');
			rd_q			<= '0';
			latched_q	<= '0';
			--
			ce_q			<= '0';
			newcmd_q		<= '0';
		elsif clr_ncmd_s = '1' or clr_ce_s = '1' then
			if clr_ncmd_s = '1' then
				newcmd_q		<= '0';
			end if;
			if clr_ce_s = '1' then
				ce_q			<= '0';
			end if;
		elsif rising_edge(cs_i) then

			if wr_i = '1' then						-- Write
				ce_q	<= '1';
				rd_q	<= '0';
				if cmd_i = '0'	then					-- Counter data
					if state_q(0) = '1' then
						initial_q(15 downto 8) <= data_i;
						if mode_q(5 downto 4) = "11" then
							state_q <= "10";
						else
							state_q <= "11";
						end if;
					else
						initial_q( 7 downto 0) <= data_i;
						if mode_q(5 downto 4) = "11" then
							state_q <= "01";
						else
							state_q <= "10";
						end if;
					end if;

				else										-- Command
					if data_i(5) = '1' or data_i(4) = '1' then
						mode_q		<= data_i(5 downto 0);
						newcmd_q		<= '1';
						state_q		<= '0' & (data_i(5) and not data_i(4));
					else
						latched_q	<= mode_q(5) and mode_q(4);
					end if;
					
				end if;
			else											-- Read
				if rd_q = '1' then
					latched_q <= '0';
				end if;
				rd_q <= not rd_q;
			end if;
		end if;
	end process;

	-- Synchronous
	process (reset_n_i, clock_c_i)
	begin
		if reset_n_i = '0' then

			out_q			<= '1';
			clr_ncmd_s	<= '0';
			clr_ce_s		<= '0';
			value_q		<= (others => '0');
			strobe_q		<= '0';

		elsif rising_edge(clock_c_i) then

			clr_ncmd_s	<= '0';
			clr_ce_s		<= '0';
			
			if state_q(1) = '1' and latched_q = '0' then

				if newcmd_q = '1' then
					clr_ncmd_s	<= '1';
				end if;

				case mode_q(3 downto 1) is

					when "000" | "001" =>
						if ce_q = '1' then
							out_q		<= '0';
							clr_ce_s	<= '1';
							value_q <= unsigned(initial_q);
						else
							value_q <= value_q - 1;
							if cnt1_s = '1' then
								out_q <= '1';
							end if;
						end if;

					when "010" | "110" =>
						out_q <= not cnt2_s;
						if cnt1_s = '1' or newcmd_q = '1' then
							if ce_q = '1' then
								clr_ce_s	<= '1';
							end if;
							value_q <= unsigned(initial_q);
						else
							value_q <= value_q - 1;
						end if;

					when "011" | "111" =>
						if cnt1_s = '1' or cnt2_s = '1' or newcmd_q = '1' then
							out_q		<= not out_q or newcmd_q;
							if ce_q = '1' then
								clr_ce_s	<= '1';
							end if;
							value_q	<= unsigned(initial_q(15 downto 1) & ((not out_q or newcmd_q) and initial_q(0)));
						else
							value_q <= value_q - 2;
						end if;

					when "100" | "101" =>
						if ce_q = '1' then
							out_q		<= '1';
							clr_ce_s	<= '1';
							value_q	<= unsigned(initial_q);
							strobe_q	<= '1';
						else
							value_q	<= value_q - 1;
							if cnt1_s = '1' then
								if strobe_q = '1' then
									out_q	<= '0';
								end if;
								strobe_q <= '0';
							else
								out_q <= '1';
							end if;
						end if;

					when others =>
						null;

				end case;
			end if;
		end if;
	end process;

	out_o	<= out_q;

	data_o	<= std_logic_vector(value_q(15 downto 8))	when mode_q(5) = '1' and  (mode_q(4) = '0' or rd_q = '1')	else
					std_logic_vector(value_q( 7 downto 0));

	-- Debug
	D_latch_o	<= latched_q;

end architecture;