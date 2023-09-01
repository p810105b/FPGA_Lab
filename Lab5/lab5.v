`define CYCLE 140000

module lab5(clk, rst_n, btn_c, seg7, seg7_sel);
input clk;
input rst_n;
input btn_c;

output reg seg7;
output reg seg7_sel;

reg [20:0] count;
wire d_clk;

reg press_flag;
wire btn_c_pluse;

reg [7:0] press_count;

reg [7:0] seg7_temp [0:3];
reg [1:0] seg7_count;

always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			count <= 0;
		else
			begin
				if(count >= `CYCLE)
					count <= 0;
				else
					count <= count + 1;
			end
	end
	
assign d_clk = count >= `CYCLE ? 1 : 0;

// one shot pluse signal
always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			press_flag <= 0;
		else
			press_flag <= btn_c;
	end

assign btn_c_pluse = {btn_c , press_flag} == 2'b10 ? 1 : 0;

always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			press_count <= 0;
		else
			begin
				if(btn_c_pluse)
					press_count <= press_count + 1;
				else
					press_count <= press_count;
			end
	end
	
always@(posedge clk or negedge rst_n)
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
				seg7_temp[3] <= press_count / 1000;
				seg7_temp[2] <= (press_count % 1000) / 100;
				seg7_temp[1] <= (press_count % 100) / 10;
				seg7_temp[0] <= press_count % 10;
			end
	end
	

always @(posedge d_clk or negedge rst_n)
	begin
		if(!rst_n)
			seg7_count <= 0;
		else
			seg7_count <= seg7_count + 1;
	end
	
always @(posedge d_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					seg7_sel <= 4'b1111;
					seg7 <= 8'b0011_1111;
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