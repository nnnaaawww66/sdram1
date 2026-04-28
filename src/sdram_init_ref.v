module sdram_init_ref(
	input Clk,
	input rst_n,
	
	input read_busy,
	input write_busy,
	output reg sys_busy,
	output reg sys_req,
	
	output CKE,
	output CS,
	output RAS,
	output CAS,
	output WE,
	output [1:0] DQM,
	output reg [12:0] ADDR,
	output [1:0] BANK,
	output [15:0] DQ
);

parameter Clk_freq=100_000_000;

reg [14:0] cnt;
parameter MCNT_120us = (Clk_freq / 1_000_000) * 120 - 1,
			 MCNT_tRP   = 1,
			 MCNT_tRC	= 6;
			 
reg [12:0] cnt_auto_ref;
parameter MCNT_7812ns = 700 - 1;

reg [3:0] init_state;
localparam init_wait 					= 0,
           init_prechage 				= 1,
			  init_prechage_nop			= 2,
           init_auto_refresh_0 		= 3,
           init_auto_refresh_nop_0  = 4,
           init_auto_refresh_1 		= 5,
           init_auto_refresh_nop_1  = 6,
           init_load_mode		 		= 7,
			  init_load_mode_nop			= 8,
			  init_end						= 9;
			  
reg [1:0] auto_ref_state;
localparam auto_refresh_wait =0,
			  auto_refresh 	  =1,
			  auto_refresh_nop  =2;
			  
reg [3:0] command;
assign {CS,RAS,CAS,WE} = command;
localparam NOP  = 4'b0111,
			  PALL = 4'b0010,
			  REF  = 4'b0001,
			  MRS  = 4'b0000;
			  
//cnt时钟复用
always@(posedge Clk or negedge rst_n)
	if(!rst_n)
		cnt<=0;
	else if(init_state==init_wait 					&& cnt==MCNT_120us ||
			  init_state==init_prechage_nop 			&& cnt==MCNT_tRP	 ||
			  init_state==init_auto_refresh_nop_0  && cnt==MCNT_tRC	 ||
			  init_state==init_auto_refresh_nop_1  && cnt==MCNT_tRC	 ||
			  auto_ref_state==auto_refresh_wait    && cnt_auto_ref==MCNT_7812ns
			  )
		cnt<=0;
	else
		cnt<=cnt+1'd1;
		
//每64ms，8192次刷新
always@(posedge Clk or negedge rst_n)
	if(!rst_n)
		cnt_auto_ref<=0;
	else if(cnt_auto_ref==MCNT_7812ns)
		if(auto_ref_state != auto_refresh_wait)
			cnt_auto_ref<=0;
		else 
			cnt_auto_ref<=MCNT_7812ns;
	else if(init_state>=init_auto_refresh_nop_1)
		cnt_auto_ref<=cnt_auto_ref+1'd1;
	
//init状态机
always@(posedge Clk or negedge rst_n)
	if(!rst_n)
		init_state<=init_wait;
	else 
		case(init_state)
			init_wait 					:begin 
				if(cnt==MCNT_120us)
					init_state<=init_prechage;
			end
			init_prechage 				:begin 
				init_state<=init_prechage_nop;
			end 
			init_prechage_nop			:begin 
				init_state<=init_auto_refresh_0;
			end 
			init_auto_refresh_0 		:begin 
					init_state<=init_auto_refresh_nop_0;
			end
			init_auto_refresh_nop_0 :begin 
				if(cnt==MCNT_tRC)
					init_state<=init_auto_refresh_1;
			end 
			init_auto_refresh_1 		:begin 
				init_state<=init_auto_refresh_nop_1;
			end
			init_auto_refresh_nop_1 :begin 
				if(cnt==MCNT_tRC)
					init_state<=init_load_mode;
			end 
			init_load_mode		 		:begin 
				init_state<=init_load_mode_nop;
			end 
			init_load_mode_nop		:begin
				init_state<=init_end;
			end 
			init_end						:begin 
				init_state<=init_end;
			end 
			default						:begin
				init_state<=init_wait;
			end 
		endcase 
		
//auto_refresh状态机
always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin 
		auto_ref_state<=auto_refresh_wait;
		sys_req<=0;
	end
	else 
		case(auto_ref_state)
			auto_refresh_wait :begin 
				if(cnt_auto_ref>=MCNT_7812ns && !write_busy && !read_busy)
					auto_ref_state<=auto_refresh;
				else if(cnt_auto_ref>=MCNT_7812ns - 6)
					sys_req<=1;
				else 
					sys_req<=0;
			end
		   auto_refresh 	   :begin 
				auto_ref_state<=auto_refresh_nop;
			end
		   auto_refresh_nop  :begin 
				if(cnt==MCNT_tRC)
					auto_ref_state<=auto_refresh_wait;
			end
			default				:begin
				sys_req<=0;
				auto_ref_state<=auto_refresh_wait;
			end 
		endcase 

always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		sys_busy<=1;
	else 
		sys_busy<=init_state!=init_end || auto_ref_state!=auto_refresh_wait || (cnt_auto_ref>=(MCNT_7812ns - 1) && !write_busy && !read_busy);

//始终使能时钟
assign CKE=1;

//command在Clk下降沿变化
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		command<=NOP;
//	else if(init_state==init_wait 				  ||
//			  init_state==init_prechage_nop 		  ||
//			  init_state==init_auto_refresh_nop_0 ||
//			  init_state==init_auto_refresh_nop_1 ||
//			  init_state==init_load_mode_nop		  ||
//			  (init_state==init_end && auto_ref_state==auto_refresh_wait) ||
//			  (init_state==init_end && auto_ref_state==auto_refresh_nop))
//		command<=NOP;
	else if(init_state==init_prechage)
		command<=PALL;
	else if(init_state==init_auto_refresh_0 || init_state==init_auto_refresh_1 || auto_ref_state==auto_refresh)
		command<=REF;
	else if(init_state==init_load_mode)
		command<=MRS;
	else 
		command<=NOP;

//DQM无关，保持0
assign DQM=0;
		
//ADDR在Clk下降沿变化
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		ADDR<=0;
	else if(init_state==init_prechage)
		ADDR<=13'b1<<10;
	else if(init_state==init_load_mode)
		ADDR<=13'b000_000_010_0111;
	else 
		ADDR<=0;

//BANK无关，保持0
assign BANK=0;
	
//DQ无关，保持高阻态
assign DQ=16'hzzzz;
		

endmodule 