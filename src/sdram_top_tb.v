`timescale 1ns/1ns

module sdram_top_tb();

reg         Clk;
reg         rst_n;

// 写端口
reg         clk_data_in;
reg  [15:0] data_in;
reg         wr_to_fifo_en;
wire        wrfull_in;
reg  [20:0] data_amount;

// 读端口
reg         clk_data_out;
wire [15:0] data_out;
reg         fifo_to_out_en;
wire        rdempty_out;

// SDRAM 物理引脚
wire        CKE;
wire        CS;
wire        RAS;
wire        CAS;
wire        WE;
wire [1:0]  DQM;
wire [12:0] ADDR;
wire [1:0]  BANK;
wire [15:0] DQ;

sdram_top sdram_top_inst(
	.Clk(Clk),
	.rst_n(rst_n),
	
	// 写数据端口
	.clk_data_in(clk_data_in),
	.data_in(data_in),
	.wr_to_fifo_en(wr_to_fifo_en),
	.wrfull_in(wrfull_in),
	.data_amount(data_amount),

	// 读数据端口
	.clk_data_out(clk_data_out),
	.data_out(data_out),
	.fifo_to_out_en(fifo_to_out_en),
	.rdempty_out(rdempty_out),

	// SDRAM 物理引脚
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
	clk_data_out=1;
	fifo_to_out_en=0;
end 
always #5 Clk=~Clk;
always #200 clk_data_in=~clk_data_in;
always #4 clk_data_out=~clk_data_out;

always@(posedge clk_data_in)
	if(wr_to_fifo_en)
		data_in<=data_in+1'd1;
	else 
		data_in<=data_in;

initial begin
	rst_n=0;
	data_amount=5000;
	data_in=0;
	wr_to_fifo_en=1;
	#20;
	rst_n=1;
	#150000;
	repeat(50) begin
		fifo_to_out_en=0;
		#50;
		fifo_to_out_en=1;
		#250;
	end 
	//fifo_to_out_en=0;
	#50000;
	$stop;

end 

endmodule 