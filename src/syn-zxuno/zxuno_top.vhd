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
use ieee.std_logic_unsigned.all;
--use work.vdp18_paletas_3bit_pack.all;

entity zxuno_top is
	port (
		-- Clocks
		clock_50_i			: in    std_logic;

		-- SRAM (AS7C34096)
		sram_addr_o			: out   std_logic_vector(18 downto 0)	:= (others => '0');
		sram_data_io		: inout std_logic_vector(7 downto 0)	:= (others => 'Z');
		sram_we_n_o			: out   std_logic								:= '1';

		-- PS2
		ps2_clk_io			: inout std_logic								:= 'Z';
		ps2_data_io			: inout std_logic								:= 'Z';
--		ps2_mouse_clk_io  : inout std_logic								:= 'Z';
--		ps2_mouse_data_io : inout std_logic								:= 'Z';

		-- SD Card
		sd_cs_n_o			: out   std_logic								:= '1';
		sd_sclk_o			: out   std_logic								:= '0';
		sd_mosi_o			: out   std_logic								:= '0';
		sd_miso_i			: in    std_logic;

		-- Flash
		flash_cs_n_o		: out   std_logic								:= '1';
		flash_sclk_o		: out   std_logic								:= '0';
		flash_mosi_o		: out   std_logic								:= '0';
		flash_miso_i		: in    std_logic;
--		flash_wp_o			: out   std_logic								:= '0';
--		flash_hold_o		: out   std_logic								:= '1';

		-- Joystick
		joy_up_i				: in    std_logic;
		joy_down_i			: in    std_logic;
		joy_left_i			: in    std_logic;
		joy_right_i			: in    std_logic;
		joy_fire1_i			: inout std_logic;
		joy_fire2_i			: inout std_logic;
		joy_fire3_o			: out   std_logic;

		-- Audio
		dac_l_o				: out   std_logic								:= '0';
		dac_r_o				: out   std_logic								:= '0';
		ear_i					: in    std_logic;

		-- VGA
		vga_r_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_g_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_b_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_csync_n_o		: out   std_logic								:= '1';
		vga_vsync_n_o		: out   std_logic								:= '1';
		vga_ntsc_o			: out   std_logic								:= '0';
		vga_pal_o			: out   std_logic								:= '1';

		-- HDMI
--		hdmi_p_o				: out   std_logic_vector(3 downto 0);
--		hdmi_n_o				: out   std_logic_vector(3 downto 0);

		-- GPIO
--		gpio_io				: inout std_logic_vector(35 downto 6)	:= (others => 'Z');

		-- Debug
		led_o					: out   std_logic								:= '0'
	);
end entity;

architecture behavior of zxuno_top is

	-- Resets
	signal por_cnt_s			: unsigned(7 downto 0)				:= (others => '1');
	signal por_clock_s		: std_logic;
	signal por_s				: std_logic;
	signal reset_s				: std_logic;
	signal soft_reset_k_s	: std_logic;
	signal soft_reset_s_s	: std_logic;
	signal soft_por_s			: std_logic;
	signal soft_rst_cnt_s	: unsigned(7 downto 0)	:= X"FF";

	-- Clocks
	signal clock_master_s	: std_logic;
	signal clock_vdp_s		: std_logic;
	signal clock_cpu_s		: std_logic;
	signal clock_psg_en_s	: std_logic;
	signal clock_3m_s			: std_logic;
	signal turbo_on_s			: std_logic;
	signal clock_vga_s		: std_logic;
	signal clock_hdmi_s		: std_logic;

	-- RAM
	signal ram_addr_s			: std_logic_vector(22 downto 0);		-- 8MB
	signal ram_data_from_s	: std_logic_vector(7 downto 0);
	signal ram_data_to_s		: std_logic_vector(7 downto 0);
	signal ram_ce_s			: std_logic;
	signal ram_oe_s			: std_logic;
	signal ram_we_s			: std_logic;

	-- ROM
	signal rom_addr_s			: std_logic_vector(14 downto 0);		-- 32K
	signal rom_data_s			: std_logic_vector(7 downto 0);
	signal rom_ce_s			: std_logic;
	signal rom_oe_s			: std_logic;

	-- VRAM memory
	signal vram_addr_s		: std_logic_vector(13 downto 0);		-- 16K
	signal vram_do_s			: std_logic_vector(7 downto 0);
	signal vram_di_s			: std_logic_vector(7 downto 0);
