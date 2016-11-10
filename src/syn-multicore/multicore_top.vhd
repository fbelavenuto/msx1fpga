--
-- MSX1FPGA Project
-- Copyright (c) 2016 - Fabio Belavenuto
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
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
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
-- You are responsible for any legal issues arising from your use of this code.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multicore_top is
	port (
		-- Clocks
		clock_50_i			: in    std_logic;

		-- Buttons
		btn_n_i				: in    std_logic_vector(4 downto 1);
		btn_oe_n_i			: in    std_logic;
		btn_clr_n_i			: in    std_logic;

		-- SRAM (AS7C34096)
		sram_addr_o			: out   std_logic_vector(18 downto 0)	:= (others => '0');
		sram_data_io		: inout std_logic_vector(7 downto 0)	:= (others => 'Z');
		sram_we_n_o			: out   std_logic								:= '1';
		sram_ce_n_o			: out   std_logic_vector(1 downto 0)	:= (others => '1');
		sram_oe_n_o			: out   std_logic								:= '1';

		-- PS2
		ps2_clk_io			: inout std_logic								:= 'Z';
		ps2_data_io			: inout std_logic								:= 'Z';
		ps2_mouse_clk_io  : inout std_logic								:= 'Z';
		ps2_mouse_data_io : inout std_logic								:= 'Z';

		-- SD Card
		sd_cs_n_o			: out   std_logic								:= '1';
		sd_sclk_o			: out   std_logic								:= '0';
		sd_mosi_o			: out   std_logic								:= '0';
		sd_miso_i			: in    std_logic;

		-- Joystick
		joy1_up_i			: in    std_logic;
		joy1_down_i			: in    std_logic;
		joy1_left_i			: in    std_logic;
		joy1_right_i		: in    std_logic;
		joy1_p6_io			: inout std_logic;
		joy1_p7_o			: out   std_logic								:= '1';
		joy1_p9_io			: inout std_logic;
		joy2_up_i			: in    std_logic;
		joy2_down_i			: in    std_logic;
		joy2_left_i			: in    std_logic;
		joy2_right_i		: in    std_logic;
		joy2_p6_io			: inout std_logic;
		joy2_p7_o			: out   std_logic								:= '1';
		joy2_p9_io			: inout std_logic;

		-- Audio
		dac_l_o				: out   std_logic								:= '0';
		dac_r_o				: out   std_logic								:= '0';
		ear_i					: in    std_logic;
		mic_o					: out   std_logic								:= '0';

		-- VGA
		vga_r_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_g_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_b_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
		vga_hsync_n_o		: out   std_logic								:= '1';
		vga_vsync_n_o		: out   std_logic								:= '1';

		-- HDMI
--		hdmi_d_o				: out   std_logic_vector(2 downto 0)	:= (others => '0');
--		hdmi_clk_o			: out   std_logic								:= '0';
--		hdmi_cec_o			: out   std_logic								:= '0';

		-- Debug
		leds_n_o				: out   std_logic_vector(7 downto 0)	:= (others => '0')
	);
end entity;

architecture behavior of multicore_top is

	-- Resets
	signal pll_locked_s		: std_logic;
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

	-- RAM
	signal ram_addr_s			: std_logic_vector(18 downto 0);		-- 512K
	signal ram_data_from_s	: std_logic_vector(7 downto 0);
	signal ram_data_to_s		: std_logic_vector(7 downto 0);
	signal ram_ce_s			: std_logic;
	signal ram_oe_s			: std_logic;
	signal ram_we_s			: std_logic;

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
	signal beep_s				: std_logic;
	signal dac_s				: std_logic;

	-- Video
	signal rgb_r_s				: std_logic_vector( 3 downto 0);
	signal rgb_g_s				: std_logic_vector( 3 downto 0);
	signal rgb_b_s				: std_logic_vector( 3 downto 0);
	signal rgb_hsync_n_s		: std_logic;
	signal rgb_vsync_n_s		: std_logic;
	signal extra_keys_s		: std_logic_vector(3 downto 0);

	-- Keyboard
	signal rows_s				: std_logic_vector(3 downto 0);
	signal cols_s				: std_logic_vector(7 downto 0);
	signal caps_en_s			: std_logic;

	-- Joystick
	signal joy1_out_s			: std_logic;
	signal joy2_out_s			: std_logic;

