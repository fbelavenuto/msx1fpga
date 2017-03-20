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

	procedure keyp (
		scancode_i			: in  std_logic_vector(7 downto 0);
		signal data_o		: out std_logic_vector(7 downto 0);
		signal data_rdy_o	: out std_logic
	) is
	begin
		data_o		<= scancode_i;
		data_rdy_o	<= '1';
		wait until( rising_edge(clock_i) );
		data_rdy_o	<= '0';
		--
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;
	end procedure;

begin

	process
	begin
		data_o		<= X"00";
		data_rdy_o	<= '0';
		wait until (reset_i = '0');
		for i in 0 to 10 loop
			wait until( rising_edge(clock_i) );
		end loop;

		keyp(X"16", data_o, data_rdy_o);		-- ! 1
		keyp(X"F0", data_o, data_rdy_o);		-- BREAK
		keyp(X"16", data_o, data_rdy_o);		-- ! 1
		keyp(X"12", data_o, data_rdy_o);		-- SHIFT
		keyp(X"52", data_o, data_rdy_o);		-- ^ ~
		keyp(X"F0", data_o, data_rdy_o);		-- BREAK
		keyp(X"52", data_o, data_rdy_o);		-- ^ ~
		keyp(X"F0", data_o, data_rdy_o);		-- BREAK
		keyp(X"12", data_o, data_rdy_o);		-- SHIFT

		keyp(X"12", data_o, data_rdy_o);		-- SHIFT
		keyp(X"52", data_o, data_rdy_o);		-- ^ ~
		keyp(X"F0", data_o, data_rdy_o);		-- BREAK
		keyp(X"12", data_o, data_rdy_o);		-- SHIFT
		keyp(X"F0", data_o, data_rdy_o);		-- BREAK
		keyp(X"52", data_o, data_rdy_o);		-- ^ ~
		wait;

	end process;

end rtl;