
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.XOR_REDUCE;

entity ps2_send is
	port (
		clock_i			: in    std_logic;
		reset_i			: in    std_logic;
		--
		ps2_clock_io	: inout std_logic;
		ps2_data_io		: inout std_logic;
		--
		data_i			: in    std_logic_vector(7 downto 0);
		data_load_i		: in    std_logic;
		ps2_error_o		: out   std_logic;
		ps2_busy_o		: out   std_logic;
		D_timeout_q		: out unsigned(15 downto 0)
	);
end entity;

architecture Behavior of ps2_send is

	signal clk_syn_s		: std_logic;
	signal clk_nedge_s	: std_logic;
	signal timeout_q		: unsigned(15 downto 0)	:= (others => '0');
	signal cnt_bits_s		: unsigned(2 downto 0);
	signal shift_s			: std_logic_vector(7 downto 0);
	signal d_to_send_s	: std_logic_vector(7 downto 0);
	signal parity_s		: std_logic;

	type send_states_t is (PULL_CLK_LOW, PULL_DATA_LOW, SEND_DATA, SEND_PARITY, RCV_ACK, RCV_IDLE, SEND_FINISH);
	signal send_state_s	: send_states_t							:= SEND_FINISH;

	signal busy_s			: std_logic;

begin

	-- Synchronizing signals
	process (reset_i, clock_i)
		variable clk_sync_v : std_logic_vector(1 downto 0);
	begin
		if reset_i = '1' then
			clk_sync_v := "00";
		elsif rising_edge(clock_i) then
			clk_sync_v := clk_sync_v(0) & ps2_clock_io;
		end if;
		clk_syn_s <= clk_sync_v(1);
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

		if edge_detect_v = X"F000" then
			clk_nedge_s <= '1';
		end if;

	end process;

	-- State machine
	process (reset_i, clock_i)
	begin
		if reset_i = '1' then
			timeout_q		<= (others => '0');
			shift_s			<= (others => '0');
			d_to_send_s		<= (others => '0');
			cnt_bits_s		<= (others => '0');
			send_state_s	<= SEND_FINISH;
			ps2_error_o		<= '0';

		elsif rising_edge(clock_i) then

			case send_state_s is

				when PULL_CLK_LOW =>
					if timeout_q >= 40000 then
						send_state_s	<= PULL_DATA_LOW;
						shift_s			<= d_to_send_s;
						cnt_bits_s		<= (others => '0');
						timeout_q		<= (others => '0');
						parity_s			<= not (XOR_REDUCE(d_to_send_s));
					end if;

				when PULL_DATA_LOW =>
					if clk_nedge_s = '1' then
						send_state_s	<= SEND_DATA;
						timeout_q		<= (others => '0');
					end if;

				when SEND_DATA =>
					if clk_nedge_s = '1' then
						timeout_q		<= (others => '0');
						shift_s			<= '0' & shift_s(7 downto 1);
						cnt_bits_s		<= cnt_bits_s + 1;
						if cnt_bits_s = 7 then
							send_state_s <= SEND_PARITY;
						end if;
					end if;

				when SEND_PARITY =>
					if clk_nedge_s = '1' then
						send_state_s	<= RCV_IDLE;
						timeout_q		<= (others => '0');
					end if;

				when RCV_IDLE =>
					if clk_nedge_s = '1' then
						send_state_s	<= RCV_ACK;
						timeout_q		<= (others => '0');
					end if;

				when RCV_ACK =>
					if clk_nedge_s = '1' then
						send_state_s	<= SEND_FINISH;
						timeout_q		<= (others => '0');
					end if;

				when SEND_FINISH =>
					busy_s		<= '0';
					timeout_q	<= (others => '0');

			end case;

			if data_load_i = '1' then
				d_to_send_s		<= data_i;
				busy_s			<= '1';
				timeout_q		<= (others => '0');
				send_state_s	<= PULL_CLK_LOW;
			end if;

			if clk_nedge_s = '0' then
				timeout_q <= timeout_q + 1;
				if timeout_q = X"FFFF" and send_state_s /= SEND_FINISH then
					ps2_error_o <= '1';
					send_state_s <= SEND_FINISH;
				end if;
			end if;

		end if;
	end process;

	ps2_busy_o <= busy_s;
	ps2_data_io		<= '0'	when send_state_s = PULL_CLK_LOW or send_state_s = PULL_DATA_LOW		else
							'0'	when send_state_s = SEND_DATA and shift_s(0) = '0'							else
							'0'	when send_state_s = SEND_PARITY and parity_s = '0'							else
							'Z';

	ps2_clock_io	<= '0'	when send_state_s = PULL_CLK_LOW													else
							'Z';

	--
	D_timeout_q <= timeout_q;

end architecture;