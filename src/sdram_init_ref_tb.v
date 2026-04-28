`timescale 1ns/1ns

module sdram_init_ref_tb();

reg Clk;
reg rst_n;

wire sys_busy;
wire sys_req;

wire CKE;
wire CS;
wire RAS;
wire CAS;
wire WE;
wire [1:0] DQM;
wire [12:0] ADDR;
wire [1:0] BANK;
wire [15:0] DQ;

sdram_init_ref sdram_init_ref_inst(
	.Clk(Clk),
	.rst_n(rst_n),
	
	.sys_busy(sys_busy),
	.sys_req(sys_req),
	
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

initial Clk=1;
always #5 Clk=~Clk;

initial begin
	rst_n=0;
	#20;
	rst_n=1;
	#200_000;
	$stop;
end 


endmodule 