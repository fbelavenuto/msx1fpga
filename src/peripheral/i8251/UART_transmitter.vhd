
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity UART_Transmitter is
	port (
		reset_n_i	: in  std_logic;
		clock_i		: in  std_logic;
		baudclk_i	: in  std_logic;
		data_i		: in  std_logic_vector(7 downto 0);
		char_len_i	: in  std_logic_vector(1 downto 0);
		stop_bits_i	: in  std_logic_vector(1 downto 0);
		txd_empty_i	: in  std_logic;
		loadTxD_i	: in  std_logic;
		tx_ready_o	: out std_logic;
		setTxE_o		: out std_logic;
		txd_o			: out std_logic
	);
end UART_Transmitter;

architecture xmit of UART_Transmitter is

	type state_t is (IDLE, SYNCH, TDATA);
	signal state_s			: state_t;
	signal nextstate_s	: state_t;
	signal tsr_q			: std_logic_vector(8 downto 0); -- Transmit Shift Register
	signal tdr_q			: std_logic_vector(7 downto 0); -- Transmit Data Register
	signal bitcount_q		: integer range 0 to 9; -- counts number of bits sent
	signal bitmax_s		: unsigned(3 downto 0);
	signal inc_s			: std_logic;
	signal clr_s			: std_logic;
	signal loadTSR			: std_logic;
	signal shftTSR			: std_logic;
	signal start_s			: std_logic;
	signal Bclk_rising	: std_logic;
	signal Bclk_dlayed	: std_logic;

begin

	txd_o <= tsr_q(0);
	setTxE_o <= loadTSR;
	Bclk_rising <= baudclk_i and (not Bclk_dlayed); -- indicates the rising edge of bit clock
	tx_ready_o	<= '1'	when state_s /= IDLE	else '0';

	bitmax_s <= to_unsigned(5, 4) + unsigned(char_len_i) + unsigned(stop_bits_i);

	Xmit_Control: process(state_s, txd_empty_i, bitcount_q, Bclk_rising, bitmax_s)
	begin
		inc_s			<= '0';
		clr_s			<= '0';
		loadTSR		<= '0';
		shftTSR		<= '0';
		start_s		<= '0';
		-- reset control signals
		case state_s is
			when IDLE =>
				if txd_empty_i = '0' then
					loadTSR <= '1';
					nextstate_s <= SYNCH;
				else
					nextstate_s <= IDLE;
				end if;

		when SYNCH =>								-- synchronize with the bit clock
			if (Bclk_rising = '1') then
				start_s		<= '1';
				nextstate_s <= TDATA;
			else
				nextstate_s <= SYNCH;
			end if;

		when TDATA =>
			if Bclk_rising = '0' then
				nextstate_s <= TDATA;
			elsif bitcount_q /= bitmax_s then
				shftTSR		<= '1';
				inc_s			<= '1';
				nextstate_s	<= TDATA;
			else
				clr_s			<= '1';
				nextstate_s	<= IDLE;
			end if;
		end case;
	end process;

	Xmit_update: process (reset_n_i, clock_i)
	begin
		if reset_n_i = '0' then
			tsr_q			<= (others => '1');
			state_s		<= IDLE;
			bitcount_q	<= 0;
			Bclk_dlayed	<= '0';
		elsif rising_edge(clock_i) then
			state_s <= nextstate_s;
			
			if clr_s = '1' then
				bitcount_q <= 0;
			elsif inc_s = '1' then
				bitcount_q <= bitcount_q + 1;
			end if;
			
			if loadTxD_i = '1' then
				tdr_q <= data_i;
			end if;
			
			if loadTSR = '1' then
				tsr_q <= tdr_q & '1';
			end if;
			
			if start_s = '1' then
				tsr_q(0) <= '0';
			end if;
			
			if shftTSR = '1' then
				tsr_q <= '1' & tsr_q(8 downto 1);
			end if; -- shift out one bit
			
			Bclk_dlayed <= baudclk_i;		-- Bclk delayed by 1 sysclk

		end if;
	end process;

end architecture;