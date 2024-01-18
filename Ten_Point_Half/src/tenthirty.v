module tenthirty(
    input clk,
    input rst_n, //negedge reset
    input btn_m, //bottom middle
    input btn_r, //bottom right
    output reg [7:0] seg7_sel,
    output reg [7:0] seg7,   //segment right
    output reg [7:0] seg7_l, //segment left
    output reg [2:0] led//, // led[0] : player win, led[1] : dealer win, led[2] : done
	//output reg [2:0] state,
	//output reg [2:0] next_state,
	//output reg pip,
	//output reg player_done,
	//output reg dealer_done,
	//output [3:0] number,
	//output reg [3:0] picked_number,
	//output reg [2:0] pick_times,
	//output reg [5:0] player_total,
	//output reg [5:0] dealer_total,
	//output reg winner,
	//output reg [3:0] int_part,
	//output reg [2:0] round,
	//output [7:0] inhand_cards_0,
	//output [7:0] inhand_cards_1,
	//output [7:0] inhand_cards_2,
	//output [7:0] inhand_cards_3,
	//output [7:0] inhand_cards_4,
	//output btn_m_pluse,
	//output btn_r_pluse,
	//output reg player_pass_flag,
	//output reg dealer_pass_flag,
	//output [3:0] player_total_digit, 
	//output [3:0] dealer_total_digit 
);

//================================================================
//   PARAMETER
//================================================================
parameter IDLE     		  = 3'd0;
parameter BEGINING        = 3'd1;
parameter HIT_CARD_PLAYER = 3'd2;
parameter HIT_CARD_DEALER = 3'd3;
parameter COMPARE  		  = 3'd4;
parameter DONE 	  		  = 3'd5;

parameter player = 1'b0;
parameter dealer = 1'b1;
//================================================================
//   d_clk
//================================================================
//frequency division
reg [24:0] counter; 
wire dis_clk; //seg display clk, frequency faster than d_clk
wire d_clk  ; //division clk

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
    end
end

assign dis_clk = counter[2];//clk;
assign d_clk   = counter[5];//clk;

//================================================================
//   REG/WIRE
//================================================================
//store segment display situation
reg [7:0] seg7_temp[0:7]; 
//display counter
reg [2:0] dis_cnt;
//LUT IO
reg  pip;
wire [3:0] number;

reg [2:0] state, next_state;
reg [4:0] inhand_cards [0:4];
reg [2:0] round;
reg [5:0] player_total;
reg [5:0] dealer_total;

reg [3:0] int_part;
reg [2:0] pick_times;
reg [3:0] picked_number;

reg player_done;
reg dealer_done;

reg winner;


// one shot pulse
reg press_flag_1, press_flag_2;
wire btn_m_pluse;
wire btn_r_pluse;
always@(posedge d_clk or negedge rst_n) begin
	if(!rst_n) begin
		press_flag_1 <= 1'b0;
		press_flag_2 <= 1'b0;
	end
	else begin
		press_flag_1 <= btn_m;
		press_flag_2 <= btn_r;
	end
end	
assign btn_m_pluse = {btn_m, press_flag_1} == 2'b10 ? 1'b1 : 1'b0;
assign btn_r_pluse = {btn_r, press_flag_2} == 2'b10 ? 1'b1 : 1'b0;


