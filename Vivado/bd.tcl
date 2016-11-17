
################################################################
# This is a generated script based on design: bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# clk_div

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35ticsg324-1L
   set_property BOARD_PART digilentinc.com:arty:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 lmb_bram ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set usb_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 usb_uart ]

  # Create ports
  set btn [ create_bd_port -dir I -from 3 -to 0 btn ]
  set led [ create_bd_port -dir O -from 3 -to 0 led ]
  set mic1 [ create_bd_port -dir I mic1 ]
  set mic2 [ create_bd_port -dir I mic2 ]
  set mic3 [ create_bd_port -dir I mic3 ]
  set micClk [ create_bd_port -dir O -from 0 -to 0 micClk ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset
  set rgbled [ create_bd_port -dir O -from 11 -to 0 rgbled ]
  set shClk [ create_bd_port -dir O shClk ]
  set shData [ create_bd_port -dir O shData ]
  set shRstn [ create_bd_port -dir O shRstn ]
  set shStr [ create_bd_port -dir O shStr ]
  set sw [ create_bd_port -dir I -from 3 -to 0 sw ]
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {100000000} \
CONFIG.PHASE {0.000} \
 ] $sys_clock

  # Create instance: AXI_SH_595, and set properties
  set AXI_SH_595 [ create_bd_cell -type ip -vlnv Xilinx.com:user:AXI_SH_595:1.0 AXI_SH_595 ]
  set_property -dict [ list \
CONFIG.C_SH_DATA_WIDTH {16} \
CONFIG.C_USE_OE_N {false} \
 ] $AXI_SH_595

  # Create instance: ArtyIO, and set properties
  set ArtyIO [ create_bd_cell -type ip -vlnv xilinx.com:user:ArtyIO:1.0 ArtyIO ]

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]
  set_property -dict [ list \
CONFIG.enable_timer2 {0} \
CONFIG.mode_64bit {0} \
 ] $axi_timer_0

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
CONFIG.C_BAUDRATE {921600} \
CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
CONFIG.UARTLITE_BOARD_INTERFACE {usb_uart} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.C_S_AXI_ACLK_FREQ_HZ.VALUE_SRC {DEFAULT} \
 ] $axi_uartlite_0

  # Create instance: clk_div_0, and set properties
  set block_name clk_div
  set block_cell_name clk_div_0
  if { [catch {set clk_div_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $clk_div_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
CONFIG.DIVIDE {32} \
 ] $clk_div_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clk_wiz_1 ]
  set_property -dict [ list \
CONFIG.CLKOUT1_JITTER {130.958} \
CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
CONFIG.CLK_IN2_BOARD_INTERFACE {Custom} \
CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
CONFIG.MMCM_CLKIN1_PERIOD {10.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.RESET_BOARD_INTERFACE {reset} \
CONFIG.RESET_PORT {resetn} \
CONFIG.RESET_TYPE {ACTIVE_LOW} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_1

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.CLKOUT1_JITTER.VALUE_SRC {DEFAULT} \
CONFIG.CLKOUT1_PHASE_ERROR.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKFBOUT_MULT_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN1_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN2_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_COMPENSATION.VALUE_SRC {DEFAULT} \
 ] $clk_wiz_1

  # Create instance: intc, and set properties
  set intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 intc ]
  set_property -dict [ list \
CONFIG.C_HAS_FAST {1} \
 ] $intc

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: mic1, and set properties
  set mic1 [ create_bd_cell -type ip -vlnv xilinx.com:user:SDM_Dezimator:1.0 mic1 ]

  # Create instance: mic2, and set properties
  set mic2 [ create_bd_cell -type ip -vlnv xilinx.com:user:SDM_Dezimator:1.0 mic2 ]

  # Create instance: mic3, and set properties
  set mic3 [ create_bd_cell -type ip -vlnv xilinx.com:user:SDM_Dezimator:1.0 mic3 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.6 microblaze_0 ]
  set_property -dict [ list \
CONFIG.C_BRANCH_TARGET_CACHE_SIZE {0} \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_DEBUG_TRACE_SIZE {0} \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {1} \
CONFIG.C_I_LMB {1} \
CONFIG.C_USE_BARREL {1} \
CONFIG.C_USE_BRANCH_TARGET_CACHE {0} \
CONFIG.C_USE_DIV {1} \
CONFIG.C_USE_EXTENDED_FSL_INSTR {0} \
CONFIG.C_USE_FPU {2} \
CONFIG.C_USE_HW_MUL {1} \
CONFIG.C_USE_MSR_INSTR {1} \
CONFIG.C_USE_PCMP_INSTR {1} \
CONFIG.C_USE_REORDER_INSTR {0} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {8} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: microblaze_0_xlconcat, and set properties
  set microblaze_0_xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 microblaze_0_xlconcat ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {6} \
 ] $microblaze_0_xlconcat

  # Create instance: rst, and set properties
  set rst [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst ]
  set_property -dict [ list \
CONFIG.RESET_BOARD_INTERFACE {reset} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $rst

  # Create interface connections
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports usb_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins ArtyIO/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins AXI_SH_595/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins mic1/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins mic2/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins mic3/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins intc/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins intc/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]

  # Create port connections
  connect_bd_net -net AXI_SH_595_0_shClk [get_bd_ports shClk] [get_bd_pins AXI_SH_595/shClk]
  connect_bd_net -net AXI_SH_595_0_shData [get_bd_ports shData] [get_bd_pins AXI_SH_595/shData]
  connect_bd_net -net AXI_SH_595_0_shRstn [get_bd_ports shRstn] [get_bd_pins AXI_SH_595/shRstn]
  connect_bd_net -net AXI_SH_595_0_shStr [get_bd_ports shStr] [get_bd_pins AXI_SH_595/shStr]
  connect_bd_net -net ArtyIO_0_irq [get_bd_pins ArtyIO/irq] [get_bd_pins microblaze_0_xlconcat/In0]
  connect_bd_net -net ArtyIO_0_led [get_bd_ports led] [get_bd_pins ArtyIO/led]
  connect_bd_net -net ArtyIO_0_rgbled [get_bd_ports rgbled] [get_bd_pins ArtyIO/rgbled]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In2]
  connect_bd_net -net axi_uartlite_0_interrupt [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In1]
  connect_bd_net -net btn_1 [get_bd_ports btn] [get_bd_pins ArtyIO/btn]
  connect_bd_net -net clk100M [get_bd_pins AXI_SH_595/s_axi_aclk] [get_bd_pins ArtyIO/s00_axi_aclk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_div_0/clk_in] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins intc/processor_clk] [get_bd_pins intc/s_axi_aclk] [get_bd_pins mic1/s_axi_aclk] [get_bd_pins mic2/s_axi_aclk] [get_bd_pins mic3/s_axi_aclk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins rst/slowest_sync_clk]
  connect_bd_net -net clk_div_0_ce_out [get_bd_pins clk_div_0/ce_out] [get_bd_pins mic1/clk_ena] [get_bd_pins mic2/clk_ena] [get_bd_pins mic3/clk_ena]
  connect_bd_net -net clk_div_0_clk_out [get_bd_ports micClk] [get_bd_pins clk_div_0/clk_out]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins clk_wiz_1/locked] [get_bd_pins rst/dcm_locked]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst/mb_debug_sys_rst]
  connect_bd_net -net mic1_1 [get_bd_ports mic1] [get_bd_pins mic1/bit_stream]
  connect_bd_net -net mic1_irq_new_val [get_bd_pins mic1/irq_new_val] [get_bd_pins microblaze_0_xlconcat/In3]
  connect_bd_net -net mic2_1 [get_bd_ports mic2] [get_bd_pins mic2/bit_stream]
  connect_bd_net -net mic2_irq_new_val [get_bd_pins mic2/irq_new_val] [get_bd_pins microblaze_0_xlconcat/In4]
  connect_bd_net -net mic3_1 [get_bd_ports mic3] [get_bd_pins mic3/bit_stream]
  connect_bd_net -net mic3_irq_new_val [get_bd_pins mic3/irq_new_val] [get_bd_pins microblaze_0_xlconcat/In5]
  connect_bd_net -net microblaze_0_intr [get_bd_pins intc/intr] [get_bd_pins microblaze_0_xlconcat/dout]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins clk_wiz_1/resetn] [get_bd_pins rst/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins intc/processor_rst] [get_bd_pins microblaze_0/Reset] [get_bd_pins rst/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins AXI_SH_595/s_axi_aresetn] [get_bd_pins ArtyIO/s00_axi_aresetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins clk_div_0/rst_n] [get_bd_pins intc/s_axi_aresetn] [get_bd_pins mic1/s_axi_aresetn] [get_bd_pins mic2/s_axi_aresetn] [get_bd_pins mic3/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst/peripheral_aresetn]
  connect_bd_net -net sw_1 [get_bd_ports sw] [get_bd_pins ArtyIO/sw]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_1/clk_in1]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs AXI_SH_595/S_AXI/S_AXI_reg] SEG_AXI_SH_595_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs ArtyIO/S00_AXI/S00_AXI_reg] SEG_ArtyIO_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mic1/S_AXI/S_AXI_reg] SEG_mic1_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A30000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mic2/S_AXI/S_AXI_reg] SEG_mic2_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A40000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mic3/S_AXI/S_AXI_reg] SEG_mic3_S_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs intc/S_AXI/Reg] SEG_microblaze_0_axi_intc_Reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.12  2016-01-29 bk=1.3547 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port shStr -pg 1 -y 930 -defaultsOSRD
