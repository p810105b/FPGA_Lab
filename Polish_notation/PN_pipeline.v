// 2023 FPGA
// FIANL : Polish Notation(PN)
//
// -----------------------------------------------------------------------------
// ©Communication IC & Signal Processing Lab 716
// -----------------------------------------------------------------------------
// Author : HSUAN-YU LIN
// File   : PN.v
// Create : 2023-02-27 13:19:54
// Revise : 2023-02-27 13:19:54
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
module PN(
	input clk,
	input rst_n,
	input [1:0] mode,
	input operator,
	input [2:0] in,
	input in_valid,
	output reg out_valid,
	output reg signed [31:0] out
    );
	
//================================================================
//   PARAMETER/INTEGER
//================================================================
parameter IDLE 		= 0;
parameter DATA_IN   = 1;
parameter PREFIX	= 2;
parameter POSTFIX	= 3;
parameter NPN		= 4;
parameter RPN		= 5;
parameter SORT 		= 6;
parameter DATA_OUT 	= 7;

//integer
integer i;

//================================================================
//   REG/WIRE
//================================================================
reg [2:0] state, next_state;
reg [1:0] mode_temp; 
 
reg signed [31:0] stack [0:11]; // width=3, depth=12
reg stack_operation [0:8]; // store operation position

// mode=0 or 1 => cycles=6 or 9 or 12
// mode=2 or 3 => cycles=5 or 7 or 9
reg [3:0] in_cycle_count; // numbers of input data 

reg [3:0] pointer;
reg [3:0] operator_pointer;

// control signal
wire compute_done;
wire sort_done;
wire out_done;

// bubble sort
reg sort_order;
reg [2:0] sort_count;
reg sort_idx;
wire [2:0] sorted_numbers; // 1~4

// locate
wire [3:0] operation_position_NPN;
wire [3:0] operation_position_RPN;

wire [3:0] operation_position_RPN_4;
wire [3:0] operation_position_RPN_6;
wire [3:0] operation_position_RPN_8;

// compute numbers times
reg [3:0] count;
reg [3:0] digit_numbers;
//================================================================
//   Design
//================================================================

