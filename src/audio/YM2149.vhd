--
-- A simulation model of YM2149 (AY-3-8910 with bells on)

-- Copyright (c) MikeJ - Jan 2005
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
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email support@fpgaarcade.com
--
-- Revision list
--
-- version 001 initial release
--
-- Clues from MAME sound driver and Kazuhiro TSUJIKAWA
--
-- These are the measured outputs from a real chip for a single Isolated channel into a 1K load (V)
-- vol 15 .. 0
-- 3.27 2.995 2.741 2.588 2.452 2.372 2.301 2.258 2.220 2.198 2.178 2.166 2.155 2.148 2.141 2.132
-- As the envelope volume is 5 bit, I have fitted a curve to the not quite log shape in order
-- to produced all the required values.
-- (The first part of the curve is a bit steeper and the last bit is more linear than expected)
--
-- by FBLabs: renamed signals and fixed port_a and port_b directions

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity YM2149 is
	port (
		clock_i				: in  std_logic;
		clock_en_i			: in  std_logic;
		reset_i				: in  std_logic;
		sel_n_i				: in  std_logic;								-- 1 = AY-3-8912 compatibility
		ayymmode_i			: in  std_logic;								-- 0 = YM, 1 = AY
		-- data bus
		data_i				: in  std_logic_vector(7 downto 0);
		data_o				: out std_logic_vector(7 downto 0);
		-- control
		a9_l_i				: in  std_logic;
		a8_i					: in  std_logic;
		bdir_i				: in  std_logic;
		bc1_i					: in  std_logic;
		bc2_i					: in  std_logic;
		-- I/O ports
		port_a_i				: in  std_logic_vector(7 downto 0);
		port_b_o				: out std_logic_vector(7 downto 0);
		-- audio channels out
		audio_ch_a_o		: out std_logic_vector(7 downto 0);
		audio_ch_b_o		: out std_logic_vector(7 downto 0);
		audio_ch_c_o		: out std_logic_vector(7 downto 0);
		audio_ch_mix_o		: out unsigned(7 downto 0)		-- mixed audio
	);
end;

architecture RTL of YM2149 is

	-- signals
	type  array_16x8_t is array (0 to 15) of std_logic_vector(7 downto 0);
	type  array_3x12_t is array (1 to 3) of std_logic_vector(11 downto 0);
	
	signal cnt_div				: unsigned(3 downto 0) := (others => '0');
	signal noise_div			: std_logic := '0';
	signal ena_div				: std_logic;
	signal ena_div_noise		: std_logic;
	signal poly17				: std_logic_vector(16 downto 0) := (others => '0');
	
	-- registers
	signal busctrl_addr_s	: std_logic;
	signal busctrl_we_s		: std_logic;
	signal busctrl_re_s		: std_logic;

	signal reg_addr_q			: std_logic_vector(7 downto 0);
	signal regs_q				: array_16x8_t	:= (7 => (others => '1'), others => (others => '0'));
	signal env_reset			: std_logic;

	signal noise_gen_cnt		: unsigned(4 downto 0)		:= (others => '0');
	signal noise_gen_op		: std_logic;
	signal tone_gen_cnt		: array_3x12_t := (others	=> (others => '0'));
	signal tone_gen_op		: std_logic_vector(3 downto 1) := "000";
	
	signal env_gen_cnt		: std_logic_vector(15 downto 0)	:= (others => '0');
	signal env_ena				: std_logic;
	signal env_hold			: std_logic;
	signal env_inc				: std_logic;
	signal env_vol				: std_logic_vector(4 downto 0);
	
	signal A						: std_logic_vector(4 downto 0);
	signal B						: std_logic_vector(4 downto 0);
	signal C						: std_logic_vector(4 downto 0);
--	signal vol_table_in         : std_logic_vector(11 downto 0);
--	signal vol_table_out        : std_logic_vector(9 downto 0);

	type volTableType32 is array (0 to 31) of unsigned(7 downto 0);
	type volTableType16 is array (0 to 15) of unsigned(7 downto 0);

	constant volTableAy : volTableType16 :=(
		x"00", x"03", x"04", x"06",
		x"0a", x"0f", x"15", x"22", 
		x"28", x"41", x"5b", x"72", 
		x"90", x"b5", x"d7", x"ff" 
	);

	constant volTableYm : volTableType32 :=(
		x"00", x"01", x"01", x"02", x"02", x"03", x"03", x"04",
		x"06", x"07", x"09", x"0a", x"0c", x"0e", x"11", x"13",
		x"17", x"1b", x"20", x"25", x"2c", x"35", x"3e", x"47",
		x"54", x"66", x"77", x"88", x"a1", x"c0", x"e0", x"ff"
	);    

