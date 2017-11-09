set_time_format -unit ns -decimal_places 3

create_clock -name ad9866_clk  	-period 73.728MHz	[get_ports ad9866_clk] 
create_clock -name ad9866_rxclk -period 73.728MHz	[get_ports ad9866_rxclk] 
create_clock -name ad9866_txclk -period 73.728MHz  [get_ports ad9866_txclk] 
create_clock -name clk_10mhz -period 10.000MHz [get_ports clk_10mhz] 
create_clock -name spi_sck -period 15.625MHz [get_ports spi_sck] 
create_clock -name spi_ce0 -period 0.400MHz [get_ports {spi_ce[0]}]
create_clock -name spi_ce1 -period 0.400MHz [get_ports {spi_ce[1]}]

create_clock -name {spi_slave:spi_slave_rx2_inst|done} -period 0.400MHz [get_registers {spi_slave:spi_slave_rx2_inst|done}]
create_clock -name {spi_slave:spi_slave_rx_inst|done} -period 0.400MHz [get_registers {spi_slave:spi_slave_rx_inst|done}]

create_clock -name virt_ad9866_clk -period 73.728MHz
create_clock -name virt_ad9866_rxclk -period 73.728MHz
#create_clock -name virt_ad9866_txclk -period 73.728MHz



derive_pll_clocks

derive_clock_uncertainty

set_clock_groups -asynchronous \
						-group {ad9866_clk ad9866_rxclk ad9866_txclk} \
						-group {	clk_10mhz } \
						-group {	spi_ce0 } \
						-group {	spi_ce1 } \
						-group {	spi_slave:spi_slave_rx_inst|done } \
						-group {	spi_slave:spi_slave_rx2_inst|done }
					
				
#*************************************************************************************************************
# set input delay
#*************************************************************************************************************
set_input_delay -add_delay -max -clock ad9866_clk 1.000 {ad9866_sdo spi_sck spi_mosi}
set_input_delay -add_delay -min -clock ad9866_clk -1.000 {ad9866_sdo spi_sck spi_mosi}

set_input_delay -add_delay -max -clock virt_ad9866_clk 10.000 [get_ports {ad9866_adio[*]}]
set_input_delay -add_delay -min -clock virt_ad9866_clk 0.500 [get_ports {ad9866_adio[*]}]



#*************************************************************************************************************
# set output delay
#*************************************************************************************************************
set_output_delay 1.000 -clock ad9866_clk {spi_miso rx1_FIFOEmpty rx2_FIFOEmpty txFIFOFull ad9866_rxclk ad9866_txclk ad9866_sclk ad9866_sdio}
set_output_delay  -add_delay -max -clock virt_ad9866_rxclk  5.000 {ad9866_adio[*]}
set_output_delay  -add_delay -min -clock virt_ad9866_rxclk  0.500 {ad9866_adio[*]}


set_max_delay -from spi_slave:spi_slave_rx2_inst|treg[*] -to spi_miso 15
set_max_delay -from spi_slave:spi_slave_rx_inst|treg[*]  -to spi_miso 15

set_max_delay -from transmitter:transmitter_inst|out_data[*]	-to ad9866_adio[*] 40

set_max_delay -from spi_ce[0]	-to spi_slave:spi_slave_rx_inst|treg[*] 3
set_max_delay -from spi_ce[1]	-to spi_slave:spi_slave_rx2_inst|treg[*] 3

set_max_delay -from spi_slave:spi_slave_rx2_inst|treg[*] -to spi_slave:spi_slave_rx2_inst|treg[*] 2

set_max_delay -from spi_mosi	-to spi_slave:spi_slave_rx_inst|rdata[0] 8
set_max_delay -from spi_mosi 	-to spi_slave:spi_slave_rx2_inst|rdata[0] 8
set_max_delay -from spi_mosi 	-to spi_slave:spi_slave_rx_inst|rreg[0] 8
set_max_delay -from spi_mosi 	-to spi_slave:spi_slave_rx2_inst|rreg[0] 8

set_max_delay -from ad9866_adio[*]	-to adcpipe[*][*] 14

set_max_delay -from rxFIFO:rxFIFO_inst|dcfifo:dcfifo_component|dcfifo_voj1:auto_generated|altsyncram_vi31:fifo_ram|q_b[*]	-to spi_slave:spi_slave_rx_inst|treg[*] 4
set_max_delay -from rxFIFO:rx2_FIFO_inst|dcfifo:dcfifo_component|dcfifo_voj1:auto_generated|altsyncram_vi31:fifo_ram|q_b[*]	-to spi_slave:spi_slave_rx2_inst|treg[*] 4
#*************************************************************************************************************
# Set False Path
#*************************************************************************************************************
# don't need fast paths to the LEDs and adhoc outputs so set false paths so Timing will be ignored
set_false_path -from * -to { DEBUG_LED* ptt_out filter[*]  ad9866_mode ad9866_pga[*] ad9866_rst_n ad9866_sen_n }

#don't need fast paths from the following inputs
set_false_path -from {ptt_in} -to *

set_false_path -from reset_handler:reset_handler_inst|reset -to *