--	signal vram_ce_s			: std_logic;
--	signal vram_oe_s			: std_logic;
	signal vram_we_s			: std_logic;

	-- Audio
	signal audio_scc_s		: signed(14 downto 0);
	signal audio_psg_s		: unsigned(7 downto 0);
	signal audio_s				: std_logic_vector(15 downto 0);
	signal beep_s				: std_logic;
	signal dac_s				: std_logic;

	-- Video
	signal rgb_col_s			: std_logic_vector( 3 downto 0);
	signal rgb_r_s				: std_logic_vector( 3 downto 0);
	signal rgb_g_s				: std_logic_vector( 3 downto 0);
	signal rgb_b_s				: std_logic_vector( 3 downto 0);
	signal cnt_hor_s			: std_logic_vector( 8 downto 0);
	signal cnt_ver_s			: std_logic_vector( 7 downto 0);
	signal rgb_hsync_n_s		: std_logic;
	signal rgb_vsync_n_s		: std_logic;
	signal ntsc_pal_s			: std_logic;
	signal vga_en_s			: std_logic;
	signal vga_hsync_n_s		: std_logic;
	signal vga_vsync_n_s		: std_logic;
	signal vga_blank_s		: std_logic;
	signal vga_col_s			: std_logic_vector( 3 downto 0);
	signal vga_r_s				: std_logic_vector( 3 downto 0);
	signal vga_g_s				: std_logic_vector( 3 downto 0);
	signal vga_b_s				: std_logic_vector( 3 downto 0);
	signal scanlines_en_s	: std_logic;
	signal odd_line_s			: std_logic;
	signal sound_hdmi_s		: std_logic_vector(15 downto 0);
	signal tdms_r_s			: std_logic_vector( 9 downto 0);
	signal tdms_g_s			: std_logic_vector( 9 downto 0);
	signal tdms_b_s			: std_logic_vector( 9 downto 0);
	signal tdms_p_s			: std_logic_vector( 3 downto 0);
	signal tdms_n_s			: std_logic_vector( 3 downto 0);
	type ram_t is array (natural range 0 to 15) of std_logic_vector(15 downto 0);
	constant rgb_c : ram_t := (
			--      RB0G
			0  => X"0000",
			1  => X"0000",
			2  => X"240C",
			3  => X"570D",
			4  => X"5E05",
			5  => X"7F07",
			6  => X"D405",
			7  => X"4F0E",
			8  => X"F505",
			9  => X"F707",
			10 => X"D50C",
			11 => X"E80C",
			12 => X"230B",
			13 => X"CB09",
			14 => X"CC0C",
			15 => X"FF0F"
	);

	-- Keyboard
	signal rows_s				: std_logic_vector(3 downto 0);
	signal cols_s				: std_logic_vector(7 downto 0);
	signal caps_en_s			: std_logic;
	signal extra_keys_s		: std_logic_vector(3 downto 0);
	signal reload_core_s		: std_logic;
	signal keymap_addr_s		: std_logic_vector(9 downto 0);
	signal keymap_data_s		: std_logic_vector(7 downto 0);
	signal keymap_we_s		: std_logic;

	-- SD
	signal sd_cs_n_s			: std_logic;

	-- Joystick
	signal joy_out1_s			: std_logic;

