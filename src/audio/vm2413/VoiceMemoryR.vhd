--
-- VoiceMemory.vhd
--
-- Copyright (c) 2006 Mitsutaka Okazaki (brezza@pokipoki.org)
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
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vm2413.all;

entity VoiceMemory is
	port (
		clk    : in std_logic;
		reset  : in std_logic;
		
		idata  : in VOICE_TYPE;
		wr     : in std_logic;
		rwaddr : in integer range 0 to 37; -- read/write address
		roaddr : in integer range 0 to 37; -- read only address
		odata  : out VOICE_TYPE;
		rodata : out VOICE_TYPE
	);
end entity;

architecture RTL of VoiceMemory is

	type VOICE_ARRAY_TYPE is array (0 to 37) of VOICE_VECTOR_TYPE;
	signal voices			: VOICE_ARRAY_TYPE;

begin

	ROM2413 : entity work.VoiceRom	port map(clk, roaddr, rodata);

	process (clk)
	begin
		if rising_edge(clk) then
			if wr = '1' then
				voices(rwaddr) <= CONV_VOICE_VECTOR(idata);
			end if;
			odata <= CONV_VOICE(voices(rwaddr));
		end if;
	end process;

end architecture;
