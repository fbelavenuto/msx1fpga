
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	port (
		clocksys_i	: in    std_logic;
		reset_n_i	: in    std_logic;
		addr_i		: in    std_logic_vector(1 downto 0);
		data_io		: inout std_logic_vector(7 downto 0);
		read_i		: in    std_logic;
		writec_i		: in    std_logic;
		writer_i		: in    std_logic;
		clock_i		: in    std_logic;
		gate_i		: in    std_logic;
		out_o			: out   std_logic
	);
end entity;

architecture Behavior of counter is

	signal cnt_mode_q		: std_logic_vector( 2 downto 0);
	signal cnt_rw_q		: std_logic_vector( 1 downto 0);
	signal cnt_lmr_q		: std_logic;
	signal cnt_lmw_q		: std_logic;
	signal cnt_read_q		: std_logic;
	signal cnt_latched_q	: std_logic;
	signal cnt_initial_q	: std_logic_vector(15 downto 0);
	signal cnt_value_q	: unsigned(15 downto 0);
	signal cnt_latch_q	: std_logic_vector(15 downto 0);
	signal cnt_out_q		: std_logic;
	signal loaded_q		: boolean;
	signal bitnum_s		: integer range 1 to 3;

begin

	with addr_i select bitnum_s <=
		1	when "00",
		2	when "01",
		3	when others;

	-- Read process
	reading: process (read_i, cnt_latched_q, cnt_read_q, cnt_value_q, cnt_latch_q, cnt_lmr_q, cnt_rw_q, cnt_mode_q)
		variable value_v	: std_logic_vector(15 downto 0);
	begin
		data_io	<= (others => 'Z');
		if read_i = '1' then
			if    cnt_read_q = '0' and cnt_latched_q = '0' then
				value_v := std_logic_vector(cnt_value_q);
			elsif cnt_read_q = '0' and cnt_latched_q = '1' then
				value_v := cnt_latch_q;
			else
				value_v := cnt_out_q & '0' & cnt_rw_q & cnt_mode_q & '0' & cnt_out_q & '0' & cnt_rw_q & cnt_mode_q & '0';	-- No Null and BCD implemented
			end if;
			if    cnt_rw_q = "01" or (cnt_lmr_q = '0' and cnt_rw_q = "11") then
				data_io	<= value_v( 7 downto 0);
			elsif cnt_rw_q = "10" or (cnt_lmr_q = '1' and cnt_rw_q = "11") then
				data_io	<= value_v(15 downto 8);
			end if;
		end if;
	end process;

	-- Write control register
	writing: process (reset_n_i, clocksys_i)
		variable edge_w_v	: std_logic_vector(1 downto 0);
		variable edge_r_v	: std_logic_vector(1 downto 0);
		variable regnum_v	: std_logic_vector(1 downto 0);
		variable r_w_v		: std_logic_vector(1 downto 0);
	begin
		if reset_n_i = '0' then
			edge_w_v			:= (others => '0');
			edge_r_v			:= (others => '0');
			cnt_mode_q		<= (others => '0');
			cnt_latch_q		<= (others => '0');
			cnt_rw_q			<= (others => '0');
			cnt_read_q		<= '0';
			cnt_lmr_q		<= '0';
		elsif rising_edge(clocksys_i) then
			edge_w_v := edge_w_v(0) & writer_i;
			edge_r_v := edge_r_v(0) & read_i;

			if edge_r_v = "10" then
				if cnt_rw_q = "11" then
					cnt_lmr_q <= not cnt_lmr_q;
				end if;
				cnt_latched_q	<= '0';
			end if;

			if edge_w_v = "01" then
				regnum_v	:= data_io(7 downto 6);
				r_w_v		:= data_io(5 downto 4);

				if r_w_v = "00" and regnum_v = addr_i then	-- Counter Latch
					cnt_latch_q	<= std_logic_vector(cnt_value_q);
					cnt_latched_q	<= '1';
				else
					if regnum_v = addr_i then
						cnt_rw_q			<= r_w_v;
						cnt_mode_q		<= data_io(3 downto 1);
						cnt_latched_q	<= '0';
					elsif regnum_v = "11" then
						cnt_read_q <= data_io(bitnum_s);
					else
						null;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Counter and write counter value
	cnt: process (reset_n_i, clocksys_i)
		variable edge_w_v	: std_logic_vector(1 downto 0);
		variable edge_c_v	: std_logic_vector(1 downto 0);
	begin
		if reset_n_i = '0' then
			edge_w_v			:= (others => '0');
			edge_c_v			:= (others => '0');
			cnt_initial_q	<= (others => '0');
			cnt_value_q	<= (others => '0');
			cnt_out_q		<= '1';
			cnt_lmw_q		<= '0';
			loaded_q			<= false;
		elsif rising_edge(clocksys_i) then
			edge_w_v := edge_w_v(0) & writec_i;
			edge_c_v := edge_c_v(0) & clock_i;

			-- 
			if edge_w_v = "01" then
				if    cnt_rw_q = "01" then
					cnt_initial_q( 7 downto 0)	<= data_io;
					cnt_lmw_q <= '0';
					loaded_q <= true;
				elsif cnt_rw_q = "10" then
					cnt_initial_q(15 downto 8)	<= data_io;
					cnt_lmw_q <= '0';
					loaded_q <= true;
				elsif cnt_rw_q = "11" and cnt_lmw_q = '0' then
					cnt_initial_q( 7 downto 0)	<= data_io;
					cnt_lmw_q <= '1';
				elsif cnt_rw_q = "11" and cnt_lmw_q = '1' then
					cnt_initial_q(15 downto 8)	<= data_io;
					cnt_lmw_q <= '0';
					loaded_q <= true;
				else
					null;
				end if;
				if loaded_q = true then
					if    cnt_mode_q = "000" then		-- Mode 0
						cnt_out_q <= '0';
					elsif cnt_mode_q(1) = '1' then		-- Mode 2 and 3
						cnt_out_q <= '1';
					else
						null;
					end if;
				end if;
			end if;

			-- Counter Clock Rising
			if edge_c_v = "01" then
				if gate_i = '1' then
					if    cnt_mode_q = "000" then					-- Mode 0
					elsif cnt_mode_q(1 downto 0) = "10" then	-- Mode 2
						if loaded_q = true then
							cnt_value_q <= unsigned(cnt_initial_q);
							loaded_q <= false;
						else
							cnt_value_q <= cnt_value_q - 1;
						end if;
						if cnt_value_q = 1 then
							cnt_out_q <= '0';
							loaded_q <= true;
						else
							cnt_out_q <= '1';
						end if;
					elsif cnt_mode_q(1 downto 0) = "11" then	-- Mode 3
						if loaded_q = true then
							cnt_value_q <= unsigned(cnt_initial_q);
							loaded_q <= false;
						else
							cnt_value_q <= cnt_value_q - 1;
						end if;
						if cnt_value_q = 1 then
							cnt_out_q <= not cnt_out_q;
							loaded_q <= true;
						end if;
					end if;

				end if;
			end if;
		end if;
	end process;

	out_o <= cnt_out_q;

end architecture;