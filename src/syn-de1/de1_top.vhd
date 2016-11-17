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
--
-- Terasic DE1 top-level
--

-- altera message_off 10540 10541

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Generic top-level entity for Altera DE1 board
entity de1_top is
	port (
		-- Clocks
		CLOCK_24       : in    std_logic_vector(1 downto 0);
		CLOCK_27       : in    std_logic_vector(1 downto 0);
		CLOCK_50       : in    std_logic;
		EXT_CLOCK      : in    std_logic;

		-- Switches
		SW             : in    std_logic_vector(9 downto 0);
		-- Buttons
		KEY            : in    std_logic_vector(3 downto 0);

		-- 7 segment displays
		HEX0           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX1           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX2           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX3           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		-- Red LEDs
		LEDR           : out   std_logic_vector(9 downto 0)		:= (others => '0');
		-- Green LEDs
		LEDG           : out   std_logic_vector(7 downto 0)		:= (others => '0');

		-- VGA
		VGA_R          : out   std_logic_vector(3 downto 0)		:= (others => '0');
		VGA_G          : out   std_logic_vector(3 downto 0)		:= (others => '0');
		VGA_B          : out   std_logic_vector(3 downto 0)		:= (others => '0');
		VGA_HS         : out   std_logic									:= '0';
		VGA_VS         : out   std_logic									:= '0';

		-- Serial
		UART_RXD       : in    std_logic;
		UART_TXD       : out   std_logic									:= '0';

		-- PS/2 Keyboard
		PS2_CLK        : inout std_logic									:= '1';
		PS2_DAT        : inout std_logic									:= '1';

		-- I2C
		I2C_SCLK       : inout std_logic									:= '1';
		I2C_SDAT       : inout std_logic									:= '1';

		-- Audio
		AUD_XCK        : out   std_logic									:= '0';
		AUD_BCLK       : out   std_logic									:= '0';
		AUD_ADCLRCK    : out   std_logic									:= '0';
		AUD_ADCDAT     : in    std_logic;
		AUD_DACLRCK    : out   std_logic									:= '0';
		AUD_DACDAT     : out   std_logic									:= '0';

		-- SRAM
		SRAM_ADDR      : out   std_logic_vector(17 downto 0)		:= (others => '0');
		SRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => '0');
		SRAM_CE_N      : out   std_logic									:= '1';
		SRAM_OE_N      : out   std_logic									:= '1';
		SRAM_WE_N      : out   std_logic									:= '1';
		SRAM_UB_N      : out   std_logic									:= '1';
		SRAM_LB_N      : out   std_logic									:= '1';

		-- SDRAM
		DRAM_ADDR      : out   std_logic_vector(11 downto 0)		:= (others => '0');
		DRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => '0');
		DRAM_BA_0      : out   std_logic									:= '1';
		DRAM_BA_1      : out   std_logic									:= '1';
		DRAM_CAS_N     : out   std_logic									:= '1';
		DRAM_CKE       : out   std_logic									:= '1';
		DRAM_CLK       : out   std_logic									:= '1';
		DRAM_CS_N      : out   std_logic									:= '1';
		DRAM_LDQM      : out   std_logic									:= '1';
		DRAM_RAS_N     : out   std_logic									:= '1';
		DRAM_UDQM      : out   std_logic									:= '1';
		DRAM_WE_N      : out   std_logic									:= '1';

		-- Flash
		FL_ADDR        : out   std_logic_vector(21 downto 0)		:= (others => '0');
		FL_DQ          : inout std_logic_vector(7 downto 0)		:= (others => 'Z');
		FL_RST_N       : out   std_logic									:= '1';
		FL_OE_N        : out   std_logic									:= '1';
		FL_WE_N        : out   std_logic									:= '1';
		FL_CE_N        : out   std_logic									:= '1';

		-- SD card (SPI mode)
		SD_nCS         : out   std_logic									:= '1';
		SD_MOSI        : out   std_logic									:= '1';
		SD_SCLK        : out   std_logic									:= '1';
		SD_MISO        : in    std_logic;

		-- GPIO
		GPIO_0         : inout std_logic_vector(35 downto 0)		:= (others => 'Z');
		GPIO_1         : inout std_logic_vector(35 downto 0)		:= (others => 'Z')
	);
end entity;

architecture behavior of de1_top is

	-- Resets
	signal pll_locked_s		: std_logic;
	signal por_s				: std_logic;
	signal reset_s				: std_logic;
	signal soft_por_s			: std_logic;
	signal soft_reset_k_s	: std_logic;
	signal soft_reset_s_s	: std_logic;
	signal soft_rst_cnt_s	: unsigned(7 downto 0)	:= X"FF";

	-- Clocks
	signal clock_master_s	: std_logic;
	signal clock_vdp_s		: std_logic;
	signal clock_5m_en_s		: std_logic;
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
	signal beep_s				: std_logic;
	signal k7_ai_s				: std_logic;

	-- Video
	signal rgb_r_s				: std_logic_vector( 3 downto 0);
	signal rgb_g_s				: std_logic_vector( 3 downto 0);
	signal rgb_b_s				: std_logic_vector( 3 downto 0);
	signal rgb_hsync_n_s		: std_logic;
	signal rgb_vsync_n_s		: std_logic;
	signal vga_en_s			: std_logic;
