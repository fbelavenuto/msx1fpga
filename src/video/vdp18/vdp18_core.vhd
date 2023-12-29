-------------------------------------------------------------------------------
--
-- Synthesizable model of TI's TMS9918A, TMS9928A, TMS9929A.
--
-- $Id: vdp18_core.vhd,v 1.28 2006/06/18 10:47:01 arnim Exp $
--
-- Core Toplevel
--
-- Notes:
--   This core implements a simple VRAM interface which is suitable for a
--   synchronous SRAM component. There is currently no support of the
--   original DRAM interface.
--
--   Please be aware that the colors might me slightly different from the
--   original TMS9918. It is assumed that the simplified conversion to RGB
--   encoding is equivalent to the compatability mode of the V9938.
--   Implementing a 100% correct color encoding for RGB would require
--   significantly more logic and 8-bit wide RGB DACs.
--
-- References:
--
--   * TI Data book TMS9918.pdf
--     http://www.bitsavers.org/pdf/ti/_dataBooks/TMS9918.pdf
--
--   * Sean Young's tech article:
--     http://bifi.msxnet.org/msxnet/tech/tms9918a.txt
--
--   * Paul Urbanus' discussion of the timing details
--     http://bifi.msxnet.org/msxnet/tech/tmsposting.txt
--
--   * Richard F. Drushel's article series
--     "This Week With My Coleco ADAM"
--     http://junior.apk.net/~drushel/pub/coleco/twwmca/index.html
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2006, Arnim Laeuger (arnim.laeuger@gmx.net)
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
-- 2016/11 - Some changes by Fabio Belavenuto
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.vdp18_pack.opmode_t;
use work.vdp18_pack.hv_t;
use work.vdp18_pack.access_t;

entity vdp18_core is
	generic (
		video_opt_g		: integer		:= 0;		-- 0 = no dblscan, 1 = dblscan configurable, 2 = dblscan always enabled, 3 = no dblscan and external palette
		start_on_g		: boolean		:= false	-- false = VDP starts off, true = VDP start showing video
	);
	port (
		-- Global Interface -------------------------------------------------------
		clock_i			: in  std_logic;
		clk_en_10m7_i	: in  std_logic;
		por_i			: in  std_logic;
		reset_i			: in  std_logic;
		-- CPU Interface ----------------------------------------------------------
		csr_n_i			: in  std_logic;
		csw_n_i			: in  std_logic;
		mode_i			: in  std_logic_vector( 0 to  1);
		int_n_o			: out std_logic;
		cd_i			: in  std_logic_vector( 0 to  7);
		cd_o			: out std_logic_vector( 0 to  7);
		wait_n_o		: out std_logic;
		-- VRAM Interface ---------------------------------------------------------
		vram_ce_n_o		: out std_logic;
		vram_oe_n_o		: out std_logic;
		vram_we_n_o		: out std_logic;
		vram_a_o		: out std_logic_vector( 0 to 13);
		vram_d_o		: out std_logic_vector( 0 to  7);
		vram_d_i		: in  std_logic_vector( 0 to  7);
		-- Video Interface --------------------------------------------------------
		vga_en_i		: in  std_logic;
		scanline_en_i	: in  std_logic;
		cnt_hor_o		: out std_logic_vector( 8 downto 0);
		cnt_ver_o		: out std_logic_vector( 7 downto 0);
		rgb_r_o			: out std_logic_vector( 0 to  3);
		rgb_g_o			: out std_logic_vector( 0 to  3);
		rgb_b_o			: out std_logic_vector( 0 to  3);
		hsync_n_o		: out std_logic;
		vsync_n_o		: out std_logic;
		ntsc_pal_i		: in  std_logic;		-- 0 = NTSC
		vertfreq_csw_o	: out std_logic;
		vertfreq_d_o	: out std_logic
	);
end entity;