begin

	-- PLL
	pll_1: entity work.pll1
	port map (
		inclk0	=> clock_50_i,
		c0			=> clock_master_s,			-- 21.512 MHz (6x NTSC)
		locked	=> pll_locked_s
	);

	-- Clocks
	clks: entity work.clocks
	port map (
		clock_i			=> clock_master_s,
		por_i				=> por_s,
		turbo_on_i		=> turbo_on_s,
		clock_vdp_o		=> clock_vdp_s,
		clock_cpu_o		=> clock_cpu_s,
		clock_psg_en_o	=> clock_psg_en_s,
		clock_3m_o		=> clock_3m_s
	);

	-- The MSX1
	the_msx: entity work.msx
	generic map (
		hw_id_g			=> 6,
		hw_txt_g			=> "Multicore Board",
		hw_version_g	=> X"10"				-- Version 1.0
	)
	port map (
		-- Clocks
		clock_i			=> clock_master_s,
		clock_vdp_i		=> clock_vdp_s,
		clock_cpu_i		=> clock_cpu_s,
		clock_psg_en_i	=> clock_psg_en_s,
		-- Turbo
		turbo_on_k_i	=> extra_keys_s(3),	-- F12
		turbo_on_o		=> turbo_on_s,
		-- Resets
		reset_i			=> reset_s,
		por_i				=> por_s,
		softreset_o		=> soft_reset_s_s,
		-- Options
		opt_nextor_i	=> '1',
		opt_mr_type_i	=> "00",
		-- RAM
		ram_addr_o		=> ram_addr_s,
		ram_data_i		=> ram_data_from_s,
		ram_data_o		=> ram_data_to_s,
		ram_ce_o			=> ram_ce_s,
		ram_we_o			=> ram_we_s,
		ram_oe_o			=> ram_oe_s,
		-- ROM
		rom_addr_o		=> open,--rom_addr_s,
		rom_data_i		=> ram_data_from_s,
		rom_ce_o			=> open,--rom_ce_s,
		rom_oe_o			=> open,--rom_oe_s,
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
		-- Audio
		audio_scc_o		=> audio_scc_s,
		audio_psg_o		=> audio_psg_s,
		beep_o			=> beep_s,
		-- K7
		k7_motor_o		=> open,
		k7_audio_o		=> open,
		k7_audio_i		=> ear_i,
		-- Joystick
		joy1_up_i		=> joy1_up_i,
		joy1_down_i		=> joy1_down_i,
		joy1_left_i		=> joy1_left_i,
		joy1_right_i	=> joy1_right_i,
		joy1_btn1_io	=> joy1_p6_io,
		joy1_btn2_io	=> joy1_p9_io,
		joy1_out_o		=> joy1_out_s,
		joy2_up_i		=> joy2_up_i,
		joy2_down_i		=> joy2_down_i,
		joy2_left_i		=> joy2_left_i,
		joy2_right_i	=> joy2_right_i,
		joy2_btn1_io	=> joy2_p6_io,
		joy2_btn2_io	=> joy2_p9_io,
		joy2_out_o		=> joy2_out_s,
		-- Video
		col_o				=> open,
		rgb_r_o			=> rgb_r_s,
		rgb_g_o			=> rgb_g_s,
		rgb_b_o			=> rgb_b_s,
		hsync_n_o		=> rgb_hsync_n_s,
		vsync_n_o		=> rgb_vsync_n_s,
		csync_n_o		=> open,
		-- SPI/SD
		spi_cs_n_o		=> sd_cs_n_o,
		spi_sclk_o		=> sd_sclk_o,
		spi_mosi_o		=> sd_mosi_o,
		spi_miso_i		=> sd_miso_i,
		-- DEBUG
		D_slots_o		=> open
	);

	joy1_p7_o <= not joy1_out_s;		-- for Sega Genesis joypad
	joy2_p7_o <= not joy2_out_s;		-- for Sega Genesis joypad

	-- Keyboard PS/2
	keyb: entity work.keyboard
	port map (
		clock_i			=> clock_3m_s,
		reset_i			=> reset_s,
		-- MSX
		rows_coded_i	=> rows_s,
		cols_o			=> cols_s,
		-- LEDs
		led_caps_i		=> '0',
		-- PS/2 interface
		ps2_clk_io		=> ps2_clk_io,
		ps2_data_io		=> ps2_data_io,
		--
		reset_o			=> soft_reset_k_s,
		por_o				=> soft_por_s,
		reload_core_o	=> open,
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

	-- Glue logic

	-- Resets
	por_s			<= '1'	when pll_locked_s = '0' or soft_por_s = '1' or btn_n_i(1) = '0'		else '0';
	reset_s		<= '1'	when por_s = '1' or soft_rst_cnt_s = X"00"  or btn_n_i(4) = '0'		else '0';

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
	sram_addr_o			<= ram_addr_s;
	sram_data_io		<= ram_data_to_s	when ram_we_s = '1'	else (others => 'Z');
	ram_data_from_s	<= sram_data_io;
	sram_we_n_o			<= not ram_we_s;
	sram_oe_n_o			<= not ram_oe_s;
	sram_ce_n_o(0)		<= not ram_ce_s;

	-- VGA Output
	vga_r_o			<= rgb_r_s(3 downto 1);
	vga_g_o			<= rgb_g_s(3 downto 1);
	vga_b_o			<= rgb_b_s(3 downto 1);
	vga_hsync_n_o	<= rgb_hsync_n_s;
	vga_vsync_n_o	<= rgb_vsync_n_s;

	-- DEBUG
	leds_n_o(0)		<= turbo_on_s;
	leds_n_o(1)		<= caps_en_s;

end architecture;