--
-- MSX1 FPGA project
--
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Audio_DACs is
	port (
		clock_i			: in  std_logic;
		reset_i			: in  std_logic;
		audio_scc_i		: in  signed(14 downto 0);
		audio_psg_i		: in  unsigned(7 downto 0);
		jt51_left_i		: in  signed(15 downto 0);
		jt51_right_i	: in  signed(15 downto 0);
		beep_i			: in  std_logic;
		audio_mix_l_o	: out std_logic_vector(15 downto 0);
		audio_mix_r_o	: out std_logic_vector(15 downto 0);
		dacout_l_o		: out std_logic;
		dacout_r_o		: out std_logic
	);
end entity;

-- 32767  0111111111111111
--
-- 1      0000000000000001
-- 0      0000000000000000
-- -1     1111111111111111
--
-- -32768 1000000000000000

architecture Behavior of Audio_DACs is

	constant beep_vol_c	: signed(15 downto 0) := "0011111111111111";

	signal pcm_l_s			: signed(15 downto 0);
	signal pcm_r_s			: signed(15 downto 0);
	signal beep_sig_s		: signed(15 downto 0);
	signal psg_sig_s		: signed(15 downto 0);
	signal scc_sig_s		: signed(15 downto 0);
	signal jt51_l_sig_s	: signed(15 downto 0);
	signal jt51_r_sig_s	: signed(15 downto 0);

begin

	-- Left
	audiol : entity work.dac_dsm2v
	generic map (
		nbits_g	=> 16
	)
	port map (
		reset_i	=> reset_i,
		clock_i	=> clock_i,
		dac_i		=> pcm_l_s,
		dac_o		=> dacout_l_o
	);

	-- Right
	audior : entity work.dac_dsm2v
	generic map (
		nbits_g	=> 16
	)
	port map (
		reset_i	=> reset_i,
		clock_i	=> clock_i,
		dac_i		=> pcm_r_s,
		dac_o		=> dacout_r_o
	);

	beep_sig_s		<= beep_vol_c when beep_i = '1'		else (others => '0');
	psg_sig_s		<= "00" & signed(audio_psg_i) & "000000";
	scc_sig_s		<= audio_scc_i(14) & audio_scc_i;
	jt51_l_sig_s	<= jt51_left_i;
	jt51_r_sig_s	<= jt51_right_i;

	pcm_l_s 	<= beep_sig_s + psg_sig_s + scc_sig_s + jt51_l_sig_s;
	pcm_r_s 	<= beep_sig_s + psg_sig_s + scc_sig_s + jt51_r_sig_s;

	audio_mix_l_o <= std_logic_vector(pcm_l_s);
	audio_mix_r_o <= std_logic_vector(pcm_r_s);

end architecture;