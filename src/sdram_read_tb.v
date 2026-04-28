`timescale 1ns/1ns

module sdram_read_tb();

reg Clk;
reg rst_n;
reg [20:0] data_amount;

reg sys_busy;
reg write_req;
wire read_busy;

reg clk_out;
reg fifo_to_out_en;
reg write_busy;
wire [15:0] fifo_rd_data;
wire rdempty;

wire CKE;
wire CS;
wire RAS;
wire CAS;
wire WE;
wire [1:0] DQM;
wire [12:0] ADDR;
wire [1:0] BANK;
wire [15:0] DQ;

sdram_read sdram_read_inst(
	.Clk(Clk),
	.rst_n(rst_n),
	.data_amount(data_amount),
	
	.sys_busy(sys_busy),
	.write_req(write_req),
	.write_busy(write_busy),
	.read_busy(read_busy),
	
	.clk_out(clk_out),
	.fifo_to_out_en(fifo_to_out_en),
	.fifo_rd_data(fifo_rd_data),
	.rdempty(rdempty),	
	
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
	sys_busy=1;
	write_req=0;
	clk_out=1;
	fifo_to_out_en=0;
	data_amount=40;
end 
always #5 Clk=~Clk;
always #1000 sys_busy=~sys_busy;
always #2000 write_req=~write_req;
always #4 clk_out=~clk_out;
always #200 fifo_to_out_en=~fifo_to_out_en;

initial begin
	rst_n=0;
	#20;
	rst_n=1;
	write_busy=0;
	#200;
	write_busy=1;
	#200;
	write_busy=0;
	#20000;
	
	
	$stop;
end 



endmodule 