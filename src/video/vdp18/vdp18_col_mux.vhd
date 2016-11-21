-------------------------------------------------------------------------------
--
-- Synthesizable model of TI's TMS9918A, TMS9928A, TMS9929A.
--
-- $Id: vdp18_col_mux.vhd,v 1.10 2006/06/18 10:47:01 arnim Exp $
--
-- Color Information Multiplexer
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2006, Arnim Laeuger (arnim.laeuger@gmx.net)
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

entity vdp18_col_mux is
	port (
		vert_active_i	: in  boolean;
		hor_active_i	: in  boolean;
		blank_i			: in  boolean;
		reg_col0_i		: in  std_logic_vector(0 to  3);
		pat_col_i		: in  std_logic_vector(0 to  3);
		spr0_col_i		: in  std_logic_vector(0 to  3);
		spr1_col_i		: in  std_logic_vector(0 to  3);
		spr2_col_i		: in  std_logic_vector(0 to  3);
		spr3_col_i		: in  std_logic_vector(0 to  3);
		col_o				: out std_logic_vector(0 to  3)
	);
end vdp18_col_mux;

architecture rtl of vdp18_col_mux is

	signal col_s	: std_logic_vector( 3 downto 0);

begin

	-----------------------------------------------------------------------------
	-- Process col_mux
	--
	-- Purpose:
	--   Multiplexes the color information from different sources.
	--
	col_mux: process (blank_i,
							hor_active_i, vert_active_i,
							spr0_col_i, spr1_col_i,
							spr2_col_i, spr3_col_i,
							pat_col_i,
							reg_col0_i)
	begin
		if not blank_i then
			if hor_active_i and vert_active_i then
				-- priority decoder
				if    spr0_col_i /= "0000" then
					col_s <= spr0_col_i;
				elsif spr1_col_i /= "0000" then
					col_s <= spr1_col_i;
				elsif spr2_col_i /= "0000" then
					col_s <= spr2_col_i;
				elsif spr3_col_i /= "0000" then
					col_s <= spr3_col_i;
				elsif pat_col_i  /= "0000" then
					col_s <= pat_col_i;
				else
					col_s <= reg_col0_i;
				end if;
			else
				-- display border
				col_s   <= reg_col0_i;
			end if;

		else
			-- blank color channels during horizontal and vertical
			-- trace back
			-- required to initialize colors for each new scan line
			col_s     <= (others => '0');
		end if;
	end process col_mux;
	--
	-----------------------------------------------------------------------------

	col_o <= col_s;

end rtl;
