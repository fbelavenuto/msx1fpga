--
-- eseps2.vhd
--   PS/2 keyboard interface for ESE-MSX
--   Revision 1.00
--
-- Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--------------------------------------------------------------------------------
-- Update note by KdL
--------------------------------------------------------------------------------
-- Oct 25 2010 - Updated the led of CMT to make it work with the I/O ports.
-- Jun 04 2010 - Fixed a bug where the shift key is not broken after a pause.
-- Mar 15 2008 - Added the CMT switch.
-- Aug 05 2013 - Typing any key during an hard reset the keyboard could continue
--               that command after the reboot: press again the key to break it.
--------------------------------------------------------------------------------
-- Update note
--------------------------------------------------------------------------------
-- Oct 05 2006 - Removed 101/106 toggle switch.
-- Sep 23 2006 - Fixed a problem where some key events are lost after 101/106
--               keyboard type switching.
-- Sep 22 2006 - Added external default keyboard layout input.
-- May 21 2005 - Modified to support Quartus2we5.
-- Jan 24 2004 - Fixed a locking key problem if 101/106 keyboard type is
--               switched during pressing keys.
--             - Fixed a problem where a comma key is pressed after a
--               pause key.
-- Jan 23 2004 - Added a 101 keyboard table.
-- Sep 16 2016 - Refactored by Fabio Belavenuto
--------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity eseps2 is
	port (
		clock_i			: in    std_logic;
		clock_en_i		: in    std_logic;
		reset_i			: in    std_logic;
		-- LEDs
		caps_i			: in    std_logic;
		scroll_i			: in    std_logic;
		numlock_i		: in    std_logic;
		--
		rows_coded_i	: in    std_logic_vector(3 downto 0);
		cols_o			: out   std_logic_vector(7 downto 0);
		-- Shift, Pause/Break, PrintScr, Scroll Lock, F11, F12
		extra_keys_o	: out   std_logic_vector(5 downto 0);
		ps2_clk_io		: inout std_logic;
		ps2_data_io		: inout std_logic
	);
end entity;

architecture RTL of eseps2 is

	signal key_we_s		: std_logic;
	signal key_row_s		: std_logic_vector(3 downto 0);
	signal key_col_in_s	: std_logic_vector(7 downto 0);
	signal key_col_out_s	: std_logic_vector(7 downto 0);
	signal mtx_idx_s		: std_logic_vector(9 downto 0);
	signal mtx_ptr_s		: std_logic_vector(7 downto 0);

