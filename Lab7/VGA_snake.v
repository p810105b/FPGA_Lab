module VGA( 
    input rst_n,
    input btn_u,  //up
    input btn_l,  //left
    input btn_d,  //down
    input btn_r,  //right
    input clk,    //100MHz
    output VGA_HS,    //Horizontal synchronize signal
    output VGA_VS,    //Vertical synchronize signal
    output [3:0] VGA_R,    //Signal RED
    output [3:0] VGA_G,    //Signal Green
    output [3:0] VGA_B     //Signal Blue
);


parameter UP      = 3'b000;
parameter DOWN    = 3'b001;
parameter LEFT    = 3'b010;
parameter RIGHT   = 3'b011;

parameter T_UP    = 3'b100;
parameter T_DOWN  = 3'b101;
parameter T_LEFT  = 3'b110;
parameter T_RIGHT = 3'b111;

//Horizontal Parameter
parameter H_FRONT = 16;
parameter H_SYNC  = 96;
parameter H_BACK  = 48;
parameter H_ACT   = 640;
parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

//Vertical Parameter
parameter V_FRONT = 10;
parameter V_SYNC  = 2;
parameter V_BACK  = 33;
parameter V_ACT   = 480;
parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

// clock
wire 		clk_25;		// 25MHz clk for VGA scan
wire        clk_1S;		// 3  Hz clk for snake moving
reg [25:0]	count;

reg [9:0] H_cnt;
reg [9:0] V_cnt;

reg vga_hs;    //register for horizontal synchronize signal
reg vga_vs;    //register for vertical synchronize signal

reg [9:0] X;    //from 1~640
reg [8:0] Y;    //from 1~480

// snake variable
reg [2:0] length; 		// 2~5

reg [1:0] direction;

// divide pixel into 40*40 ( 40*16 = 640 , 40*12 = 480 ) 
reg [3:0] head_x; 		// 0~15
reg [3:0] head_y; 		// 0~11
reg [3:0] temp_x_2; 	// 0~15
reg [3:0] temp_y_2; 	// 0~11
reg [3:0] temp_x_3; 	// 0~15
reg [3:0] temp_y_3; 	// 0~11
reg [3:0] temp_x_4; 	// 0~15
reg [3:0] temp_y_4; 	// 0~11
reg [3:0] temp_x_5; 	// 0~15
reg [3:0] temp_y_5; 	// 0~11
reg [3:0] turn_x; 		// 0~15
reg [3:0] turn_y; 		// 0~11

// apple variable
reg [3:0] apple_x; 		// 0~15
reg [3:0] apple_y; 		// 0~11


assign VGA_HS = vga_hs;
assign VGA_VS = vga_vs;

reg [11:0] VGA_RGB;

assign VGA_R = VGA_RGB[11:8];
assign VGA_G = VGA_RGB[7:4];
assign VGA_B = VGA_RGB[3:0];

// 100 MHz -> 25MHz , 100 MHz -> 3Hz  
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		count <= 0;
	else
		count <= count + 1;
end
	
assign clk_25 = count[1];  // 25MHz
assign clk_1S = count[22]; // 3Hz

