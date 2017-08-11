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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity romnextor is
	port (
		reset_i		: in  std_logic;
		clock_i		: in  std_logic;
		enable_i		: in  std_logic;
		addr_i		: in  std_logic_vector(15 downto 0);
		data_i		: in  std_logic_vector( 7 downto 0);
		sltsl_n_i	: in  std_logic;
		rd_n_i		: in  std_logic;
		wr_n_i		: in  std_logic;
		--
		rom_cs_o		: out std_logic;
		rom_wr_o		: out std_logic;
		rom_page_o	: out std_logic_vector( 2 downto 0)
	);
end entity;

architecture Behavior of romnextor is

	signal rom_page_s	: std_logic_vector(2 downto 0);
	signal ram_wr_s	: std_logic;

begin

	-- Writes
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
			rom_page_s	<= (others => '0');
		elsif falling_edge(clock_i) then
			if enable_i = '1' then
				if sltsl_n_i = '0' and wr_n_i = '0' and addr_i = X"6000" then
					rom_page_s <= data_i(2 downto 0);
				end if;
			end if;
		end if;
	end process;

	rom_page_o <= rom_page_s;

	ram_wr_s	<= '1' when sltsl_n_i = '0' and wr_n_i = '0' and rom_page_s = "111" and
								addr_i >= X"7000" and addr_i <= X"7FD0"									else
					'0';

	rom_cs_o <=	'0' when enable_i = '0'																		else
					'1' when sltsl_n_i = '0' and rd_n_i = '0' and addr_i(15 downto 14) = "01"	else
					'1' when ram_wr_s = '1'																		else
					'0';

	rom_wr_o	<= '0' when enable_i = '0'																		else
					'1' when ram_wr_s = '1'																		else
					'0';

end architecture;