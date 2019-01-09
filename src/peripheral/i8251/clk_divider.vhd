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
use ieee.std_logic_unsigned.all; -- use '+' operator, CONV_INTEGER func.

entity clk_divider is
	port(
		clock_i		: in  std_logic;
		reset_n_i	: in  std_logic;
		baudsel_i	: in  std_logic_vector(1 downto 0);
		baudclk_o	: out std_logic
	);
end entity;

architecture baudgen of clk_divider is

	signal counter_q		: std_logic_vector(7 downto 0)	:= (others => '0');
	signal clock_out_s	: std_logic;

begin

	-- Coouter used to divide clock
	process (reset_n_i, clock_i)
	begin
		if reset_n_i = '0' then
			counter_q	<= (others => '0');
		elsif rising_edge(clock_i) then
			counter_q	<= counter_q + 1;
		end if;
	end process;

	-- select baud rate
	clock_out_s	<= clock_i			when baudsel_i = "00"	else		-- Sync Mode (not implemented)
						clock_i			when baudsel_i = "01"	else		-- / 1
						counter_q(3)	when baudsel_i = "10"	else		-- / 16
						counter_q(5);												-- / 64


	baudclk_o	<= clock_out_s;

end architecture;