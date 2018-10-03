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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.VM2413.ALL;

entity VoiceMemory is
  port (
    clk    : in std_logic;
    reset  : in std_logic;

    idata  : in VOICE_TYPE;
    wr     : in std_logic;
    rwaddr : in VOICE_ID_TYPE; -- read/write address
    roaddr : in VOICE_ID_TYPE; -- read only address
    odata  : out VOICE_TYPE;
    rodata : out VOICE_TYPE
  );
end VoiceMemory;

architecture RTL of VoiceMemory is

  -- The following array is mapped into a Single-Clock Synchronous RAM with two-read
  -- addresses by Altera's QuartusII compiler.
  type VOICE_ARRAY_TYPE is array (0 to 37) of VOICE_VECTOR_TYPE;
  signal voices : VOICE_ARRAY_TYPE;

  component VoiceRom port (
    clk   : in std_logic;
    addr  : in VOICE_ID_TYPE;
    data  : out VOICE_TYPE
  );
  end component;

  signal rom_addr : VOICE_ID_TYPE;
  signal rom_data : VOICE_TYPE;
  signal rstate : integer range 0 to 2;
	signal init_id  : integer range 0 to VOICE_ID_TYPE'high+1;
	signal rom_wr_s	: std_logic;
  signal mem_addr_s	: integer;
  signal mem_data_s	: VOICE_VECTOR_TYPE;
  signal mem_wr_s		: std_logic;

begin

	ROM2413 : VoiceRom port map(clk, rom_addr, rom_data);

	mem_addr_s	<= init_id								when init_id /= VOICE_ID_TYPE'high+1	else rwaddr;
	mem_data_s	<= CONV_VOICE_VECTOR(rom_data)	when init_id /= VOICE_ID_TYPE'high+1	else CONV_VOICE_VECTOR(idata);
	mem_wr_s		<= rom_wr_s								when init_id /= VOICE_ID_TYPE'high+1	else wr;

	process (clk, reset)
	begin
		if reset = '1' then
			init_id <= 0;
			rstate <= 0;
		elsif clk'event and clk = '1' then
			if init_id /= VOICE_ID_TYPE'high+1 then
				case rstate is
					when 0 =>
						rom_wr_s <= '0';
						rstate <= 1;
					when 1 =>
						rstate <= 2;
					when 2 =>
						rom_wr_s   <= '1';
						rstate <= 0;
						init_id <= init_id + 1;
				end case;
			else
			end if;		 
		end if;
	end process;

  process (clk)
  begin
    if clk'event and clk = '1' then
      if mem_wr_s = '1' then
        voices(mem_addr_s) <= mem_data_s;
      end if;
      odata <= CONV_VOICE(voices(rwaddr));
      rodata <= CONV_VOICE(voices(roaddr));

    end if;

  end process;


end RTL;