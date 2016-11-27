# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {XCorr Parameter}]
  set D_WIDTH [ipgui::add_param $IPINST -name "D_WIDTH" -parent ${Page_0}]
  set_property tooltip {Defines the input data width.} ${D_WIDTH}
  set D_SAMPLE_ADDR_WIDTH [ipgui::add_param $IPINST -name "D_SAMPLE_ADDR_WIDTH" -parent ${Page_0}]
  set_property tooltip {The width of the microphon RAM address bus. 2 to the power of D_SAMPLE_ADDR_WIDTH values will be stored.} ${D_SAMPLE_ADDR_WIDTH}
  set D_TAU_MAX [ipgui::add_param $IPINST -name "D_TAU_MAX" -parent ${Page_0}]
  set_property tooltip {Number of TAU to be calculated. Correlation ranges from -TAU/2 to TAU/2} ${D_TAU_MAX}


}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.D_SAMPLE_ADDR_WIDTH { PARAM_VALUE.D_SAMPLE_ADDR_WIDTH } {
	# Procedure called to update D_SAMPLE_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_SAMPLE_ADDR_WIDTH { PARAM_VALUE.D_SAMPLE_ADDR_WIDTH } {
	# Procedure called to validate D_SAMPLE_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.D_TAU_MAX { PARAM_VALUE.D_TAU_MAX } {
	# Procedure called to update D_TAU_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_TAU_MAX { PARAM_VALUE.D_TAU_MAX } {
	# Procedure called to validate D_TAU_MAX
	return true
}

proc update_PARAM_VALUE.D_WIDTH { PARAM_VALUE.D_WIDTH } {
	# Procedure called to update D_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.D_WIDTH { PARAM_VALUE.D_WIDTH } {
	# Procedure called to validate D_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_BASEADDR { PARAM_VALUE.C_S01_AXI_BASEADDR } {
	# Procedure called to update C_S01_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_BASEADDR { PARAM_VALUE.C_S01_AXI_BASEADDR } {
	# Procedure called to validate C_S01_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_HIGHADDR { PARAM_VALUE.C_S01_AXI_HIGHADDR } {
	# Procedure called to update C_S01_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_HIGHADDR { PARAM_VALUE.C_S01_AXI_HIGHADDR } {
	# Procedure called to validate C_S01_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.D_WIDTH { MODELPARAM_VALUE.D_WIDTH PARAM_VALUE.D_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_WIDTH}] ${MODELPARAM_VALUE.D_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.D_SAMPLE_ADDR_WIDTH { MODELPARAM_VALUE.D_SAMPLE_ADDR_WIDTH PARAM_VALUE.D_SAMPLE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_SAMPLE_ADDR_WIDTH}] ${MODELPARAM_VALUE.D_SAMPLE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.D_TAU_MAX { MODELPARAM_VALUE.D_TAU_MAX PARAM_VALUE.D_TAU_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.D_TAU_MAX}] ${MODELPARAM_VALUE.D_TAU_MAX}
}