//================================================================
//   FSM
//================================================================
always@(posedge d_clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= next_state;
	end
end

// next state logic
always@(*) begin
	case(state)
		IDLE 			: next_state = (pip == 1'b1) ? BEGINING : IDLE;
		BEGINING        : next_state = HIT_CARD_PLAYER; 
		HIT_CARD_PLAYER : next_state = (player_done == 1'b1) ? HIT_CARD_DEALER : HIT_CARD_PLAYER;
		HIT_CARD_DEALER : next_state = (dealer_done == 1'b1) ? COMPARE : HIT_CARD_DEALER;
		COMPARE  		: next_state = (round == 3'd4) ? DONE : (btn_r_pluse == 1'b1) ? IDLE : COMPARE; 
		DONE 	  		: next_state = DONE; 
		default  		: next_state = IDLE; 
	endcase
end

//================================================================
//   DESIGN
//================================================================


//pip 
always@(posedge d_clk or negedge rst_n) begin
	if(!rst_n) pip <= 1'b0;
	else pip <= btn_m_pluse;
end

// round
always@(posedge dealer_done or negedge rst_n) begin
	if(!rst_n) round <= 1'b0;
	else if(dealer_done == 1'b1) round = round + 3'd1;
end

// pick_times
always@(posedge d_clk or negedge rst_n) begin
	if(!rst_n) begin
		pick_times <= 3'd0;
	end
	else begin
		case(state)
			IDLE 		    : pick_times = 3'd0;
			BEGINING        : pick_times = 3'd1;
			HIT_CARD_PLAYER : pick_times = (player_done == 1'b1) ? 3'd0 :
										   (pip == 1'b1) ? pick_times + 3'd1 : pick_times;
			HIT_CARD_DEALER : pick_times = (dealer_done == 1'b1) ? 3'd0 :
										   (pip == 1'b1) ? pick_times + 3'd1 : pick_times;
		endcase
	end
end

// total score
always@(negedge d_clk or negedge rst_n) begin
	if(!rst_n) begin
		player_total = 6'd0;
		dealer_total = 6'd0;
	end
	else begin
		case(state)
			IDLE : begin
				player_total = 6'd0;
				dealer_total = 6'd0;
			end
			BEGINING        : player_total = (picked_number == 11) ? player_total + 6'b00_0001 : (picked_number == 0) ?  player_total : player_total + (int_part<<1'b1);
			HIT_CARD_PLAYER : player_total = (picked_number == 11) ? player_total + 6'b00_0001 : (picked_number == 0) ?  player_total : player_total + (int_part<<1'b1);
			HIT_CARD_DEALER : dealer_total = (picked_number == 11) ? dealer_total + 6'b00_0001 : (picked_number == 0) ?  dealer_total : dealer_total + (int_part<<1'b1);
		endcase
	end
end


// done control
always@(posedge d_clk or negedge rst_n) begin
	if(!rst_n) begin
		player_done = 1'b0;
		dealer_done = 1'b0;
	end
	else begin
		case(state)
			IDLE : begin
				player_done = 1'b0;
				dealer_done = 1'b0;
			end
			HIT_CARD_PLAYER : player_done  = (player_done == 1'b1) ? 1'b0 : 
											 ((pick_times == 5) || (player_total > 6'b010101) || (btn_r_pluse == 1'b1)) ? 1'b1 : 1'b0;
			//player_done  = ((pick_times == 5) || (player_total > 6'b010101) || (btn_r_pluse == 1'b1) || (player_done != 1'b1)) ? 1'b1 : 1'b0;
			HIT_CARD_DEALER : dealer_done  = (dealer_done == 1'b1) ? 1'b0 : 
											 ((pick_times == 5) || (dealer_total > 6'b010101) || (btn_r_pluse == 1'b1)) ? 1'b1 : 1'b0;
		endcase
	end
end

/*
// done control
always@(pick_times or state or player_total or btn_r_pluse) begin
	case(state)
		IDLE : begin
			player_done = 1'b0;
			dealer_done = 1'b0;
		end
		HIT_CARD_PLAYER : player_done  = ((pick_times == 5) || (player_total > 6'b010101) || (btn_r_pluse == 1'b1)) ? 1'b1 : 1'b0;
		HIT_CARD_DEALER : dealer_done  = ((pick_times == 5) || (dealer_total > 6'b010101) || (btn_r_pluse == 1'b1)) ? 1'b1 : 1'b0;
	endcase
end
*/

// pip number revise number=11 for 0.5 representation  
always@(*) begin
	int_part      = (number < 11) ? number : 4'd0;
	picked_number = (btn_r_pluse == 1'b1) ? 4'd0 : 
				    (number > 10)   ? 11   : number;
end			
					   
// determine winner 
reg player_pass_flag;
reg dealer_pass_flag;
always@(*) begin
	if(state == IDLE) begin
		player_pass_flag = 1'b0;
		dealer_pass_flag = 1'b0;
	end
	if(state == HIT_CARD_PLAYER) begin
		player_pass_flag = (pick_times == 5) && (player_total <= 6'b010101) ? 1'b1 : player_pass_flag;
	end
	else if(state == HIT_CARD_DEALER) begin
		dealer_pass_flag = (pick_times == 5) && (dealer_total <= 6'b010101) ? 1'b1 : dealer_pass_flag;
	end
end

always@(*) begin
	if(state == COMPARE || state == DONE) begin
		if(dealer_pass_flag == 1'b1) winner = dealer;
		else if(player_pass_flag == 1'b1) winner = player;
		else if(player_total > 6'b010101) winner = dealer;
		else if(dealer_total > 6'b010101) winner = player;
		else if(player_total > dealer_total) winner = player;
		else if(player_total < dealer_total) winner = dealer;
		else winner = dealer;
	end
	else begin 
		winner = 1'bz; 
	end
end				

// inhand card reg
always@(negedge d_clk or negedge rst_n)begin
	if(!rst_n) begin
		inhand_cards[0] = 4'd0;
		inhand_cards[1] = 4'd0;
		inhand_cards[2] = 4'd0;
		inhand_cards[3] = 4'd0;
		inhand_cards[4] = 4'd0;
	end
	else if(player_done == 1'b1 || dealer_done == 1'b1) begin
		inhand_cards[0] = 4'd0;
		inhand_cards[1] = 4'd0;
		inhand_cards[2] = 4'd0;
		inhand_cards[3] = 4'd0;
		inhand_cards[4] = 4'd0;
	end
	else begin
		if(picked_number != 4'd0) begin
			case(state)
				IDLE : begin
					inhand_cards[0] = 4'd0;
					inhand_cards[1] = 4'd0;
					inhand_cards[2] = 4'd0;
					inhand_cards[3] = 4'd0;
					inhand_cards[4] = 4'd0;
				end
				BEGINING : begin
					inhand_cards[0] = picked_number;
				end
				HIT_CARD_PLAYER : begin
					case(pick_times)
						3'd2 : inhand_cards[1] = picked_number;
						3'd3 : inhand_cards[2] = picked_number;
						3'd4 : inhand_cards[3] = picked_number;
						3'd5 : inhand_cards[4] = picked_number;
						default : inhand_cards[0] = 3'd0;
					endcase
				end
				HIT_CARD_DEALER : begin
					case(pick_times)
						3'd1 : inhand_cards[0] = picked_number;
						3'd2 : inhand_cards[1] = picked_number;
						3'd3 : inhand_cards[2] = picked_number;
						3'd4 : inhand_cards[3] = picked_number;
						3'd5 : inhand_cards[4] = picked_number;
						default : inhand_cards[0] = 3'd0;
					endcase
				end
				//COMPARE :
				//DONE :
				//default : 
			endcase
		end
	end
end
	   

assign inhand_cards_0 = inhand_cards[0];
assign inhand_cards_1 = inhand_cards[1];
assign inhand_cards_2 = inhand_cards[2];
assign inhand_cards_3 = inhand_cards[3];
assign inhand_cards_4 = inhand_cards[4];

// number display format for 7-seg
parameter num_0_format = 8'b0011_1111; //63  3f
parameter num_1_format = 8'b0000_0110; //6   6
parameter num_2_format = 8'b0101_1011; //91  5b
parameter num_3_format = 8'b0100_1111; //79  4f
parameter num_4_format = 8'b0110_0110; //102 66 
parameter num_5_format = 8'b0110_1101; //109 6d
parameter num_6_format = 8'b0111_1101; //125 7d 
parameter num_7_format = 8'b0000_0111; //7   7
parameter num_8_format = 8'b0111_1111; //127 7f
parameter num_9_format = 8'b0110_1111; //111 6f
parameter point_format = 8'b1000_0000; //128 80
parameter line_format  = 8'b0000_0001; //1   1

wire [7:0] digit_display_0,
		   digit_display_1,
		   digit_display_2,
		   digit_display_3,
		   digit_display_4,
		   player_total_digit_display,
		   dealer_total_digit_display;
		   
//wire [3:0] player_total_digit, dealer_total_digit; 

assign digit_display_0 = inhand_cards[0] == 10 ? num_0_format : 
						 inhand_cards[0] == 1  ? num_1_format : 
						 inhand_cards[0] == 2  ? num_2_format : 
						 inhand_cards[0] == 3  ? num_3_format : 
						 inhand_cards[0] == 4  ? num_4_format : 
						 inhand_cards[0] == 5  ? num_5_format : 
						 inhand_cards[0] == 6  ? num_6_format : 
						 inhand_cards[0] == 7  ? num_7_format : 
						 inhand_cards[0] == 8  ? num_8_format : 
						 inhand_cards[0] == 9  ? num_9_format : point_format;

assign digit_display_1 = inhand_cards[1] == 10 ? num_0_format : 
						 inhand_cards[1] == 1  ? num_1_format : 
						 inhand_cards[1] == 2  ? num_2_format : 
						 inhand_cards[1] == 3  ? num_3_format : 
						 inhand_cards[1] == 4  ? num_4_format : 
						 inhand_cards[1] == 5  ? num_5_format : 
						 inhand_cards[1] == 6  ? num_6_format : 
						 inhand_cards[1] == 7  ? num_7_format : 
						 inhand_cards[1] == 8  ? num_8_format : 
						 inhand_cards[1] == 9  ? num_9_format : point_format;

assign digit_display_2 = inhand_cards[2] == 10 ? num_0_format : 
						 inhand_cards[2] == 1  ? num_1_format : 
						 inhand_cards[2] == 2  ? num_2_format : 
						 inhand_cards[2] == 3  ? num_3_format : 
						 inhand_cards[2] == 4  ? num_4_format : 
						 inhand_cards[2] == 5  ? num_5_format : 
						 inhand_cards[2] == 6  ? num_6_format : 
						 inhand_cards[2] == 7  ? num_7_format : 
						 inhand_cards[2] == 8  ? num_8_format : 
						 inhand_cards[2] == 9  ? num_9_format : point_format;					 

assign digit_display_3 = inhand_cards[3] == 10 ? num_0_format : 
						 inhand_cards[3] == 1  ? num_1_format : 
						 inhand_cards[3] == 2  ? num_2_format : 
						 inhand_cards[3] == 3  ? num_3_format : 
						 inhand_cards[3] == 4  ? num_4_format : 
						 inhand_cards[3] == 5  ? num_5_format : 
						 inhand_cards[3] == 6  ? num_6_format : 
						 inhand_cards[3] == 7  ? num_7_format : 
						 inhand_cards[3] == 8  ? num_8_format : 
						 inhand_cards[3] == 9  ? num_9_format : point_format;
						 
assign digit_display_4 = inhand_cards[4] == 10 ? num_0_format : 
						 inhand_cards[4] == 1  ? num_1_format : 
						 inhand_cards[4] == 2  ? num_2_format : 
						 inhand_cards[4] == 3  ? num_3_format : 
						 inhand_cards[4] == 4  ? num_4_format : 
						 inhand_cards[4] == 5  ? num_5_format : 
						 inhand_cards[4] == 6  ? num_6_format : 
						 inhand_cards[4] == 7  ? num_7_format : 
						 inhand_cards[4] == 8  ? num_8_format : 
						 inhand_cards[4] == 9  ? num_9_format : point_format;						 

assign player_total_digit = ((player_total>>1'b1) >= 6'b010100) ? (player_total>>1'b1) - 5'b10100 : 
						    ((player_total>>1'b1) >= 6'b001010) ? (player_total>>1'b1) - 5'b01010 : player_total>>1'b1;
assign dealer_total_digit = ((dealer_total>>1'b1) >= 6'b001010) ? (dealer_total>>1'b1) - 5'b01010 : dealer_total>>1'b1;


assign player_total_digit_display = player_total_digit == 0  ? num_0_format : 
									player_total_digit == 1  ? num_1_format : 
									player_total_digit == 2  ? num_2_format : 
									player_total_digit == 3  ? num_3_format : 
									player_total_digit == 4  ? num_4_format : 
									player_total_digit == 5  ? num_5_format : 
									player_total_digit == 6  ? num_6_format : 
									player_total_digit == 7  ? num_7_format : 
									player_total_digit == 8  ? num_8_format : 
									player_total_digit == 9  ? num_9_format : 
									player_total_digit == 10 ? num_0_format : point_format;
									
assign dealer_total_digit_display = dealer_total_digit == 0  ? num_0_format : 
									dealer_total_digit == 1  ? num_1_format : 
									dealer_total_digit == 2  ? num_2_format : 
									dealer_total_digit == 3  ? num_3_format : 
									dealer_total_digit == 4  ? num_4_format : 
									dealer_total_digit == 5  ? num_5_format : 
									dealer_total_digit == 6  ? num_6_format : 
									dealer_total_digit == 7  ? num_7_format : 
									dealer_total_digit == 8  ? num_8_format : 
									dealer_total_digit == 9  ? num_9_format : 
									dealer_total_digit == 10 ? num_0_format : point_format;									


//seg7_temp
always@(*) begin
	if(!rst_n) begin
		seg7_temp[0] = line_format;
		seg7_temp[1] = line_format;
		seg7_temp[2] = line_format;
		seg7_temp[3] = line_format;
		seg7_temp[4] = line_format;
		seg7_temp[5] = line_format;
		seg7_temp[6] = num_0_format;
		seg7_temp[7] = num_0_format;
	end
	else begin
		case(state)
			IDLE : begin
				seg7_temp[0] = line_format;
				seg7_temp[1] = line_format;
				seg7_temp[2] = line_format;
				seg7_temp[3] = line_format;
				seg7_temp[4] = line_format;
				seg7_temp[5] = line_format;
				seg7_temp[6] = num_0_format;
				seg7_temp[7] = num_0_format;
			end	
			/*
			BEGINING : begin
				seg7_temp[0] = digit_display_0;
				if(inhand_cards[0] == 11) begin // 0.5
					seg7_temp[5] = point_format; // 0.5
					seg7_temp[6] = num_0_format;
					seg7_temp[7] = num_0_format;
				end
				else if(inhand_cards[0] == 10) begin 
					seg7_temp[5] = line_format; // - head line
					seg7_temp[6] = num_0_format;
					seg7_temp[7] = num_1_format;
				end
				else begin
					seg7_temp[5] = line_format; // - head line
					seg7_temp[6] = digit_display_0;
					seg7_temp[7] = num_0_format;
				end
			end	       
			*/
			HIT_CARD_PLAYER : begin
			    case(pick_times)
					1 : begin
						seg7_temp[0] = digit_display_0;
						seg7_temp[1] = line_format;
						seg7_temp[2] = line_format;
						seg7_temp[3] = line_format;
						seg7_temp[4] = line_format;
					end
					2 : begin
						seg7_temp[1] = digit_display_1;
						seg7_temp[2] = line_format;
						seg7_temp[3] = line_format;
						seg7_temp[4] = line_format;
					end
					3 : begin
						seg7_temp[2] = digit_display_2;
						seg7_temp[3] = line_format;
						seg7_temp[4] = line_format;
					end
					4 : begin
						seg7_temp[3] = digit_display_3;
						seg7_temp[4] = line_format;
					end
					5 : begin
						seg7_temp[4] = digit_display_4;
					end
			    endcase
				seg7_temp[5] = ((player_total & 6'b00_0001) == 1) ? point_format : line_format; // 0.5
				seg7_temp[6] = player_total_digit_display;
				seg7_temp[7] =((player_total>>1'b1) > 19) ? num_2_format : 
							  ((player_total>>1'b1) > 9)  ? num_1_format : num_0_format;
			end
			HIT_CARD_DEALER : begin
				if(pick_times == 3'd0) begin
					seg7_temp[0] = line_format;
					seg7_temp[1] = line_format;
					seg7_temp[2] = line_format;
					seg7_temp[3] = line_format;
					seg7_temp[4] = line_format;
					seg7_temp[5] = line_format;
					seg7_temp[6] = num_0_format;
					seg7_temp[7] = num_0_format;
				end
				else begin
					case(pick_times)
						1 : begin
							seg7_temp[0] = digit_display_0;
							seg7_temp[1] = line_format;
							seg7_temp[2] = line_format;
							seg7_temp[3] = line_format;
							seg7_temp[4] = line_format;
						end
						2 : begin
							seg7_temp[1] = digit_display_1;
							seg7_temp[2] = line_format;
							seg7_temp[3] = line_format;
							seg7_temp[4] = line_format;
						end
						3 : begin
							seg7_temp[2] = digit_display_2;
							seg7_temp[3] = line_format;
							seg7_temp[4] = line_format;
						end
						4 : begin
							seg7_temp[3] = digit_display_3;
							seg7_temp[4] = line_format;
						end
						5 : begin
							seg7_temp[4] = digit_display_4;
						end
					endcase
					seg7_temp[5] = ((dealer_total & 6'b00_0001) == 1) ? point_format : line_format; // 0.5
					seg7_temp[6] = dealer_total_digit_display;
					seg7_temp[7] = ((dealer_total>>1'b1) > 19) ? num_2_format : 
								   ((dealer_total>>1'b1) > 19) ? num_1_format : num_0_format;
				end
			end
			COMPARE : begin
				//---------------player---------------//
				seg7_temp[0] = ((player_total & 6'b00_0001) == 1) ? point_format : line_format; // 0.5
				seg7_temp[1] = player_total_digit_display;
				seg7_temp[2] =((player_total>>1'b1) > 19) ? num_2_format : 
							  ((player_total>>1'b1) > 9)  ? num_1_format : num_0_format;
				//--------------- line ---------------//
				seg7_temp[3] = line_format;
				seg7_temp[4] = line_format;
				//---------------dealer---------------//
				seg7_temp[5] = ((dealer_total & 6'b00_0001) == 1) ? point_format : line_format; // 0.5
				seg7_temp[6] = dealer_total_digit_display;
				seg7_temp[7] = ((dealer_total>>1'b1) > 19) ? num_2_format : 
							   ((dealer_total>>1'b1) > 19) ? num_1_format : num_0_format;
			end
			//DONE : 	  		
			//default : 
		endcase
	end
end

//================================================================
//   LED
//================================================================

always@(posedge d_clk or negedge rst_n) begin
	if(!rst_n) begin
		led = 3'b000;
	end
	else begin
		case(state)  
			COMPARE : led = (winner == player) ? 3'b001 : (winner == dealer) ? 3'b010 : 3'b000;
			DONE 	: led = 3'b100;
			default : led = 3'b000;
			
		endcase
	end
end

//#################### Don't revise the code below ############################## 

//================================================================
//   SEGMENT
//================================================================

//display counter 
always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        dis_cnt <= 0;
    end
    else begin
        dis_cnt <= (dis_cnt >= 7) ? 0 : (dis_cnt + 1);
    end
end

always @(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7 <= 8'b0000_0001;
    end 
    else begin
        if(!dis_cnt[2]) begin
            seg7 <= seg7_temp[dis_cnt];
        end
    end
end

always @(posedge dis_clk or negedge rst_n) begin 
    if(!rst_n) begin
        seg7_l <= 8'b0000_0001;
    end 
    else begin
        if(dis_cnt[2]) begin
            seg7_l <= seg7_temp[dis_cnt];
        end
    end
end

always@(posedge dis_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg7_sel <= 8'b11111111;
    end
    else begin
        case(dis_cnt)
            0 : seg7_sel <= 8'b00000001;
            1 : seg7_sel <= 8'b00000010;
            2 : seg7_sel <= 8'b00000100;
            3 : seg7_sel <= 8'b00001000;
            4 : seg7_sel <= 8'b00010000;
            5 : seg7_sel <= 8'b00100000;
            6 : seg7_sel <= 8'b01000000;
            7 : seg7_sel <= 8'b10000000;
            default : seg7_sel <= 8'b11111111;
        endcase
    end
end

//================================================================
//   LUT
//================================================================
 
LUT inst_LUT (.clk(d_clk), .rst_n(rst_n), .pip(pip), .number(number));



endmodule 