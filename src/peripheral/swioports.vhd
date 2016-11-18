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
--use ieee.textio.all;

entity swioports is
	port (
		reset_i			: in  std_logic;
		clock_i			: in  std_logic;
		addr_i			: in  std_logic_vector(7 downto 0);
		cs_i				: in  std_logic;
		rd_i				: in  std_logic;
		wr_i				: in  std_logic;
		data_i			: in  std_logic_vector(7 downto 0);
		data_o			: out std_logic_vector(7 downto 0);
		has_data_o		: out std_logic;
		--
		hw_id_i			: in  std_logic_vector(7 downto 0);
		hw_txt_i			: in  string;
		hw_version_i	: in  std_logic_vector(7 downto 0);
		nextor_en_i		: in  std_logic;
		mr_type_i		: in  std_logic_vector(1 downto 0);
		turbo_on_k_i	: in  std_logic;
		vga_on_k_i		: in  std_logic;
		--
		nextor_en_o		: out std_logic;
		mr_type_o		: out std_logic_vector(1 downto 0);
		turbo_on_o		: out std_logic;
		softreset_o		: out std_logic;
		vga_en_o			: out std_logic;
		keymap_addr_o	: out std_logic_vector(9 downto 0);
		keymap_data_o	: out std_logic_vector(7 downto 0);
		keymap_we_o		: out std_logic
	);
end entity;

architecture Behavior of swioports is

	signal maker_id_s			: std_logic_vector(7 downto 0);
	signal has_data_mkid_s	: std_logic;
	signal has_data_regv_s	: std_logic;
	signal reg_addr_q			: std_logic_vector(7 downto 0);
	signal reg_data_s			: std_logic_vector(7 downto 0);
	signal nextor_en_q		: std_logic;
	signal mapper_q			: std_logic_vector(1 downto 0);
	signal turbo_on_q			: std_logic;
	signal softreset_q		: std_logic								:= '0';
	signal keymap_addr_q		: unsigned(9 downto 0);
	signal keymap_data_q		: std_logic_vector(7 downto 0);
	signal keymap_we_s		: std_logic;
	signal vga_en_q			: std_logic								:= '0';