begin

	-- BDIR BC2 BC1 MODE
	--   0   0   0  inactive
	--   0   0   1  address
	--   0   1   0  inactive
	--   0   1   1  read
	--   1   0   0  address
	--   1   0   1  inactive
	--   1   1   0  write
	--   1   1   1  read
	-- CPU Bus
	process (bdir_i, bc1_i, bc2_i, a8_i, a9_l_i, reg_addr_q)
		variable cs_v	: std_logic;
		variable sel_v	: std_logic_vector(2 downto 0);
	begin
		busctrl_addr_s	<= '0';
		busctrl_re_s	<= '0';
		busctrl_we_s	<= '0';

		cs_v		:= '0';
		if a9_l_i = '0' and a8_i = '1' and reg_addr_q(7 downto 4) = "0000" then
			cs_v := '1';
		end if;

		sel_v := bdir_i & bc2_i & bc1_i;
		case sel_v is
			when "000"	=> null;
			when "001"	=> busctrl_addr_s <= '1';
			when "010"	=> null;							-- 00
			when "011"	=> busctrl_re_s	<= cs_v;	-- 01
			when "100"	=> busctrl_addr_s <= '1';
			when "101"	=> null;
			when "110"	=> busctrl_we_s	<= cs_v;	-- 10
			when "111"	=> busctrl_addr_s <= '1';	-- 11
			when others => null;
		end case;
	end process;

	-- latch addr
	process(reset_i, busctrl_addr_s)
	begin
		if reset_i = '1' then
			reg_addr_q <= (others => '0');
		elsif falling_edge(busctrl_addr_s) then
			reg_addr_q <= data_i;
		end if;
	end process;

	-- latch register
	process(reset_i, busctrl_we_s, reg_addr_q)
	begin
		if reset_i = '1' then
			regs_q <= (7 => (others => '1'), others => (others => '0'));
		elsif falling_edge(busctrl_we_s) then
			case reg_addr_q(3 downto 0) is
				when x"0" => regs_q(0)  <= data_i;
				when x"1" => regs_q(1)  <= data_i;
				when x"2" => regs_q(2)  <= data_i;
				when x"3" => regs_q(3)  <= data_i;
				when x"4" => regs_q(4)  <= data_i;
				when x"5" => regs_q(5)  <= data_i;
				when x"6" => regs_q(6)  <= data_i;
				when x"7" => regs_q(7)  <= data_i;
				when x"8" => regs_q(8)  <= data_i;
				when x"9" => regs_q(9)  <= data_i;
				when x"A" => regs_q(10) <= data_i;
				when x"B" => regs_q(11) <= data_i;
				when x"C" => regs_q(12) <= data_i;
				when x"D" => regs_q(13) <= data_i;
				when x"E" => regs_q(14) <= data_i;
				when x"F" => regs_q(15) <= data_i;
				when others => null;
			end case;
		end if;
		env_reset <= '0';
		if busctrl_we_s = '1' and reg_addr_q(3 downto 0) = x"D" then
			env_reset <= '1';
		end if;
	end process;

	-- read register
	process(busctrl_re_s, reg_addr_q, regs_q, port_a_i)
	begin
		data_o <= (others => '0');
		if busctrl_re_s = '1' then
			case reg_addr_q(3 downto 0) is
				when x"0" => data_o <= regs_q(0);
				when x"1" => data_o <= "0000" & regs_q(1)(3 downto 0);
				when x"2" => data_o <= regs_q(2);
				when x"3" => data_o <= "0000" & regs_q(3)(3 downto 0);
				when x"4" => data_o <= regs_q(4);
				when x"5" => data_o <= "0000" & regs_q(5)(3 downto 0);
				when x"6" => data_o <= "000"  & regs_q(6)(4 downto 0);
				when x"7" => data_o <= regs_q(7);
				when x"8" => data_o <= "000"  & regs_q(8)(4 downto 0);
				when x"9" => data_o <= "000"  & regs_q(9)(4 downto 0);
				when x"A" => data_o <= "000"  & regs_q(10)(4 downto 0);
				when x"B" => data_o <= regs_q(11);
				when x"C" => data_o <= regs_q(12);
				when x"D" => data_o <= "0000" & regs_q(13)(3 downto 0);
				when x"E" =>
						data_o <= port_a_i;
				when x"F" =>
						data_o <= regs_q(15);
				when others => null;
			end case;
		end if;
	end process;

	port_b_o <= regs_q(15);

	--  p_divider              : process
	process(clock_i, clock_en_i)
	begin
		if rising_edge(clock_i) and clock_en_i = '1' then
			ena_div			<= '0';
			ena_div_noise	<= '0';
			if cnt_div = "0000" then
				cnt_div <= (not sel_n_i) & "111";
				ena_div <= '1';

				noise_div <= not noise_div;
				if noise_div = '1' then
					ena_div_noise <= '1';
				end if;
			else
				cnt_div <= cnt_div - "1";
			end if;
		end if;
	end process;  

	--  p_noise_gen            : process
	process(clock_i)
		variable noise_gen_comp : unsigned(4 downto 0)	:= (others => '0');
		variable poly17_zero : std_logic;
	begin
		if rising_edge(clock_i) then
  
			if regs_q(6)(4 downto 0) = "00000" then
				noise_gen_comp := "00000";
			else
				noise_gen_comp := unsigned( regs_q(6)(4 downto 0) ) - 1;
			end if;

			poly17_zero := '0';
			if poly17 = "00000000000000000" then
				poly17_zero := '1'; 
			end if;

			if clock_en_i = '1' then
				if ena_div_noise = '1' then -- divider ena
					if noise_gen_cnt >= noise_gen_comp then
						noise_gen_cnt <= "00000";
						poly17 <= (poly17(0) xor poly17(2) xor poly17_zero) & poly17(16 downto 1);
					else
						noise_gen_cnt <= noise_gen_cnt + 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	noise_gen_op <= poly17(0);

	--p_tone_gens            : process
	process(clock_i)
		variable tone_gen_freq : array_3x12_t	:= (others => (others => '0'));
		variable tone_gen_comp : array_3x12_t	:= (others => (others => '0'));
	begin
		if rising_edge(clock_i) then
			-- looks like real chips count up - we need to get the Exact behaviour ..
			tone_gen_freq(1) := regs_q(1)(3 downto 0) & regs_q(0);
			tone_gen_freq(2) := regs_q(3)(3 downto 0) & regs_q(2);
			tone_gen_freq(3) := regs_q(5)(3 downto 0) & regs_q(4);
		
			-- period 0 = period 1
			for i in 1 to 3 loop
				if (tone_gen_freq(i) = x"000") then
					tone_gen_comp(i) := x"000";
				else
					tone_gen_comp(i) := std_logic_vector( unsigned(tone_gen_freq(i)) - 1 );
				end if;
			end loop;

			if clock_en_i = '1' then
				for i in 1 to 3 loop
					if ena_div = '1' then -- divider ena

						if tone_gen_cnt(i) >= tone_gen_comp(i) then
							tone_gen_cnt(i) <= x"000";
							tone_gen_op(i) <= not tone_gen_op(i);
						else
							tone_gen_cnt(i) <= std_logic_vector( unsigned(tone_gen_cnt(i)) + 1 );
						end if;
					end if;
				end loop;
			end if;
		end if;
	end process;

	--p_envelope_freq        : process
	process(clock_i)
		variable env_gen_freq : std_logic_vector(15 downto 0)	:= (others => '0');
		variable env_gen_comp : std_logic_vector(15 downto 0)	:= (others => '0');
	begin
		if rising_edge(clock_i) then
	
			env_gen_freq := regs_q(12) & regs_q(11);
			-- envelope freqs 1 and 0 are the same.
			if (env_gen_freq = x"0000") then
				env_gen_comp := x"0000";
			else
				env_gen_comp := std_logic_vector( unsigned(env_gen_freq) - 1 );
			end if;

			if clock_en_i = '1' then
				env_ena <= '0';
				if ena_div = '1' then -- divider ena
					if env_gen_cnt >= env_gen_comp then
						env_gen_cnt <= x"0000";
						env_ena <= '1';
					else
						env_gen_cnt <= std_logic_vector( unsigned( env_gen_cnt ) + 1 );
					end if;
				end if;
			end if;
		end if;
	end process;

	--p_envelope_shape       : process(env_reset, CLK)
	process(clock_i)
		variable is_bot    : boolean;
		variable is_bot_p1 : boolean;
		variable is_top_m1 : boolean;
		variable is_top    : boolean;
	begin
        -- envelope shapes
        -- C AtAlH
        -- 0 0 x x  \___
        --
        -- 0 1 x x  /___
        --
        -- 1 0 0 0  \\\\
        --
        -- 1 0 0 1  \___
        --
        -- 1 0 1 0  \/\/
        --           ___
        -- 1 0 1 1  \
        --
        -- 1 1 0 0  ////
        --           ___
        -- 1 1 0 1  /
        --
        -- 1 1 1 0  /\/\
        --
        -- 1 1 1 1  /___
		if rising_edge(clock_i) then
			if env_reset = '1' then
				-- load initial state
				if (regs_q(13)(2) = '0') then -- attack
					env_vol <= "11111";
					env_inc <= '0'; -- -1
				else
					env_vol <= "00000";
					env_inc <= '1'; -- +1
				end if;
				env_hold <= '0';
			else
				is_bot    := (env_vol = "00000");
				is_bot_p1 := (env_vol = "00001");
				is_top_m1 := (env_vol = "11110");
				is_top    := (env_vol = "11111");

				if clock_en_i = '1' then
					if env_ena = '1' then
						if env_hold = '0' then
							if env_inc = '1' then
								env_vol <= std_logic_vector( unsigned( env_vol ) + "00001");
							else
								env_vol <= std_logic_vector( unsigned( env_vol ) + "11111");
							end if;
						end if;

						-- envelope shape control.
						if (regs_q(13)(3) = '0') then
							if (env_inc = '0') then -- down
								if is_bot_p1 then
									env_hold <= '1'; 
								end if;
							else
								if is_top then
									env_hold <= '1';
								end if;
							end if;
						else
							if (regs_q(13)(0) = '1') then -- hold = 1
								if (env_inc = '0') then -- down
									if (regs_q(13)(1) = '1') then -- alt
										if is_bot then
											env_hold <= '1';
										end if;
									else
										if is_bot_p1 then
											env_hold <= '1';
										end if;
									end if;
								else
									if (regs_q(13)(1) = '1') then -- alt
										if is_top then
											env_hold <= '1';
										end if;
									else
										if is_top_m1 then
											env_hold <= '1'; 
										end if;
									end if;
								end if;

							elsif (regs_q(13)(1) = '1') then -- alternate
								if (env_inc = '0') then -- down
									if is_bot_p1 then 
										env_hold <= '1';
									end if;
									if is_bot then
										env_hold <= '0';
										env_inc <= '1';
									end if;
								else
									if is_top_m1 then
										env_hold <= '1';
									end if;
									if is_top then
										env_hold <= '0';
										env_inc <= '0';
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	--p_chan_mixer_table     : process
	process(clock_i)
		variable chan_mixed : std_logic_vector(2 downto 0);
	begin
		if rising_edge(clock_i) then
			if clock_en_i = '1' then
				chan_mixed(0) := (regs_q(7)(0) or tone_gen_op(1)) and (regs_q(7)(3) or noise_gen_op);
				chan_mixed(1) := (regs_q(7)(1) or tone_gen_op(2)) and (regs_q(7)(4) or noise_gen_op);
				chan_mixed(2) := (regs_q(7)(2) or tone_gen_op(3)) and (regs_q(7)(5) or noise_gen_op);

				A <= "00000";
				B <= "00000";
				C <= "00000";

				if (chan_mixed(0) = '1') then
					if (regs_q(8)(4) = '0') then
						A <= regs_q(8)(3 downto 0) & "1";
					else
						A <= env_vol(4 downto 0);
					end if;
				end if;

				if (chan_mixed(1) = '1') then
					if (regs_q(9)(4) = '0') then
						B <= regs_q(9)(3 downto 0) & "1";
					else
						B <= env_vol(4 downto 0);
					end if;
				end if;

				if (chan_mixed(2) = '1') then
					if (regs_q(10)(4) = '0') then
						C <= regs_q(10)(3 downto 0) & "1";
					else
						C <= env_vol(4 downto 0);
					end if;
				end if;
			end if;
		end if;    
	end process;

	process(clock_i)
		variable out_audio_mixed : unsigned(9 downto 0);
	begin
		if rising_edge(clock_i) then
			if reset_i = '1' then
				audio_ch_mix_o	<= x"00";
				audio_ch_a_o	<= x"00";
				audio_ch_b_o	<= x"00";
				audio_ch_c_o	<= x"00";
			else
				if ayymmode_i = '0' then
					out_audio_mixed :=	("00" & volTableYm( to_integer( unsigned( A )))) + 
												("00" & volTableYm( to_integer( unsigned( B )))) + 
												("00" & volTableYm( to_integer( unsigned( C ))));
					audio_ch_mix_o	<= out_audio_mixed(9 downto 2);
					audio_ch_a_o	<= std_logic_vector( volTableYm( to_integer( unsigned( A ) ) ) );
					audio_ch_b_o	<= std_logic_vector( volTableYm( to_integer( unsigned( B ) ) ) );
					audio_ch_c_o	<= std_logic_vector( volTableYm( to_integer( unsigned( C ) ) ) );
				else
					out_audio_mixed :=	( "00" & volTableAy( to_integer( unsigned( A(4 downto 1) )))) + 
												( "00" & volTableAy( to_integer( unsigned( B(4 downto 1) )))) + 
												( "00" & volTableAy( to_integer( unsigned( C(4 downto 1) ))));
					audio_ch_mix_o	<= out_audio_mixed(9 downto 2);
					audio_ch_a_o	<= std_logic_vector( volTableAy( to_integer( unsigned( A(4 downto 1) ) ) ) );
					audio_ch_b_o	<= std_logic_vector( volTableAy( to_integer( unsigned( B(4 downto 1) ) ) ) );
					audio_ch_c_o	<= std_logic_vector( volTableAy( to_integer( unsigned( C(4 downto 1) ) ) ) );
				end if;
			end if;
		end if;
	end process;

end architecture RTL;
