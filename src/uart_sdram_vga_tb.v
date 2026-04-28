// synthesis translate_off
`timescale 1ns / 10ps
`include "mt48lc16m16a2.v"

`define write_test 1

`ifdef write_test

module uart_sdram_vga_tb();

// ===================== Parameter Define =====================
parameter CLK_PERIOD = 20;
parameter BAUD_RATE  = 115200;
localparam BIT_TIME  = 1000000000 / BAUD_RATE;

// ===================== Signal Declaration =====================
reg        Clk;
reg        rst_n;
reg        Rxd;

// SDRAM Interface
wire        sdram_clk;
wire        CKE;
wire        CS_n;
wire        RAS_n;
wire        CAS_n;
wire        WE_n;
wire [1:0]  DQM;
wire [12:0] ADDR;
wire [1:0]  BANK;
wire [15:0] DQ;

// VGA Interface
wire [7:0]  VGA_R, VGA_G, VGA_B;
wire        VGA_HS, VGA_VS, VGA_CLK;

// Segment Display
wire [6:0]  seg_w0, seg_w1, seg_r0, seg_r1, seg_r2, seg_r3;

// ===================== DUT Instance =====================
uart_sdram_vga u_dut (
    .Clk                 (Clk),
    .rst_n               (rst_n),
    .sdram_clk           (sdram_clk),
    .CKE                 (CKE),
    .CS                  (CS_n),
    .RAS                 (RAS_n),
    .CAS                 (CAS_n),
    .WE                  (WE_n),
    .DQM                 (DQM),
    .ADDR                (ADDR),
    .BANK                (BANK),
    .DQ                  (DQ),
    .Rxd                 (Rxd),
    .VGA_R               (VGA_R),
    .VGA_G               (VGA_G),
    .VGA_B               (VGA_B),
    .VGA_CLK             (VGA_CLK),
    .VGA_HS              (VGA_HS),
    .VGA_VS              (VGA_VS),
    .write_wrusedw_seg1  (seg_w1),
    .write_wrusedw_seg0  (seg_w0),
    .read_wrusedw_seg3   (seg_r3),
    .read_wrusedw_seg2   (seg_r2),
    .read_wrusedw_seg1   (seg_r1),
    .read_wrusedw_seg0   (seg_r0)
);

// ===================== SDRAM Simulation Model =====================
mt48lc16m16a2 u_sdram_model (
    .Dq    (DQ),
    .Addr  (ADDR),
    .Ba    (BANK),
    .Clk   (sdram_clk),
    .Cke   (CKE),
    .Cs_n  (CS_n),
    .Ras_n (RAS_n),
    .Cas_n (CAS_n),
    .We_n  (WE_n),
    .Dqm   (DQM)
);

// ===================== Clock Generate =====================
initial Clk = 0;
always #(CLK_PERIOD/2) Clk = ~Clk;

// ===================== UART Send Task =====================
task uart_send_byte(input [7:0] data);
    integer i;
    begin
        Rxd = 0;
        #(BIT_TIME);
        for (i = 0; i < 8; i = i + 1) begin
            Rxd = data[i];
            #(BIT_TIME);
        end
        Rxd = 1;
        #(BIT_TIME);
    end
endtask

// ===================== Send Pixel Data Task =====================
task send_pixel_data(input integer count);
    integer p;
    reg [15:0] pixel_val;
    begin
        $display("[%t] Start sending data: total = %d", $time, count);
        
        for (p = 2; p <= count; p = p + 1) begin
            pixel_val = p[15:0];
            uart_send_byte(pixel_val[15:8]);
            uart_send_byte(pixel_val[7:0]);

            if (p % 500 == 0)
                $display("[%t] Progress: sent = %d, data = 16'h%h", $time, p, pixel_val);
        end
        
        $display("[%t] All %d pixel data transmission completed.", $time, count);
    end
endtask

// ===================== Simulation Stimulus =====================
initial begin
    rst_n = 0;
    Rxd   = 1;
    #(CLK_PERIOD * 10);
    rst_n = 1;

    $display("[%t] Waiting for SDRAM initialization...", $time);
    #(150000);
    
    send_pixel_data(2000);

    $display("[%t] UART transmission done, wait for SDRAM write sync...", $time);
    #(50000);

    $display("[%t] Simulation Finished.", $time);
    $stop;
end

//// Waveform dump
//initial begin
//    $fsdbDumpfile("wave.fsdb");
//    $fsdbDumpvars(0, uart_sdram_vga_tb);
//end

endmodule

`endif
// synthesis translate_on