begin

	-- PLL
	pll_1: entity work.pll1
	port map (
		CLK_IN1	=> clock_50_i,
		CLK_OUT1	=> clock_master_s,		-- 21.47727 (21.249) MHz (6x NTSC)
		CLK_OUT2 => clock_vga_s,			-- 25.20000 (25.000) MHz
		CLK_OUT3 => clock_hdmi_s			-- 126.0000 (125.00) MHz
	);

	-- Clocks
	clks: entity work.clocks
	port map (
		clock_i			=> clock_master_s,
		por_i				=> por_clock_s,
		turbo_on_i		=> turbo_on_s,
		clock_vdp_o		=> clock_vdp_s,
		clock_5m_en_o	=> open,
		clock_cpu_o		=> clock_cpu_s,
		clock_psg_en_o	=> clock_psg_en_s,
		clock_3m_o		=> clock_3m_s
	);

	-- The MSX1
	the_msx: entity work.msx
	generic map (
		hw_id_g			=> 6,
		hw_txt_g			=> "ZX-Uno Board",
		hw_version_g	=> X"11",				-- Version 1.1
		video_opt_g		=> 3,						-- No dblscan and external palette (Color in rgb_r_o)
		ramsize_g		=> 512
	)
	port map (
		-- Clocks
		clock_i			=> clock_master_s,
		clock_vdp_i		=> clock_vdp_s,
		clock_cpu_i		=> clock_cpu_s,
		clock_psg_en_i	=> clock_psg_en_s,
		-- Turbo
		turbo_on_k_i	=> extra_keys_s(3),	-- F11
		turbo_on_o		=> turbo_on_s,
		-- Resets
		reset_i			=> reset_s,
		por_i				=> por_s,
		softreset_o		=> soft_reset_s_s,
		-- Options
		opt_nextor_i	=> '1',
		opt_mr_type_i	=> "00",
		opt_vga_on_i	=> '0',
		-- RAM
		ram_addr_o		=> ram_addr_s,
		ram_data_i		=> ram_data_from_s,
		ram_data_o		=> ram_data_to_s,
		ram_ce_o			=> ram_ce_s,
		ram_we_o			=> ram_we_s,
		ram_oe_o			=> ram_oe_s,
		-- ROM
		rom_addr_o		=> rom_addr_s,
		rom_data_i		=> rom_data_s,
		rom_ce_o			=> rom_ce_s,
		rom_oe_o			=> rom_oe_s,
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
		-- VDP RAM
		vram_addr_o		=> vram_addr_s,
		vram_data_i		=> vram_do_s,
		vram_data_o		=> vram_di_s,
		vram_ce_o		=> open,--vram_ce_s,
		vram_oe_o		=> open,--vram_oe_s,
		vram_we_o		=> vram_we_s,
		-- Keyboard
		rows_o			=> rows_s,
		cols_i			=> cols_s,
		caps_en_o		=> caps_en_s,
		keymap_addr_o	=> keymap_addr_s,
		keymap_data_o	=> keymap_data_s,
		keymap_we_o		=> keymap_we_s,
		-- Audio
		audio_scc_o		=> audio_scc_s,
		audio_psg_o		=> audio_psg_s,
		beep_o			=> beep_s,
		-- K7
		k7_motor_o		=> open,
		k7_audio_o		=> open,
		k7_audio_i		=> ear_i,
		-- Joystick
		joy1_up_i		=> joy_up_i,
		joy1_down_i		=> joy_down_i,
		joy1_left_i		=> joy_left_i,
		joy1_right_i	=> joy_right_i,
		joy1_btn1_i		=> joy_fire1_i,
		joy1_btn1_o		=> joy_fire1_i,
		joy1_btn2_i		=> joy_fire2_i,
		joy1_btn2_o		=> joy_fire2_i,
		joy1_out_o		=> joy_out1_s,
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
		cnt_hor_o		=> cnt_hor_s,
		cnt_ver_o		=> cnt_ver_s,
		rgb_r_o			=> rgb_col_s,
		rgb_g_o			=> open,
		rgb_b_o			=> open,
		hsync_n_o		=> rgb_hsync_n_s,
		vsync_n_o		=> rgb_vsync_n_s,
		ntsc_pal_o		=> ntsc_pal_s,
		vga_on_k_i		=> extra_keys_s(2),		-- Print Screen
		vga_en_o			=> vga_en_s,
		scanline_on_k_i=> extra_keys_s(1),		-- Scroll Lock
		scanline_en_o	=> scanlines_en_s,
		-- SPI/SD
		flspi_cs_n_o	=> open,
		spi_cs_n_o		=> sd_cs_n_s,
		spi_sclk_o		=> sd_sclk_o,
		spi_mosi_o		=> sd_mosi_o,
		spi_miso_i		=> sd_miso_i,
		-- DEBUG
		D_wait_o			=> open,
		D_slots_o		=> open,
		D_ipl_en_o		=> open

	);

	sd_cs_n_o	<= sd_cs_n_s;
	joy_fire3_o <= not joy_out1_s;		-- for Sega Genesis joypad

	-- ROM
	rom: entity work.mainrom
	port map (
		clk		=> clock_master_s,
		addr		=> rom_addr_s,
		data		=> rom_data_s
	);
	
	-- Keyboard PS/2
	keyb: entity work.keyboard
	port map (
		clock_i			=> clock_3m_s,
		reset_i			=> reset_s,
		-- MSX
		rows_coded_i	=> rows_s,
		cols_o			=> cols_s,
		keymap_addr_i	=> keymap_addr_s,
		keymap_data_i	=> keymap_data_s,
		keymap_we_i		=> keymap_we_s,
		-- LEDs
		led_caps_i		=> '0',
		-- PS/2 interface
		ps2_clk_io		=> ps2_clk_io,
		ps2_data_io		=> ps2_data_io,
		--
		reset_o			=> soft_reset_k_s,
		por_o				=> soft_por_s,
		reload_core_o	=> reload_core_s,
		extra_keys_o	=> extra_keys_s
	);

	-- Audio
	audio: entity work.Audio_DAC
	port map (
		clock_i			=> clock_master_s,
		reset_i			=> reset_s,
		audio_scc_i		=> audio_scc_s,
		audio_psg_i		=> audio_psg_s,
		beep_i			=> beep_s,
		audio_mix_o		=> audio_s,
		dac_out_o		=> dac_s
	);

	-- VRAM
	vram: entity work.spram
	generic map (
		addr_width_g => 14,
		data_width_g => 8
	)
	port map (
		clk_i		=> clock_master_s,
		we_i		=> vram_we_s,
		addr_i	=> vram_addr_s,
		data_i	=> vram_di_s,
		data_o	=> vram_do_s
	);

	-- Multiboot
	mb: entity work.multiboot
	port map (
		reset_i		=> por_s,
		clock_i		=> clock_vdp_s,
		start_i		=> reload_core_s,
		spi_addr_i	=> X"6B000000"
	);

	-- Glue logic

	-- Power-on counter
	process (clock_master_s)
	begin
		if rising_edge(clock_master_s) then
			if por_cnt_s /= 0 then
				por_cnt_s <= por_cnt_s - 1;
			end if;
		end if;
	end process;

	-- Resets
	por_clock_s	<= '1'	when por_cnt_s /= 0									else '0';
	por_s			<= '1'	when por_cnt_s /= 0 or soft_por_s = '1'		else '0';
	reset_s		<= '1'	when por_s = '1' or soft_rst_cnt_s = X"00"	else '0';

	process(reset_s, clock_master_s)
	begin
		if reset_s = '1' then
			soft_rst_cnt_s	<= X"FF";
		elsif rising_edge(clock_master_s) then
			if (soft_reset_k_s = '1' or soft_reset_s_s = '1') and soft_rst_cnt_s /= X"00" then
				soft_rst_cnt_s <= soft_rst_cnt_s - 1;
			end if;
		end if;
	end process;

	-- Audio
	dac_l_o		<= dac_s;
	dac_r_o		<= dac_s;

	-- RAM
	sram_addr_o			<= ram_addr_s(18 downto 0);
	sram_data_io		<= ram_data_to_s	when ram_we_s = '1'	else (others => 'Z');
	ram_data_from_s	<= sram_data_io;
	sram_we_n_o			<= not ram_we_s;

	-- VGA framebuffer
--	vga: entity work.vga
--	port map (
--		I_CLK			=> clock_master_s,
--		I_CLK_VGA	=> clock_vga_s,
--		I_COLOR		=> rgb_col_s,
--		I_HCNT		=> cnt_hor_s,
--		I_VCNT		=> cnt_ver_s,
--		O_HSYNC		=> vga_hsync_n_s,
--		O_VSYNC		=> vga_vsync_n_s,
--		O_COLOR		=> vga_col_s,
--		O_HCNT		=> open,
--		O_VCNT		=> open,
--		O_H			=> open,
--		O_BLANK		=> vga_blank_s
--	);

	-- Scanlines
	process(vga_hsync_n_s, vga_vsync_n_s)
	begin
		if vga_vsync_n_s = '0' then
			odd_line_s <= '0';
		elsif rising_edge(vga_hsync_n_s) then
			odd_line_s <= not odd_line_s;
		end if;
	end process;

	-- Index => RGB
	process (clock_vdp_s)
		variable rgb_col_v	: integer range 0 to 15;
		variable rgb_rgb_v	: std_logic_vector(15 downto 0);
		variable rgb_r_v		: std_logic_vector( 3 downto 0);
		variable rgb_g_v		: std_logic_vector( 3 downto 0);
		variable rgb_b_v		: std_logic_vector( 3 downto 0);
	begin
		if rising_edge(clock_vdp_s) then
			rgb_col_v := to_integer(unsigned(rgb_col_s));
			rgb_rgb_v := rgb_c(rgb_col_v);
			rgb_r_s <= rgb_rgb_v(15 downto 12);
			rgb_b_s <= rgb_rgb_v(11 downto  8);
			rgb_g_s <= rgb_rgb_v( 3 downto  0);
		end if;
	end process;

