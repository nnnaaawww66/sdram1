module sdram_write(
	input Clk,
	input rst_n,
	
	output [7:0] wrusedw,
	output reg [12:0] wr_ROW,
	output reg [9:0] wr_COLUMN,
	output reg [1:0] wr_BANK,
	
	input sys_busy,
	input sys_req,
	input read_busy,
	input read_req,
	output reg write_busy,
	output reg write_req,
	
	input clk_data_in,//外部数据源输入时钟
	input [15:0] data_in,
	input wr_to_fifo_en,
	output wrfull,
	
	output CKE,
	output CS,
	output RAS,
	output CAS,
	output WE,
	output reg [1:0] DQM,
	output reg [12:0] ADDR,
	output reg [1:0] BANK,
	output [15:0] DQ
);

wire fifo_to_sdram_en;
wire rdempty;
wire [15:0] wr_data;
wire [7:0] rdusedw;

wr_fifo u_wr_fifo(
	.aclr     (~rst_n),        // 复位不用就接 0
	.data     (data_in),    	// 往 FIFO 写数据
	.rdclk    (~Clk),    		// SDRAM 100MHz 时钟
	.rdreq    (fifo_to_sdram_en),        	// 从 FIFO 往外读
	.wrclk    (clk_data_in),   // 数据源时钟
	.wrreq    (wr_to_fifo_en),         // 往 FIFO 里写
	.q        (wr_data),  		// FIFO 输出给 SDRAM
	.rdempty  (rdempty),       // FIFO 空标志
	.rdusedw  (rdusedw),              // 不用可以空着
	.wrfull   (wrfull),        // FIFO 满标志
	.wrusedw  (wrusedw)               // 不用可以空着
);



reg [3:0] wr_state;
localparam wr_idle 	       = 0,
			  wr_active        = 1,
			  wr_active_nop    = 2,
			  wr_command 	    = 3,
			  wr_writing       = 4,
			  wr_nop_before_pre= 5,
			  wr_precharge		 = 6,
			  wr_precharge_nop = 7;
			  			  
reg [3:0] command;
assign {CS,RAS,CAS,WE} = command;
localparam NOP    = 4'b0111,
			  ACTIVE = 4'b0011,
			  WRITE  = 4'b0100,
			  PALL   = 4'b0010;
			  
always@(posedge Clk or negedge rst_n)
	if(!rst_n)
		write_req<=0;
	else if(wr_state==wr_idle && !rdempty)
		write_req<=1;
	else if(wr_state==wr_idle)
		write_req<=0;
	else 
		write_req<=write_req;

