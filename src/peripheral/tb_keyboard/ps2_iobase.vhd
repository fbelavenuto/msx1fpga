-------------------------------------------------------------------------------
-- Title      : MC613
-- Project    : PS2 Basic Protocol
-- Details    : www.ic.unicamp.br/~corte/mc613/
--							www.computer-engineering.org/ps2protocol/
-------------------------------------------------------------------------------
-- File       : ps2_base.vhd
-- Author     : Thiago Borges Abdnur
-- Company    : IC - UNICAMP
-- Last update: 2010/04/12
-------------------------------------------------------------------------------
-- Description: 
-- PS2 basic control
-------------------------------------------------------------------------------

-- FOR SIMULATION ONLY!!!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_iobase is
	generic(
		clkfreq_g		: integer										-- This is the system clock value in kHz
	);
	port(
		enable_i			: in    std_logic;							-- Enable
		clock_i			: in    std_logic;							-- system clock (same frequency as defined in 'clkfreq' generic)
		reset_i			: in    std_logic;							-- Reset when '1'
		ps2_data_io		: inout std_logic;							-- PS2 data pin
		ps2_clk_io		: inout std_logic;							-- PS2 clock pin
		data_rdy_i		: in    std_logic;							-- Rise this to signal data is ready to be sent to device
		data_i			: in    std_logic_vector(7 downto 0);	-- Data to be sent to device
		send_rdy_o		: out   std_logic;							-- '1' if data can be sent to device (wait for this before rising 'iData_rdy'
		data_rdy_o		: out   std_logic;							-- '1' when data from device has arrived
		data_o			: out   std_logic_vector(7 downto 0)	-- Data from device
	);
end;

architecture rtl of ps2_iobase is

begin

	process
	begin
		data_o		<= X"00";
		data_rdy_o	<= '0';
		wait until (reset_i = '0');
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
		data_o		<= X"12";					-- SHIFT
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
		data_o		<= X"1C";					-- A
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
		data_o		<= X"F0";					-- BREAK
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
		data_o		<= X"1C";					-- A
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
		data_o		<= X"F0";					-- BREAK
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
		data_o		<= X"12";					-- SHIFT
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;

	end process;

end rtl;