begin

	--
	matrix: entity work.spram
	generic map (
		addr_width_g => 4,
		data_width_g => 8
	)
	port map (
		clk_i		=> clock_i,
		we_i		=> key_we_s,
		addr_i	=> key_row_s,
		data_i	=> key_col_in_s,
		data_o	=> key_col_out_s
	);

	--
	keymap: entity work.keymap
	port map (
		clock_i	=> clock_i,
		addr_i	=> mtx_idx_s,
		data_o	=> mtx_ptr_s
	);

	--
	ps2_clk_io <= 'Z';

	--
	process(clock_i, reset_i)

		type typps2_seq_v_t is (Ps2Idle, Ps2Rxd, Ps2Txd, Ps2Stop);
		variable ps2_seq_v		: typps2_seq_v_t;
		variable ps2_chg_v		: std_logic;
		variable ps2_brk_v		: std_logic;
		variable ps2_xE0_v		: std_logic;
		variable ps2_xE1_v		: std_logic;
		variable ps2_cnt_v		: std_logic_vector(3 downto 0);
		variable ps2_clk_v		: std_logic_vector(2 downto 0);
		variable ps2_dat_v		: std_logic_vector(7 downto 0);
		variable ps2_led_v		: std_logic_vector(8 downto 0);
		variable ps2_skp_v		: std_logic_vector(2 downto 0);
		variable timeout_v		: std_logic_vector(15 downto 0);
		variable ps2_caps_v		: std_logic;
		variable ps2_numlck_v	: std_logic;
		variable ps2_scro_v		: std_logic;
		variable ps2_shift_v		: std_logic;								-- real shift status
		variable ps2_vshi_v		: std_logic;								-- virtual shift status
		variable ext_keys_v		: std_logic_vector(5 downto 0);
		variable key_id_v			: std_logic_vector(8 downto 0);

		type typmtx_seq_v_t is (MtxIdle, MtxSettle, MtxClean, MtxRead, MtxWrite, MtxEnd, MtxReset);
		variable mtx_seq_v		: typmtx_seq_v_t;
		variable mtx_tmp_v		: std_logic_vector(3 downto 0);

	begin
		if reset_i = '1' then
			ps2_seq_v		:= Ps2Idle;
			ps2_chg_v		:= '0';
			ps2_brk_v		:= '0';
			ps2_xE0_v		:= '0';
			ps2_xE1_v		:= '0';
			ps2_cnt_v		:= (others => '0');
			ps2_clk_v		:= (others => '1');
			ps2_dat_v		:= (others => '1');
			timeout_v		:= (others => '1');
			ps2_led_v		:= (others => '1');
			ps2_vshi_v		:= '0';
			ps2_skp_v		:= "000";
			ps2_caps_v		:= '1';
			ps2_numlck_v	:= '1';
			ext_keys_v		:= (others => '0');       -- Sync to vFkeys
			mtx_seq_v		:= MtxIdle;
			ps2_data_io		<= 'Z';
			cols_o			<= (others => '1');
			key_we_s			<= '0';
			key_row_s		<= (others => '0');
			key_col_in_s	<= (others => '0');
		elsif rising_edge(clock_i) then
			if clock_en_i = '1' then

				-- "Scan table > MSX key-matrix" conversion
				case mtx_seq_v is

					when MtxIdle =>
						if ps2_chg_v = '1' then
							mtx_seq_v	:= MtxSettle;
							key_id_v		:= ps2_xE0_v & ps2_dat_v;
							mtx_idx_s	<= ps2_shift_v & key_id_v;
							cols_o		<= (others => '1');
						else
							cols_o(7 downto 1) <= not key_col_out_s(7 downto 1);
							if rows_coded_i = X"6" then
								cols_o(0) <= not ps2_vshi_v;
							else
								cols_o(0) <= not key_col_out_s(0);
							end if;
							key_row_s	<= rows_coded_i;
						end if;

					when MtxSettle =>
						mtx_seq_v		:= MtxClean;
						key_we_s			<= '0';
						key_row_s		<= mtx_ptr_s(3 downto 0);							-- 3-0 = ROW

					when MtxClean =>
						mtx_seq_v		:= MtxRead;
						key_we_s			<= '1';
						key_col_in_s	<= key_col_out_s;
						key_col_in_s(conv_integer(mtx_ptr_s(6 downto 4))) <= '0';	-- 6-4 = COL
						mtx_idx_s		<= ps2_shift_v & key_id_v;

					when MtxRead =>
						mtx_seq_v		:= MtxWrite;
						key_we_s			<= '0';
						key_row_s		<= mtx_ptr_s(3 downto 0);							-- 3-0 = ROW
						if ps2_brk_v = '0' then
							ps2_vshi_v	:= mtx_ptr_s(7);
						else
							ps2_vshi_v	:= ps2_shift_v;
						end if;

					when MtxWrite  =>
						mtx_seq_v		:= MtxEnd;
						key_we_s			<= '1';
						key_col_in_s	<= key_col_out_s;
						key_col_in_s(conv_integer(mtx_ptr_s(6 downto 4))) <= not ps2_brk_v;

					when MtxEnd  =>
						mtx_seq_v	:= MtxIdle;
						key_we_s		<= '0';
						key_row_s	<= rows_coded_i;
						ps2_chg_v	:= '0';
						ps2_brk_v	:= '0';
						ps2_xE0_v	:= '0';
						ps2_xE1_v	:= '0';

