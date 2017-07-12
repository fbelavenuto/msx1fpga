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
-- Terasic DE2 top-level
--

-- altera message_off 10540 10541

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Generic top-level entity for Altera DE2 board
entity de2_top is
	port (
		-- Clocks
		CLOCK_27       : in    std_logic;
		CLOCK_50       : in    std_logic;
		EXT_CLOCK      : in    std_logic;

		-- Switches
		SW             : in    std_logic_vector(17 downto 0);
		-- Buttons
		KEY            : in    std_logic_vector(3 downto 0);

		-- 7 segment displays
		HEX0           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX1           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX2           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX3           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX4           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX5           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX6           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		HEX7           : out   std_logic_vector(6 downto 0)		:= (others => '1');
		
		-- Red LEDs
		LEDR           : out   std_logic_vector(17 downto 0)		:= (others => '0');
		-- Green LEDs
		LEDG           : out   std_logic_vector(8 downto 0)		:= (others => '0');

		-- Serial
		UART_RXD       : in    std_logic;
		UART_TXD       : out   std_logic									:= '1';

		-- IRDA
		IRDA_RXD       : in    std_logic;
		IRDA_TXD       : out   std_logic									:= '0';

		-- SDRAM
		DRAM_ADDR      : out   std_logic_vector(11 downto 0)		:= (others => '0');
		DRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => 'Z');
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

		-- SRAM
		SRAM_ADDR      : out   std_logic_vector(17 downto 0)		:= (others => '0');
		SRAM_DQ        : inout std_logic_vector(15 downto 0)		:= (others => 'Z');
		SRAM_CE_N      : out   std_logic									:= '1';
		SRAM_OE_N      : out   std_logic									:= '1';
		SRAM_WE_N      : out   std_logic									:= '1';
		SRAM_UB_N      : out   std_logic									:= '1';
		SRAM_LB_N      : out   std_logic									:= '1';

		--	ISP1362 Interface	
		OTG_ADDR       : out   std_logic_vector(1 downto 0)		:= (others => '0');	--	ISP1362 Address 2 Bits
		OTG_DATA       : inout std_logic_vector(15 downto 0)		:= (others => 'Z');	--	ISP1362 Data bus 16 Bits
		OTG_CS_N       : out   std_logic									:= '1';					--	ISP1362 Chip Select
		OTG_RD_N       : out   std_logic									:= '1';					--	ISP1362 Write
		OTG_WR_N       : out   std_logic									:= '1';					--	ISP1362 Read
		OTG_RST_N      : out   std_logic									:= '1';					--	ISP1362 Reset
		OTG_FSPEED     : out   std_logic									:= 'Z';					--	USB Full Speed,	0 = Enable, Z = Disable
		OTG_LSPEED     : out   std_logic									:= 'Z';					--	USB Low Speed, 	0 = Enable, Z = Disable
		OTG_INT0       : in    std_logic;															--	ISP1362 Interrupt 0
		OTG_INT1       : in    std_logic;															--	ISP1362 Interrupt 1
		OTG_DREQ0      : in    std_logic;															--	ISP1362 DMA Request 0
		OTG_DREQ1      : in    std_logic;															--	ISP1362 DMA Request 1
		OTG_DACK0_N    : out   std_logic									:= '1';					--	ISP1362 DMA Acknowledge 0
		OTG_DACK1_N    : out   std_logic									:= '1';					--	ISP1362 DMA Acknowledge 1
		
		--	LCD Module 16X2		
		LCD_ON         : out   std_logic									:= '0';					--	LCD Power ON/OFF, 0 = Off, 1 = On
		LCD_BLON       : out   std_logic									:= '0';					--	LCD Back Light ON/OFF, 0 = Off, 1 = On
		LCD_DATA       : inout std_logic_vector(7 downto 0)		:= (others => '0');	--	LCD Data bus 8 bits
		LCD_RW         : out   std_logic									:= '1';					--	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN         : out   std_logic									:= '1';					--	LCD Enable
		LCD_RS         : out   std_logic									:= '1';					--	LCD Command/Data Select, 0 = Command, 1 = Data
		
		--	SD_Card Interface	
		SD_DAT         : inout std_logic									:= 'Z';					--	SD Card Data (SPI MISO)
		SD_DAT3        : inout std_logic									:= 'Z';					--	SD Card Data 3 (SPI /CS)
		SD_CMD         : inout std_logic									:= 'Z';					--	SD Card Command Signal (SPI MOSI)
		SD_CLK         : out   std_logic									:= '1';					--	SD Card Clock (SPI SCLK)
		
		-- I2C
		I2C_SCLK       : inout std_logic									:= 'Z';
		I2C_SDAT       : inout std_logic									:= 'Z';

		-- PS/2 Keyboard
		PS2_CLK        : inout std_logic									:= 'Z';
		PS2_DAT        : inout std_logic									:= 'Z';

		-- VGA
		VGA_R          : out   std_logic_vector(9 downto 0)		:= (others => '0');
		VGA_G          : out   std_logic_vector(9 downto 0)		:= (others => '0');
		VGA_B          : out   std_logic_vector(9 downto 0)		:= (others => '0');
		VGA_HS         : out   std_logic									:= '0';
		VGA_VS         : out   std_logic									:= '0';
		VGA_BLANK		: out   std_logic									:= '1';				
		VGA_SYNC			: out   std_logic									:= '0';	
		VGA_CLK		   : out   std_logic									:= '0';	
		
		-- Ethernet Interface	
		ENET_CLK       : out   std_logic									:= '0';					--	DM9000A Clock 25 MHz
		ENET_DATA      : inout std_logic_vector(15 downto 0)		:= (others => 'Z');	--	DM9000A DATA bus 16Bits
		ENET_CMD       : out   std_logic									:= '0';					--	DM9000A Command/Data Select, 0 = Command, 1 = Data
		ENET_CS_N      : out   std_logic									:= '1';					--	DM9000A Chip Select
		ENET_WR_N      : out   std_logic									:= '1';					--	DM9000A Write
		ENET_RD_N      : out   std_logic									:= '1';					--	DM9000A Read
		ENET_RST_N     : out   std_logic									:= '1';					--	DM9000A Reset
		ENET_INT       : in    std_logic;															--	DM9000A Interrupt
	               
		-- Audio
		AUD_XCK        : out   std_logic									:= '0';
		AUD_BCLK       : out   std_logic									:= '0';
		AUD_ADCLRCK    : out   std_logic									:= '0';
		AUD_ADCDAT     : in    std_logic;
		AUD_DACLRCK    : out   std_logic									:= '0';
		AUD_DACDAT     : out   std_logic									:= '0';

		-- TV Decoder		
		TD_DATA        : in    std_logic_vector(7 downto 0);									--	TV Decoder Data bus 8 bits
		TD_HS          : in    std_logic;															--	TV Decoder H_SYNC
		TD_VS          : in    std_logic;															--	TV Decoder V_SYNC
		TD_RESET       : out   std_logic									:= '1';					--	TV Decoder Reset
	
		-- GPIO
		GPIO_0         : inout std_logic_vector(35 downto 0)		:= (others => 'Z');
		GPIO_1         : inout std_logic_vector(35 downto 0)		:= (others => 'Z')
	);
