module seg_Decoder(
    input  wire [23:0] din,    // 24位输入：{num5,num4,num3,num2,num1,num0}
    output reg  [6:0] seg0,
    output reg  [6:0] seg1,
    output reg  [6:0] seg2,
    output reg  [6:0] seg3,
    output reg  [6:0] seg4,
    output reg  [6:0] seg5
);

// 把24位拆成6个4位BCD
wire [3:0] num0 = din[3:0];
wire [3:0] num1 = din[7:4];
wire [3:0] num2 = din[11:8];
wire [3:0] num3 = din[15:12];
wire [3:0] num4 = din[19:16];
wire [3:0] num5 = din[23:20];

// ---------------------- seg0 ----------------------
always@(*)begin
    case(num0)
        4'd0: seg0 = 7'b100_0000;
        4'd1: seg0 = 7'b111_1001;
        4'd2: seg0 = 7'b010_0100;
        4'd3: seg0 = 7'b011_0000;
        4'd4: seg0 = 7'b001_1001;
        4'd5: seg0 = 7'b001_0010;
        4'd6: seg0 = 7'b000_0010;
        4'd7: seg0 = 7'b111_1000;
        4'd8: seg0 = 7'b000_0000;
        4'd9: seg0 = 7'b001_0000;
        default: seg0 = 7'b000_0000;
    endcase
end

// ---------------------- seg1 ----------------------
always@(*)begin
    case(num1)
        4'd0: seg1 = 7'b100_0000;
        4'd1: seg1 = 7'b111_1001;
        4'd2: seg1 = 7'b010_0100;
        4'd3: seg1 = 7'b011_0000;
        4'd4: seg1 = 7'b001_1001;
        4'd5: seg1 = 7'b001_0010;
        4'd6: seg1 = 7'b000_0010;
        4'd7: seg1 = 7'b111_1000;
        4'd8: seg1 = 7'b000_0000;
        4'd9: seg1 = 7'b001_0000;
        default: seg1 = 7'b000_0000;
    endcase
end

// ---------------------- seg2 ----------------------
always@(*)begin
    case(num2)
        4'd0: seg2 = 7'b100_0000;
        4'd1: seg2 = 7'b111_1001;
        4'd2: seg2 = 7'b010_0100;
        4'd3: seg2 = 7'b011_0000;
        4'd4: seg2 = 7'b001_1001;
        4'd5: seg2 = 7'b001_0010;
        4'd6: seg2 = 7'b000_0010;
        4'd7: seg2 = 7'b111_1000;
        4'd8: seg2 = 7'b000_0000;
        4'd9: seg2 = 7'b001_0000;
        default: seg2 = 7'b000_0000;
    endcase
end

// ---------------------- seg3 ----------------------
always@(*)begin
    case(num3)
        4'd0: seg3 = 7'b100_0000;
        4'd1: seg3 = 7'b111_1001;
        4'd2: seg3 = 7'b010_0100;
        4'd3: seg3 = 7'b011_0000;
        4'd4: seg3 = 7'b001_1001;
        4'd5: seg3 = 7'b001_0010;
        4'd6: seg3 = 7'b000_0010;
        4'd7: seg3 = 7'b111_1000;
        4'd8: seg3 = 7'b000_0000;
        4'd9: seg3 = 7'b001_0000;
        default: seg3 = 7'b000_0000;
    endcase
end

// ---------------------- seg4 ----------------------
always@(*)begin
    case(num4)
        4'd0: seg4 = 7'b100_0000;
        4'd1: seg4 = 7'b111_1001;
        4'd2: seg4 = 7'b010_0100;
        4'd3: seg4 = 7'b011_0000;
        4'd4: seg4 = 7'b001_1001;
        4'd5: seg4 = 7'b001_0010;
        4'd6: seg4 = 7'b000_0010;
        4'd7: seg4 = 7'b111_1000;
        4'd8: seg4 = 7'b000_0000;
        4'd9: seg4 = 7'b001_0000;
        default: seg4 = 7'b000_0000;
    endcase
end

// ---------------------- seg5 ----------------------
always@(*)begin
    case(num5)
        4'd0: seg5 = 7'b100_0000;
        4'd1: seg5 = 7'b111_1001;
        4'd2: seg5 = 7'b010_0100;
        4'd3: seg5 = 7'b011_0000;
        4'd4: seg5 = 7'b001_1001;
        4'd5: seg5 = 7'b001_0010;
        4'd6: seg5 = 7'b000_0010;
        4'd7: seg5 = 7'b111_1000;
        4'd8: seg5 = 7'b000_0000;
        4'd9: seg5 = 7'b001_0000;
        default: seg5 = 7'b000_0000;
    endcase
end

endmodule 