// button 
always @(posedge clk_25 or negedge rst_n) begin
	if(!rst_n) begin
		direction <= RIGHT;
	end
	else begin
		case(direction)
			UP : begin
				if(btn_l) begin 
					direction <= T_LEFT; 
					turn_x 	  <= head_x; 
					turn_y    <= head_y; 
				end
				else if(btn_r) begin 
					direction <= T_RIGHT; 
					turn_x 	  <= head_x; 
					turn_y    <= head_y; 
				end
				else 
					direction <= UP;
			end
			DOWN : begin
				if(btn_l begin 
					direction <= T_LEFT; 
					turn_x 	  <= head_x; 
					turn_y    <= head_y; 
				end
				else if (btn_r) begin 
					direction <= T_RIGHT; 
					turn_x    <= head_x; 
					turn_y    <= head_y; 
				end
				else 
					direction <= DOWN;
			end
			LEFT : begin
				if(btn_u) begin 
					direction <= T_UP; 
					turn_x    <= head_x; 
					turn_y    <= head_y; 
				end
				else if (btn_d) begin 
					direction <= T_DOWN; 
					turn_x    <= head_x; 
					turn_y    <= head_y; 
				end
				else 
					direction <= LEFT;
			end
			RIGHT : begin
				if(btn_u) begin 
					direction <= T_UP; 
					turn_x    <= head_x; 
					turn_y    <= head_y; 
				end
				else if(btn_d) begin 
					direction <= T_DOWN; 
					turn_x    <= head_x; 
					turn_y    <= head_y; 
				end
				else 
					direction <= RIGHT;
			end
			default : direction <= direction;
		endcase
	end
end


always@(posedge clk_1S or negedge rst_n) begin
	// initial position
	if(!rst_n) begin
		length  <= 5;
		head_x  <= 5;  temp_x_2 <= 4; temp_x_3 <= 3; temp_x_4 <= 2; temp_x_5 <= 1;
		head_y  <= 5;  temp_y_2 <= 4; temp_y_3 <= 3; temp_y_4 <= 2; temp_y_5 <= 1;
		apple_x <= 10; apple_y  <= 10;
	end
	// button control
	else begin
		case(direction)
			RIGHT : begin
				head_x <= head_x + 1;
				head_y <= head_y;
			end
			LEFT : begin
				head_x <= head_x - 1;
				head_y <= head_y;
			end
			UP : begin
			 	head_x <= head_x;
			 	head_y <= head_y - 1;
			 end
			DOWN : begin
				head_x <= head_x;
				head_y <= head_y + 1;
			end	
			T_UP : begin
				head_x    <= turn_x;
				head_y    <= head_y - 1;
				direction <= UP;
			end
			T_DOWN : begin
				head_x <= turn_x;
				head_y <= head_y + 1;
				direction <= DOWN;
			end
			T_LEFT : begin
				head_x <= turn_x - 1;
				head_y <= head_y;
				direction <= LEFT;
			end
			T_RIGHT : begin
				head_x <= turn_x + 1;
				head_y <= head_y;
				direction <= RIGHT;
			end
			default : begin
				head_x <= head_x;
				head_y <= head_y;
				direction <= direction;
			end
		endcase
			
		temp_x_2 <= head_x;
		temp_y_2 <= head_y;
		
		temp_x_3 <= temp_x_2;
		temp_y_3 <= temp_y_2;
		
		temp_x_4 <= temp_x_3;
		temp_y_4 <= temp_y_3;
		
		temp_x_5 <= temp_x_4;
		temp_y_5 <= temp_y_4;
		
		// collision apple
		if((head_x == apple_x) && (head_y == apple_y)) begin // overlap for apple and head
		
			// next apple position generator
			apple_x <= apple_x + head_y;
			apple_y <= apple_y + head_x;
			
			if(length > 2) 
				length <= length - 1;
			else 
				length <= 2;
		end
		else begin
			apple_x <= apple_x;
			apple_y <= apple_y;
		end
	end
end


//Horizontal counter
always@(posedge clk_25 or negedge rst_n) begin    //count 0~800
    H_cnt <= (!rst_n)? H_TOTAL : (H_cnt < H_TOTAL)?  H_cnt+1'b1 : 10'd0; 
end

//Vertical counter
always@(posedge VGA_HS or negedge rst_n) begin    //count 0~525
    V_cnt <= (!rst_n)? V_TOTAL : (V_cnt < V_TOTAL)?  V_cnt+1'b1 : 10'd0; 
end

//Horizontal Generator: Refer to the pixel clock
always@(posedge clk_25 or negedge rst_n) begin
    if(!rst_n) begin
        vga_hs <= 1;
        X      <= 0;
    end
    else begin
        //Horizontal Sync
        if(H_cnt<=H_SYNC)    //Sync pulse start
            vga_hs <= 1'b0;    //horizontal synchronize pulse
        else
            vga_hs <= 1'b1;
        //Current X
        if( (H_cnt>=H_SYNC+H_BACK) && (H_cnt<=H_TOTAL-H_FRONT) )
            X <= X + 1;
        else
            X <= 0;
    end
end

//Vertical Generator: Refer to the horizontal sync
always@(posedge VGA_HS or negedge rst_n) begin
    if(!rst_n) begin
        vga_vs <= 1;
        Y      <= 0;
    end
    else begin
        //Vertical Sync
        if (V_cnt<=V_SYNC)    //Sync pulse start
            vga_vs <= 0;
        else
            vga_vs <= 1;
        //Current Y
        if( (V_cnt>=V_SYNC+V_BACK) && (V_cnt<=V_TOTAL-V_FRONT) )
            Y <= Y + 1;
        else
            Y <= 0;
    end
end


//VGA Display
integer i; // x
integer j; // y

always@(*) begin
	for(i = 0; i < 16; i = i + 1) begin
		for(j = 0; j < 16; j = j + 1) begin
			if((i*40 + 4) <= X && X <= (i*40 + 37) && (j*40 + 4) <= Y && Y <= (j*40 + 37) ) begin
				if((head_x == i) && (head_y == j)) 
					VGA_RGB = 12'hfff;
				else if((temp_x_2 == i) && (temp_y_2 == j)) 
					VGA_RGB = 12'hfff;
				else if((length >= 3)   && (temp_x_3 == i) && (temp_y_3 == j)) 
					VGA_RGB = 12'hfff;
				else if((length >= 4)   && (temp_x_4 == i) && (temp_y_4 == j)) 
					VGA_RGB = 12'hfff;
				else if((length >= 5)   && (temp_x_5 == i) && (temp_y_5 == j)) 
					VGA_RGB = 12'hfff;
				else if((apple_x == i)  && (apple_y == j)) 
					VGA_RGB <= 12'hf00;
				else 
					VGA_RGB = 12'h000;
			end
		end
	end
end

endmodule 
