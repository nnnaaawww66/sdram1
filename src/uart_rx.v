module uart_rx(
	input Clk,
	input rst_n,
	input Rxd,
	
	input fifo_full,
	output reg write_en,
	output reg [15:0] data_RX_r
);

parameter baud_rate = 115200;
parameter MCNT = 50_000_000 / baud_rate - 1;

//----------------UART_RX-----------------//
localparam START_RX = 0;
localparam STOP_RX = 9;

reg [12:0] cnt_RX;
reg [3:0]  Rxd_state;
reg en_Rxd;

reg [7:0] data_RX;

reg bit_flag;
reg data_ready;

//输出给fifo的写入时钟
//always@(negedge Clk or negedge rst_n)
//	if(!rst_n)
//		write_en<=0;
//	else if(data_ready && !fifo_full)
//		write_en<=1;
//	else
//		write_en<=0;

//data_RX寄存器两轮收集16位
always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin 
		data_RX_r<=0;
		bit_flag<=0;
		write_en<=0;
	end 
	else if(Rxd_state==STOP_RX && cnt_RX==MCNT/2)begin 
		if(bit_flag==0)begin 
			 data_RX_r <= {data_RX , 8'b0000_0000}; 
			 bit_flag <= 1;
		end 
		else if(bit_flag==1)begin 
			 data_RX_r <= { data_RX_r[15:8], data_RX };  
			 bit_flag <= 0;
			 if(!fifo_full)
				write_en<=1;
		end
	end 
	else begin 
		data_ready<=0;
		write_en<=0;
	end 

//时钟分频
always@(posedge Clk or negedge rst_n)
	if(!rst_n)
		cnt_RX<=0;
	else if(!en_Rxd)
		cnt_RX<=0;
	else if(cnt_RX==MCNT)
		cnt_RX<=0;
	else
		cnt_RX<=cnt_RX+1'd1;

//接收状态机
always@(posedge Clk or negedge rst_n)
	if(!rst_n)begin
		Rxd_state<=0;
		en_Rxd<=0;
		data_RX<=8'b0000_0000;
	end
	else if(!Rxd && !en_Rxd)begin
		Rxd_state<=START_RX;
		en_Rxd<=1;
	end
	else if(en_Rxd)
		case(Rxd_state)
			START_RX  :begin 
							if(cnt_RX==MCNT/2 && Rxd)begin
								en_Rxd<=0;
								Rxd_state<=0;
							end
							else if(cnt_RX==MCNT)
								Rxd_state<=1;
							else 
							Rxd_state<=Rxd_state;
			end
			1			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[0]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=2;
							else 
								Rxd_state<=Rxd_state;
			end
			2			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[1]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=3;
							else 
								Rxd_state<=Rxd_state;
			end
			3			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[2]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=4;
							else 
								Rxd_state<=Rxd_state;
			end
			4			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[3]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=5;
							else 
								Rxd_state<=Rxd_state;
			end
			5			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[4]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=6;
							else 
								Rxd_state<=Rxd_state;
			end
			6			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[5]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=7;
							else 
								Rxd_state<=Rxd_state;
			end
			7			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[6]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=8;
							else 
								Rxd_state<=Rxd_state;
			end
			8			 :begin 
							if(cnt_RX==MCNT/2)
								data_RX[7]<=Rxd;
							else if(cnt_RX==MCNT)
								Rxd_state<=STOP_RX;
							else 
								Rxd_state<=Rxd_state;
			end
			STOP_RX   :begin 
							if(cnt_RX==MCNT/2)begin
								en_Rxd<=0;
								Rxd_state<=0;
							end
							else 
								Rxd_state<=Rxd_state;
			end
			default   :begin 
								Rxd_state<=0;
								en_Rxd<=0;
								data_RX<=8'b0000_0000;
			end
		endcase 
		else begin
			Rxd_state<=0;
			en_Rxd<=0;
			data_RX<=8'b0000_0000;
		end


endmodule 