--
-- Z80 compatible microprocessor core, synchronous top level
-- Different timing than the original z80
-- Inputs needs to be synchronous and outputs may glitch
--
-- Version : 0242
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
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
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/t80/
--
-- Limitations :
--
-- File history :
--
--	0208 : First complete release
--
--	0210 : Fixed read with wait
--
--	0211 : Fixed interrupt cycle
--
--	0235 : Updated for T80 interface change
--
--	0236 : Added T2write_s generic
--
--	0237 : Fixed T2write_s with wait state
--
--	0238 : Updated for T80 interface change
--
--	0240 : Updated for T80 interface change
--
--	0242 : Updated for T80 interface change
--
-------------------------------------------------------------------------------
--
--  2023.12 by Fabio Belavenuto: Refactoring signal names
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.t80_pack.all;

entity T80s is
	generic(
		mode_g		: integer	:= 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		iowait_g	: integer	:= 1;	-- 0 => Single cycle I/O, 1 => Std I/O cycle
		nmos_g		: boolean	:= true	-- false => OUT(C),255; true => OUT(C),0
	);
	port (
		r800_mode_i	: in  std_logic;
		reset_n_i	: in  std_logic;
		clock_i		: in  std_logic;
		clock_en_i	: in  std_logic							:= '1';
		address_o	: out std_logic_vector(15 downto 0);
		data_i		: in  std_logic_vector(7 downto 0);
		data_o		: out std_logic_vector(7 downto 0);
		wait_n_i	: in  std_logic							:= '1';
		int_n_i		: in  std_logic							:= '1';
		nmi_n_i		: in  std_logic							:= '1';
		m1_n_o		: out std_logic;
		mreq_n_o	: out std_logic;
		iorq_n_o	: out std_logic;
		rd_n_o		: out std_logic;
		wr_n_o		: out std_logic;
		refresh_n_o	: out std_logic;
		halt_n_o	: out std_logic;
		busrq_n_i	: in  std_logic							:= '1';
		busak_n_o	: out std_logic
	);
end T80s;

architecture rtl of T80s is

	signal intcycle_n_s	: std_logic;
	signal noread_s		: std_logic;
	signal write_s		: std_logic;
	signal iorq_s		: std_logic;
	signal address_s	: std_logic_vector(15 downto 0);
	signal data_out_s	: std_logic_vector( 7 downto 0);
	signal data_r_s		: std_logic_vector(7 downto 0);
	signal mcycle_s		: std_logic_vector(2 downto 0);
	signal tstate_s		: std_logic_vector(2 downto 0);
	signal mreq_n_s		: std_logic;
	signal mreq_a_s		: std_logic;
	signal iorq_n_s		: std_logic;
	signal iorq_a_s		: std_logic;
	signal rd_n_s		: std_logic;
	signal rd_a_s		: std_logic;
	signal wr_n_s		: std_logic;
	signal wr_a_s		: std_logic;
	signal rfsh_n_s		: std_logic;
	signal busak_n_s	: std_logic;

begin

	mreq_n_o    <= mreq_n_s and mreq_a_s	when busak_n_s = '1' else 'Z';
	iorq_n_o    <= iorq_n_s and iorq_a_s	when busak_n_s = '1' else 'Z';
	rd_n_o      <= rd_n_s and rd_a_s		when busak_n_s = '1' else 'Z';
	wr_n_o      <= wr_n_s 					when busak_n_s = '1' else 'Z';
	refresh_n_o <= rfsh_n_s					when busak_n_s = '1' else 'Z';
	address_o   <= address_s				when busak_n_s = '1' else (others => 'Z');
	data_o      <= data_out_s				when busak_n_s = '1' else (others => 'Z');
	busak_n_o   <= busak_n_s;

	u0 : entity work.T80
	generic map(
		Mode	=> mode_g,
		IOWait	=> iowait_g,
		NMOS_g	=> nmos_g
	)
	port map(
		R800_mode	=> r800_mode_i,
		RESET_n		=> reset_n_i,
		CLK_n		=> clock_i,
		CEN			=> clock_en_i,
		WAIT_n		=> wait_n_i,
		INT_n		=> int_n_i,
		NMI_n		=> nmi_n_i,
		BUSRQ_n		=> busrq_n_i,
		M1_n		=> m1_n_o,
		IORQ		=> iorq_s,
		NoRead		=> noread_s,
		Write		=> write_s,
		RFSH_n		=> rfsh_n_s,
		HALT_n		=> halt_n_o,
		BUSAK_n		=> busak_n_s,
		A			=> address_s,
		DInst		=> data_i,
		DI			=> data_r_s,
		DO			=> data_out_s,
		MC			=> mcycle_s,
		TS			=> tstate_s,
		IntCycle_n	=> intcycle_n_s
	);

	mreq_a_s	<= not intcycle_n_s		when	mcycle_s = 1 and tstate_s = 1						else
				   iorq_s				when	tstate_s = 1 and noread_s = '0' and write_s = '0'	else
--				   iorq_s				when	tstate_s = 1 and write_s = '1'						else
				   '1';

	iorq_a_s	<= intcycle_n_s			when	mcycle_s = 1 and tstate_s = 1						else
				   not iorq_s			when	tstate_s = 1 and noread_s = '0' and write_s = '0'	else
--				   not iorq_s			when	tstate_s = 1 and write_s = '1'						else
				   '1';
				
	rd_a_s		<= not intcycle_n_s		when	mcycle_s = 1 and tstate_s = 1						else
				   '0'					when	tstate_s = 1 and noread_s = '0' and write_s = '0'	else
				   '1';

	process (reset_n_i, clock_i, clock_en_i)
	begin
		if reset_n_i = '0' then
			rd_n_s <= '1';
			wr_n_s <= '1';
			iorq_n_s <= '1';
			mreq_n_s <= '1';
			data_r_s <= "00000000";
		elsif rising_edge(clock_i) and clock_en_i = '1' then
			rd_n_s <= '1';
			wr_n_s <= '1';
			iorq_n_s <= '1';
			mreq_n_s <= '1';
			if mcycle_s = 1 then
				if tstate_s = 1 or (tstate_s = 2 and wait_n_i = '0') then
					rd_n_s <= not intcycle_n_s;
					mreq_n_s <= not intcycle_n_s;
					iorq_n_s <= intcycle_n_s;
				end if;
				--if tstate_s = 3 then
				--	mreq_n_s <= '0';
				--end if;
			else
				if (tstate_s = 1 or (tstate_s = 2 and wait_n_i = '0')) and noread_s = '0' and write_s = '0' then
					rd_n_s <= '0';
					iorq_n_s <= not iorq_s;
					mreq_n_s <= iorq_s;
				end if;
				if (tstate_s = 1 or (tstate_s = 2 and wait_n_i = '0')) and write_s = '1' then
					wr_n_s <= '0';
					iorq_n_s <= not iorq_s;
					mreq_n_s <= iorq_s;
				end if;
			end if;
			if tstate_s = 2 and wait_n_i = '1' then
				data_r_s <= data_i;
			end if;
		end if;
	end process;

end;
