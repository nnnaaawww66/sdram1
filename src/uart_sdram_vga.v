module uart_sdram_vga(
	input Clk,
	input rst_n,
	
	//sdram物理引脚
	output sdram_clk,
	output CKE,
	output CS,
	output RAS,
	output CAS,
	output WE,
	output [1:0] DQM,
	output [12:0] ADDR,
	output [1:0] BANK,
	inout [15:0] DQ,
	
	input Rxd,
	
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_CLK,
	output VGA_BLANK_N,
	output VGA_HS,
	output VGA_VS,
	output VGA_SYNC_N,
	
	output [6:0] write_wrusedw_seg1,
	output [6:0] write_wrusedw_seg0,
	output [6:0] read_wrusedw_seg3,
	output [6:0] read_wrusedw_seg2,
	output [6:0] read_wrusedw_seg1,
	output [6:0] read_wrusedw_seg0
);

wire locked;
wire sys_rst_n;
assign sys_rst_n=rst_n && locked;

wire clk_100m,write_en,fifo_full,read_en;
wire [15:0] data_RX_r;
wire [20:0] data_amount;
wire [15:0] data_out;
wire [7:0] write_wrusedw;   // 写指针 8位
wire [15:0] read_wrusedw;    // 读指针 16位

wire [12:0] wr_ROW;
wire [9:0] wr_COLUMN;
wire [1:0] wr_BANK;

// ===================== 0.25秒刷新计数器 (25MHz → 12_499_999) =====================
reg [23:0] refresh_cnt;
reg        refresh_en;

always @(posedge Clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        refresh_cnt <= 24'd0;
        refresh_en   <= 1'b0;
    end
    else if(refresh_cnt == 24'd12499999) begin
        refresh_cnt <= 24'd0;
        refresh_en   <= 1'b1;
    end
    else begin
        refresh_cnt <= refresh_cnt + 1'b1;
        refresh_en   <= 1'b0;
    end
end
// ================================================================================

sdram_100m u_sdram_100m(
		.refclk(Clk),   
		.rst(~rst_n),    
		.outclk_0(clk_100m), 
		.locked(locked)    
);

assign sdram_clk=clk_100m;

sdram_top u_sdram_top(
	.Clk_100m(clk_100m),
	.rst_n(sys_rst_n),	
	
	.write_wrusedw(write_wrusedw),
	.read_wrusedw(read_wrusedw),	
	.wr_ROW(wr_ROW),
	.wr_COLUMN(wr_COLUMN),
	.wr_BANK(wr_BANK),
	
	.clk_data_in(~Clk),
	.data_in(data_RX_r),
	.wr_to_fifo_en(write_en),
	.wrfull_in(fifo_full),
	.data_amount(data_amount),
	
	.clk_data_out(~VGA_CLK),
	.data_out(data_out),
	.fifo_to_out_en(read_en),
	.rdempty_out(),
	
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

uart_rx u_uart_rx(
	.Clk(Clk),
	.rst_n(sys_rst_n),
	.Rxd(Rxd),	
	.fifo_full(fifo_full),
	.write_en(write_en),
	.data_RX_r(data_RX_r)
);

wire [23:0] DATA;
assign DATA={3'b000,data_out[15:11],2'b00,data_out[10:5],3'b000,data_out[4:0]};

VGA_0 u_VGA_0(
	.sys_clk_50m(Clk),
	.rst_n(sys_rst_n),
	
	.DATA(DATA),	
	
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_CLK(VGA_CLK),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_SYNC_N(VGA_SYNC_N),
	
	.data_amount(data_amount),
	.read_en(read_en)
);

// ===================== 显示刷新寄存器 =====================
reg [9:0]  col_r;
reg [1:0]  bank_r;
reg [12:0] row_r;

always @(posedge Clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        col_r  <= 10'd0;
        bank_r <= 2'd0;
        row_r  <= 13'd0;
    end
    else if(refresh_en) begin
        col_r  <= wr_COLUMN;
        bank_r <= wr_BANK;
        row_r  <= wr_ROW;
    end
end

// 0123位十进制显示 wr_column
hex_to_7seg u0(.hex_data(col_r % 10),               .seg(read_wrusedw_seg0));  // 个位
hex_to_7seg u1(.hex_data((col_r / 10) % 10),        .seg(read_wrusedw_seg1));  // 十位
hex_to_7seg u2(.hex_data((col_r / 100) % 10),       .seg(read_wrusedw_seg2));  // 百位
hex_to_7seg u3(.hex_data((col_r / 1000) % 10),      .seg(read_wrusedw_seg3));  // 千位

// 4显示 wr_bank
hex_to_7seg u4(.hex_data({2'b00, bank_r}),          .seg(write_wrusedw_seg0));

// 5显示 wr_row 的个位
hex_to_7seg u5(.hex_data(row_r % 10),               .seg(write_wrusedw_seg1));

endmodule 

// ---------------- 十六进制转七段数码管编码 (共阳极逻辑，0有效) ----------------
module hex_to_7seg (
    input      [3:0] hex_data,
    output reg [6:0] seg
);
    always @(*) begin
        case (hex_data)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule