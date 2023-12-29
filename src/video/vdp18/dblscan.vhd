-------------------------------------------------------------------------------
--
-- Synthesizable model of TI's TMS9918A, TMS9928A, TMS9929A.
--
-- $Id: dblscan.vhd,v 1.10 2023/12/20 08:00:00 fbelavenuto Exp $
--
-- Scan doubler
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2023, Fabio Belavenuto <belavenuto@gmail.com>
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dblscan is
	port (
		clock_master_i	: in  std_logic;
		clock_low_en_i	: in  std_logic;
		clock_high_en_i	: in  std_logic;
		color_i			: in  std_logic_vector(3 downto 0);
		color_o			: out std_logic_vector(3 downto 0);
		oddline_o		: out std_logic;
		hsync_n_i		: in  std_logic;
		vsync_n_i		: in  std_logic;
		hsync_n_o		: out std_logic;
		vsync_n_o		: out std_logic;
		hblank_o		: out std_logic
  );
end entity;

architecture rtl of dblscan is

	--
	-- input timing
	--
	signal hsync_n_t1_s		: std_logic;
	signal vsync_n_t1_s		: std_logic;
	signal hpos_s			: std_logic_vector(8 downto 0) := (others => '0');    -- input capture postion
	signal ibank_s			: std_logic;
	signal we_a_s			: std_logic;
	signal we_b_s			: std_logic;
	--
	-- output timing
	--
	signal hpos_o_s			: std_logic_vector(8 downto 0) := (others => '0');
	signal ohs_s			: std_logic;
	signal ohs_t1_s			: std_logic;
	signal ovs_s			: std_logic;
	signal ovs_t1_s			: std_logic;
	signal obank_s			: std_logic;
	signal oddline_s		: std_logic;
	--
	signal vs_cnt_s			: std_logic_vector(2 downto 0);
	signal vga_out_a_s		: std_logic_vector(3 downto 0);
	signal vga_out_b_s		: std_logic_vector(3 downto 0);

begin

	u_ram_a: entity work.dprame
	generic map (
		addr_width_g => 9,
		data_width_g => 4
	)
	port map (
		clock_master_i	=> clock_master_i,
		clock_a_en_i	=> clock_low_en_i,
		we_i			=> we_a_s,
		addr_a_i		=> hpos_s,
		data_a_i		=> color_i,
		clock_b_en_i	=> clock_high_en_i,
		addr_b_i		=> hpos_o_s,
		data_b_o		=> vga_out_a_s
	);

	u_ram_b: entity work.dprame
	generic map (
		addr_width_g => 9,
		data_width_g => 4
	)
	port map (
		clock_master_i	=> clock_master_i,
		clock_a_en_i	=> clock_low_en_i,
		we_i			=> we_b_s,
		addr_a_i		=> hpos_s,
		data_a_i		=> color_i,
		clock_b_en_i	=> clock_high_en_i,
		addr_b_i		=> hpos_o_s,
		data_b_o		=> vga_out_b_s
	);

	we_a_s	<= ibank_s;
	we_b_s	<= not ibank_s;

	process(clock_master_i, clock_low_en_i)
		variable rising_h_v : boolean;
		variable rising_v_v : boolean;
	begin
		if rising_edge (clock_master_i) and clock_low_en_i = '1' then
			hsync_n_t1_s <= hsync_n_i;
			vsync_n_t1_s <= vsync_n_i;

			rising_h_v := (hsync_n_i = '0') and (hsync_n_t1_s = '1');
			rising_v_v := (vsync_n_i = '0') and (vsync_n_t1_s = '1');

			if rising_v_v then
				ibank_s <= '0';
			elsif rising_h_v then
				ibank_s <= not ibank_s;
			end if;

			if rising_h_v then
				hpos_s <= (others => '0');
			else
				hpos_s <= hpos_s + "1";
			end if;
		end if;
	end process;

	process (clock_master_i, clock_high_en_i)
		variable rising_h_v : boolean;
	begin
		if rising_edge (clock_master_i) and clock_high_en_i = '1' then
			rising_h_v := (ohs_s = '0') and (ohs_t1_s = '1');

			if rising_h_v or (hpos_o_s = 341) then			-- 341
				hpos_o_s <= (others => '0');
				oddline_s <= not oddline_s;
			else
				hpos_o_s <= hpos_o_s + "1";
			end if;

			if (ovs_s = '0') and (ovs_t1_s = '1') then		-- rising_v_v
				obank_s <= '0';
				oddline_s <= '0';
				vs_cnt_s <= "000";
			elsif rising_h_v then
				obank_s <= not obank_s;
				if (vs_cnt_s(2) = '0') then
					vs_cnt_s <= vs_cnt_s + "1";
				end if;
			end if;

			ohs_s <= hsync_n_i; -- reg on clock_high_en_i
			ohs_t1_s <= ohs_s;

			ovs_s <= vsync_n_i; -- reg on clock_high_en_i
			ovs_t1_s <= ovs_s;
		end if;
	end process;
	
	oddline_o <= oddline_s;

	p_op : process (clock_master_i, clock_high_en_i)
	begin
		if rising_edge(clock_master_i) and clock_high_en_i = '1' then
			hsync_n_o <= '1';
			if (hpos_o_s < 26) then
				hsync_n_o <= '0';
			end if;

			hblank_o <= '0';
			if hpos_o_s < 51 or hpos_o_s > 333 then
				hblank_o <= '1';
			end if;

			if (obank_s = '1') then
				color_o <= vga_out_b_s;
			else
				color_o <= vga_out_a_s;
			end if;

			vsync_n_o <= vs_cnt_s(2);
		end if;
	end process;

end architecture;
