## Generated SDC file "msx_mist.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Fri Dec 29 18:17:41 2023"

##
## DEVICE  "EP3C25E144C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

set sys_clk "pll_1|altpll_component|pll|clk[0]"

create_clock -name {clock_27m_i[0]} -period 37.037 -waveform { 0.000 18.518 } [get_ports {clock_27m_i[0]}]
create_clock -name {clocks:clks|clock_3m_en_s} -period 279.000 -waveform { 0.000 46.500 } [get_registers { clocks:clks|clock_3m_en_s }]
create_clock -name {spi_sck_i} -period 41.666 -waveform { 20.8 41.666 } [get_ports {spi_sck_i}]

set_clock_groups -asynchronous -group [get_clocks {spi_sck_i}] -group [get_clocks $sys_clk]

#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_1|altpll_component|pll|clk[0]} -source [get_pins {pll_1|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 19 -divide_by 24 -master_clock {clock_27m_i[0]} [get_pins {pll_1|altpll_component|pll|clk[0]}] 
create_generated_clock -name {pll_1|altpll_component|pll|clk[1]} -source [get_pins {pll_1|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 19 -divide_by 6 -master_clock {clock_27m_i[0]} [get_pins {pll_1|altpll_component|pll|clk[1]}] 
create_generated_clock -name {pll_1|altpll_component|pll|clk[2]} -source [get_pins {pll_1|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 19 -divide_by 6 -phase -45.000 -master_clock {clock_27m_i[0]} [get_pins {pll_1|altpll_component|pll|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {keyboard:keyb|por_o}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {keyboard:keyb|por_o}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_en_s}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[1]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {spi_sck_i}] -rise_to [get_clocks {spi_sck_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {spi_sck_i}] -fall_to [get_clocks {spi_sck_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {spi_sck_i}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {spi_sck_i}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {spi_sck_i}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {spi_sck_i}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {spi_sck_i}] -rise_to [get_clocks {spi_sck_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {spi_sck_i}] -fall_to [get_clocks {spi_sck_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {spi_sck_i}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {spi_sck_i}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {spi_sck_i}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {spi_sck_i}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {keyboard:keyb|por_o}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {keyboard:keyb|por_o}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {keyboard:keyb|por_o}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {keyboard:keyb|por_o}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {spi_sck_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {spi_sck_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {spi_sck_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {spi_sck_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {keyboard:keyb|por_o}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {keyboard:keyb|por_o}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {keyboard:keyb|por_o}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {keyboard:keyb|por_o}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_en_s}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_en_s}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {spi_sck_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {spi_sck_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {spi_sck_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {spi_sck_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -rise_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|pll|clk[0]}] -fall_to [get_clocks {pll_1|altpll_component|pll|clk[0]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

