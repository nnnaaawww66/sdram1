set_global_assignment -entity "PLL_40_56" -library "lib_PLL_40_56" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_40_56" -library "lib_PLL_40_56" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "PLL_40_56" -library "lib_PLL_40_56" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_40_56" -name SPD_FILE [file join $::quartus(sip_path) "PLL_40_56.spd"]

set_global_assignment -library "lib_PLL_40_56" -name MISC_FILE [file join $::quartus(sip_path) "PLL_40_56_sim/PLL_40_56.vo"]
