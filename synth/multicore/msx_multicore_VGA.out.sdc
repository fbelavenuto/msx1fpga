## Generated SDC file "msx_multicore_VGA.out.sdc"

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

## DATE    "Tue Nov 22 21:27:47 2016"

##
## DEVICE  "EP4CE10E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock_50_i} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clock_50_i}]
create_clock -name {clocks:clks|clock_3m_s} -period 279.365 -waveform { 0.000 139.683 } [get_registers { clocks:clks|clock_3m_s }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_1|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll_1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 67 -divide_by 78 -master_clock {clock_50_i} [get_pins {pll_1|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_s}] -rise_to [get_clocks {clocks:clks|clock_3m_s}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_s}] -fall_to [get_clocks {clocks:clks|clock_3m_s}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_s}] -rise_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_s}] -rise_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_s}] -fall_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {clocks:clks|clock_3m_s}] -fall_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_s}] -rise_to [get_clocks {clocks:clks|clock_3m_s}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_s}] -fall_to [get_clocks {clocks:clks|clock_3m_s}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_s}] -rise_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_s}] -rise_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_s}] -fall_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {clocks:clks|clock_3m_s}] -fall_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_s}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_s}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_s}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_s}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_s}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {clocks:clks|clock_3m_s}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_s}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {clocks:clks|clock_3m_s}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  


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