--					when MtxReset =>
--						if mtx_tmp_v = "1011" then
--							mtx_seq_v := MtxIdle;
--							key_we_s <= '0';
--							key_row_s <= rows_coded_i;
--						end if;
--						key_we_s   <= '1';
--						key_row_s  <= mtx_tmp_v;
--						key_col_in_s <= (others => '0');
--						mtx_tmp_v := mtx_tmp_v + '1';

					when others =>
						mtx_seq_v	:= MtxIdle;

				end case;
			end if;		-- clock_en_i = '1'

			-- "PS/2 interface > Scan table" conversion
			if clock_en_i = '1' then

				if ps2_clk_v = "100" then						-- clk inactive
					ps2_clk_v(2)	:= '0';
					timeout_v		:= X"01FF";					-- countdown timeout (143us = 279ns x 512clk, exceed 100us)

					if ps2_seq_v = Ps2Idle then
						ps2_data_io		<= 'Z';
						ps2_seq_v		:= Ps2Rxd;
						ps2_cnt_v		:= (others => '0');

					elsif ps2_seq_v = Ps2Txd then
						if ps2_cnt_v = "1000" then
							ps2_caps_v		:= caps_i;
							ps2_numlck_v	:= numlock_i;
							ps2_scro_v		:= scroll_i;
							ps2_seq_v		:= Ps2Idle;
						end if;
						ps2_data_io		<= ps2_led_v(0);
						ps2_led_v		:= ps2_led_v(0) & ps2_led_v(8 downto 1);
						ps2_dat_v		:= '1' & ps2_dat_v(7 downto 1);
						ps2_cnt_v		:= ps2_cnt_v + 1;

					elsif ps2_seq_v = Ps2Rxd then
						if ps2_cnt_v = "0111" then
							ps2_seq_v := Ps2Stop;
						end if;
						ps2_dat_v := ps2_data_io & ps2_dat_v(7 downto 1);
						ps2_cnt_v := ps2_cnt_v + 1;

					elsif ps2_seq_v = Ps2Stop then
						ps2_seq_v := Ps2Idle;
						if ps2_dat_v = X"AA" then									-- BAT code (basic assurance test)
							ps2_caps_v		:= not caps_i;							-- force sending command 0xED?
							ps2_numlck_v	:= not numlock_i;
							ps2_scro_v		:= not scroll_i;
						elsif ps2_skp_v /= "000" then								-- Skip some sequences
							ps2_skp_v := ps2_skp_v - 1;
						elsif ps2_dat_v = X"14" and ps2_xE0_v = '0' and ps2_xE1_v = '1' then		-- pause/break make
							if ps2_brk_v = '0' then
								ext_keys_v(4) := not ext_keys_v(4);
								ps2_skp_v := "110";									-- Skip the next 6 sequences
								ps2_dat_v := X"12";									-- shift + pause bug fixed
								ps2_xE0_v := '0';
								ps2_xE1_v := '0';
							end if;
						elsif ps2_dat_v = X"7C" and ps2_xE0_v = '1' and ps2_xE1_v = '0' then		-- printscreen make
							if ps2_brk_v = '0' then
								ext_keys_v(3) := not ext_keys_v(3);
							end if;
							ps2_chg_v := '1';
						elsif ps2_dat_v = X"7E" and ps2_xE0_v = '0' and ps2_xE1_v = '0' then		-- scroll-lock make
							if ps2_brk_v = '0' then
								ext_keys_v(2) := not ext_keys_v(2);
							end if;
							ps2_chg_v := '1';
						elsif ps2_dat_v = X"78" and ps2_xE0_v = '0' and ps2_xE1_v = '0' then		-- F11 make
							if ps2_brk_v = '0' then
								ext_keys_v(1) := not ext_keys_v(1);
							end if;
							ps2_chg_v := '1';
						elsif ps2_dat_v = X"07" and ps2_xE0_v = '0' and ps2_xE1_v = '0' then		-- F12 make
							if ps2_brk_v = '0' then
								ext_keys_v(0) := not ext_keys_v(0);
							end if;
							ps2_chg_v := '1';
						elsif (ps2_dat_v = X"12" or ps2_dat_v = X"59") and ps2_xE0_v = '0' and ps2_xE1_v ='0' then	-- shift make
							ps2_shift_v		:= not ps2_brk_v;
							ext_keys_v(5)	:= ps2_shift_v;
							ps2_chg_v		:= '1';
						elsif ps2_dat_v = X"F0" then -- break code
							ps2_brk_v		:= '1';
						elsif ps2_dat_v = X"E0" then -- extnd code E0
							ps2_xE0_v		:= '1';
						elsif ps2_dat_v = X"E1" then -- extnd code E1 (ignore)
							ps2_xE1_v		:= '1';
						elsif ps2_dat_v = X"FA" then -- Ack of "EDh" command
							ps2_seq_v		:= Ps2Idle;
						else
							ps2_chg_v		:= '1';
						end if;
					end if;

				elsif ps2_clk_v = "011" then									-- clk active
					ps2_clk_v(2)	:= '1';
					timeout_v		:= X"01FF";									-- countdown timeout (143us = 279ns x 512clk, exceed 100us)
				elsif timeout_v = X"0000" then								-- timeout

					ps2_data_io	<= 'Z';
					ps2_seq_v	:= Ps2Idle;										-- to Idle state

					if ps2_seq_v = Ps2Idle and ps2_clk_v(2) = '1' then

						if ps2_dat_v = X"FA" and ps2_led_v = "111101101" then
							ps2_seq_v := Ps2Txd;         -- Tx data state
							ps2_data_io <= '0';

							ps2_led_v := (caps_i xor numlock_i xor scroll_i xor '1') & "00000" & caps_i & numlock_i & scroll_i;
							timeout_v := X"FFFF";        -- countdown timeout (18.3ms = 279ns x 65536clk, exceed 1ms)

						elsif caps_i /= ps2_caps_v or numlock_i /= ps2_numlck_v or scroll_i /= ps2_scro_v then
							ps2_seq_v := Ps2Txd;         -- Tx data state
							ps2_data_io <= '0';
							ps2_led_v := "111101101";    -- Command EDh
							timeout_v := X"FFFF";        -- countdown timeout (18.3ms = 279ns x 65536clk, exceed 1ms)
						end if;
					end if;

				else
					timeout_v := timeout_v - 1;         -- countdown timeout
				end if;

				ps2_clk_v(1) := ps2_clk_v(0);
				ps2_clk_v(0) := ps2_clk_io;

			end if;		-- clock_en_i = '1'

		end if;		-- rising_edge(clock_i)

		extra_keys_o <= ext_keys_v;

	end process;


end RTL;