// FSM
always@(posedge clk or negedge rst_n) begin
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
		IDLE 	 : next_state = (in_valid == 1'b1) ? DATA_IN : IDLE;
		DATA_IN  : next_state = (in_valid == 1'b1) ? DATA_IN : 
								(mode_temp == 2'd0) 	   ? PREFIX  :
								(mode_temp == 2'd1) 	   ? POSTFIX : 
								(mode_temp == 2'd2) 	   ? NPN 	 : RPN;		
		PREFIX	 : next_state = SORT;								  
		POSTFIX	 : next_state = SORT;											 
        NPN		 : next_state = (compute_done == 1'b1) ? DATA_OUT : NPN;
        RPN		 : next_state = (compute_done == 1'b1) ? DATA_OUT : RPN;
		SORT 	 : next_state = (sort_done == 1'b1)    ? DATA_OUT : SORT;	
		DATA_OUT : next_state = (out_done == 1'b1)     ? IDLE : DATA_OUT;	
		default  : next_state = IDLE;
	endcase
end


// stack
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		digit_numbers <= 4'd0;
		pointer  <= 4'd0;
		for(i=0 ; i<12 ; i=i+1) begin
			stack[i]  <= 32'd0;
			stack_operation[i] <= 1'd0;
		end
	end
	else if(in_valid == 1'b1) begin
		digit_numbers <= (operator == 1'b0) ? digit_numbers + 4'd1 : digit_numbers;
		pointer  <= pointer  + 4'd1;
		stack[pointer] <= in;
		stack_operation[pointer] <= operator;
	end
	else begin
		digit_numbers <= (state == IDLE) ? 4'd0 : digit_numbers;
		pointer  <= 4'd0;
		stack[pointer] <= stack[pointer];
		stack_operation[pointer] <= stack_operation[pointer];
	end
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		in_cycle_count <= 4'd0; 
	end
	else if(state == IDLE) begin
		in_cycle_count <= 4'd0; 
	end
	else begin
		in_cycle_count <= (in_valid == 1'd1) ? (in_cycle_count + 4'd1) : in_cycle_count;
	end
end


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid 	 <= 1'd0;
		out		  	 <= 32'd0;
		mode_temp 	 <= 1'd0;
		for(i=0 ; i<12 ; i=i+1) begin
			stack[i]  <= 32'd0;
		end
	end
	else begin
		case(state)
			IDLE : begin
				out_valid 	 <= 1'd0;
				out		  	 <= 32'd0;
				mode_temp 	 <= mode;
				count		 <= 4'd0;
			end
			DATA_IN : begin
				
				
				
			end
			PREFIX : begin // 6, 9, 12 datas => 2, 3, 4 group
				sort_order <= 0;
				for(i=0 ; i<sorted_numbers ; i=i+1) begin
					case(stack[3*i])
						3'b000 : stack[i] <= stack[3*i+1] + stack[3*i+2]; // a + b
						3'b001 : stack[i] <= stack[3*i+1] - stack[3*i+2]; // a - b
						3'b010 : stack[i] <= stack[3*i+1] * stack[3*i+2]; // a * b
						3'b011 : stack[i] <= stack[3*i+1] + stack[3*i+2]; // |a + b|
						default : stack[i] <= stack[i];
					endcase
				end
			end
			POSTFIX	: begin
				sort_order <= 1;
				for(i=0 ; i<(sorted_numbers) ; i=i+1) begin
					case(stack[3*i+2])
						3'b000 : stack[i] <= stack[3*i] + stack[3*i+1]; // a + b
						3'b001 : stack[i] <= stack[3*i] - stack[3*i+1]; // a - b
						3'b010 : stack[i] <= stack[3*i] * stack[3*i+1]; // a * b
						3'b011 : stack[i] <= stack[3*i] + stack[3*i+1]; // |a + b|
						default : stack[i] <= stack[i];
					endcase
				end
			end
			NPN	: begin
				count <= count + 4'd1;
				case(stack[operation_position_NPN-1])
					3'b000 : stack[operation_position_NPN+1] <= stack[operation_position_NPN] + stack[operation_position_NPN+1]; // a + b
					3'b001 : stack[operation_position_NPN+1] <= stack[operation_position_NPN] - stack[operation_position_NPN+1]; // a - b
					3'b010 : stack[operation_position_NPN+1] <= stack[operation_position_NPN] * stack[operation_position_NPN+1]; // a * b
					3'b011 : stack[operation_position_NPN+1] <= (stack[operation_position_NPN] + stack[operation_position_NPN+1] < 0) ? 
																~(stack[operation_position_NPN] + stack[operation_position_NPN+1])+1 : 
																  stack[operation_position_NPN] + stack[operation_position_NPN+1]; // |a + b|
					default : stack[operation_position_NPN+1] <= stack[operation_position_NPN+1];
				endcase
				for(i=0 ; i<(operation_position_NPN-1) ; i=i+1) begin
					stack[operation_position_NPN-i] <= stack[operation_position_NPN-2-i];
					stack_operation[operation_position_NPN-i] <= stack_operation[operation_position_NPN-2-i];
				end
			end
			RPN	: begin
				count <= count + 4'd1;
				case(stack[operation_position_RPN+1])
					3'b000 : stack[operation_position_RPN-1] <= stack[operation_position_RPN-1] + stack[operation_position_RPN]; // a + b
					3'b001 : stack[operation_position_RPN-1] <= stack[operation_position_RPN-1] - stack[operation_position_RPN]; // a - b
					3'b010 : stack[operation_position_RPN-1] <= stack[operation_position_RPN-1] * stack[operation_position_RPN]; // a * b
					3'b011 : stack[operation_position_RPN-1] <= (stack[operation_position_RPN-1] + stack[operation_position_RPN] < 0) ? 
																~(stack[operation_position_RPN-1] + stack[operation_position_RPN])+1 :
																  stack[operation_position_RPN-1] + stack[operation_position_RPN]; // |a + b|
					default : stack[operation_position_RPN-1] <= stack[operation_position_RPN-1];
				endcase
				for(i=0 ; i<(in_cycle_count-operation_position_RPN-1) ; i=i+1) begin
					stack[operation_position_RPN+i] <= stack[operation_position_RPN+2+i];
					stack_operation[operation_position_RPN+i] <= stack_operation[operation_position_RPN+2+i];
				end
			end
			SORT : begin
				pointer <= 4'd0;
				
			end
			DATA_OUT : begin
				if(mode_temp == 2'd0 || mode_temp == 2'd1) begin
					out_valid <= (pointer < sorted_numbers) ? 1'b1 : 1'b0;
					out <= (sort_order == 1'b0) ? (stack[sorted_numbers - pointer -1]) : (stack[pointer]);
					pointer <= pointer + 1;
				end
				else begin
					out_valid <= 1'b1;
					out <= (mode_temp == 2'd2) ? stack[in_cycle_count] : stack[0];
				end
			end
			default : begin
				
				
				
			end
		endcase
	end
end

assign out_done = (state == DATA_OUT && (pointer == sorted_numbers-1 || mode_temp == 2'd2 || mode_temp == 2'd3)) ? 1'b1 : 1'b0;
assign compute_done = (count == digit_numbers-2 && (state == NPN || state == RPN)) ? 1'b1 : 1'b0;

// NPN
assign operation_position_NPN = (!stack_operation[0] && !stack_operation[1]) ? 4'd0 : 
								(!stack_operation[1] && !stack_operation[2]) ? 4'd1 : 
								(!stack_operation[2] && !stack_operation[3]) ? 4'd2 : 
								(!stack_operation[3] && !stack_operation[4]) ? 4'd3 : 
								(!stack_operation[4] && !stack_operation[5]) ? 4'd4 : 
								(!stack_operation[5] && !stack_operation[6]) ? 4'd5 : 
								(!stack_operation[6] && !stack_operation[7]) ? 4'd6 : 
								(!stack_operation[7] && !stack_operation[8]) ? 4'd7 : 4'd8;
							
// RPN						
// first 4 search
assign operation_position_RPN_4 = (!stack_operation[4] && !stack_operation[3]) ? 4'd4 : 
								  (!stack_operation[3] && !stack_operation[2]) ? 4'd3 : 
								  (!stack_operation[2] && !stack_operation[1]) ? 4'd2 : 
								  (!stack_operation[1] && !stack_operation[0]) ? 4'd1 : 4'd9; 	
// first 6 search							  
assign operation_position_RPN_6 = (!stack_operation[6] && !stack_operation[5]) ? 4'd6 : 
								  (!stack_operation[5] && !stack_operation[4]) ? 4'd5 : operation_position_RPN_4;
// first 8 search							
assign operation_position_RPN_8 = (!stack_operation[8] && !stack_operation[7]) ? 4'd8 : 
								  (!stack_operation[7] && !stack_operation[6]) ? 4'd7 : operation_position_RPN_6;			

assign operation_position_RPN = (in_cycle_count == 4) ? operation_position_RPN_4 : 
								(in_cycle_count == 6) ? operation_position_RPN_6 : operation_position_RPN_8;


// bubble sort
assign sort_flag = (state == SORT) ? 1'b1 : 1'b0;
assign sorted_numbers = (in_cycle_count+1)/3;
assign sort_done = (sort_count == sorted_numbers);

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
		sort_idx <= 0;
    else if(sort_flag)
		sort_idx <= ~sort_idx;
	else	
		sort_idx <= sort_idx;
end
       
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		sort_count <= 3'd0;
	end
	else if(sort_flag) begin
		sort_count <= (sort_count == sorted_numbers) ? sort_count : sort_count + 3'd1;
	end
	else begin
		sort_count <= 3'd0;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(sort_flag & ~sort_idx) begin
		for(i=1 ; i<sorted_numbers ; i=i+2)begin
			stack[i-1] <= (stack[i-1] > stack[i]) ? stack[i]   : stack[i-1]; // smaller
			stack[i]   <= (stack[i-1] > stack[i]) ? stack[i-1] : stack[i];   // larger
		end
	end
	else if(sort_flag & sort_idx) begin
		for(i=2 ; i<sorted_numbers ; i=i+2)begin
			stack[i-1] <= (stack[i-1] > stack[i]) ? stack[i]   : stack[i-1];
			stack[i]   <= (stack[i-1] > stack[i]) ? stack[i-1] : stack[i];
		end
	end
end

endmodule
