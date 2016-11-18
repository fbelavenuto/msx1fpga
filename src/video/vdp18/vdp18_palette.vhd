-------------------------------------------------------------------------------
--
-- Synthesizable model of TI's TMS9918A, TMS9928A, TMS9929A.
--
-- $Id: vdp18_palette.vhd,v 1.10 2016/11/09 10:47:01 fbelavenuto Exp $
--
-- Palette
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2006, Arnim Laeuger (arnim.laeuger@gmx.net)
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

entity vdp18_palette is
	port (
		reset_i			: in  boolean;
		clock_i			: in  std_logic;
		we_i				: in  std_logic;
		addr_wr_i		: in  std_logic_vector(0 to  3);
		data_i			: in  std_logic_vector(0 to 15);
		addr_rd_i		: in  std_logic_vector(0 to  3);
		data_o			: out std_logic_vector(0 to 15)
	);
end entity;

architecture Memory of vdp18_palette is

	type ram_t is array (natural range 15 downto 0) of std_logic_vector(15 downto 0);
	signal ram_q : ram_t;
	signal read_addr_q : unsigned(3 downto 0);

begin

	process (reset_i, clock_i)
	begin
		if reset_i then
			ram_q <= (
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
		elsif rising_edge(clock_i) then
			if we_i = '1' then
				ram_q(to_integer(unsigned(addr_wr_i))) <= data_i;
			end if;
			read_addr_q <= unsigned(addr_rd_i);
		end if;
	end process;

	data_o <= ram_q(to_integer(read_addr_q));

end architecture;