set_global_assignment -entity "PLL_25_36_75" -library "lib_PLL_25_36_75" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_25_36_75" -library "lib_PLL_25_36_75" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "PLL_25_36_75" -library "lib_PLL_25_36_75" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_25_36_75" -name SPD_FILE [file join $::quartus(sip_path) "PLL_25_36_75.spd"]

set_global_assignment -library "lib_PLL_25_36_75" -name MISC_FILE [file join $::quartus(sip_path) "PLL_25_36_75_sim/PLL_25_36_75.vo"]