architecture struct of vdp18_core is

	signal clk_en_5m37_s,
	       clk_en_acc_s			: std_logic;

	signal opmode_s				: opmode_t;
	signal access_type_s		: access_t;
	signal num_pix_s,
			num_line_s			: hv_t;

	signal rgb_hsync_n_s		: std_logic;
	signal rgb_vsync_n_s		: std_logic;
	signal vga_hsync_n_s		: std_logic;
	signal vga_vsync_n_s		: std_logic;

	signal blank_s          	: std_logic;
	signal vert_inc_s       	: std_logic;
	signal reg_blank_s,
			reg_size1_s,
			reg_mag1_s			: std_logic;

	signal spr_5th_s			: std_logic;
	signal spr_5th_num_s		: std_logic_vector(0 to 4);

	signal stop_sprite_s		: std_logic;
	signal vert_active_s,
			hor_active_s		: std_logic;

	signal reg_ntb_s			: std_logic_vector(0 to  3);
	signal reg_ctb_s			: std_logic_vector(0 to  7);
	signal reg_pgb_s			: std_logic_vector(0 to  2);
	signal reg_satb_s			: std_logic_vector(0 to  6);
	signal reg_spgb_s			: std_logic_vector(0 to  2);
	signal reg_col1_s,
			reg_col0_s			: std_logic_vector(0 to  3);
	signal cpu_vram_a_s			: std_logic_vector(0 to 13);

	signal pat_table_s			: std_logic_vector(0 to  9);
	signal pat_name_s			: std_logic_vector(0 to  7);
	signal pat_col_s			: std_logic_vector(0 to  3);

	signal spr_num_s			: std_logic_vector(0 to  4);
	signal spr_line_s			: std_logic_vector(0 to  3);
	signal spr_name_s			: std_logic_vector(0 to  7);
	signal spr0_col_s,
			spr1_col_s,
			spr2_col_s,
			spr3_col_s			: std_logic_vector(0 to  3);
	signal spr_coll_s			: std_logic;

	signal irq_s				: std_logic;
 
	signal vram_read_s			: std_logic;
	signal vram_write_s			: std_logic;
	signal col_s				: std_logic_vector(0 to  3);
	signal col_rgb_s			: std_logic_vector(0 to  3);
	signal col_vga_s			: std_logic_vector(0 to  3);
	signal rgb_s				: std_logic_vector(0 to 15);
	signal palette_idx_s		: std_logic_vector(0 to  3);
	signal palette_val_s		: std_logic_vector(0 to 15);
	signal palette_wr_s			: std_logic;
	signal ntsc_pal_e_s			: std_logic;
	signal oddline_s			: std_logic							:= '0';

