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

entity i2s is
	generic (
		left_justified_g	: boolean		:= false
	)
	port (
		clock_i				: in    std_logic;
		audio_left_i		: in    std_logic_vector(15 downto 0);
		audio_right_i		: in    std_logic_vector(15 downto 0);
		----
		bck_o					: out   std_logic;
		lrck_o				: out   std_logic;
		data_o				: out   std_logic
	);
end entity;

architecture behavior of i2s is

begin

	process(clock_i)
		variable outLeft_v			: unsigned(15 downto 0) := x"0000";
		variable outRight_v			: unsigned(15 downto 0) := x"0000";
		variable outData_v			: unsigned(31 downto 0) := x"000000000000";

		variable leftDataTemp_v		: unsigned(19 downto 0) := x"00000";
		variable rightDataTemp_v	: unsigned(19 downto 0) := x"00000";

		variable tdaCounter_v		: unsigned(7 downto 0) := x"00";
		variable skipCounter_v		: unsigned(7 downto 0) := x"00";
		
	begin
		if rising_edge(clock_i) then

			if tdaCounter_v = 32 * 2 then
				tdaCounter_v := x"00";

				outRight_v := rightDataTemp_v(19 downto 4);
				rightDataTemp_v := x"00000";

				outLeft_v := leftDataTemp_v(19 downto 4);
				leftDataTemp_v := x"00000";

				outRight_v(15) := not outRight_v(15);
				outLeft_v(15)  := not outLeft_v(15);

				outData_v := unsigned(std_logic_vector(outRight_v(15 downto 0)) & std_logic_vector(outLeft_v(15 downto 0)));

			end if;
			
			if tdaCounter_v(0) = '0' then
    			
				data_o <= outData_v(31);
				outData_v := outData_v(30 downto 0) & "0";

				-- verificar I2S / left_justified aqui
				if tdaCounter_v(7 downto 1) = 0 then
					lrck_o <= '1';
				elsif tdaCounter_v(7 downto 1) = 16 then
					lrck_o <= '0';
				end if;

				if skipCounter_v >= 2 then
					leftDataTemp_v  := leftDataTemp_v  + unsigned(audio_left_i);
					rightDataTemp_v := rightDataTemp_v + unsigned(audio_right_i);
					skipCounter_v   := x"00";					
				else
					skipCounter_v := skipCounter_v + 1;
				end if;
			
			end if;
		
			bck_o <= tdaCounter_v(0);
			tdaCounter_v := tdaCounter_v + 1;
			
		end if;
	end process;

end architecture;