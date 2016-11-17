


create_clock -period 10.000 -name clk100M -waveform {0.000 5.000} -add [get_pins bd_i/clk_wiz_1/clk_out1]
create_generated_clock -name micClk -source [get_pins bd_i/clk_wiz_1/clk_out1] -divide_by 32 -add -master_clock clk100M [get_ports {micClk[0]}]
