`timescale 1ns/1ns

module sdram_write_tb();

reg Clk;
reg rst_n;

reg sys_busy;
reg sys_req;
reg read_busy;
reg read_req;
wire write_busy;
wire write_req;

reg clk_data_in;
reg [15:0] data_in;
reg wr_to_fifo_en;
wire wrfull;

wire CKE;
wire CS;
wire RAS;
wire CAS;
wire WE;
wire [1:0] DQM;
wire [12:0] ADDR;
wire [1:0] BANK;
wire [15:0] DQ;

sdram_write sdram_write_inst(
	.Clk(Clk),
	.rst_n(rst_n),
	
	.sys_busy(sys_busy),
	.sys_req(sys_req),
	.read_busy(read_busy),
	.read_req(read_req),
	.write_busy(write_busy),
	.write_req(write_req),
	
	.clk_data_in(clk_data_in),
	.data_in(data_in),
	.wr_to_fifo_en(wr_to_fifo_en),
	.wrfull(wrfull),
	
	.CKE(CKE),
	.CS(CS),
	.RAS(RAS),
	.CAS(CAS),
	.WE(WE),
	.DQM(DQM),
	.ADDR(ADDR),
	.BANK(BANK),
	.DQ(DQ)
);

initial begin
	Clk=1;
	clk_data_in=1;
	sys_busy=1;
	read_busy=1;
	data_in=16'habcd;
end 
always #5 Clk=~Clk;
always #20 clk_data_in=~clk_data_in;
always #2000 sys_busy=~sys_busy;
always #500 read_busy=~read_busy;


initial begin
	rst_n=0;
	sys_req=0;
	read_req=0;
	#20;
	rst_n=1;
	wr_to_fifo_en=0;
	#100;
	wr_to_fifo_en=1;
	#20000;
	
	$stop;
end 


endmodule 