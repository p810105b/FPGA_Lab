module VGA_a( 
	input 				rst_n,
	input          		clk,      // 100 MHz
	input 				btn_c,
	output         		VGA_HS,        // Horizontal synchronize signal
	output         		VGA_VS,        // Vertical synchronize signal
	output		[3:0]	VGA_R,	// Signal RED  
	output		[3:0]	VGA_G,	// Signal Green   
	output		[3:0]	VGA_B	// Signal Blue
);
// Horizontal Parameter
parameter H_FRONT = 16;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_ACT   = 640;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

// Vertical Parameter
parameter V_FRONT = 10;
parameter V_SYNC  = 2;
parameter V_BACK  = 33;
parameter V_ACT   = 480;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

wire 		clk_25;		// 25MHz clk
reg [1:0]	count;

reg [9:0] 	H_cnt; 
reg [9:0] 	V_cnt;
reg       	vga_hs;		// register for horizontal synchronize signal
reg       	vga_vs;		// register for vertical synchronize signal
reg [9:0] 	X;			// from 1~640
reg [8:0] 	Y;			// from 1~480

assign VGA_HS = vga_hs;
assign VGA_VS = vga_vs;

reg [11:0]	VGA_RGB;


// 除頻   100 MHz -> 25MHz
always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			count <= 0;
		else
			count <= count + 1;
	end
	
assign clk_25 = count[1];


// Horizontal counter
always@(posedge clk_25, negedge rst_n) // count 0~800
	H_cnt <= (!rst_n)? H_TOTAL : (H_cnt < H_TOTAL)?  H_cnt+1'b1 : 10'd0; 
	
// vertical counter
always@(posedge VGA_HS, negedge rst_n) // count 0~525
	V_cnt <= (!rst_n)? V_TOTAL : (V_cnt < V_TOTAL)?  V_cnt+1'b1 : 10'd0; 
	
	
// Horizontal Generator: Refer to the pixel clock
always@(posedge clk_25, negedge rst_n)
	begin 
		if(!rst_n) 
			begin
				vga_hs <= 1;
				X      <= 0;
			end
		else 
			begin
				// Horizontal Sync
				if( H_cnt < H_SYNC ) 
					vga_hs <= 1'b0;
				else
					vga_hs <= 1'b1;
				// Current X
				if( (H_cnt >= H_SYNC + H_BACK) && (H_cnt < H_SYNC + H_BACK + H_ACT) ) 
					X <= (X + 1);
				else
					X <= 0;
			end
	end
	
// Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS, negedge rst_n) 
	begin
		if(!rst_n) 
			begin
				vga_vs <= 1;
				Y      <= 0;
			end
		else 
			begin      
				// Vertical Sync
				if ( V_cnt <V_SYNC ) 
					vga_vs <= 0;
				else
					vga_vs <= 1;
				// Current Y
				if( (V_cnt >= V_SYNC + V_BACK) && (V_cnt < V_SYNC + V_BACK + V_ACT) )
					Y <= (Y + 1);
				else
					Y <= 0;
			end
	end


// pattern 組合邏輯電路

always@(*) 
	begin
		 if(btn_c) 
			begin  // 119號
				// 數字1
				if( (X > 100) && (X <=150) && (Y > 150) && (Y <= 330) ) 
					VGA_RGB = 12'hf00;
				// 數字1	
				else if( (X > 250) && (X <=300) && (Y > 150) && (Y <= 330) )
					VGA_RGB = 12'hff0;
				// 數字9	
				else if( (X > 400) && (X <=550) && (Y > 150) && (Y <= 180) )
					VGA_RGB = 12'hfff;
				else if( (X > 400) && (X <=500) && (Y > 250) && (Y <= 280) )
					VGA_RGB = 12'hfff;
				else if( (X > 400) && (X <=500) && (Y > 310) && (Y <= 340) )
					VGA_RGB = 12'hfff;
				else if( (X > 500) && (X <=550) && (Y > 150) && (Y <= 340) )
					VGA_RGB = 12'hfff;
				else if( (X > 400) && (X <=450) && (Y > 150) && (Y <= 250) )
					VGA_RGB = 12'hfff;
				else
					VGA_RGB = 12'h000;
			end
			
		else
			begin
				// 圓形
				if( (X-320)*(X-320) + (Y-125)*(Y-125) <= 2500 ) 
					VGA_RGB = 12'hf00; // 紅色
				// 三角形
				else if( (199*X + 100*Y >= 63780) && (199*X - 100*Y <= 63580) && (Y < 199))
					VGA_RGB = 12'h00f; // 藍色
				// 矩形
				else if( (X >= 220) && (X <= 420) && (Y >  200) && (Y <= 300) )
					VGA_RGB = 12'h0f0; // 綠色
				// 矩形	
				else if( (X >= 100) && (X <= 540) && (Y > 300) && (Y <= 400) )
					VGA_RGB = 12'hf0f; // 洋紅
				// 背景
				else
					VGA_RGB = 12'h000; // 黑色
					
			end

	end
	
	
assign VGA_R = VGA_RGB[11:7];
assign VGA_G = VGA_RGB[7:4];
assign VGA_B = VGA_RGB[3:0];

endmodule
