`define CYCLE 100000 // 單一cycle 長度

//模組名稱
module seg7_switch_a( clk, rst_n, switch, seg7, seg7_sel);
	
	input clk;
	input rst_n;
	input [7:0] switch;
	output [7:0] seg7;
	output [3:0] seg7_sel;
	
	//暫存器宣告
	reg [7:0] seg7;
	reg [3:0] seg7_sel;
	reg [3:0] seg7_temp [0:3];
	reg [1:0] seg7_count;
	
	reg [29:0] count;
	wire d_clk;
	
	//除頻
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			count <= 0;
		else if (count >= `CYCLE)
			count <= 0;
		else
			count <= count + 1;
	end
	assign d_clk = count > (`CYCLE/2) ? 0 : 1;
	
	//switch 二進位轉
	always @(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					seg7_temp[0] <= 0;
					seg7_temp[1] <= 0;
					seg7_temp[2] <= 0;
					seg7_temp[3] <= 0;
				end
			else 
				begin
				//switch後四位轉無號數
					if( switch[3:0] > 10)
						begin
							seg7_temp[1] <= 1;
							seg7_temp[0] <= switch[3:0] - 10;
						end
					else
						begin
							seg7_temp[1] <= 0;
							seg7_temp[0] <= switch[3:0];
						end
				
				//switch前四位轉二補數
					if(switch[7] == 1)
						begin
							seg7_temp[3] <= 10; // negative
							case( switch[6:4] )
								3'b000 : seg7_temp[2] <= 4'd8;
								3'b001 : seg7_temp[2] <= 4'd7;
								3'b010 : seg7_temp[2] <= 4'd6;
								3'b011 : seg7_temp[2] <= 4'd5;
								3'b100 : seg7_temp[2] <= 4'd4;
								3'b101 : seg7_temp[2] <= 4'd3;
								3'b110 : seg7_temp[2] <= 4'd2;
								3'b111 : seg7_temp[2] <= 4'd1;
							endcase 	
						end
					else
						begin
							seg7_temp[3] <=  0;
							seg7_temp[2] <= switch[6:4];	
						end
				end
		end
	
	
	//七段顯示器顯示
	always @(posedge d_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					seg7_count <= 0;
				end
			else 
				begin
					seg7_count <= seg7_count + 1;
				end
		end
	
	always @(posedge d_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					seg7_sel <= 0;
					seg7 <= 0;
				end
			else 
				begin
					case(seg7_count)
						0:	seg7_sel <= 4'b0001;
						1:	seg7_sel <= 4'b0010;
						2:	seg7_sel <= 4'b0100;
						3:	seg7_sel <= 4'b1000;
					endcase
					
					case(seg7_temp[seg7_count])
					   10:seg7 <= 8'b0100_0000;
						0:seg7 <= 8'b0011_1111;
						1:seg7 <= 8'b0000_0110;
						2:seg7 <= 8'b0101_1011;
						3:seg7 <= 8'b0100_1111;
						4:seg7 <= 8'b0110_0110;
						5:seg7 <= 8'b0110_1101;
						6:seg7 <= 8'b0111_1101;
						7:seg7 <= 8'b0000_0111;
						8:seg7 <= 8'b0111_1111;
						9:seg7 <= 8'b0110_1111;
					endcase
				end
		end
	
endmodule
