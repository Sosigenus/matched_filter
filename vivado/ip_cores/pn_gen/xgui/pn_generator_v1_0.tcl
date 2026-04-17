# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "OS" -show_label false
  ipgui::add_param $IPINST -name "SEED_DEFAULT"

}

proc update_PARAM_VALUE.OS { PARAM_VALUE.OS } {
	# Procedure called to update OS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OS { PARAM_VALUE.OS } {
	# Procedure called to validate OS
	return true
}

proc update_PARAM_VALUE.SEED_DEFAULT { PARAM_VALUE.SEED_DEFAULT } {
	# Procedure called to update SEED_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SEED_DEFAULT { PARAM_VALUE.SEED_DEFAULT } {
	# Procedure called to validate SEED_DEFAULT
	return true
}

proc update_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to update S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to validate S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to update S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to validate S_AXI_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.OS { MODELPARAM_VALUE.OS PARAM_VALUE.OS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OS}] ${MODELPARAM_VALUE.OS}
}

proc update_MODELPARAM_VALUE.SEED_DEFAULT { MODELPARAM_VALUE.SEED_DEFAULT PARAM_VALUE.SEED_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SEED_DEFAULT}] ${MODELPARAM_VALUE.SEED_DEFAULT}
}

proc update_MODELPARAM_VALUE.S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.S_AXI_ADDR_WIDTH PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.S_AXI_DATA_WIDTH { MODELPARAM_VALUE.S_AXI_DATA_WIDTH PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.S_AXI_DATA_WIDTH}
}

