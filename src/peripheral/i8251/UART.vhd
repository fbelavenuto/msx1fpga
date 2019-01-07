
library ieee;
use ieee.std_logic_1164.all;

entity UART is
	port (
		clock_sys_i	: in    std_logic;
		clock_i		: in    std_logic;
		reset_n_i	: in    std_logic;
		addr_i		: in    std_logic;
		data_io		: inout std_logic_vector(7 downto 0);
		cs_n_i		: in    std_logic;
		rd_n_i		: in    std_logic;
		wr_n_i		: in    std_logic;
		rxd_i			: in    std_logic;
		txd_o			: out   std_logic;
		dsr_n_i		: in    std_logic;
		cts_n_i		: in    std_logic;
		rts_n_o		: out   std_logic;
		dtr_n_o		: out   std_logic
	);
end entity;

architecture uart1 of UART is

	signal baudclk_s		: std_logic;

	signal isread_s		: std_logic;
	signal iswrite_s		: std_logic;
	signal load_s			: std_logic;
	signal modectrl_q		: std_logic;
	signal load_mode_s	: std_logic;
	signal load_ctrl_s	: std_logic;

	signal txd_ready_s	: std_logic;
	signal txd_empty_s	: std_logic;
	signal loadTxD_s		: std_logic;
	signal setTxE_s		: std_logic;

	signal rx_data_q		: std_logic_vector(7 downto 0); -- Receive Data Register
	signal RxReady_s		: std_logic;
	signal setRxR_s		: std_logic;
	signal clrRxR_s		: std_logic;
	signal setOE_s			: std_logic;
	signal setFE_s			: std_logic;
	signal setPE_s			: std_logic;

	signal status_s		: std_logic_vector(7 downto 0);	-- Status Register
	signal overrun_err_q	: std_logic;
	signal frame_err_q	: std_logic;
	signal parity_err_q	: std_logic;
	signal softreset_q	: std_logic;
	signal err_reset_q	: std_logic;
	signal tx_en_q			: std_logic;
	signal rx_en_q			: std_logic;
	signal rts_q			: std_logic;
	signal dtr_q			: std_logic;
	signal baud_sel_q		: std_logic_vector(1 downto 0);
	signal char_len_q		: std_logic_vector(1 downto 0);
	signal parity_q		: std_logic_vector(1 downto 0);
	signal stop_bits_q	: std_logic_vector(1 downto 0);

begin

	RCVR: entity work.UART_Receiver
	port map (
		reset_n_i	=> reset_n_i,
		clock_i		=> clock_sys_i,
		baudclk_i	=> baudclk_s,
		rxd_i			=> rxd_i,
		enable_i		=> rx_en_q,
		RDRF			=> RxReady_s,
		RDR			=> rx_data_q,
		setRDRF		=> setRxR_s,
		setPE			=> setPE_s,
		setOE			=> setOE_s,
		setFE			=> setFE_s
	);

	XMIT: entity work.UART_Transmitter 
	port map (
		reset_n_i	=> reset_n_i,
		clock_i		=> clock_sys_i,
		baudclk_i	=> baudclk_s,
		char_len_i	=> char_len_q,
		stop_bits_i	=> stop_bits_q,
		data_i		=> data_io,
		txd_empty_i	=> txd_empty_s,
		loadTxD_i	=> loadTxD_s,
		tx_ready_o	=> txd_ready_s,
		setTxE_o		=> setTxE_s,
		txd_o			=> txd_o
	);

	CLKDIV: entity work.clk_divider
	port map (
		clock_i		=> clock_i,
		reset_n_i	=> reset_n_i,
		baudsel_i	=> baud_sel_q,
		baudclk_o	=> baudclk_s
	);

	-- Bus Interface
	isread_s		<= '1'	when cs_n_i = '0' and rd_n_i = '0'	else '0';
	iswrite_s	<= '1'	when cs_n_i = '0' and wr_n_i = '0'	else '0';

	clrRxR_s		<= '1' when isread_s  = '1' and addr_i = '0'									else '0';
	
	loadTxD_s	<= '1' when 
								iswrite_s = '1' and addr_i = '0' and 
								cts_n_i = '0' and tx_en_q = '1'										else '0';

	load_s		<= '1' when iswrite_s = '1' and addr_i = '1' 								else '0';
	load_mode_s	<= '1' when iswrite_s = '1' and addr_i = '1' and modectrl_q = '0'		else '0';
	load_ctrl_s	<= '1' when iswrite_s = '1' and addr_i = '1' and modectrl_q = '1'		else '0';


	-- This process updates the control and status registers
	process (clock_sys_i)
		variable	edge_v	: std_logic_vector(1 downto 0);
	begin
		if rising_edge(clock_sys_i) then

			edge_v	:= edge_v(0) & load_s;

			softreset_q	<= '0';
			err_reset_q	<= '0';

			if reset_n_i = '0' or softreset_q = '1' then
				txd_empty_s		<= '1';
				RxReady_s		<= '0';
				overrun_err_q	<= '0';
				frame_err_q		<= '0';
				parity_err_q	<= '0';
				tx_en_q			<= '0';
				rx_en_q			<= '0';
				rts_q				<= '0';
				dtr_q				<= '0';
				stop_bits_q		<= "01";
				parity_q			<= "00";
				char_len_q		<= "11";
				baud_sel_q		<= "10";
				modectrl_q		<= '0';
			else
				txd_empty_s		<= (setTxE_s and not txd_empty_s)   or (not loadTxD_s   and txd_empty_s);
				RxReady_s		<= (setRxR_s and not RxReady_s)     or (not clrRxR_s    and RxReady_s);
				overrun_err_q	<= (setOE_s  and not overrun_err_q) or (not err_reset_q and overrun_err_q);
				frame_err_q		<= (setFE_s  and not frame_err_q)   or (not err_reset_q and frame_err_q);
				parity_err_q	<= (setPE_s  and not parity_err_q)  or (not err_reset_q and parity_err_q);
				if edge_v = "01" then
					if load_mode_s = '1' then
						stop_bits_q	<= data_io(7 downto 6);
						parity_q		<= data_io(5 downto 4);
						char_len_q	<= data_io(3 downto 2);
						baud_sel_q	<= data_io(1 downto 0);
						modectrl_q	<= '1';
					elsif load_ctrl_s = '1' then
						-- Enter Hunt Mode <= data_io(7);
						softreset_q	<= data_io(6);
						rts_q			<= data_io(5);
						err_reset_q	<= data_io(4);
						--Send Break Character	<= data_io(3);
						rx_en_q		<= data_io(2);
						dtr_q			<= data_io(1);
						tx_en_q		<= data_io(0);
					end if;
				end if;
			end if;
		end if;
	end process;

	--
	rts_n_o	<= rts_q;
	dtr_n_o	<= dtr_q;

	status_s	<= dsr_n_i & "0" & frame_err_q & overrun_err_q & parity_err_q & txd_empty_s & RxReady_s & txd_ready_s;

	data_io	<= (others => 'Z')	when isread_s = '0'	else		-- tristate bus when not reading
					rx_data_q			when addr_i = '0'		else
					status_s				when addr_i = '1';

end architecture;