begin

	-- Maker ID
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
			maker_id_s <= (others => '0');
		elsif falling_edge(clock_i) then
			if cs_i = '1' and wr_i = '1' and addr_i = X"40" then
				if data_i = X"08" or data_i = X"28" or data_i = X"D4" then
					maker_id_s <= data_i;
				else
					maker_id_s <= X"00";
				end if;
			end if;
		end if;
	end process;

	-- Reading Maker ID
	has_data_mkid_s	<= '1'	when addr_i = X"40"		else '0';

	-- Has data to reading
	has_data_o	<= '1'	when cs_i = '1' and rd_i = '1' and has_data_mkid_s = '1'	else
						'1'	when cs_i = '1' and rd_i = '1' and has_data_regv_s = '1'	else
						'0';

	data_o <=	not maker_id_s	when has_data_mkid_s = '1'	else
					reg_data_s		when has_data_regv_s = '1'	else
					(others => '1');

	-- Set register number (only if maker id = 40)
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
			reg_addr_q <= (others => '0');
		elsif falling_edge(clock_i) then
			if cs_i = '1' and wr_i = '1' and maker_id_s = X"28" and addr_i = X"48" then
				reg_addr_q <= data_i;
			end if;
		end if;
	end process;

	-- Write to Switched I/O ports
	process (reset_i, clock_i, nextor_en_i, mr_type_i)
		variable turbo_on_de_v	: std_logic_vector(1 downto 0) := "00";
		variable vga_on_de_v		: std_logic_vector(1 downto 0) := "00";
		variable keymap_we_a_v	: std_logic;
	begin
		if reset_i = '1' then
			nextor_en_q	<= nextor_en_i;
			mapper_q		<= mr_type_i;
			turbo_on_q	<= '0';
			softreset_q	<= '0';
			keymap_we_s	<= '0';
			vga_en_q		<= '0';
		elsif falling_edge(clock_i) then
			turbo_on_de_v := turbo_on_de_v(0) & turbo_on_k_i;
			vga_on_de_v   := vga_on_de_v(0) & vga_on_k_i;
			if turbo_on_de_v = "01" then
				turbo_on_q <= not turbo_on_q;
			end if;
			if vga_on_de_v = "01" then
				vga_en_q <= not vga_en_q;
			end if;
			keymap_we_s	<= '0';		-- default

			-- Panasonic
			if    cs_i = '1' and wr_i = '1' and maker_id_s = X"08" then
				if addr_i = X"41" then
					turbo_on_q <= not data_i(0);
				end if;
			-- MSX1FPGA ID
			elsif cs_i = '1' and wr_i = '1' and maker_id_s = X"28" and addr_i = X"49" then
				case reg_addr_q is
					when X"0A" =>
						softreset_q		<= data_i(0);
					when X"0D" =>
						keymap_addr_q(7 downto 0) <= unsigned(data_i);
					when X"0E" =>
						keymap_addr_q(9 downto 8) <= unsigned(data_i(1 downto 0));
					when X"0F" =>
						keymap_data_q	<= data_i;
						keymap_we_s		<= '1';
					when X"10" =>
						vga_en_q			<= data_i(1);
						nextor_en_q		<= data_i(0);
					when X"11" =>
						mapper_q			<= data_i(1 downto 0);
					when X"12" =>
						turbo_on_q		<= data_i(0);
					when others =>
						null;
				end case;
			-- KdL ID (only for MGLOCM)
			elsif cs_i = '1' and wr_i = '1' and maker_id_s = X"D4" then
				if    addr_i = X"41" then
					-- Smart Command
					if    data_i = X"03" then
						turbo_on_q <= '0';
					elsif data_i = X"0A" then
						turbo_on_q <= '1';
					elsif data_i = X"0F" then
						mapper_q <= "00";
					elsif data_i = X"10" then
						mapper_q <= "00";
					elsif data_i = X"11" then
						mapper_q <= "01";
					elsif data_i = X"12" then
						mapper_q <= "01";
					elsif data_i = X"13" then
						mapper_q <= "11";
					elsif data_i = X"14" then
						mapper_q <= "11";
					elsif data_i = X"41" then
						turbo_on_q <= '1';
					end if;
				end if;
			end if;
			if keymap_we_a_v = '1' and keymap_we_s = '0' then
				keymap_addr_q <= keymap_addr_q + 1;
			end if;
			keymap_we_a_v	:= keymap_we_s;
		end if;
	end process;

	-- Reading register
	process (reset_i, clock_i)
		variable index_v		: integer range 0 to 20	:= 0;
		variable reading_v	: boolean	:= false;
		variable char_v		: character;
	begin
		if reset_i = '1' then
			reading_v 	:= false;
			index_v		:= 0;
		elsif falling_edge(clock_i) then
			has_data_regv_s	<= '0';
			reg_data_s			<= (others => '0');
			-- Panasonic
			if    cs_i = '1' and rd_i = '1' and maker_id_s = X"08" then
				if addr_i = X"41" then
					reg_data_s			<= "0000000" & not turbo_on_q;
					has_data_regv_s	<= '1';
				end if;
			-- MSX1FPGA ID
			elsif cs_i = '1' and rd_i = '1' and maker_id_s = X"28" and addr_i = X"49" then
				case reg_addr_q is
					when X"00" =>
						reg_data_s			<= hw_id_i;
						has_data_regv_s	<= '1';
						index_v				:= 0;
					when X"01" =>
						if index_v = hw_txt_i'length then
							reg_data_s	<= (others => '0');
						else
							char_v		:= hw_txt_i(index_v + 1);
							reg_data_s	<= std_logic_vector(to_unsigned(character'pos(char_v), 8));
						end if;
						has_data_regv_s	<= '1';
						reading_v			:= true;
					when X"02" =>
						reg_data_s			<= hw_version_i;
						has_data_regv_s	<= '1';
					when X"10" =>
						reg_data_s			<= "000000" & vga_en_q & nextor_en_q;
						has_data_regv_s	<= '1';
					when X"11" =>
						reg_data_s			<= "000000" & mapper_q;
						has_data_regv_s	<= '1';
					when X"12" =>
						reg_data_s			<= "0000000" & turbo_on_q;
						has_data_regv_s	<= '1';
					when others =>
						null;
				end case;
			-- KdL ID
			elsif cs_i = '1' and rd_i = '1' and maker_id_s = X"D4" then
				if    addr_i = X"42" then
					reg_data_s			<= nextor_en_q & "0" & mapper_q & "0000";
					has_data_regv_s	<= '1';
				elsif addr_i = X"49" then
					reg_data_s			<= "01000000";
					has_data_regv_s	<= '1';
				elsif addr_i = X"4E" then
					reg_data_s			<= nextor_en_q & "0" & mapper_q & "0000";
					has_data_regv_s	<= '1';
				elsif addr_i = X"4F" then
					reg_data_s			<= "00000100";
					has_data_regv_s	<= '1';
				end if;
			elsif reading_v then
				if index_v < hw_txt_i'length then
					index_v 	:= index_v + 1;
				end if;
				reading_v	:= false;
			end if;
		end if;
	end process;

	--
	nextor_en_o		<= nextor_en_q;
	mr_type_o		<= mapper_q;
	turbo_on_o		<= turbo_on_q;
	softreset_o		<= softreset_q;
	keymap_addr_o	<= std_logic_vector(keymap_addr_q);
	keymap_data_o	<= keymap_data_q;
	keymap_we_o		<= keymap_we_s;
	vga_en_o			<= vga_en_q;

end architecture;