end entity;

architecture behavior of de2_top is

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
	signal clock_sdram_s		: std_logic;
	signal clock_audio_s		: std_logic;
	signal clock_vdp_s		: std_logic;
	signal clock_cpu_s		: std_logic;
	signal clock_psg_en_s	: std_logic;
	signal clock_3m_s			: std_logic;
	signal turbo_on_s			: std_logic;

	-- RAM
	signal ram_addr_s			: std_logic_vector(22 downto 0);		-- 8MB
	signal ram_data_from_s	: std_logic_vector( 7 downto 0);
	signal ram_data_to_s		: std_logic_vector( 7 downto 0);
	signal ram_ce_s			: std_logic;
	signal ram_oe_s			: std_logic;
	signal ram_we_s			: std_logic;

	-- VRAM memory
	signal vram_addr_s		: std_logic_vector(13 downto 0);		-- 16K
	signal vram_data_from_s	: std_logic_vector( 7 downto 0);
	signal vram_data_to_s	: std_logic_vector( 7 downto 0);
	signal vram_ce_s			: std_logic;
	signal vram_oe_s			: std_logic;
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
	signal ntsc_pal_s			: std_logic;
	signal vga_en_s			: std_logic;

	-- Keyboard
	signal rows_s				: std_logic_vector( 3 downto 0);
	signal cols_s				: std_logic_vector( 7 downto 0);
	signal caps_en_s			: std_logic;
	signal extra_keys_s		: std_logic_vector( 3 downto 0);
	signal keymap_addr_s		: std_logic_vector( 9 downto 0);
	signal keymap_data_s		: std_logic_vector( 7 downto 0);
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

	-- Alias SD
	alias SD_nCS  is SD_DAT3;
	alias SD_MISO is SD_DAT;
	alias SD_MOSI is SD_CMD;
	alias SD_SCLK is SD_CLK;

	-- Bus
	signal bus_addr_s			: std_logic_vector(15 downto 0);
	signal bus_data_from_s	: std_logic_vector( 7 downto 0);
	signal bus_data_to_s		: std_logic_vector( 7 downto 0);
	signal bus_rd_n_s			: std_logic;
	signal bus_wr_n_s			: std_logic;
	signal bus_m1_n_s			: std_logic;
	signal bus_iorq_n_s		: std_logic;
	signal bus_mreq_n_s		: std_logic;
	signal bus_sltsl1_n_s	: std_logic;
	signal bus_sltsl2_n_s	: std_logic;

	-- JT51
	signal jt51_cs_n_s		: std_logic;
	signal jt51_left_s		: signed(15 downto 0)		:= (others => '0');
	signal jt51_right_s		: signed(15 downto 0)		:= (others => '0');

	-- Debug
	signal D_display_s		: std_logic_vector(15 downto 0);

