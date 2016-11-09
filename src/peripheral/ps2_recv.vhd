
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_recv is
	port (
		clock_i			: in  std_logic;
		reset_i			: in  std_logic;
		enable_i			: in  std_logic;
		--
		ps2_clock_i		: in  std_logic;
		ps2_data_i		: in  std_logic;
		--
		scancode_o		: out std_logic_vector(7 downto 0);
		has_data_o		: out std_logic
	);
end entity;

architecture Behavior of ps2_recv is

	signal clk_syn_s		: std_logic;
	signal dat_syn_s		: std_logic;
	signal clk_nedge_s	: std_logic;
	signal timeout_q		: unsigned(15 downto 0)	:= X"0000";
	signal shift_s			: std_logic_vector(7 downto 0);

	type rcv_states_t is (RCV_START, RCV_DATA, RCV_PARITY, RCV_STOP);
	signal rcv_state_s	: rcv_states_t							:= RCV_START;

begin

	-- Synchronizing signals
	process (reset_i, clock_i)
		variable clk_sync_v : std_logic_vector(1 downto 0);
		variable dat_sync_v : std_logic_vector(1 downto 0);
	begin
		if reset_i = '1' then
			clk_sync_v := "00";
			dat_sync_v := "00";
		elsif rising_edge(clock_i) then
			clk_sync_v := clk_sync_v(0) & ps2_clock_i;
			dat_sync_v := dat_sync_v(0) & ps2_data_i;
		end if;
		clk_syn_s <= clk_sync_v(1);
		dat_syn_s <= dat_sync_v(1);
	end process;

	-- Detect edge
	process (reset_i, clock_i)
		variable edge_detect_v : std_logic_vector(15 downto 0);
	begin
		if reset_i = '1' then
			edge_detect_v	:= (others => '0');
		elsif rising_edge(clock_i) then
			edge_detect_v := edge_detect_v(14 downto 0) & clk_syn_s;
		end if;

		clk_nedge_s <= '0';
		if    edge_detect_v = X"F000" then
			clk_nedge_s <= '1';
		end if;
	end process;

	-- State machine
	process (reset_i, clock_i)
		variable parity_v : std_logic;
	begin
		if reset_i = '1' then
			timeout_q	<= (others => '0');
			shift_s		<= (others => '0');
			rcv_state_s	<= RCV_START;
		elsif rising_edge(clock_i) then

			has_data_o <= '0';

			if clk_nedge_s = '1' and enable_i = '1' then

				timeout_q <= X"0000";

				case rcv_state_s is
					when RCV_START =>
						parity_v := '0';
						if dat_syn_s = '0' then
							shift_s <= X"80";
							rcv_state_s <= RCV_DATA;
						end if;

					when RCV_DATA =>
						shift_s <= dat_syn_s & shift_s(7 downto 1);
						parity_v := parity_v xor dat_syn_s;
						if shift_s(0) = '1' then 
							rcv_state_s <= RCV_PARITY;
						end if;

					when RCV_PARITY =>
						if (dat_syn_s xor parity_v) = '1' then
							rcv_state_s <= RCV_STOP;
						else
							rcv_state_s <= RCV_START;
						end if;

					when RCV_STOP =>
						rcv_state_s <= RCV_START;
						if dat_syn_s = '1' then
							scancode_o <= shift_s;
							has_data_o <= '1';
						end if;
				end case;
			else
				timeout_q <= timeout_q + 1;
				if timeout_q = X"FFFF" then
					rcv_state_s <= RCV_START;
				end if;
			end if;
		end if;
	end process;

end architecture;