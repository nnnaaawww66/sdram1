// 分辨率开关
`define Resolution_640x480_60Hz   1    // 25MHz
//`define Resolution_640x480_85Hz   1    // 36MHz
//`define Resolution_800x600_60Hz   1    // 40MHz
//`define Resolution_800x600_85Hz   1    // 56MHz
//`define Resolution_1024x768_60Hz  1    // 65MHz
//`define Resolution_1024x768_70Hz  1    // 75MHz
//`define Resolution_1024x768_85Hz  1    // 95MHz
//`define Resolution_1280x1024_60Hz 1    // 108MHz

// ==============================
// 640x480@60Hz  25MHz
// ==============================
`ifdef Resolution_640x480_60Hz
`define PIXEL_CLK        clk_25m
`define H_Sync           95    // 3.8*25
`define H_Back_Porch     48    // 1.9*25=47.5 → 48
`define H_Data           640   // 25.4*25
`define H_Front_Porch    15    // 0.6*25
`define H_Total          793   // 95+48+635+15

`define V_Sync           2
`define V_Back_Porch     33
`define V_Data           480
`define V_Front_Porch    10
`define V_Total          525
`endif

// ==============================
// 640x480@85Hz  36MHz
// ==============================
`ifdef Resolution_640x480_85Hz
`define PIXEL_CLK        clk_36m
`define H_Sync           58    // 1.6*36=57.6→58
`define H_Back_Porch     80    // 2.2*36=79.2→80
`define H_Data           641   // 17.8*36=640.8→641
`define H_Front_Porch    58    // 1.6*36=57.6→58
`define H_Total          837

`define V_Sync           3
`define V_Back_Porch     25
`define V_Data           480
`define V_Front_Porch    1
`define V_Total          509
`endif

// ==============================
// 800x600@60Hz  40MHz
// ==============================
`ifdef Resolution_800x600_60Hz
`define PIXEL_CLK        clk_40m
`define H_Sync           128   // 3.2*40
`define H_Back_Porch     88    // 2.2*40
`define H_Data           800   // 20*40
`define H_Front_Porch    40    // 1*40
`define H_Total          1056

`define V_Sync           4
`define V_Back_Porch     23
`define V_Data           600
`define V_Front_Porch    1
`define V_Total          628
`endif

// ==============================
//// 800x600@75Hz  49MHz
// ==============================
//`ifdef Resolution_800x600_75Hz
//`define PIXEL_CLK        clk_49m
//`define H_Sync           79    // 1.6*49=78.4→79
//`define H_Back_Porch     157   // 3.2*49=156.8→157
//`define H_Data           794   // 16.2*49=793.8→794
//`define H_Front_Porch    15    // 0.3*49=14.7→15
//`define H_Total          1045
//
//`define V_Sync           3
//`define V_Back_Porch     21
//`define V_Data           600
//`define V_Front_Porch    1
//`define V_Total          625
//`endif

// ==============================
// 800x600@85Hz  56MHz
// ==============================
`ifdef Resolution_800x600_85Hz
`define PIXEL_CLK        clk_56m
`define H_Sync           62    // 1.1*56=61.6→62
`define H_Back_Porch     152   // 2.7*56=151.2→152
`define H_Data           796   // 14.2*56=795.2→796
`define H_Front_Porch    34    // 0.6*56=33.6→34
`define H_Total          1044

`define V_Sync           3
`define V_Back_Porch     27
`define V_Data           600
`define V_Front_Porch    1
`define V_Total          631
`endif

// ==============================
// 1024x768@60Hz  65MHz
// ==============================
`ifdef Resolution_1024x768_60Hz
`define PIXEL_CLK        clk_65m
`define H_Sync           137   // 2.1*65=136.5→137
`define H_Back_Porch     163   // 2.5*65=162.5→163
`define H_Data           1027  // 15.8*65=1027
`define H_Front_Porch    26    // 0.4*65
`define H_Total          1353

`define V_Sync           6
`define V_Back_Porch     29
`define V_Data           768
`define V_Front_Porch    3
`define V_Total          806
`endif

// ==============================
// 1024x768@70Hz  75MHz
// ==============================
`ifdef Resolution_1024x768_70Hz
`define PIXEL_CLK        clk_75m
`define H_Sync           135   // 1.8*75
`define H_Back_Porch     143   // 1.9*75=142.5→143
`define H_Data           1028  // 13.7*75=1027.5→1028
`define H_Front_Porch    23    // 0.3*75=22.5→23
`define H_Total          1329

`define V_Sync           6
`define V_Back_Porch     29
`define V_Data           768
`define V_Front_Porch    3
`define V_Total          806
`endif

// ==============================
// 1024x768@85Hz  95MHz
// ==============================
`ifdef Resolution_1024x768_85Hz
`define PIXEL_CLK        clk_95m
`define H_Sync           95    // 1.0*95
`define H_Back_Porch     209   // 2.2*95
`define H_Data           1026  // 10.8*95=1026
`define H_Front_Porch    48    // 0.5*95=47.5→48
`define H_Total          1378

`define V_Sync           3
`define V_Back_Porch     36
`define V_Data           768
`define V_Front_Porch    1
`define V_Total          808
`endif

// ==============================
// 1280x1024@60Hz  108MHz
// ==============================
`ifdef Resolution_1280x1024_60Hz
`define PIXEL_CLK        clk_108m
`define H_Sync           108   // 1.0*108
`define H_Back_Porch     249   // 2.3*108=248.4→249
`define H_Data           1286  // 11.9*108=1285.2→1286
`define H_Front_Porch    44    // 0.4*108=43.2→44
`define H_Total          1687

`define V_Sync           3
`define V_Back_Porch     38
`define V_Data           1024
`define V_Front_Porch    1
`define V_Total          1066
`endif