begin

	-- PLL
	pll_1: entity work.pll1
	port map (
		inclk0	=> CLOCK_50,
		c0			=> clock_master_s,		-- 21.428571 MHz (6x NTSC)
		c1			=> clock_sdram_s,			-- 85.714286
		c2			=> DRAM_CLK,				-- 85.714286 90°
		locked	=> pll_locked_s
	);

	pll_2: entity work.pll2
	port map (
		inclk0		=> CLOCK_27,
		c0				=> clock_audio_s		-- 24.000000 MHz
	);

	-- Clocks
	clks: entity work.clocks
	port map (
		clock_i			=> clock_master_s,
		por_i				=> not pll_locked_s,
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
		hw_id_g			=> 2,
		hw_txt_g			=> "DE-2 Board",
		hw_version_g	=> X"11",				-- Version 1.1
		video_opt_g		=> 1,						-- dblscan configurable
		ramsize_g		=> 8192
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
		opt_mr_type_i	=> SW(2 downto 1),
		opt_vga_on_i	=> '1',
		-- RAM
		ram_addr_o		=> ram_addr_s,
		ram_data_i		=> ram_data_from_s,
		ram_data_o		=> ram_data_to_s,
		ram_ce_o			=> ram_ce_s,
		ram_we_o			=> ram_we_s,
		ram_oe_o			=> ram_oe_s,
		-- ROM
		rom_addr_o		=> open,
		rom_data_i		=> ram_data_from_s,
		rom_ce_o			=> open,
		rom_oe_o			=> open,
		-- External bus
		bus_addr_o		=> bus_addr_s,
		bus_data_i		=> bus_data_from_s,
		bus_data_o		=> bus_data_to_s,
		bus_rd_n_o		=> bus_rd_n_s,
		bus_wr_n_o		=> bus_wr_n_s,
		bus_m1_n_o		=> bus_m1_n_s,
		bus_iorq_n_o	=> bus_iorq_n_s,
		bus_mreq_n_o	=> bus_mreq_n_s,
		bus_sltsl1_n_o	=> bus_sltsl1_n_s,
		bus_sltsl2_n_o	=> bus_sltsl2_n_s,
		bus_wait_n_i	=> '1',
		bus_nmi_n_i		=> '1',
		bus_int_n_i		=> '1',
		-- VDP RAM
		vram_addr_o		=> vram_addr_s,
		vram_data_i		=> vram_data_from_s,
		vram_data_o		=> vram_data_to_s,
		vram_ce_o		=> vram_ce_s,
		vram_oe_o		=> vram_oe_s,
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
		joy1_btn1_i		=> J0_BTN,
		joy1_btn1_o		=> J0_BTN,
		joy1_btn2_i		=> J0_BTN2,
		joy1_btn2_o		=> J0_BTN2,
		joy1_out_o		=> open,
		joy2_up_i		=> J1_UP,
		joy2_down_i		=> J1_DOWN,
		joy2_left_i		=> J1_LEFT,
		joy2_right_i	=> J1_RIGHT,
		joy2_btn1_i		=> J1_BTN,
		joy2_btn1_o		=> J1_BTN,
		joy2_btn2_i		=> J1_BTN2,
		joy2_btn2_o		=> J1_BTN2,
		joy2_out_o		=> open,
		-- Video
		rgb_r_o			=> rgb_r_s,
		rgb_g_o			=> rgb_g_s,
		rgb_b_o			=> rgb_b_s,
		hsync_n_o		=> rgb_hsync_n_s,
		vsync_n_o		=> rgb_vsync_n_s,
		ntsc_pal_o		=> ntsc_pal_s,
		vga_on_k_i		=> extra_keys_s(2),		-- Print Screen
		scanline_on_k_i=> extra_keys_s(1),		-- Scroll Lock
		vga_en_o			=> vga_en_s,
		-- SPI/SD
		flspi_cs_n_o	=> open,
		spi_cs_n_o		=> SD_nCS,
		spi_sclk_o		=> SD_SCLK,
		spi_mosi_o		=> SD_MOSI,
		spi_miso_i		=> SD_MISO,
		-- DEBUG
		D_wait_o			=> open,
		D_slots_o		=> open,
		D_ipl_en_o		=> open
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
		clock_i			=> clock_audio_s,
		reset_i			=> reset_s,
		audio_scc_i		=> audio_scc_s,
		audio_psg_i		=> audio_psg_s,
		jt51_left_i		=> jt51_left_s,
		jt51_right_i	=> jt51_right_s,
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
		data_i	=> vram_data_to_s,
		data_o	=> vram_data_from_s
	);