--	signal vga_r_s				: std_logic_vector( 3 downto 0)	:= "0000";
--	signal vga_g_s				: std_logic_vector( 3 downto 0)	:= "0000";
--	signal vga_b_s				: std_logic_vector( 3 downto 0)	:= "0000";
--	signal vga_hsync_n_s		: std_logic;
--	signal vga_vsync_n_s		: std_logic;

	-- Keyboard
	signal rows_s				: std_logic_vector(3 downto 0);
	signal cols_s				: std_logic_vector(7 downto 0);
	signal caps_en_s			: std_logic;
	signal extra_keys_s		: std_logic_vector(3 downto 0);
	signal keymap_addr_s		: std_logic_vector(9 downto 0);
	signal keymap_data_s		: std_logic_vector(7 downto 0);
	signal keymap_we_s		: std_logic;

	-- Joystick (Minimig Standard)
	alias J0_UP					: std_logic						is GPIO_1(34);	-- Pin 1
	alias J0_DOWN				: std_logic						is GPIO_1(32);	-- Pin 2
	alias J0_LEFT				: std_logic						is GPIO_1(30);	-- Pin 3
	alias J0_RIGHT				: std_logic						is GPIO_1(28);	-- Pin 4
	alias J0_MMB				: std_logic						is GPIO_1(26);	-- Pin 5
	alias J0_BTN				: std_logic						is GPIO_1(35);	-- Pin 6
	alias J0_BTN2				: std_logic						is GPIO_1(29);	-- Pin 9
	alias J1_UP					: std_logic						is GPIO_1(24);
	alias J1_DOWN				: std_logic						is GPIO_1(22);
	alias J1_LEFT				: std_logic						is GPIO_1(20);
	alias J1_RIGHT				: std_logic						is GPIO_1(23);
	alias J1_MMB				: std_logic						is GPIO_1(27);
	alias J1_BTN				: std_logic						is GPIO_1(25);
	alias J1_BTN2				: std_logic						is GPIO_1(21);

	-- Debug
	signal D_display_s		: std_logic_vector(15 downto 0);
	signal D_cpu_addr_s		: std_logic_vector(15 downto 0);

