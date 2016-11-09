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
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
end tb;

architecture testbench of tb is

	-- test target
	component vdp18_core
	generic (
		is_pal_g		: boolean := false;
		is_cvbs_g		: boolean := false
	);
	port (
		clock_i			: in  std_logic;
		clk_en_10m7_i	: in  std_logic;
		reset_n_i		: in  std_logic;
		csr_n_i			: in  std_logic;
		csw_n_i			: in  std_logic;
		mode_i			: in  std_logic_vector(0 to  1);
		int_n_o			: out std_logic;
		cd_i			: in  std_logic_vector(0 to  7);
		cd_o			: out std_logic_vector(0 to  7);
		wait_o			: out std_logic;
		vram_ce_o		: out std_logic;
		vram_oe_o		: out std_logic;
		vram_we_o		: out std_logic;
		vram_a_o		: out std_logic_vector(0 to 13);
		vram_d_o		: out std_logic_vector(0 to  7);
		vram_d_i		: in  std_logic_vector(0 to  7);
		col_o			: out std_logic_vector(0 to  3);
		rgb_r_o			: out std_logic_vector(0 to  7);
		rgb_g_o			: out std_logic_vector(0 to  7);
		rgb_b_o			: out std_logic_vector(0 to  7);
		hsync_n_o		: out std_logic;
		vsync_n_o		: out std_logic;
		comp_sync_n_o	: out std_logic
	);
	end component;

	signal tb_end				: std_logic;
	signal clock_s				: std_logic;
	signal reset_n_s			: std_logic;
	signal csr_n_s				: std_logic;
	signal csw_n_s				: std_logic;
	signal mode_s				: std_logic_vector( 1 downto 0);
	signal int_n_s				: std_logic;
	signal cd_i_s				: std_logic_vector( 7 downto 0);
	signal cd_o_s				: std_logic_vector( 7 downto 0);
	signal wait_s				: std_logic;
	signal vram_ce_s			: std_logic;
	signal vram_oe_s			: std_logic;
	signal vram_we_s			: std_logic;
	signal vram_addr_s			: std_logic_vector(13 downto 0);	-- 16K
	signal vram_data_i_s		: std_logic_vector( 7 downto 0);
	signal vram_data_o_s		: std_logic_vector( 7 downto 0);
	signal col_s				: std_logic_vector( 3 downto 0);
	signal hsync_n_s			: std_logic;
	signal vsync_n_s			: std_logic;

begin

	--  instance
	u_target: vdp18_core
	generic map (
		is_pal_g		=> false,
		is_cvbs_g		=> false
	)
    port map (
      clock_i       => clock_s,
      clk_en_10m7_i => '1',
      reset_n_i     => reset_n_s,
      csr_n_i       => csr_n_s,
      csw_n_i       => csw_n_s,
      mode_i        => mode_s,
      int_n_o       => int_n_s,
      cd_i          => cd_i_s,
      cd_o          => cd_o_s,
      wait_o		=> wait_s,
      vram_ce_o		=> vram_ce_s,
      vram_oe_o		=> vram_oe_s,
      vram_we_o     => vram_we_s,
      vram_a_o      => vram_addr_s,
      vram_d_o      => vram_data_o_s,
      vram_d_i      => vram_data_i_s,
      col_o         => col_s,
      rgb_r_o       => open,
      rgb_g_o       => open,
      rgb_b_o       => open,
      hsync_n_o     => hsync_n_s,
      vsync_n_o     => vsync_n_s,
      comp_sync_n_o => open
    );


	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_s <= '0';
		wait for 46.729 ns;
		clock_s <= '1';
		wait for 46.729 ns;
	end process;


	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		csr_n_s			<= '1';
		csw_n_s			<= '1';
		mode_s			<= "00";
		cd_i_s			<= (others => '0');
		vram_data_i_s	<= (others => '0');

		-- reset
		reset_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		reset_n_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );

		wait for 30.4 ms;

		-- Escrita 98
--		cd_i_s		<= X"AA";
--		csw_n_s		<= '0';
--		wait until( rising_edge(clock_s) );
--		wait until( rising_edge(clock_s) );
--		csw_n_s		<= '1';
--		wait until( rising_edge(clock_s) );
--		wait until( rising_edge(clock_s) );
--		cd_i_s		<= X"00";
--		wait for 2 us;
--		-- Escrita 99
--		cd_i_s		<= X"55";
--		csw_n_s		<= '0';
--		mode_s		<= "01";
--		wait until( rising_edge(clock_s) );
--		wait until( rising_edge(clock_s) );
--		wait until( falling_edge(wait_s) );
--		wait until( rising_edge(clock_s) );
--		wait until( rising_edge(clock_s) );
--		csw_n_s		<= '1';
--		wait until( rising_edge(clock_s) );
--		wait until( rising_edge(clock_s) );
--		cd_i_s		<= X"00";
--		mode_s		<= "00";
--		wait for 1 us;
--		wait for 3 us;

		-- Leitura
		csr_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		if wait_s = '1' then
			wait until( falling_edge(wait_s) );
		end if;
		csr_n_s		<= '1';
		wait for 1 us;
		csr_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		if wait_s = '1' then
			wait until( falling_edge(wait_s) );
		end if;
		csr_n_s		<= '1';
		wait for 1 us;

		wait for 7 us;

		-- Escrita registro 16
		cd_i_s		<= X"02";					-- dado
		csw_n_s		<= '0';
		mode_s		<= "01";
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		if wait_s = '1' then
			wait until( falling_edge(wait_s) );
		end if;
		csw_n_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		cd_i_s		<= X"00";
		wait for 1 us;
		cd_i_s		<= X"D0";					-- escrita registro 16
		csw_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		if wait_s = '1' then
			wait until( falling_edge(wait_s) );
		end if;
		csw_n_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		cd_i_s		<= X"00";
		mode_s		<= "00";
		wait for 2 us;

		-- escrita paleta
		cd_i_s		<= X"A5";
		csw_n_s		<= '0';
		mode_s		<= "10";
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		if wait_s = '1' then
			wait until( falling_edge(wait_s) );
		end if;
		csw_n_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		cd_i_s		<= X"00";
		wait for 850 ns;
		cd_i_s		<= X"5A";
		csw_n_s		<= '0';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		if wait_s = '1' then
			wait until( falling_edge(wait_s) );
		end if;
		csw_n_s		<= '1';
		wait until( rising_edge(clock_s) );
		wait until( rising_edge(clock_s) );
		cd_i_s		<= X"00";
		mode_s		<= "00";

		wait for 10 us;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end testbench;
