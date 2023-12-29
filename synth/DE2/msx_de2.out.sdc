## Generated SDC file "msx_de2.out.sdc"

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

## DATE    "Fri Dec 22 21:22:00 2023"

##
## DEVICE  "EP2C35F672C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk50_i} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk50_i}]
create_clock -name {clk27_i} -period 37.037 -waveform { 0.000 18.518 } [get_ports {clk27_i}]
create_clock -name {clocks:clks|clock_3m_en_s} -period 279.000 -waveform { 0.000 46.500 } [get_registers { clocks:clks|clock_3m_en_s }]
create_clock -name {clocks:clks|clock_7m_en_s} -period 139.000 -waveform { 0.000 46.500 } [get_registers { clocks:clks|clock_7m_en_s }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll_1|altpll_component|pll|clk[0]} -source [get_pins {pll_1|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -divide_by 7 -master_clock {clk50_i} [get_pins {pll_1|altpll_component|pll|clk[0]}] 
create_generated_clock -name {pll_1|altpll_component|pll|clk[1]} -source [get_pins {pll_1|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 12 -divide_by 7 -master_clock {clk50_i} [get_pins {pll_1|altpll_component|pll|clk[1]}] 
create_generated_clock -name {pll_1|altpll_component|pll|clk[2]} -source [get_pins {pll_1|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 12 -divide_by 7 -phase -45.000 -master_clock {clk50_i} [get_pins {pll_1|altpll_component|pll|clk[2]}] 
create_generated_clock -name {pll_2|altpll_component|pll|clk[0]} -source [get_pins {pll_2|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 8 -divide_by 9 -master_clock {clk27_i} [get_pins {pll_2|altpll_component|pll|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



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