--	SRAM_ADDR	<= "0000" & vram_addr_s;
--	SRAM_DQ		<= "ZZZZZZZZ" & vram_data_to_s	when vram_we_s = '1' else
--						(others => 'Z');
--	vram_data_from_s	<= SRAM_DQ( 7 downto 0);
--	SRAM_UB_N			<= '1';
--	SRAM_LB_N			<= '0';
--	SRAM_CE_N			<= not vram_ce_s;
--	SRAM_OE_N			<= not vram_oe_s;
--	SRAM_WE_N			<= not vram_we_s;

	-- RAM
	ram: entity work.ssdram
	generic map (
		freq_g		=> 86
	)
	port map (
		clock_i		=> clock_sdram_s,
		reset_i		=> reset_s,
		refresh_i	=> '1',
		-- Static RAM bus
		addr_i		=> ram_addr_s,
		data_i		=> ram_data_to_s,
		data_o		=> ram_data_from_s,
		cs_i			=> ram_ce_s,
		oe_i			=> ram_oe_s,
		we_i			=> ram_we_s,
		-- SD-RAM ports
		mem_cke_o	=> DRAM_CKE,
		mem_cs_n_o	=> DRAM_CS_N,
		mem_ras_n_o	=> DRAM_RAS_N,
		mem_cas_n_o	=> DRAM_CAS_N,
		mem_we_n_o	=> DRAM_WE_N,
		mem_udq_o	=> DRAM_UDQM,
		mem_ldq_o	=> DRAM_LDQM,
		mem_ba_o(0)	=> DRAM_BA_0,
		mem_ba_o(1)	=> DRAM_BA_1,
		mem_addr_o	=> DRAM_ADDR,
		mem_data_io	=> DRAM_DQ
	);

	-- Glue logic

	-- Resets
	por_s			<= '1'	when pll_locked_s = '0' or soft_por_s = '1' or KEY(3) = '0'	else '0';
	reset_s		<= '1'	when soft_rst_cnt_s = X"00" or por_s = '1'  or KEY(0) = '0'	else '0';

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

	-- VGA Output
	VGA_R			<= rgb_r_s & "000000";
	VGA_G			<= rgb_g_s & "000000";
	VGA_B			<= rgb_b_s & "000000";
	VGA_HS		<= rgb_hsync_n_s;
	VGA_VS		<= rgb_vsync_n_s;
	VGA_BLANK	<= '1';
	VGA_CLK		<= clock_master_s;

	-- JT51 tests
	jt51_cs_n_s <= '0' when bus_addr_s(7 downto 1) = "0010000" and bus_iorq_n_s = '0' and bus_m1_n_s = '1'	else '1';	-- 0x20 - 0x21

	jt51: entity work.jt51_wrapper
	port map (
		clock_i			=> clock_3m_s,
		reset_i			=> reset_s,
		addr_i			=> bus_addr_s(0),
		cs_n_i			=> jt51_cs_n_s,
		wr_n_i			=> bus_wr_n_s,
		data_i			=> bus_data_to_s,
		data_o			=> bus_data_from_s,
		ct1_o				=> open,
		ct2_o				=> open,
		irq_n_o			=> open,
		p1_o				=> open,
		-- Low resolution output (same as real chip)
		sample_o			=> open,
		left_o			=> open,
		right_o			=> open,
		-- Full resolution output
		xleft_o			=> jt51_left_s,
		xright_o			=> jt51_right_s,
		-- unsigned outputs for sigma delta converters, full resolution		
		dacleft_o		=> open,
		dacright_o		=> open
	);

	-- DEBUG
	D_display_s	<= bus_addr_s;

	LEDG(0) <= turbo_on_s;
	LEDG(1) <= vga_en_s;
	LEDG(2) <= ntsc_pal_s;
	LEDG(7) <= not jt51_cs_n_s;
--	LEDG(8) <= reset_s;

	LEDR(15 downto 0) <= std_logic_vector(jt51_left_s);

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