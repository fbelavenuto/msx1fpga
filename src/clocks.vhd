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

entity clocks is
	port (
		clock_i			: in  std_logic;				-- 21 MHz
		por_i				: in  std_logic;
		turbo_on_i		: in  std_logic;				-- 0 = 3.57, 1 = 7.15
		clock_vdp_o		: out std_logic;
		clock_5m_en_o	: out std_logic;
		clock_cpu_o		: out std_logic;
		clock_psg_en_o	: out std_logic;				-- 3.57 clock enable
		clock_3m_o		: out std_logic
	);
end entity;

architecture rtl of clocks is

	-- Clocks
	signal clk1_cnt_q			: unsigned(2 downto 0)				:= (others => '0');
	signal clk2_cnt_q			: unsigned(2 downto 0)				:= (others => '0');
	signal pos_cnt3_q			: unsigned(1 downto 0)				:= "00";
	signal neg_cnt3_q			: unsigned(1 downto 0)				:= "00";
	signal div3_s				: std_logic								:= '0';
	signal clock_vdp_s		: std_logic								:= '0';
	signal clock_5m_en_s		: std_logic								:= '0';
	signal clock_3m_s			: std_logic								:= '0';
	signal clock_7m_s			: std_logic								:= '0';
	signal clock_psg_en_s	: std_logic								:= '0';
	-- Switcher
	signal sw_ff_q				: std_logic_vector(1 downto 0)	:= "11";
	signal clock_out1_s		: std_logic;
	signal clock_out2_s		: std_logic;

begin

	-- clk1_cnt_q: 5 4 3 2 1 0
	-- 0 and 3 = 3.57
	-- 0, 2, 4 = 10.7

	-- Clocks generation
	process (por_i, clock_i)
	begin
		if por_i = '1' then
			clk2_cnt_q	<= (others => '0');
			clock_5m_en_s	<= '0';
		elsif rising_edge(clock_i) then
			clock_5m_en_s	<= '0';
			if clk2_cnt_q = 0 then
				clk2_cnt_q <= "111";
			else
				clk2_cnt_q <= clk2_cnt_q - 1;
			end if;
			if clk2_cnt_q = 0 or clk2_cnt_q = 4 then
				clock_5m_en_s <= '1';				-- Scandoubler: 5.37 MHz enable
			end if;
		end if;
	end process;

	process (por_i, clock_i)
	begin
		if por_i = '1' then
			clk1_cnt_q		<= (others => '0');
			clock_vdp_s		<= '0';
			clock_3m_s		<= '0';
			pos_cnt3_q		<= "00";
		elsif rising_edge(clock_i) then
			clock_psg_en_s	<= '0';						-- PSG clock enable
			if clk1_cnt_q = 0 then
				clk1_cnt_q <= "101";
				clock_psg_en_s	<= '1';					-- PSG clock enable
			else
				clk1_cnt_q <= clk1_cnt_q - 1;
			end if;
			clock_vdp_s	<= not clock_vdp_s;			-- VDP: 10.7 MHz
			if clk1_cnt_q = 0 or clk1_cnt_q = 3 then
				clock_3m_s		<= not clock_3m_s;	-- 3.57 MHz
			end if;
			-- /3
			if pos_cnt3_q = 2 then
				pos_cnt3_q <= "00";
			else
				pos_cnt3_q <= pos_cnt3_q + 1;
			end if;
		end if;
	end process;

	-- /3
	process (por_i, clock_i)
	begin
		if por_i = '1' then
			neg_cnt3_q <= "00";
		elsif falling_edge(clock_i) then
			if neg_cnt3_q = 2 then
				neg_cnt3_q <= "00";
			else
				neg_cnt3_q <= neg_cnt3_q + 1;
			end if;
		end if;
	end process;

	clock_7m_s <= '1' when pos_cnt3_q /= 2 and neg_cnt3_q /= 2 else '0';

	-- Switcher
	process(por_i, clock_out1_s)
	begin
		if por_i = '1' then
			sw_ff_q	<= "00";
		elsif rising_edge(clock_out1_s) then
			sw_ff_q(1) <= turbo_on_i;
			sw_ff_q(0) <= sw_ff_q(1);
		end if;
	end process;

	clock_out1_s <= clock_3m_s when sw_ff_q(1) = '0' else clock_7m_s;

	-- Out
	clock_vdp_o		<= clock_vdp_s;
	clock_5m_en_o	<= clock_5m_en_s;
	clock_psg_en_o	<= clock_psg_en_s;
	clock_3m_o		<= clock_3m_s;

	with sw_ff_q select
		clock_cpu_o <=
			clock_3m_s		when "00",
			clock_7m_s		when "11",
			'1'				when others;

end architecture;