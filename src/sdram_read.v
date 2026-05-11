//`define debug 1

module sdram_read(
	input Clk,
	input rst_n,
	
	output [15:0] wrusedw,
	
	input [20:0] data_amount,
	
	input sys_busy,
	input write_req,
	input write_busy,
	input sys_req,
	output read_busy,
	output reg read_req,
	
	input clk_out,
	input fifo_to_out_en,
	output [15:0] fifo_rd_data,
	output rdempty,
	
	output CKE,
	output CS,
	output RAS,
	output CAS,
	output WE,
	output reg [1:0] DQM,
	output reg [12:0] ADDR,
	output reg [1:0] BANK,
	input [15:0] DQ

	`ifdef dubug
	,
	output [22:0] debug_data_cnt
	`endif
);

reg sdram_to_fifo_en;
wire wrfull;
wire wrempty;
wire [15:0] rdusedw;

rd_fifo u_rd_fifo (
	.aclr    (~rst_n),        // 复位
	.data    (DQ),			// 从SDRAM读出的数据
	.rdclk   (clk_out),      // 读时钟（比如out时钟）
	.rdreq   (fifo_to_out_en),   // 读请求（你要读就给1）
	.wrclk   (Clk),    		// 写时钟（SDRAM工作时钟）
	.wrreq   (sdram_to_fifo_en),  // SDRAM读出来就写进FIFO
	.q       (fifo_rd_data), // FIFO输出给你用的数据
	.rdempty (rdempty),             
	.rdusedw (rdusedw),
	.wrempty (wrempty),
	.wrfull  (wrfull),
	.wrusedw (wrusedw)
);

reg [3:0] rd_state;
localparam rd_idle 		    = 0,
			  rd_active		    = 1,
			  rd_active_nop    = 2,
			  rd_command	    = 3,
			  rd_reading	    = 4,
			  rd_wait_tRAS		 = 5,
			  rd_precharge	    = 6,
			  rd_precharge_nop = 7;

reg [12:0] rd_ROW;
reg [9:0] rd_COLUMN;
reg [1:0] rd_BANK;

reg [22:0] data_cnt;

reg [3:0] command;
assign {CS,RAS,CAS,WE} = command;
localparam NOP    = 4'b0111,
			  ACTIVE = 4'b0011,
			  READ   = 4'b0101,
			  PALL   = 4'b0010;
			  