preplace port shData -pg 1 -y 970 -defaultsOSRD
preplace port shRstn -pg 1 -y 990 -defaultsOSRD
preplace port mic1 -pg 1 -y 40 -defaultsOSRD
preplace port mic2 -pg 1 -y 20 -defaultsOSRD
preplace port sys_clock -pg 1 -y 1180 -defaultsOSRD
preplace port mic3 -pg 1 -y 130 -defaultsOSRD
preplace port usb_uart -pg 1 -y 780 -defaultsOSRD
preplace port shClk -pg 1 -y 910 -defaultsOSRD
preplace port reset -pg 1 -y 1110 -defaultsOSRD
preplace portBus sw -pg 1 -y 1050 -defaultsOSRD
preplace portBus rgbled -pg 1 -y 630 -defaultsOSRD
preplace portBus btn -pg 1 -y 1030 -defaultsOSRD
preplace portBus led -pg 1 -y 610 -defaultsOSRD
preplace portBus micClk -pg 1 -y 370 -defaultsOSRD
preplace inst mic1 -pg 1 -lvl 6 -y 280 -defaultsOSRD
preplace inst microblaze_0_axi_periph -pg 1 -lvl 5 -y 640 -defaultsOSRD
preplace inst mic2 -pg 1 -lvl 6 -y 100 -defaultsOSRD
preplace inst axi_timer_0 -pg 1 -lvl 5 -y 270 -defaultsOSRD -orient R180
preplace inst microblaze_0_xlconcat -pg 1 -lvl 4 -y 230 -defaultsOSRD -orient R180
preplace inst mic3 -pg 1 -lvl 6 -y 470 -defaultsOSRD
preplace inst ArtyIO -pg 1 -lvl 6 -y 630 -defaultsOSRD
preplace inst intc -pg 1 -lvl 3 -y 950 -defaultsOSRD
preplace inst AXI_SH_595 -pg 1 -lvl 6 -y 950 -defaultsOSRD
preplace inst rst -pg 1 -lvl 2 -y 1130 -defaultsOSRD
preplace inst mdm_1 -pg 1 -lvl 3 -y 1190 -defaultsOSRD
preplace inst axi_uartlite_0 -pg 1 -lvl 6 -y 790 -defaultsOSRD
preplace inst microblaze_0 -pg 1 -lvl 4 -y 980 -defaultsOSRD
preplace inst clk_div_0 -pg 1 -lvl 5 -y 100 -defaultsOSRD
preplace inst clk_wiz_1 -pg 1 -lvl 1 -y 1170 -defaultsOSRD
preplace inst microblaze_0_local_memory -pg 1 -lvl 5 -y 990 -defaultsOSRD
preplace netloc ArtyIO_0_led 1 6 1 NJ
preplace netloc btn_1 1 0 6 NJ 1030 NJ 1030 NJ 1070 NJ 1070 NJ 1070 NJ
preplace netloc microblaze_0_axi_periph_M04_AXI 1 5 1 1630
preplace netloc ArtyIO_0_rgbled 1 6 1 NJ
preplace netloc mic1_irq_new_val 1 4 3 1270 40 NJ 190 2010
preplace netloc mic2_1 1 0 6 NJ 20 NJ 20 NJ 20 NJ 20 NJ 20 NJ
preplace netloc axi_uartlite_0_interrupt 1 4 3 1260 900 NJ 860 2010
preplace netloc microblaze_0_intr 1 2 2 560 230 NJ
preplace netloc clk_div_0_ce_out 1 5 1 1740
preplace netloc microblaze_0_axi_periph_M06_AXI 1 5 1 1650
preplace netloc microblaze_0_axi_periph_M03_AXI 1 5 1 1630
preplace netloc microblaze_0_intc_axi 1 2 4 570 1100 NJ 1100 NJ 1100 1620
preplace netloc microblaze_0_interrupt 1 3 1 N
preplace netloc AXI_SH_595_0_shRstn 1 6 1 NJ
preplace netloc microblaze_0_ilmb_1 1 4 1 N
preplace netloc mic3_1 1 0 6 NJ 130 NJ 130 NJ 130 NJ 130 NJ 160 NJ
preplace netloc sys_clock_1 1 0 1 NJ
preplace netloc microblaze_0_axi_periph_M05_AXI 1 5 1 1680
preplace netloc microblaze_0_axi_dp 1 4 1 1280
preplace netloc rst_clk_wiz_1_100M_interconnect_aresetn 1 2 3 NJ 1120 NJ 1120 1310
preplace netloc rst_clk_wiz_1_100M_bus_struct_reset 1 2 3 NJ 1110 NJ 1110 1320
preplace netloc microblaze_0_axi_periph_M01_AXI 1 5 1 N
preplace netloc clk_div_0_clk_out 1 5 2 NJ 370 NJ
preplace netloc ArtyIO_0_irq 1 4 3 1250 380 NJ 720 2010
preplace netloc rst_clk_wiz_1_100M_peripheral_aresetn 1 2 4 540 1130 NJ 1130 1290 370 1720
preplace netloc rst_clk_wiz_1_100M_mb_reset 1 2 2 520 1060 NJ
preplace netloc clk_wiz_1_locked 1 1 1 180
preplace netloc axi_uartlite_0_UART 1 6 1 NJ
preplace netloc AXI_SH_595_0_shData 1 6 1 NJ
preplace netloc microblaze_0_axi_periph_M07_AXI 1 5 1 1710
preplace netloc microblaze_0_axi_periph_M02_AXI 1 5 1 1640
preplace netloc microblaze_0_dlmb_1 1 4 1 N
preplace netloc AXI_SH_595_0_shStr 1 6 1 NJ
preplace netloc sw_1 1 0 6 NJ 1050 NJ 1040 NJ 1080 NJ 1080 NJ 1090 NJ
preplace netloc clk100M 1 1 5 180 1020 550 1050 810 1060 1300 1080 1670
preplace netloc microblaze_0_debug 1 3 1 790
preplace netloc mic3_irq_new_val 1 4 3 NJ 170 NJ 380 2010
preplace netloc mic2_irq_new_val 1 4 3 1260 10 NJ 10 2010
preplace netloc mic1_1 1 0 6 NJ 40 NJ 40 NJ 40 NJ 40 NJ 30 NJ
preplace netloc AXI_SH_595_0_shClk 1 6 1 NJ
preplace netloc reset_1 1 0 2 20 1110 NJ
preplace netloc mdm_1_debug_sys_rst 1 1 3 190 1250 NJ 1250 800
preplace netloc axi_timer_0_interrupt 1 4 1 N
levelinfo -pg 1 0 100 350 680 1030 1470 1890 2030 -top 0 -bot 1260
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