--	process (clock_vga_s)
--		variable vga_col_v	: integer range 0 to 15;
--		variable vga_rgb_v	: std_logic_vector(15 downto 0);
--		variable vga_r_v		: std_logic_vector( 3 downto 0);
--		variable vga_g_v		: std_logic_vector( 3 downto 0);
--		variable vga_b_v		: std_logic_vector( 3 downto 0);
--	begin
--		if rising_edge(clock_vga_s) then
--			vga_col_v := to_integer(unsigned(vga_col_s));
--			vga_rgb_v := rgb_c(vga_col_v);
--			if scanlines_en_s = '1' then
--				--
--				if vga_rgb_v(15 downto 12) > 1 and odd_line_s = '1' then
--					vga_r_s <= vga_rgb_v(15 downto 12) - 2;
--				else
--					vga_r_s <= vga_rgb_v(15 downto 12);
--				end if;
--				--
--				if vga_rgb_v(11 downto 8) > 1 and odd_line_s = '1' then
--					vga_b_s <= vga_rgb_v(11 downto 8) - 2;
--				else
--					vga_b_s <= vga_rgb_v(11 downto 8);
--				end if;
--				--
--				if vga_rgb_v(3 downto 0) > 1 and odd_line_s = '1' then
--					vga_g_s <= vga_rgb_v(3 downto 0) - 2;
--				else
--					vga_g_s <= vga_rgb_v(3 downto 0);
--				end if;
--			else
--				vga_r_s <= vga_rgb_v(15 downto 12);
--				vga_b_s <= vga_rgb_v(11 downto  8);
--				vga_g_s <= vga_rgb_v( 3 downto  0);
--			end if;
--		end if;
--	end process;

	-- HDMI
--	sound_hdmi_s <= '0' & audio_s(15 downto 1);

--	hdmi: entity work.hdmi
--	generic map (
--		FREQ	=> 25200000,	-- pixel clock frequency 
--		FS		=> 48000,		-- audio sample rate - should be 32000, 41000 or 48000 = 48KHz
--		CTS	=> 25200,		-- CTS = Freq(pixclk) * N / (128 * Fs)
--		N		=> 6144			-- N = 128 * Fs /1000,  128 * Fs /1500 <= N <= 128 * Fs /300 (Check HDMI spec 7.2 for details)
--	)
--	port map (
--		I_CLK_PIXEL		=> clock_vga_s,
--		I_R				=> vga_r_s & vga_r_s,
--		I_G				=> vga_g_s & vga_g_s,
--		I_B				=> vga_b_s & vga_b_s,
--		I_BLANK			=> vga_blank_s,
--		I_HSYNC			=> vga_hsync_n_s,
--		I_VSYNC			=> vga_vsync_n_s,
--		-- PCM audio
--		I_AUDIO_ENABLE	=> '1',
--		I_AUDIO_PCM_L 	=> sound_hdmi_s,
--		I_AUDIO_PCM_R	=> sound_hdmi_s,
--		-- TMDS parallel pixel synchronous outputs (serialize LSB first)
--		O_RED				=> tdms_r_s,
--		O_GREEN			=> tdms_g_s,
--		O_BLUE			=> tdms_b_s
--	);
--
--	hdmio: entity work.hdmi_out_xilinx
--	port map (
--		clock_pixel_i		=> clock_vga_s,
--		clock_tdms_i		=> clock_hdmi_s,
--		red_i					=> tdms_r_s,
--		green_i				=> tdms_g_s,
--		blue_i				=> tdms_b_s,
--		tmds_out_p			=> hdmi_p_o,
--		tmds_out_n			=> hdmi_n_o
--	);

	-- RGB/VGA Output
	vga_r_o			<= vga_r_s(3 downto 1)	when vga_en_s = '1'	else rgb_r_s(3 downto 1);
	vga_g_o			<= vga_g_s(3 downto 1)	when vga_en_s = '1'	else rgb_g_s(3 downto 1);
	vga_b_o			<= vga_b_s(3 downto 1)	when vga_en_s = '1'	else rgb_b_s(3 downto 1);
	vga_csync_n_o	<= vga_hsync_n_s			when vga_en_s = '1'	else (rgb_hsync_n_s and rgb_vsync_n_s);
	vga_vsync_n_o	<= vga_vsync_n_s			when vga_en_s = '1'	else '1';
--	vga_ntsc_o		<= not ntsc_pal_s;
--	vga_pal_o		<= ntsc_pal_s;
	vga_ntsc_o		<= '1';
	vga_pal_o		<= '0';

	-- DEBUG
	led_o		<= not sd_cs_n_s;
--	led_o <= extra_keys_s(1);

end architecture;