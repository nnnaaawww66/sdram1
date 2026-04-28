set_global_assignment -entity "PLL_108" -library "lib_PLL_108" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_108" -library "lib_PLL_108" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "PLL_108" -library "lib_PLL_108" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_108" -name SPD_FILE [file join $::quartus(sip_path) "PLL_108.spd"]

set_global_assignment -library "lib_PLL_108" -name MISC_FILE [file join $::quartus(sip_path) "PLL_108_sim/PLL_108.vo"]