begin

	-----------------------------------------------------------------------------
	-- Clock Generator
	-----------------------------------------------------------------------------
	clk_gen_b: entity work.vdp18_clk_gen
	port map (
		clock_i			=> clock_i,
		clk_en_10m7_i	=> clk_en_10m7_i,
		reset_i			=> por_i,
		clk_en_5m37_o	=> clk_en_5m37_s
	);

	-----------------------------------------------------------------------------
	-- Horizontal and Vertical Timing Generator
	-----------------------------------------------------------------------------
	hor_vert_b: entity  work.vdp18_hor_vert
	port map (
		clock_i			=> clock_i,
		clk_en_5m37_i	=> clk_en_5m37_s,
		reset_i			=> por_i,
		opmode_i		=> opmode_s,
		ntsc_pal_i		=> ntsc_pal_e_s,
		num_pix_o		=> num_pix_s,
		num_line_o		=> num_line_s,
		vert_inc_o		=> vert_inc_s,
		hsync_n_o		=> rgb_hsync_n_s,
		vsync_n_o		=> rgb_vsync_n_s,
		blank_o			=> blank_s,
		cnt_hor_o		=> cnt_hor_o,
		cnt_ver_o		=> cnt_ver_o
	);

	-----------------------------------------------------------------------------
	-- Control Module
	-----------------------------------------------------------------------------
	ctrl_b: entity  work.vdp18_ctrl
	port map (
		clock_i			=> clock_i,
		clk_en_5m37_i	=> clk_en_5m37_s,
		reset_i			=> reset_i,
		opmode_i		=> opmode_s,
		vram_read_i		=> vram_read_s,
		vram_write_i	=> vram_write_s,
		vram_ce_n_o		=> vram_ce_n_o,
		vram_oe_n_o		=> vram_oe_n_o,
		num_pix_i		=> num_pix_s,
		num_line_i		=> num_line_s,
		vert_inc_i		=> vert_inc_s,
		reg_blank_i		=> reg_blank_s,
		reg_size1_i		=> reg_size1_s,
		stop_sprite_i	=> stop_sprite_s,
		clk_en_acc_o	=> clk_en_acc_s,
		access_type_o	=> access_type_s,
		vert_active_o	=> vert_active_s,
		hor_active_o	=> hor_active_s,
		irq_o			=> irq_s
	);

	-----------------------------------------------------------------------------
	-- CPU I/O Module
	-----------------------------------------------------------------------------
	cpu_io_b: entity  work.vdp18_cpuio
	generic map (
		start_on_g		=> start_on_g
	)
	port map (
		clock_i			=> clock_i,
		clk_en_10m7_i	=> clk_en_10m7_i,
		clk_en_acc_i	=> clk_en_acc_s,
		reset_i			=> por_i,
		csr_n_i			=> csr_n_i,
		csw_n_i			=> csw_n_i,
		mode_i			=> mode_i,
		cd_i			=> cd_i,
		cd_o			=> cd_o,
		wait_n_o		=> wait_n_o,
		access_type_i	=> access_type_s,
		opmode_o		=> opmode_s,
		vram_read_o		=> vram_read_s,
		vram_write_o	=> vram_write_s,
		vram_we_n_o		=> vram_we_n_o,
		vram_a_o		=> cpu_vram_a_s,
		vram_d_o		=> vram_d_o,
		vram_d_i		=> vram_d_i,
		spr_coll_i		=> spr_coll_s,
		spr_5th_i		=> spr_5th_s,
		spr_5th_num_i	=> spr_5th_num_s,
		reg_ev_o		=> open,
		reg_16k_o		=> open,
		reg_blank_o		=> reg_blank_s,
		reg_size1_o		=> reg_size1_s,
		reg_mag1_o		=> reg_mag1_s,
		reg_ntb_o		=> reg_ntb_s,
		reg_ctb_o		=> reg_ctb_s,
		reg_pgb_o		=> reg_pgb_s,
		reg_satb_o		=> reg_satb_s,
		reg_spgb_o		=> reg_spgb_s,
		reg_col1_o		=> reg_col1_s,
		reg_col0_o		=> reg_col0_s,
		palette_idx_o	=> palette_idx_s,
		palette_val_o	=> palette_val_s,
		palette_wr_o	=> palette_wr_s,
		irq_i			=> irq_s,
		int_n_o			=> int_n_o,
		vertfreq_csw_o	=> vertfreq_csw_o,
		vertfreq_d_o	=> vertfreq_d_o
 );

	-----------------------------------------------------------------------------
	-- VRAM Address Multiplexer
	-----------------------------------------------------------------------------
	addr_mux_b: entity work.vdp18_addr_mux
	port map (
		access_type_i	=> access_type_s,
		opmode_i		=> opmode_s,
		num_line_i		=> num_line_s,
		reg_ntb_i		=> reg_ntb_s,
		reg_ctb_i		=> reg_ctb_s,
		reg_pgb_i		=> reg_pgb_s,
		reg_satb_i		=> reg_satb_s,
		reg_spgb_i		=> reg_spgb_s,
		reg_size1_i		=> reg_size1_s,
		cpu_vram_a_i	=> cpu_vram_a_s,
		pat_table_i		=> pat_table_s,
		pat_name_i		=> pat_name_s,
		spr_num_i		=> spr_num_s,
		spr_line_i		=> spr_line_s,
		spr_name_i		=> spr_name_s,
		vram_a_o		=> vram_a_o
	);

	-----------------------------------------------------------------------------
	-- Pattern Generator
	-----------------------------------------------------------------------------
	pattern_b: entity  work.vdp18_pattern
	port map (
		clock_i			=> clock_i,
		clk_en_5m37_i	=> clk_en_5m37_s,
		clk_en_acc_i	=> clk_en_acc_s,
		reset_i			=> reset_i,
		opmode_i		=> opmode_s,
		access_type_i	=> access_type_s,
		num_line_i		=> num_line_s,
		vram_d_i		=> vram_d_i,
		vert_inc_i		=> vert_inc_s,
		vsync_n_i		=> rgb_vsync_n_s,
		reg_col1_i		=> reg_col1_s,
		reg_col0_i		=> reg_col0_s,
		pat_table_o		=> pat_table_s,
		pat_name_o		=> pat_name_s,
		pat_col_o		=> pat_col_s
	);

	-----------------------------------------------------------------------------
	-- Sprite Generator
	-----------------------------------------------------------------------------
	sprite_b: entity  work.vdp18_sprite
	port map (
		clock_i			=> clock_i,
		clk_en_5m37_i	=> clk_en_5m37_s,
		clk_en_acc_i	=> clk_en_acc_s,
		reset_i			=> reset_i,
		access_type_i	=> access_type_s,
		num_pix_i		=> num_pix_s,
		num_line_i		=> num_line_s,
		vram_d_i		=> vram_d_i,
		vert_inc_i		=> vert_inc_s,
		reg_size1_i		=> reg_size1_s,
		reg_mag1_i		=> reg_mag1_s,
		spr_5th_o		=> spr_5th_s,
		spr_5th_num_o	=> spr_5th_num_s,
		stop_sprite_o	=> stop_sprite_s,
		spr_coll_o		=> spr_coll_s,
		spr_num_o		=> spr_num_s,
		spr_line_o		=> spr_line_s,
		spr_name_o		=> spr_name_s,
		spr0_col_o		=> spr0_col_s,
		spr1_col_o		=> spr1_col_s,
		spr2_col_o		=> spr2_col_s,
		spr3_col_o		=> spr3_col_s
	);

	-----------------------------------------------------------------------------
	-- Color Multiplexer
	-----------------------------------------------------------------------------
	col_mux_b: entity  work.vdp18_col_mux
	port map (
		vert_active_i	=> vert_active_s,
		hor_active_i	=> hor_active_s,
		blank_i			=> blank_s,
		reg_col0_i		=> reg_col0_s,
		pat_col_i		=> pat_col_s,
		spr0_col_i		=> spr0_col_s,
		spr1_col_i		=> spr1_col_s,
		spr2_col_i		=> spr2_col_s,
		spr3_col_i		=> spr3_col_s,
		col_o			=> col_rgb_s
	);

	von3: if video_opt_g /= 3 generate

		ntsc_pal_e_s <= ntsc_pal_i;

		-----------------------------------------------------------------------------
		-- Palette memory
		-----------------------------------------------------------------------------
		palette: entity work.vdp18_palette
		port map (
			reset_i		=> reset_i,
			clock_i		=> clock_i,
			we_i		=> palette_wr_s,
			addr_wr_i	=> palette_idx_s,
			data_i		=> palette_val_s,
			addr_rd_i	=> col_s,
			data_o		=> rgb_s
		);

		-----------------------------------------------------------------------------
		-- Process rgb_reg
		--
		-- Purpose:
		--   Converts the color information to simple RGB and saves these in
		--   output registers.
		--
		rgb_reg: process (clock_i, por_i)
		begin
			if por_i = '1' then
				rgb_r_o   <= (others => '0');
				rgb_g_o   <= (others => '0');
				rgb_b_o   <= (others => '0');
			elsif rising_edge(clock_i) then
				if clk_en_10m7_i = '1' then
					if scanline_en_i = '1' and vga_en_i = '1' then
						if rgb_s( 0 to 3) > 1 and oddline_s = '1' then
							rgb_r_o <= rgb_s( 0 to 3) - 2;
						else
							rgb_r_o <= rgb_s( 0 to 3);
						end if;
						if rgb_s(12 to 15) > 1 and oddline_s = '1' then
							rgb_g_o <= rgb_s(12 to 15) - 2;
						else
							rgb_g_o <= rgb_s(12 to 15);
						end if;
						if rgb_s( 4 to 7) > 1 and oddline_s = '1' then
							rgb_b_o <= rgb_s( 4 to 7) - 2;
						else
							rgb_b_o <= rgb_s( 4 to 7);
						end if;
					else
						rgb_r_o <= rgb_s( 0 to 3);
						rgb_g_o <= rgb_s(12 to 15);
						rgb_b_o <= rgb_s( 4 to 7);
					end if;
				end if;
			end if;
		end process rgb_reg;
		--
		-----------------------------------------------------------------------------
	end generate;

	vo0: if video_opt_g = 0 generate

		col_s		<= col_rgb_s;
		hsync_n_o	<= rgb_hsync_n_s;
		vsync_n_o	<= rgb_vsync_n_s;

	end generate;

	vo3: if video_opt_g = 3 generate

		ntsc_pal_e_s	<= '0';					-- Only NTSC
		rgb_r_o			<= col_rgb_s;
		rgb_g_o			<= (others => '0');
		rgb_b_o			<= (others => '0');
		hsync_n_o		<= rgb_hsync_n_s;
		vsync_n_o		<= rgb_vsync_n_s;

	end generate;

	vo1_2: if video_opt_g = 1 or video_opt_g = 2 generate

		col_s	<= col_vga_s	when vga_en_i = '1' or video_opt_g = 2	else col_rgb_s;

		dblscan: entity work.dblscan
		port map (
			clock_master_i	=> clock_i,
			clock_low_en_i	=> clk_en_5m37_s,
			clock_high_en_i	=> clk_en_10m7_i,
			color_i			=> col_rgb_s,
			color_o			=> col_vga_s,
			oddline_o		=> oddline_s,
			hsync_n_i		=> rgb_hsync_n_s,
			vsync_n_i		=> rgb_vsync_n_s,
			hsync_n_o		=> vga_hsync_n_s,
			vsync_n_o		=> vga_vsync_n_s
		);

		hsync_n_o		<= vga_hsync_n_s	when vga_en_i = '1' or video_opt_g = 2	else rgb_hsync_n_s;
		vsync_n_o		<= vga_vsync_n_s	when vga_en_i = '1' or video_opt_g = 2	else rgb_vsync_n_s;

	end generate;

end architecture;
