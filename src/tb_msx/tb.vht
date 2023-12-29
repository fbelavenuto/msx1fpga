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
use work.msx_pack.all;

entity tb is
end tb;

architecture testbench of tb is

	signal tb_end				: std_logic;
	signal por_s				: std_logic;
	signal reset_s				: std_logic;
	signal clock_s				: std_logic;
	signal clock_3m_en_s		: std_logic;
	signal clock_5m_en_s		: std_logic;
	signal clock_7m_en_s		: std_logic;
	signal clock_10m_en_s		: std_logic;
	signal ram_addr_s			: std_logic_vector(22 downto 0);
	signal ram_data_from_s		: std_logic_vector( 7 downto 0);
	signal ram_data_to_s		: std_logic_vector( 7 downto 0);
	signal ram_ce_n_s			: std_logic;
	signal ram_oe_n_s			: std_logic;
	signal ram_we_n_s			: std_logic;

begin

	--  instance
	u_clocks: entity work.clocks
	port map (
		clock_master_i	=> clock_s,
		por_i			=> por_s,
		clock_3m_en_o	=> clock_3m_en_s,
		clock_5m_en_o	=> clock_5m_en_s,
		clock_7m_en_o	=> clock_7m_en_s,
		clock_10m_en_o	=> clock_10m_en_s
	);

	u_target: entity work.msx
	generic map (
		hw_id_g			=> 255,
		hw_txt_g		=> "SIMUL",
		hw_version_g	=> X"13",
		video_opt_g		=> 0,		-- 0 = no dblscan, 1 = dblscan configurable, 2 = dblscan always enabled, 3 = no dblscan and external palette
		ramsize_g		=> 512,		-- 512, 2048 or 8192
		hw_hashwds_g	=> '0',		-- 0 = Software disk-change, 1 = Hardware disk-change
		opll_en_g		=> true
	)
	port map(
		-- Resets
		por_i			=> por_s,
		softreset_o		=> open,
		reload_o		=> open,
		reset_i			=> reset_s,
		-- clocks
		clock_master_i	=> clock_s,
		clock_vdp_en_i	=> clock_10m_en_s,
		clock_cpu_en_i	=> clock_7m_en_s,
		clock_psg_en_i	=> clock_3m_en_s,
		-- Turbo
		turbo_on_k_i	=> '1',
		turbo_on_o		=> open,
		-- Options
		opt_nextor_i	=> '1',
		opt_mr_type_i	=> "00",
		opt_vga_on_i	=> '1',
		-- RAM
		ram_addr_o		=> ram_addr_s,
		ram_data_i		=> ram_data_from_s,
		ram_data_o		=> ram_data_to_s,
		ram_ce_n_o		=> ram_ce_n_s,
		ram_oe_n_o		=> ram_oe_n_s,
		ram_we_n_o		=> ram_we_n_s,
		-- ROM
		rom_addr_o		=> open,
		rom_data_i		=> ram_data_from_s,
		rom_ce_n_o		=> open,
		rom_oe_n_o		=> open,
		-- External bus
		bus_addr_o		=> open,
		bus_data_i		=> (others => '1'),
		bus_data_o		=> open,
		bus_rd_n_o		=> open,
		bus_wr_n_o		=> open,
		bus_m1_n_o		=> open,
		bus_iorq_n_o	=> open,
		bus_mreq_n_o	=> open,
		bus_sltsl1_n_o	=> open,
		bus_sltsl2_n_o	=> open,
		bus_wait_n_i	=> '1',
		bus_nmi_n_i		=> '1',
		bus_int_n_i		=> '1',
		-- VDP VRAM
		vram_addr_o		=> open,
		vram_data_i		=> (others => '0'),
		vram_data_o		=> open,
		vram_ce_n_o		=> open,
		vram_oe_n_o		=> open,
		vram_we_n_o		=> open,
		-- Keyboard
		rows_o			=> open,
		cols_i			=> (others => '1'),
		caps_en_o		=> open,
		keyb_valid_i	=> '0',
		keyb_data_i		=> (others => '0'),
		keymap_addr_o	=> open,
		keymap_data_o	=> open,
		keymap_we_n_o	=> open,
		-- Audio
		audio_scc_o		=> open,
		audio_psg_o		=> open,
		beep_o			=> open,
		volumes_o		=> open,
		-- K7
		k7_motor_o		=> open,
		k7_audio_o		=> open,
		k7_audio_i		=> '0',
		-- Joystick
		joy1_up_i		=> '1',
		joy1_down_i		=> '1',
		joy1_left_i		=> '1',
		joy1_right_i	=> '1',
		joy1_btn1_i		=> '1',
		joy1_btn1_o		=> open,
		joy1_btn2_i		=> '1',
		joy1_btn2_o		=> open,
		joy1_out_o		=> open,
		joy2_up_i		=> '1',
		joy2_down_i		=> '1',
		joy2_left_i		=> '1',
		joy2_right_i	=> '1',
		joy2_btn1_i		=> '1',
		joy2_btn1_o		=> open,
		joy2_btn2_i		=> '1',
		joy2_btn2_o		=> open,
		joy2_out_o		=> open,
		-- Video
		cnt_hor_o		=> open,
		cnt_ver_o		=> open,
		rgb_r_o			=> open,
		rgb_g_o			=> open,
		rgb_b_o			=> open,
		hsync_n_o		=> open,
		vsync_n_o		=> open,
		ntsc_pal_o		=> open,
		vga_on_k_i		=> '0',
		vga_en_o		=> open,
		scanline_on_k_i	=> '0',
		scanline_en_o	=> open,
		vertfreq_on_k_i	=> '0',
		-- SPI/SD
		flspi_cs_n_o	=> open,
		spi2_cs_n_o		=> open,
		spi_cs_n_o		=> open,
		spi_sclk_o		=> open,
		spi_mosi_o		=> open,
		spi_miso_i		=> '0',
		sd_pres_n_i		=> '0',
		sd_wp_i			=> '0'
	);

	-- Main RAM
	ram: entity work.spram
	generic map (
		addr_width_g => 23,
		data_width_g => 8
	)
	port map (
		clock_i		=> clock_s,
		clock_en_i	=> '1',
		we_n_i		=> ram_we_n_s,
		addr_i		=> ram_addr_s,
		data_i		=> ram_data_to_s,
		data_o		=> ram_data_from_s
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

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init

		-- reset
		reset_s		<= '1';
		por_s		<= '1';
		wait for 100 ns;
		por_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 3800 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end architecture;
