`include "disp_param_conf.v"
module VGA_0(
	input sys_clk_50m,
	input rst_n,
	input [23:0] DATA,
	
	input fifo_empty,
	output fifo_rd_clk,
	
	output reg [7:0] VGA_R,
	output reg [7:0] VGA_G,
	output reg [7:0] VGA_B,
	output VGA_CLK,
	output reg VGA_BLANK_N,
	output reg VGA_HS,
	output reg VGA_VS,
	output VGA_SYNC_N,
	
	output [20:0] data_amount,
	output read_en
);

assign data_amount=`H_Data * `V_Data ;
assign read_en=VGA_BLANK_N & ~fifo_empty;

//PLL
wire clk_25m, clk_36m, clk_75m;
wire clk_40m, clk_56m;
wire clk_65m, clk_95m;
wire clk_108m;

wire clk_108m_rev,clk_25m_rev;

wire locked;

`ifdef Resolution_640x480_60Hz
    PLL_25_36_75 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (clk_25m),     
        .outclk_1 (),            
        .outclk_2 (),
		  .outclk_3(clk_25m_rev),
        .locked   (locked)
    );
`elsif Resolution_640x480_85Hz
    PLL_25_36_75 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (),
        .outclk_1 (clk_36m),      
        .outclk_2 (),
        .locked   (locked)
    );
`elsif Resolution_1024x768_70Hz
    PLL_25_36_75 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (),
        .outclk_1 (),
        .outclk_2 (clk_75m),     
        .locked   (locked)
    );
`elsif Resolution_800x600_60Hz
    PLL_40_56 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (clk_40m),
        .outclk_1 (),
        .locked   (locked)
    );
`elsif Resolution_800x600_85Hz
    PLL_40_56 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (),
        .outclk_1 (clk_56m),
        .locked   (locked)
    );
`elsif Resolution_1024x768_60Hz
    PLL_65_95 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (clk_65m),
        .outclk_1 (),
        .locked   (locked)
    );
`elsif Resolution_1024x768_85Hz
    PLL_65_95 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (),
        .outclk_1 (clk_95m),
        .locked   (locked)
    );
`elsif Resolution_1280x1024_60Hz
    PLL_108 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (clk_108m),
		  .outclk_1 (clk_108m_rev),
        .locked   (locked)
    );
`elsif test
    PLL_108 u_pll (
        .refclk   (sys_clk_50m),
        .rst      (~rst_n),
        .outclk_0 (clk_108m),
		  .outclk_1 (clk_108m_rev),
        .locked   (locked)
    );
`else
    assign locked = 1'b0;
`endif




wire sys_locked = locked;
wire sys_rst_n  = sys_locked & rst_n;

//pixel clock
assign VGA_CLK = `PIXEL_CLK;
assign fifo_rd_clk = `fifo_clk;

reg [11:0] H_cnt;
reg [11:0] V_cnt;

parameter H_Sync_end = `H_Sync - 1;
parameter H_Data_start = `H_Sync + `H_Back_Porch - 1;
parameter H_Data_end = `H_Sync + `H_Back_Porch + `H_Data - 1;
parameter H_end = `H_Total - 1;

parameter V_Sync_end = `V_Sync - 1;
parameter V_Data_start = `V_Sync + `V_Back_Porch - 1;
parameter V_Data_end = `V_Sync + `V_Back_Porch + `V_Data - 1;
parameter V_end = `V_Total - 1;

always@(posedge VGA_CLK or negedge sys_rst_n)
	if(!sys_rst_n)
		H_cnt<=0;
	else if(H_cnt==H_end)
		H_cnt<=0;
	else 
		H_cnt<=H_cnt+1'd1;
		
always@(posedge VGA_CLK or negedge sys_rst_n)
	if(!sys_rst_n)
		V_cnt<=0;
	else if(V_cnt==V_end && H_cnt==H_end)
		V_cnt<=0;
	else if(H_cnt==H_end)
		V_cnt<=V_cnt+1'd1;
	
//VGA_BLANK_N
always@(posedge VGA_CLK or negedge sys_rst_n)
	if(!sys_rst_n)
		VGA_BLANK_N<=0;
	else 
		VGA_BLANK_N<=(H_cnt > H_Data_start) && (H_cnt <= H_Data_end) && (V_cnt > V_Data_start) && (V_cnt <= V_Data_end);

//356<H_cnt<=1680
//40<V_cnt<=1065
		
//H_Sync & V_Sync
always@(posedge VGA_CLK or negedge sys_rst_n)
	if(!sys_rst_n)begin
		VGA_HS<=0;
	end
	else begin
		VGA_HS<=(H_cnt <= H_Sync_end)?0:1;
		VGA_VS<=(V_cnt <= V_Sync_end)?0:1;
	end 

assign VGA_SYNC_N=0;

//DATA
always@(posedge VGA_CLK or negedge sys_rst_n)
	if(!sys_rst_n)
		{VGA_R,VGA_G,VGA_B}<=0;
	else if(VGA_BLANK_N)
		{VGA_R,VGA_G,VGA_B}<=DATA;
		

endmodule 