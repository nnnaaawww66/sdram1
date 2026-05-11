//`define debug 1

module sdram_top(
	input Clk_100m,
	input rst_n,
	
	output [7:0] write_wrusedw,
	output [15:0] read_wrusedw,
	output [12:0] wr_ROW,
	output [9:0] wr_COLUMN,
	output [1:0] wr_BANK,
	
	//输入sdram的数据
	input clk_data_in,
	input [15:0] data_in,
	input wr_to_fifo_en,
	output wrfull_in,
	input [20:0] data_amount,

	//sdram输出的数据
	input clk_data_out,
	output [15:0] data_out,
	input fifo_to_out_en,
	output rdempty_out,

	//sdram物理引脚
	output CKE,
	output CS,
	output RAS,
	output CAS,
	output WE,
	output [1:0] DQM,
	output [12:0] ADDR,
	output [1:0] BANK,
	inout [15:0] DQ	
	
	`ifdef dubug
	,
	output [22:0] debug_data_cnt
	`endif
);

wire sys_busy , sys_req , write_busy , write_req , read_busy , read_req;

wire        init_ref_CKE,   write_CKE,   read_CKE;
wire        init_ref_CS,    write_CS,    read_CS;
wire        init_ref_RAS,   write_RAS,   read_RAS;
wire        init_ref_CAS,   write_CAS,   read_CAS;
wire        init_ref_WE,    write_WE,    read_WE;
wire [1:0]  init_ref_DQM,   write_DQM,   read_DQM;
wire [12:0] init_ref_ADDR,  write_ADDR,  read_ADDR;
wire [1:0]  init_ref_BANK,  write_BANK,  read_BANK;
wire [15:0] init_ref_DQ,    write_DQ,    read_DQ;

assign CKE	= sys_busy ? init_ref_CKE  : read_busy ? read_CKE  : write_busy ? write_CKE  : 1'b1;
assign CS   = sys_busy ? init_ref_CS   : read_busy ? read_CS   : write_busy ? write_CS   : 1'b0;
assign RAS  = sys_busy ? init_ref_RAS  : read_busy ? read_RAS  : write_busy ? write_RAS  : 1'b1;
assign CAS  = sys_busy ? init_ref_CAS  : read_busy ? read_CAS  : write_busy ? write_CAS  : 1'b1;
assign WE   = sys_busy ? init_ref_WE   : read_busy ? read_WE   : write_busy ? write_WE   : 1'b1;
assign DQM  = sys_busy ? init_ref_DQM  : read_busy ? read_DQM  : write_busy ? write_DQM  : 2'b00;
assign ADDR = sys_busy ? init_ref_ADDR : read_busy ? read_ADDR : write_busy ? write_ADDR : 13'h0;
assign BANK = sys_busy ? init_ref_BANK : read_busy ? read_BANK : write_busy ? write_BANK : 2'b00;

assign DQ = write_busy ? write_DQ : 16'hzzzz;
assign read_DQ = DQ;

wire [3:0] command , init_ref_command , write_command , read_command;
assign command = {CS , RAS , CAS , WE};
assign init_ref_command = {init_ref_CS , init_ref_RAS , init_ref_CAS , init_ref_WE};
assign write_command = {write_CS , write_RAS , write_CAS , write_WE};
assign read_command = {read_CS , read_RAS , read_CAS , read_WE};

//sdram_init_ref模块
sdram_init_ref u_sdram_init_ref(
	.Clk(Clk_100m),
	.rst_n(rst_n),
	
	.read_busy(read_busy),
	.write_busy(write_busy),
	.sys_busy(sys_busy),
	.sys_req(sys_req),
	
	.CKE(init_ref_CKE),
	.CS(init_ref_CS),
	.RAS(init_ref_RAS),
	.CAS(init_ref_CAS),
	.WE(init_ref_WE),
	.DQM(init_ref_DQM),
	.ADDR(init_ref_ADDR),
	.BANK(init_ref_BANK),
	.DQ(init_ref_DQ)
);

//sdram_write模块
sdram_write u_sdram_write(
	.Clk(Clk_100m),
	.rst_n(rst_n),
	
	.wrusedw(write_wrusedw),
	.wr_ROW(wr_ROW),
	.wr_COLUMN(wr_COLUMN),
	.wr_BANK(wr_BANK),
	
	.sys_busy(sys_busy),
	.sys_req(sys_req),
	.read_busy(read_busy),
	.read_req(read_req),
	.write_busy(write_busy),
	.write_req(write_req),
	
	.clk_data_in(clk_data_in),//外部数据源输入时钟
	.data_in(data_in),
	.wr_to_fifo_en(wr_to_fifo_en),
	.wrfull(wrfull_in),
	
	.CKE(write_CKE),
	.CS(write_CS),
	.RAS(write_RAS),
	.CAS(write_CAS),
	.WE(write_WE),
	.DQM(write_DQM),
	.ADDR(write_ADDR),
	.BANK(write_BANK),
	.DQ(write_DQ)
);

//sdram_read模块
sdram_read u_sdram_read(
	.Clk(Clk_100m),
	.rst_n(rst_n),
	
	.wrusedw(read_wrusedw),
	
	.data_amount(data_amount),
	
	.sys_busy(sys_busy),
	.sys_req(sys_req),
	.write_busy(write_busy),
	.write_req(write_req),    
	.read_busy(read_busy),    
	.read_req(read_req),
	                          
	.clk_out(clk_data_out),   
	.fifo_to_out_en(fifo_to_out_en),   
	.fifo_rd_data(data_out),
	.rdempty(rdempty_out),
	
	.CKE(read_CKE),
	.CS(read_CS),
	.RAS(read_RAS),
	.CAS(read_CAS),
	.WE(read_WE),
	.DQM(read_DQM),
	.ADDR(read_ADDR),
	.BANK(read_BANK),
	.DQ(read_DQ),
	
	`ifdef dubug
	.debug_data_cnt(debug_data_cnt)
	`endif
);

endmodule 