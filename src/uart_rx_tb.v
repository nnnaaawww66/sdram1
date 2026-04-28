`timescale 1ns/1ns
module uart_rx_tb();

reg Clk;
reg reset_n;
reg rx_data;
reg fifo_full;
wire write_en;
wire [15:0] data_RX_r;


uart_rx uart_rx_inst(
	.Clk(Clk),
	.rst_n(reset_n),
	.Rxd(rx_data),
	
	.fifo_full(fifo_full),
	.write_en(write_en),
	.data_RX_r(data_RX_r)
);
	
	initial Clk=1;
	always #10 Clk=~Clk;
	
	task uart_tx;
		input [7:0] data;
		integer i;
		begin
			rx_data=0;
			#8680;
			for(i=0;i<8;i=i+1)begin
				rx_data=data[i];
				#8680;
			end
			rx_data=1;
			#8680;
		end
	endtask
		
		
	initial begin
		fifo_full=0;
		rx_data=1;
		reset_n=0;
		#20;
		reset_n=1;
		repeat(2) begin
			uart_tx(8'b0101_0101);
			#1000;
			uart_tx(8'b0111_0001);
			#1000;
		end
		$stop;
	end


endmodule 