begin

	-- PLL
	pll_1: entity work.pll1
	port map (
		inclk0	=> CLOCK_50,
		c0			=> clock_master_s,		-- 21.428571 MHz (6x NTSC)
		locked	=> pll_locked_s
	);

	-- Clocks
	clks: entity work.clocks
	port map (
		clock_i			=> clock_master_s,
		por_i				=> por_s,
		turbo_on_i		=> turbo_on_s,
		clock_vdp_o		=> clock_vdp_s,
		clock_5m_en_o	=> clock_5m_en_s,
		clock_cpu_o		=> clock_cpu_s,
		clock_psg_en_o	=> clock_psg_en_s,
		clock_3m_o		=> clock_3m_s
	);

	-- The MSX1
	the_msx: entity work.msx
	generic map (
		hw_id_g			=> 1,
		hw_txt_g			=> "DE-1 Board",
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
		opt_nextor_i	=> SW(0),
		opt_mr_type_i	=> SW(2 downto 1),
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
		bus_addr_o		=> D_cpu_addr_s,
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
		k7_audio_i		=> k7_ai_s,
		-- Joystick
		joy1_up_i		=> J0_UP,
		joy1_down_i		=> J0_DOWN,
		joy1_left_i		=> J0_LEFT,
		joy1_right_i	=> J0_RIGHT,
		joy1_btn1_io	=> J0_BTN,
		joy1_btn2_io	=> J0_BTN2,
		joy1_out_o		=> open,
		joy2_up_i		=> J1_UP,
		joy2_down_i		=> J1_DOWN,
		joy2_left_i		=> J1_LEFT,
		joy2_right_i	=> J1_RIGHT,
		joy2_btn1_io	=> J1_BTN,
		joy2_btn2_io	=> J1_BTN2,
		joy2_out_o		=> open,
		-- Video
		col_o				=> open,
		rgb_r_o			=> rgb_r_s,
		rgb_g_o			=> rgb_g_s,
		rgb_b_o			=> rgb_b_s,
		hsync_n_o		=> rgb_hsync_n_s,
		vsync_n_o		=> rgb_vsync_n_s,
		csync_n_o		=> open,
		vga_on_k_i		=> extra_keys_s(2),
		vga_en_o			=> vga_en_s,
		-- SPI/SD
		spi_cs_n_o		=> SD_nCS,
		spi_sclk_o		=> SD_SCLK,
		spi_mosi_o		=> SD_MOSI,
		spi_miso_i		=> SD_MISO,
		-- DEBUG
		D_wait_o			=> GPIO_0(0),
		D_slots_o		=> open
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
		led_caps_i		=> caps_en_s,
		-- PS/2 interface
		ps2_clk_io		=> PS2_CLK,
		ps2_data_io		=> PS2_DAT,
		--
		reset_o			=> soft_reset_k_s,
		por_o				=> soft_por_s,
		reload_core_o	=> open,
		extra_keys_o	=> extra_keys_s
	);

	-- Audio
	audio: entity work.Audio_WM8731
	port map (
		clock_i			=> CLOCK_24(0),
		reset_i			=> reset_s,
		audio_scc_i		=> audio_scc_s,
		audio_psg_i		=> audio_psg_s,
		beep_i			=> beep_s,
		k7_audio_o		=> k7_ai_s,

		i2s_xck_o		=> AUD_XCK,
		i2s_bclk_o		=> AUD_BCLK,
		i2s_adclrck_o	=> AUD_ADCLRCK,
		i2s_adcdat_i	=> AUD_ADCDAT,
		i2s_daclrck_o	=> AUD_DACLRCK,
		i2s_dacdat_o	=> AUD_DACDAT,

		i2c_sda_io		=> I2C_SDAT,
		i2c_scl_io		=> I2C_SCLK
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
	por_s			<= '1'	when KEY(3) = '0' or pll_locked_s = '0' or soft_por_s = '1'	else '0';
	reset_s		<= '1'	when KEY(0) = '0' or soft_rst_cnt_s = X"00" or por_s = '1'	else '0';

	process(clock_master_s)
	begin
		if rising_edge(clock_master_s) then
			if reset_s = '1' or por_s = '1' then
				soft_rst_cnt_s	<= X"FF";
			elsif (soft_reset_k_s = '1' or soft_reset_s_s = '1') and soft_rst_cnt_s /= X"00" then
				soft_rst_cnt_s <= soft_rst_cnt_s - 1;
			end if;
		end if;
	end process;

	-- RAM
	SRAM_ADDR	<= ram_addr_s(18 downto 1);
	SRAM_DQ		<= "ZZZZZZZZ" & ram_data_to_s	when ram_we_s = '1' and ram_addr_s(0) = '0' 	else
						ram_data_to_s & "ZZZZZZZZ"	when ram_we_s = '1' and ram_addr_s(0) = '1' 	else
						(others => 'Z');
	ram_data_from_s	<= SRAM_DQ( 7 downto 0)	when ram_oe_s = '1' and ram_addr_s(0) = '0' 	else
								SRAM_DQ(15 downto 8)	when ram_oe_s = '1' and ram_addr_s(0) = '1' 	else
								(others => '1');
	SRAM_UB_N			<= not ram_addr_s(0);
	SRAM_LB_N			<= ram_addr_s(0);
	SRAM_CE_N			<= not ram_ce_s;
	SRAM_OE_N			<= not ram_oe_s;
	SRAM_WE_N			<= not ram_we_s;

	-- ROM
	FL_ADDR				<= "0000000" & rom_addr_s;
	FL_DQ					<= (others => 'Z');
	rom_data_s			<= FL_DQ;
	FL_CE_N				<= not rom_ce_s;
	FL_OE_N				<= not rom_oe_s;
	FL_RST_N				<= '1';
	FL_WE_N				<= '1';
	
	-- VGA Output
--	VGA_R		<= rgb_r_s			when vga_en_s = '0'	else vga_r_s;
--	VGA_G		<= rgb_g_s			when vga_en_s = '0'	else vga_g_s;
--	VGA_B		<= rgb_b_s			when vga_en_s = '0'	else vga_b_s;
--	VGA_HS	<= rgb_hsync_n_s	when vga_en_s = '0'	else vga_hsync_n_s;
--	VGA_VS	<= rgb_vsync_n_s	when vga_en_s = '0'	else vga_vsync_n_s;
	VGA_R		<= rgb_r_s;
	VGA_G		<= rgb_g_s;
	VGA_B		<= rgb_b_s;
	VGA_HS	<= rgb_hsync_n_s;
	VGA_VS	<= rgb_vsync_n_s;

	-- DEBUG
	D_display_s	<= D_cpu_addr_s;

	LEDG(0) <= turbo_on_s;
	LEDG(1) <= vga_en_s;

	ld3: entity work.seg7
	port map(
		D		=> D_display_s(15 downto 12),
		Q		=> HEX3
	);

	ld2: entity work.seg7
	port map(
		D		=> D_display_s(11 downto 8),
		Q		=> HEX2
	);

	ld1: entity work.seg7
	port map(
		D		=> D_display_s(7 downto 4),
		Q		=> HEX1
	);

	ld0: entity work.seg7
	port map(
		D		=> D_display_s(3 downto 0),
		Q		=> HEX0
	);

end architecture;