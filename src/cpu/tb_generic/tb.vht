--
-- T80 testbench
-- Copyright (c) 2023 - Fabio Belavenuto
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
use work.T80_Pack.all;

entity tb is
end tb;

architecture testbench of tb is

	signal tb_end			: std_logic := '0';
	signal clock			: std_logic;                                -- CLOCK
	signal clock_enable		: std_logic;
	signal reset_n			: std_logic;                                -- /RESET
	signal cpu_wait_n		: std_logic;                                -- /WAIT
	signal cpu_irq_n		: std_logic;                                -- /IRQ
	signal cpu_nmi_n		: std_logic;                                -- /NMI
	signal cpu_busreq_n		: std_logic;                                -- /BUSREQ
	signal cpu_m1_n			: std_logic;                                -- /M1
	signal cpu_mreq_n		: std_logic;                                -- /MREQ
	signal cpu_ioreq_n		: std_logic;                                -- /IOREQ
	signal cpu_rd_n			: std_logic;                                -- /RD
	signal cpu_wr_n			: std_logic;                                -- /WR
	signal cpu_rfsh_n		: std_logic;                                -- /REFRESH
	signal cpu_halt_n		: std_logic;                                -- /HALT
	signal cpu_busak_n		: std_logic;                                -- /BUSAK
	signal cpu_a			: std_logic_vector(15 downto 0);            -- A
	signal cpu_di			: std_logic_vector(7 downto 0);
	signal cpu_do			: std_logic_vector(7 downto 0);
	signal texto			: string (1 to 12)				:= "            ";
	
begin

	--  instance
	u_target: entity work.t80s
	generic map(
		mode_g      => 0, -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		iowait_g    => 1,  -- 0 => Single cycle I/O, 1 => Std I/O cycle
		nmos_g      => true
	)
	port map(
		r800_mode_i	=> '0',
		reset_n_i	=> reset_n,
		clock_i		=> clock,
		clock_en_i	=> clock_enable,
		address_o	=> cpu_a,
		data_i		=> cpu_di,
		data_o		=> cpu_do,
		wait_n_i	=> cpu_wait_n,
		int_n_i		=> cpu_irq_n,
		nmi_n_i		=> cpu_nmi_n,
		m1_n_o		=> cpu_m1_n,
		mreq_n_o	=> cpu_mreq_n,
		iorq_n_o	=> cpu_ioreq_n,
		rd_n_o		=> cpu_rd_n,
		wr_n_o		=> cpu_wr_n,
		refresh_n_o	=> cpu_rfsh_n,
		halt_n_o	=> cpu_halt_n,
		busrq_n_i	=> cpu_busreq_n,
		busak_n_o	=> cpu_busak_n
	);

	-- ----------------------------------------------------- --
	--  clock generator                                      --
	-- ----------------------------------------------------- --
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock <= '1';
		wait for 20 ns;
		clock <= '0';
		wait for 20 ns;
	end process;

	-- clock enable
	process
	begin
		if tb_end = '1' then
			wait;
		end if;
		clock_enable <= '1';
		wait for 40 ns;
		clock_enable <= '0';
		wait for 80 ns;
	end process;

	--
	--
	--
	process (cpu_a, cpu_m1_n, cpu_rfsh_n, cpu_mreq_n, cpu_rd_n)
	begin
		case cpu_a is
			when X"0000" => cpu_di <= X"21"; if cpu_m1_n='0' then texto <= "LD HL, $1000"; end if;	-- CYCLE = 10
			when X"0001" => cpu_di <= X"00";
			when X"0002" => cpu_di <= X"10";
			when X"0003" => cpu_di <= X"36"; if cpu_m1_n='0' then texto <= "LD (HL), $34"; end if;	-- CYCLE = 14
			when X"0004" => cpu_di <= X"34";
			when X"0005" => cpu_di <= X"DB"; if cpu_m1_n='0' then texto <= "IN A,(0)    "; end if;	-- CYCLE = 24
			when X"0006" => cpu_di <= X"00";
			when X"0007" => cpu_di <= X"D3"; if cpu_m1_n='0' then texto <= "OUT (0), A  "; end if;	-- CYCLE = 11
			when X"0008" => cpu_di <= X"00";
			when X"0009" => cpu_di <= X"21"; if cpu_m1_n='0' then texto <= "LD HL, $1000"; end if;	-- CYCLE = 10
			when X"000A" => cpu_di <= X"00";
			when X"000B" => cpu_di <= X"10";
			when X"000C" => cpu_di <= X"36"; if cpu_m1_n='0' then texto <= "LD (HL), $34"; end if;	-- CYCLE = 14
			when X"000D" => cpu_di <= X"34";
			when X"000E" => cpu_di <= X"DB"; if cpu_m1_n='0' then texto <= "IN A,(0)    "; end if;	-- CYCLE = 24
			when X"000F" => cpu_di <= X"00";
			when X"0010" => cpu_di <= X"D3"; if cpu_m1_n='0' then texto <= "OUT (0), A  "; end if;	-- CYCLE = 11
			when X"0011" => cpu_di <= X"00";

			when others  => cpu_di <= X"00"; if cpu_m1_n='0' then texto <= "NOP         "; end if;	-- CYCLE = 8
		end case;
	end process;

	-- ----------------------------------------------------- --
	--  test bench                                           --
	-- ----------------------------------------------------- --
	process
	begin
		-- init
		cpu_wait_n      <= '1';
		cpu_irq_n       <= '1';
		cpu_nmi_n       <= '1';
		cpu_busreq_n    <= '1';

		-- reset
		reset_n    <= '0';
		wait until( rising_edge(clock_enable) );
		wait until( rising_edge(clock_enable) );
		reset_n    <= '1';
		wait until( rising_edge(clock_enable) );

		for i in 0 to 41 loop
			wait until( rising_edge(clock_enable) );
		end loop;

        cpu_wait_n <= '0';
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        cpu_wait_n <= '1';

        for i in 0 to 2 loop
            wait until( rising_edge(clock_enable) );
        end loop;

        cpu_wait_n <= '0';
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        cpu_wait_n <= '1';

        for i in 0 to 12 loop
            wait until( rising_edge(clock_enable) );
        end loop;

        cpu_wait_n <= '0';
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        cpu_wait_n <= '1';

        for i in 0 to 9 loop
            wait until( rising_edge(clock_enable) );
        end loop;

        cpu_wait_n <= '0';
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        cpu_wait_n <= '1';

        for i in 0 to 10 loop
            wait until( rising_edge(clock_enable) );
        end loop;

        cpu_wait_n <= '0';
        wait until( rising_edge(clock_enable) );
        wait until( rising_edge(clock_enable) );
        cpu_wait_n <= '1';



		cpu_busreq_n <= '0';
		wait until( rising_edge(clock_enable) );
		wait until( rising_edge(clock_enable) );
		wait until( rising_edge(clock_enable) );
		cpu_busreq_n <= '1';

		for i in 0 to 8 loop
			wait until( rising_edge(clock_enable) );
		end loop;

		-- wait
		tb_end <= '1';
		wait;
	end process;

end architecture;