reg meet_tRAS;
reg [2:0] cycle_tRAS_cnt;
			  
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		read_req<=0;
	else if(rd_state==rd_idle && wrusedw<=16'd12800)
		read_req<=1;
	else 
		read_req<=0;
			  

always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin 
		data_cnt<=0;
		rd_state<=rd_idle;
		rd_BANK<=0;
		rd_ROW<=0;
		rd_COLUMN<=0;
	end 
	else 
		case(rd_state)
			rd_idle 		     :begin 
				if(!sys_busy && !((wrfull || wrusedw>=16'd12800) && write_req) &&
					!write_busy && !sys_req && !(wrusedw>=16'd65520 || wrfull))
					rd_state<=rd_active;
			end
			rd_active		  :begin 
				rd_state<=rd_active_nop;
			end   
			rd_active_nop    :begin 
				rd_state<=rd_command;
			end 
			rd_command	     :begin
				data_cnt<=data_cnt+1'd1;
				rd_COLUMN<=rd_COLUMN+1'd1;
				
				if(sys_req)
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
					
				if(data_cnt==data_amount-1)begin
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
				end 
				else if((sys_busy || wrusedw>=16'd65520 || wrfull || ((wrfull || wrusedw>=16'd12800) && write_req)))
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
				else if(rd_BANK==2'b11 && rd_COLUMN>=10'd1015)begin
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
				end 
				else if(rd_COLUMN>=10'd1015)begin
					rd_state<=rd_active;
				end 
				else 
					rd_state<=rd_reading;
					
				if(data_cnt==data_amount-1)begin
					data_cnt<=0;
					rd_COLUMN<=0;
					rd_BANK<=0;
					rd_ROW<=0;
				end 
				else if(rd_BANK==2'b11 && rd_COLUMN>=10'd1018)begin
					data_cnt<=data_cnt+3;
					rd_COLUMN<=0;
					rd_BANK<=0;
					rd_ROW<=rd_ROW+1'd1;
				end 
				else if(rd_COLUMN>=10'd1015)begin
					data_cnt<=data_cnt+3;
					rd_COLUMN<=0;
					rd_BANK<=rd_BANK+1'd1;
					rd_ROW<=rd_ROW;
				end 
			end
			rd_reading	     :begin 
				data_cnt<=data_cnt+1'd1;
				rd_COLUMN<=rd_COLUMN+1'd1;
				
				if(sys_req)
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
					
				if(data_cnt==(data_amount-1))begin
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
				end 
				else if((sys_busy || wrusedw>=16'd65520 || wrfull || ((wrfull || wrusedw>=16'd12800) && write_req)))
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
				else if(rd_BANK==2'b11 && rd_COLUMN>=10'd1018)begin
					if(meet_tRAS)
						rd_state<=rd_precharge;
					else 
						rd_state<=rd_wait_tRAS;
				end 
				else if(rd_COLUMN>=10'd1015)begin
					rd_state<=rd_active;
				end 	
				
				if(data_cnt==(data_amount-1))begin
					data_cnt<=0;
					rd_COLUMN<=0;
					rd_BANK<=0;
					rd_ROW<=0;
				end 
				else if(rd_BANK==2'b11 && rd_COLUMN>=10'd1015)begin
					data_cnt<=data_cnt+3;
					rd_COLUMN<=0;
					rd_BANK<=0;
					rd_ROW<=rd_ROW+1'd1;
				end 
				else if(rd_COLUMN>=10'd1015)begin
					data_cnt<=data_cnt+3;
					rd_COLUMN<=0;
					rd_BANK<=rd_BANK+1'd1;
					rd_ROW<=rd_ROW;
				end 	
			end
			rd_wait_tRAS  	  :begin 
				if(meet_tRAS)
					rd_state<=rd_precharge;
			end 
			rd_precharge	  :begin 
				rd_state<=rd_precharge_nop;
			end   
			rd_precharge_nop :begin 
				if(!sys_busy && !write_req && !(wrusedw>=16'd65520 || wrfull) && !sys_req)
					rd_state<=rd_active;
				else 
					rd_state<=rd_idle;
			end 
		endcase 

//始终使能时钟
assign CKE=1;

//command在Clk下降沿发生改变
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		command<=NOP;
	else if(rd_state==rd_active)
		command<=ACTIVE;
	else if(rd_state==rd_command)
		command<=READ;
	else if(rd_state==rd_precharge)
		command<=PALL;
	else 
		command<=NOP;

//DQM在Clk下降沿变化，需要换ROW但meet_tRAS不满足的时候，DQM拉高，其余为0
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		DQM<=0;
	else if(rd_state == rd_wait_tRAS)
		DQM<=2'b11;
	else 
		DQM<=0;

//ADDR在Clk下降沿变化
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		ADDR<=0;
	else if(rd_state==rd_active)
		ADDR<=rd_ROW;
	else if(rd_state==rd_command)
		ADDR<={2'b00,1'b0,rd_COLUMN};
	else if(rd_state==rd_precharge)
		ADDR<=13'b1<<10;
	else 
		ADDR<=0;

//BANK在Clk下降沿变化
always@(negedge Clk or negedge rst_n)
	if(!rst_n)
		BANK<=0;
	else if(rd_state>=rd_active && rd_state<=rd_command)
		BANK<=rd_BANK;
	else 
		BANK<=0;	
	
//因为有CAS Latency，将state打几拍获取延迟后的状态
reg [3:0] rd_state_r0;
reg [3:0] rd_state_r1;      //CAS Latency=2使用r1作为DQ使能state判断
reg [3:0] rd_state_r2;      //CAS Latency=3使用r2作为DQ使能state判断
reg [3:0] rd_state_r3;		 //换bank的时候判断fifo_to_out_en持续打开
always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin 
		rd_state_r0<=0;
		rd_state_r1<=0;
		rd_state_r2<=0;
		rd_state_r3<=0;
	end 
	else begin 
		rd_state_r0<=rd_state;
		rd_state_r1<=rd_state_r0;
		rd_state_r2<=rd_state_r1;
		rd_state_r3<=rd_state_r2;
	end 
	
always@(negedge Clk or negedge rst_n)
	if(!rst_n)begin 
		sdram_to_fifo_en <= 1'b0;
	end 
	else if(rd_state_r1 == rd_command ||
			  rd_state_r1 == rd_reading ||
			  (rd_state_r1==rd_active && rd_state==rd_command && rd_state_r2!=rd_idle && rd_state_r2!=rd_precharge_nop) ||
			  (rd_state_r1==rd_active_nop && rd_state==rd_reading && (rd_state_r3 == rd_reading || rd_state_r3 == rd_command)))
		begin
		sdram_to_fifo_en <= 1'b1;
	end 
	else begin 
		sdram_to_fifo_en <= 1'b0;
	end

assign read_busy = (rd_state != rd_idle);

//meet tRAS
always@(negedge Clk or negedge rst_n)
	if(!rst_n)begin 
		cycle_tRAS_cnt<=0;
		meet_tRAS<=0;
	end 
	else if(rd_state == rd_active)begin 
		cycle_tRAS_cnt<=0;
		meet_tRAS<=0;
	end 
	else if(cycle_tRAS_cnt>=5)begin 
		cycle_tRAS_cnt<=5;
		meet_tRAS<=1;
	end 
	else begin 
		cycle_tRAS_cnt<=cycle_tRAS_cnt+1'd1;
		meet_tRAS<=0;
	end 
	
`ifdef dubug
assign debug_data_cnt=data_cnt;
`endif

endmodule 