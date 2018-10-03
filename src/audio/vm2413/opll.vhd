--
-- OPLL.vhd
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

--
--  modified by t.hara
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.vm2413.all;

entity OPLL is
	port(
		clock_i		: in    std_logic;
		clock_en_i	: in    std_logic;
		reset_i		: in    std_logic;
		data_i		: in    std_logic_vector(7 downto 0);
		addr_i		: in    std_logic;
		cs_n        : in    std_logic;
		we_n        : in    std_logic;
		melody_o		: out   signed(12 downto 0);
		rythm_o		: out   signed(12 downto 0)
	);
end entity;

architecture rtl of OPLL is

	signal opllptr  : std_logic_vector( 7 downto 0 );
	signal oplldat  : std_logic_vector( 7 downto 0 );
	signal opllwr   : std_logic;

	signal am       : std_logic;
	signal pm       : std_logic;
	signal wf       : std_logic;
	signal tl       : std_logic_vector(6 downto 0);
	signal fb       : std_logic_vector(2 downto 0);
	signal ar       : std_logic_vector(3 downto 0);
	signal dr       : std_logic_vector(3 downto 0);
	signal sl       : std_logic_vector(3 downto 0);
	signal rr       : std_logic_vector(3 downto 0);
	signal ml       : std_logic_vector(3 downto 0);
	signal fnum     : std_logic_vector(8 downto 0);
	signal blk      : std_logic_vector(2 downto 0);
	signal rks      : std_logic_vector(3 downto 0);
	signal key      : std_logic;

	signal rhythm   : std_logic;

	signal noise    : std_logic;
	signal pgout    : std_logic_vector( 17 downto 0 );  --  ������ 9bit, ������ 9bit

	signal egout    : std_logic_vector( 12 downto 0 );

	signal opout    : std_logic_vector( 13 downto 0 );


	signal faddr    : integer range 0 to 9-1;
	signal maddr    : std_logic_vector( 4 downto 0 );
	signal fdata    : signed_li_type;
	signal mdata    : signed_li_type;

	signal state2   : std_logic_vector( 6 downto 0 );
	signal state5   : std_logic_vector( 6 downto 0 );
	signal state8   : std_logic_vector( 6 downto 0 );
	signal slot     : std_logic_vector( 4 downto 0 );
	signal slot2    : std_logic_vector( 4 downto 0 );
	signal slot5    : std_logic_vector( 4 downto 0 );
	signal slot8    : std_logic_vector( 4 downto 0 );
	signal stage    : std_logic_vector( 1 downto 0 );
	signal stage2   : std_logic_vector( 1 downto 0 );
	signal stage5   : std_logic_vector( 1 downto 0 );
	signal stage8   : std_logic_vector( 1 downto 0 );

begin

	--  CPU�A�N�Z�X���� ------------------------------------------------------
	process( clock_i, reset_i )
	begin
		if reset_i ='1' then
			opllwr  <= '0';
			opllptr <= (others =>'0');
		elsif rising_edge(clock_i) then
			if clock_en_i = '1' then
				if cs_n = '0' and we_n = '0' and addr_i = '0' then
					--  �����W�X�^�A�h���X�w�背�W�X�^ �ւ̏�������
					opllptr <= data_i;
					opllwr  <= '0';
				elsif cs_n = '0' and we_n = '0' and addr_i = '1' then
					--  �����W�X�^ �ւ̏�������
					oplldat <= data_i;
					opllwr  <= '1';
				end if;
			end if;
		end if;
	end process;

	--  �^�C�~���O�W�F�l���[�^ -----------------------------------------------
	s0: entity work.SlotCounter
	generic map(
		delay   => 0
	)
	port map(
		clk     => clock_i,
		reset   => reset_i,
		clkena  => clock_en_i,
		slot    => slot,
		stage   => stage
	);

	s2: entity work.SlotCounter
	generic map(
		delay   => 2
	)
	port map(
		clk     => clock_i,
		reset   => reset_i,
		clkena  => clock_en_i,
		slot    => slot2,
		stage   => stage2
	);

	s5: entity work.SlotCounter
	generic map(
		delay   => 5
	)
	port map(
		clk     => clock_i,
		reset   => reset_i,
		clkena  => clock_en_i,
		slot    => slot5,
		stage   => stage5
	);

	s8: entity work.SlotCounter
	generic map(
		delay   => 8
	)
	port map(
		clk     => clock_i,
		reset   => reset_i,
		clkena  => clock_en_i,
		slot    => slot8,
		stage   => stage8
	);

	-- no delay
	ct: entity work.Controller
	port map (
		clock_i,reset_i,clock_en_i, slot, stage, opllwr,opllptr,oplldat,
		am,pm,wf,ml,tl,fb,ar,dr,sl,rr,blk,fnum,rks,key,rhythm);

	-- 2 stages delay
	eg: entity work.EnvelopeGenerator
	port map (
		clock_i,reset_i,clock_en_i,
		slot2, stage2, rhythm,
		am, tl, ar, dr, sl, rr, rks, key,
		egout
	);

	pg: entity work.PhaseGenerator
	port map (
		clock_i,reset_i,clock_en_i,
		slot2, stage2, rhythm,
		pm, ml, blk, fnum, key,
		noise, pgout
	);

	-- 5 stages delay
	op: entity work.Operator
	port map (
		clock_i,reset_i,clock_en_i,
		slot5, stage5, rhythm,
		wf, fb, noise, pgout, egout, faddr, fdata, opout
	);

	-- 8 stages delay
	og: entity work.OutputGenerator
	port map (
		clock_i, reset_i, clock_en_i, slot8, stage8, rhythm,
		opout, faddr, fdata, maddr, mdata
	);

	-- by Fabio Belavenuto
	sm: entity work.SumMixer
	port map (
		clock_i, reset_i, clock_en_i,
		slot, stage, rhythm,
		maddr, mdata,
		melody_o, rythm_o
	);

end architecture;

