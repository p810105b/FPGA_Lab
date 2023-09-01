module snake(
    input clk,
    input rst_n,
    input sw,
    input btn_c,
    output [3:0] seg7_sel,
    output [7:0] seg7
);


reg [3:0] seg7_sel;
reg [7:0] seg7;
reg [7:0] seg7_temp [0:3];
reg [24:0] count;
reg [4:0] seg7_count; 
reg [2:0] s_count; 

wire d_clk;   
wire s_clk; 
	
always@(posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		count <= 0;
	else
		count <= count + 1;
end
	
assign d_clk = btn_c ? count[22] :count[23];
assign s_clk = count[16];
	
always@(posedge d_clk or negedge rst_n) 
begin
	if(!rst_n)
	    seg7_count <= 0;
	else 
		begin
		    if(!sw) 
				begin 
					if(seg7_count >= 23)
						seg7_count <= 0;
					else
						seg7_count <=  seg7_count - 1;
				end
			else 
				begin 
					if(seg7_count <= 0)
						seg7_count <= 23;
					else
						seg7_count <=  seg7_count + 1;
				end
		end
end
	
always@(posedge d_clk or negedge rst_n) 
begin
    if(!rst_n) 
		begin
			seg7_temp[0] <= 8'b0000_0001;
			seg7_temp[1] <= 8'b0000_0001;
			seg7_temp[2] <= 8'b0000_0001;
			seg7_temp[3] <= 8'b0000_0001;
		end
	else 
		begin
		    case(seg7_count)
				0:
					begin 
						seg7_temp[3]=8'b0000_0001;
						seg7_temp[2]=8'b0000_0001;
						seg7_temp[1]=8'b0000_0001;
						seg7_temp[0]=8'b0000_0001;
					end
				1:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_0001;
						seg7_temp[1]=8'b0000_0001;
						seg7_temp[0]=8'b0000_0011;
					end
				2:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0000_0001;
						seg7_temp[0]=8'b0000_0111;
					end
				3:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_1111;
					end
				4:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_1110;
					end
				5:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_1100;
					end
				6:
					begin 
						seg7_temp[3]=8'b0000_1000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_1000;
					end
				7:
					begin 
						seg7_temp[3]=8'b0001_1000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_0000;
					end
				8:
					begin 
						seg7_temp[3]=8'b0101_1000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				9:
					begin 
						seg7_temp[3]=8'b0101_1000;
						seg7_temp[2]=8'b0100_0000;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				10:
					begin 
						seg7_temp[3]=8'b0101_0000;
						seg7_temp[2]=8'b0100_0000;
						seg7_temp[1]=8'b0100_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				11:
					begin 
						seg7_temp[3]=8'b0100_0000;
						seg7_temp[2]=8'b0100_0000;
						seg7_temp[1]=8'b0100_0000;
						seg7_temp[0]=8'b0100_0000;
					end
				12:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0100_0000;
						seg7_temp[1]=8'b0100_0000;
						seg7_temp[0]=8'b0100_0100;
					end
				13:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0100_0000;
						seg7_temp[0]=8'b0100_1100;
					end
				14:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0100_1100;
					end
				15:
					begin 
						seg7_temp[3]=8'b0000_0000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_1100;
					end
				16:
					begin 
						seg7_temp[3]=8'b0000_1000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_1000;
					end
				17:
					begin 
						seg7_temp[3]=8'b0001_1000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_1000;
						seg7_temp[0]=8'b0000_0000;
					end
				18:
					begin 
						seg7_temp[3]=8'b0011_1000;
						seg7_temp[2]=8'b0000_1000;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				19:
					begin 
						seg7_temp[3]=8'b0011_1001;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				20:
					begin 
						seg7_temp[3]=8'b0011_1001;
						seg7_temp[2]=8'b0000_0000;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				21:
					begin 
						seg7_temp[3]=8'b0011_0001;
						seg7_temp[2]=8'b0000_0001;
						seg7_temp[1]=8'b0000_0000;
						seg7_temp[0]=8'b0000_0000;
					end
				22:
					begin 
						seg7_temp[3]=8'b0010_0001;
						seg7_temp[2]=8'b0000_0001;
						seg7_temp[1]=8'b0000_0001;
						seg7_temp[0]=8'b0000_0000;
					end
				23:
					begin 
						seg7_temp[3]=8'b0000_0001;
						seg7_temp[2]=8'b0000_0001;
						seg7_temp[1]=8'b0000_0001;
						seg7_temp[0]=8'b0000_0001;
					end
			endcase
		end
end
	
always@(posedge s_clk or negedge rst_n) 
	begin
	    if(!rst_n)
		    s_count <= 0;
		else 
			begin
				if(s_count>=3)
					s_count <= 0;
				else
					s_count <= s_count + 1;
			end
	end
	
	
always@(posedge s_clk or negedge rst_n) 
	begin
	    if(!rst_n) 
			begin
				seg7_sel <= 4'b1111;
				seg7 <= 8'b0000_0001;
			end
		else 
			begin
				case(s_count)
					0:seg7_sel <= 4'b0001;
					1:seg7_sel <= 4'b0010;
					2:seg7_sel <= 4'b0100;
					3:seg7_sel <= 4'b1000;
				endcase
				
			seg7 <= seg7_temp[s_count];
			end
    end
	
endmodule