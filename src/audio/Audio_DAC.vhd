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

entity Audio_DAC is
	port (
		clock_i		: in  std_logic;
		reset_i		: in  std_logic;
		audio_scc_i	: in  signed(14 downto 0);
		audio_psg_i	: in  unsigned(7 downto 0);
		beep_i		: in  std_logic;
		audio_mix_o	: out std_logic_vector(15 downto 0);
		dac_out_o	: out std_logic
	);
end entity;

-- 32767	0111111111111111
--
-- 1		0000000000000001
-- 0		0000000000000000
-- -1		1111111111111111
--
-- -32768	1000000000000000

architecture Behavior of Audio_DAC is

	signal pcm_s			: std_logic_vector(15 downto 0);
	signal beep_s			: std_logic_vector(15 downto 0);

	constant beep_vol_c	: std_logic_vector(15 downto 0) := "0110000000000000";

begin

	audioo : entity work.dac
	generic map (
		msbi_g	=> 15
	)
	port map (
		clk_i		=> clock_i,
		res_i		=> reset_i,
		dac_i		=> pcm_s,
		dac_o		=> dac_out_o
	);

	beep_s	<= beep_vol_c when beep_i = '1'		else (others => '0');

	pcm_s 	<= std_logic_vector(
						unsigned(beep_s) + 
						unsigned(audio_psg_i & "00000000") +
						unsigned(audio_scc_i + 16384)
	);

	audio_mix_o <= pcm_s;

end architecture;