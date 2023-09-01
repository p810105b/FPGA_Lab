`timescale 1ns / 1ps

//====== module ======
module seg7_counter_a(
    input clk,
    input rst_n,
	input btn_c,
	output [15:0] led,
    output [7:0]  seg7,
    output [7:0]  seg7_sel
);

//====== Register ======
reg [7:0] seg7;
reg [3:0] seg7_cnt;
reg [24:0] count;
reg [15:0] led;

wire d_clk;

//====== frequency division ======
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        count <= 0;
    else
        count <= count + 1;
end

assign d_clk = btn_c ? count[22] : count[23] ;

//====== Set the chip select signal ======
assign seg7_sel = 8'b0000_0001;

//====== Seven segment display light control ======
always @(posedge d_clk or negedge rst_n)begin
    if(!rst_n)
        seg7_cnt <= 0;
    else
        seg7_cnt <= seg7_cnt + 1;
end

always @(posedge d_clk or negedge rst_n)begin
    if(!rst_n)
        seg7 <= 8'b1111_1111;
    else begin
        case(seg7_cnt)
            0:seg7  <= 8'b0011_1111;
            1:seg7  <= 8'b0000_0110;
            2:seg7  <= 8'b0101_1011;
            3:seg7  <= 8'b0100_1111;
            4:seg7  <= 8'b0110_0110;
            5:seg7  <= 8'b0110_1101;
            6:seg7  <= 8'b0111_1101;
            7:seg7  <= 8'b0000_0111;
			8:seg7  <= 8'b0111_1111;
			9:seg7  <= 8'b0110_1111;
			10:seg7 <= 8'b1111_0111;
			11:seg7 <= 8'b1111_1100;
			12:seg7 <= 8'b1101_1000;
			13:seg7 <= 8'b1101_1110;
			14:seg7 <= 8'b1111_1001;
			15:seg7 <= 8'b1111_0001;
            default: seg7 <= 8'b1111_1111;
        endcase
    end
end

always@(posedge d_clk or negedge rst_n)
begin
	if(!rst_n)
		led <= 16'b0000_0000_0000_0000;
	else 
		begin
			case(seg7_cnt)
				4'd0  : led <= 16'b0000_0000_0000_0000;
				4'd1  : led <= 16'b1000_0000_0000_0000;
				4'd2  : led <= 16'b1100_0000_0000_0000;
				4'd3  : led <= 16'b1110_0000_0000_0000;
				4'd4  : led <= 16'b1111_1000_0000_0000;
				4'd5  : led <= 16'b1111_1100_0000_0000;
				4'd6  : led <= 16'b1111_1110_0000_0000;
				4'd7  : led <= 16'b1111_1111_0000_0000;
				4'd8  : led <= 16'b1111_1111_1000_0000;
				4'd9  : led <= 16'b1111_1111_1100_0000;
				4'd10 : led <= 16'b1111_1111_1110_0000;
				4'd11 : led <= 16'b1111_1111_1111_0000;
				4'd12 : led <= 16'b1111_1111_1111_1000;
				4'd13 : led <= 16'b1111_1111_1111_1100;
				4'd14 : led <= 16'b1111_1111_1111_1110;
				4'd15 : led <= 16'b1111_1111_1111_1111;
				default:led <= 16'b1111_1111_1111_1111;
			endcase
		end
end

endmodule