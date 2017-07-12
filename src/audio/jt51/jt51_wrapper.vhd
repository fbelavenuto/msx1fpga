
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jt51_wrapper is
	port (
		clock_i			: in  std_logic;
		reset_i			: in  std_logic;
		addr_i			: in  std_logic;
		cs_n_i			: in  std_logic;
		wr_n_i			: in  std_logic;
		rd_n_i			: in  std_logic;
		data_i			: in  std_logic_vector( 7 downto 0);
		data_o			: out std_logic_vector( 7 downto 0);
		ct1_o				: out std_logic;
		ct2_o				: out std_logic;
		irq_n_o			: out std_logic;
		p1_o				: out std_logic;
		-- Low resolution output (same as real chip)
		sample_o			: out std_logic;
		left_o			: out signed(15 downto 0);
		right_o			: out signed(15 downto 0);
		-- Full resolution output
		xleft_o			: out signed(15 downto 0);
		xright_o			: out signed(15 downto 0);
		-- unsigned outputs for sigma delta converters, full resolution		
		dacleft_o		: out unsigned(15 downto 0);
		dacright_o		: out unsigned(15 downto 0)
	);
end entity;

architecture rtl of jt51_wrapper is

	component jt51 is
	port (
		clk			: in  std_logic;
		rst			: in  std_logic;
		a0				: in  std_logic;
		cs_n			: in  std_logic;
		wr_n			: in  std_logic;
		d_in			: in  std_logic_vector( 7 downto 0);
		d_out			: out std_logic_vector( 7 downto 0);
		ct1			: out std_logic;
		ct2			: out std_logic;
		irq_n			: out std_logic;
		p1				: out std_logic;
		-- Low resolution output (same as real chip)
		sample		: out std_logic;
		left			: out signed(15 downto 0);
		right			: out signed(15 downto 0);
		-- Full resolution output
		xleft			: out signed(15 downto 0);
		xright		: out signed(15 downto 0);
		-- unsigned outputs for sigma delta converters, full resolution		
		dacleft		: out unsigned(15 downto 0);
		dacright		: out unsigned(15 downto 0)
	);
	end component;

	signal jt51_data_from_s	: std_logic_vector( 7 downto 0);

begin

	jt51_inst : jt51
	port map (
		clk			=> clock_i,
		rst			=> reset_i,
		a0				=> addr_i,
		cs_n			=> cs_n_i,
		wr_n			=> wr_n_i,
		d_in			=> data_i,
		d_out			=> jt51_data_from_s,
		ct1			=> ct1_o,
		ct2			=> ct2_o,
		irq_n			=> irq_n_o,
		p1				=> p1_o,
		-- Low resolution output (same as real chip)
		sample		=> sample_o,
		left			=> left_o,
		right			=> right_o,
		-- Full resolution output
		xleft			=> xleft_o,
		xright		=> xright_o,
		-- unsigned outputs for sigma delta converters, full resolution		
		dacleft		=> dacleft_o,
		dacright		=> dacright_o
	);

	data_o	<= jt51_data_from_s when cs_n_i = '0' and rd_n_i = '0' and addr_i = '1'	else
					(others => '1');


end architecture;