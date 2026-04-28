set_global_assignment -entity "sdram_100m" -library "lib_sdram_100m" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "sdram_100m" -library "lib_sdram_100m" -name IP_TOOL_VERSION "13.1"
set_global_assignment -entity "sdram_100m" -library "lib_sdram_100m" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_sdram_100m" -name SPD_FILE [file join $::quartus(sip_path) "sdram_100m.spd"]

set_global_assignment -library "lib_sdram_100m" -name MISC_FILE [file join $::quartus(sip_path) "sdram_100m_sim/sdram_100m.vo"]