//write状态机
always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin
		wr_BANK<=0;
		wr_COLUMN<=0;
		wr_ROW<=0;
		wr_state<=wr_idle;
	end 
	else 
		case(wr_state)
			wr_idle 	     :begin 
				if(!sys_busy && !rdempty && !read_busy && !read_req && !sys_req)begin
					wr_state<=wr_active;
				end 
			end
		   wr_active     :begin 
				wr_state<=wr_active_nop;
			end
		   wr_active_nop :begin 
				wr_state<=wr_command;
			end
			wr_command    :begin
				wr_COLUMN<=wr_COLUMN+1'd1;
				if(read_req || sys_req)begin 
					wr_state<=wr_nop_before_pre;
				end 
				else if(sys_busy || rdempty || read_busy)begin
					wr_state<=wr_nop_before_pre;
				end 
				else if(wr_BANK==2'b11 && wr_COLUMN>=10'd1017)
					wr_state<=wr_nop_before_pre;
				else if(wr_COLUMN>=10'd1017)
					if(rdusedw>=3)
						wr_state<=wr_active;
					else 
						wr_state<=wr_nop_before_pre;
				else if(rdusedw>=2)
					wr_state<=wr_writing;
				else 
					wr_state<=wr_nop_before_pre;
				
				if(wr_BANK==2'b11 && wr_COLUMN>=10'd1017)begin
					wr_BANK<=0;
					wr_COLUMN<=0;
					wr_ROW<=wr_ROW+1'd1;
				end 
				else if(wr_COLUMN>=10'd1017)begin
					wr_BANK<=wr_BANK+1'd1;
					wr_COLUMN<=0;
					wr_ROW<=wr_ROW;
				end 
			end 
		   wr_writing 	  :begin 
				wr_COLUMN<=wr_COLUMN+1'd1;
				if(read_req || sys_req)begin 
					wr_state<=wr_nop_before_pre;
				end 
				else if(sys_busy || rdempty || read_busy)begin
					wr_state<=wr_nop_before_pre;
				end 
				else if(wr_BANK==2'b11 && wr_COLUMN>=10'd1017)begin
					wr_state<=wr_nop_before_pre;
				end 
				else if(wr_COLUMN>=10'd1017)begin
					if(rdusedw>=3)
						wr_state<=wr_active;
					else 
						wr_state<=wr_nop_before_pre;
				end 
				else if(rdusedw>=2)
					wr_state<=wr_writing;
				else 
					wr_state<=wr_nop_before_pre;
				
				
				if(wr_BANK==2'b11 && wr_COLUMN>=10'd1017)begin
					wr_BANK<=0;
					wr_COLUMN<=0;
					wr_ROW<=wr_ROW+1'd1;
				end 
				else if(wr_COLUMN>=10'd1017)begin
					wr_BANK<=wr_BANK+1'd1;
					wr_COLUMN<=0;
					wr_ROW<=wr_ROW;
				end 
			end
			wr_nop_before_pre:begin 
				wr_state<=wr_precharge;
			end 
		   wr_precharge  :begin 
				wr_state<=wr_precharge_nop;
			end
			wr_precharge_nop:begin
				if(!rdempty && !sys_busy && !read_busy && !sys_req && !read_req)
					wr_state<=wr_active;
				else 
					wr_state<=wr_idle;
			end 
			default       :begin
				wr_state<=wr_idle;
			end 
		endcase 

//始终使能时钟	
assign CKE=1;		

//command在Clk下降沿改变
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		command<=NOP;
	else if(wr_state==wr_active)
		command<=ACTIVE;
	else if(wr_state==wr_command)
		command<=WRITE;
	else if(wr_state==wr_precharge)
		command<=PALL;
	else 
		command<=NOP;

//DQM在下降沿变化，除了在precharge的时候等于1，其他都是0
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		DQM<=0;
	else if(wr_state == wr_nop_before_pre || wr_state == wr_precharge || wr_state == wr_precharge_nop)
		DQM<=2'b11;
	else 
		DQM<=0;

//ADDR在Clk下降沿变化
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		ADDR<=0;
	else if(wr_state==wr_active)
		ADDR<=wr_ROW;
	else if(wr_state==wr_command)
		ADDR<={2'b00,1'b0,wr_COLUMN};
	else if(wr_command==wr_precharge)
		ADDR<=13'b1<<10;
	else 
		ADDR<=0;

//BANK在Clk下降沿变化
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		BANK<=0;
	else if(wr_state>=wr_active && wr_state<=wr_command)
		BANK<=wr_BANK;
	else 
		BANK<=0;
		
reg [3:0] wr_state_r0;
reg [3:0] wr_state_r1;         
always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin 
		wr_state_r0<=0;
		wr_state_r1<=0;
	end 
	else begin 
		wr_state_r0<=wr_state;
		wr_state_r1<=wr_state_r0;
	end 

// DQ 输出使能控制（在下降沿更新）
reg DQ_en;
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		DQ_en <= 1'b0;
	else if(wr_state == wr_command || wr_state==wr_writing ||
			  (wr_state == wr_active && (wr_state_r0 == wr_command || wr_state_r0 == wr_writing)) ||
			  (wr_state == wr_active_nop && (wr_state_r1 == wr_command || wr_state_r1 == wr_writing)))
		DQ_en <= 1'b1;  // 使能输出
	else 
		DQ_en <= 1'b0;  
		
assign DQ = DQ_en ? wr_data : 16'hzzzz;	

always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		write_busy<=0;
	else 
		write_busy=(wr_state!=wr_idle);
		
assign fifo_to_sdram_en=DQ_en;		

		
endmodule 