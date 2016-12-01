# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  set D_WIDTH [ipgui::add_param $IPINST -name "D_WIDTH" -parent ${Page_0}]
  set_property tooltip {The internal with of the filter. Defines the width of Integrator and comb stage as well as the decimation counter. Must be less or equal to C_S_AXI_DATA_WIDTH} ${D_WIDTH}
  set D_OUT_WIDTH [ipgui::add_param $IPINST -name "D_OUT_WIDTH" -parent ${Page_0}]
  set_property tooltip {Defines the width of output data. Internal values are truncated if output width is less than internal width.} ${D_OUT_WIDTH}
  set DIVIDE [ipgui::add_param $IPINST -name "DIVIDE" -parent ${Page_0}]
  set_property tooltip {Divide axi clk by this rate to generate bitstream clock} ${DIVIDE}


}

proc update_PARAM_VALUE.DIVIDE { PARAM_VALUE.DIVIDE } {
	# Procedure called to update DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIVIDE { PARAM_VALUE.DIVIDE } {
	# Procedure called to validate DIVIDE
	return true
}

proc update_PARAM_VALUE.D_OUT_WIDTH { PARAM_VALUE.D_OUT_WIDTH } {
	# Procedure called to update D_OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_OUT_WIDTH { PARAM_VALUE.D_OUT_WIDTH } {
	# Procedure called to validate D_OUT_WIDTH
	return true
}

proc update_PARAM_VALUE.D_WIDTH { PARAM_VALUE.D_WIDTH } {
	# Procedure called to update D_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_WIDTH { PARAM_VALUE.D_WIDTH } {
	# Procedure called to validate D_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.D_WIDTH { MODELPARAM_VALUE.D_WIDTH PARAM_VALUE.D_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_WIDTH}] ${MODELPARAM_VALUE.D_WIDTH}
}

proc update_MODELPARAM_VALUE.D_OUT_WIDTH { MODELPARAM_VALUE.D_OUT_WIDTH PARAM_VALUE.D_OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_OUT_WIDTH}] ${MODELPARAM_VALUE.D_OUT_WIDTH}
}

proc update_MODELPARAM_VALUE.DIVIDE { MODELPARAM_VALUE.DIVIDE PARAM_VALUE.DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DIVIDE}] ${MODELPARAM_VALUE.DIVIDE}
}

