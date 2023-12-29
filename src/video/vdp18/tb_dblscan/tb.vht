-------------------------------------------------------------------------------
--
-- Testbench
--
-- Copyright (c) 2023, Fabio Belavenuto (belavenuto@gmail.com)
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

entity tb is
end tb;

architecture testbench of tb is

	component dblscan
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
	end component;

	signal tb_end				: std_logic;
	signal clock_s				: std_logic;
	signal clock_low_en_s		: std_logic;
	signal clock_high_en_s		: std_logic;
	signal color_rgb_s			: std_logic_vector( 3 downto 0)	:= (others => '0');
	signal color_vga_s			: std_logic_vector( 3 downto 0);
	signal oddline_s			: std_logic;
	signal hsync_n_rgb_s		: std_logic;
	signal vsync_n_rgb_s		: std_logic;
	signal hsync_n_vga_s		: std_logic;
	signal vsync_n_vga_s		: std_logic;
	signal hblank_s				: std_logic;

begin

	--  instance
	u_target: dblscan
	port map (
		clock_master_i	=> clock_s,
		clock_low_en_i	=> clock_low_en_s,
		clock_high_en_i	=> clock_high_en_s,
		color_i			=> color_rgb_s,
		color_o			=> color_vga_s,
		oddline_o		=> oddline_s,
		hsync_n_i		=> hsync_n_rgb_s,
		vsync_n_i		=> vsync_n_rgb_s,
		hsync_n_o		=> hsync_n_vga_s,
		vsync_n_o		=> vsync_n_vga_s,
		hblank_o		=> hblank_s
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 25 ns;
		clock_s <= '1';
		wait for 25 ns;
	end process;

	process (clock_s)
		variable cnt_q	: std_logic_vector(2 downto 0)	:= (others => '0');
	begin
		if rising_edge(clock_s) then
			clock_low_en_s <= '0';
			clock_high_en_s <= '0';
			if cnt_q = 0 then
				cnt_q := "111";
			else
				cnt_q := cnt_q - 1;
			end if;
			if cnt_q = 0 or cnt_q = 4 then
				clock_low_en_s <= '1';
			end if;
			if cnt_q = 0 or cnt_q = 2 or cnt_q = 4 or cnt_q = 6 then
				clock_high_en_s <= '1';
			end if;
		end if;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --

	-- Color in
	process (clock_s)
	begin
		if rising_edge(clock_s) then
			color_rgb_s <= color_rgb_s + 1;
		end if;
	end process;

	-- Main
	process
	begin
		-- init
		hsync_n_rgb_s	<= '1';
		vsync_n_rgb_s	<= '1';

		for i in 0 to 63 loop
			wait until( rising_edge(clock_s) );
		end loop;
		hsync_n_rgb_s	<= '0';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		hsync_n_rgb_s	<= '1';
		for i in 0 to 11 loop
			wait until( rising_edge(clock_s) );
		end loop;
		vsync_n_rgb_s	<= '0';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		vsync_n_rgb_s	<= '1';
		wait for 120 us;
		hsync_n_rgb_s	<= '0';
		for i in 0 to 9 loop
			wait until( rising_edge(clock_s) );
		end loop;
		hsync_n_rgb_s	<= '1';
		wait for 200 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end architecture;
