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
 
reg signed [31:0] operand_stack  [0:11]; // width=3, depth=12
reg [2:0] operator_stack [0:11]; // width=3, depth=12


// mode=0 or 1 => cycles=6 or 9 or 12
// mode=2 or 3 => cycles=5 or 7 or 9
reg [3:0] in_cycle_count; 

reg [3:0] operand_pointer;
reg [3:0] operator_pointer;

// wire sort_done;
reg compute_done;
wire out_done;

// reg sort_order;
// reg [2:0] sort_count;
// reg sort_idx;
wire [2:0] sorted_numbers; // 1~4

wire signed [31:0] out_array [0:3]; 

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
		DATA_IN  : next_state = (in_valid == 1'b1) ? DATA_IN : DATA_OUT;
		PREFIX	 : next_state = SORT; 					  
		POSTFIX	 : next_state = SORT; 										 
        NPN		 : next_state = (compute_done == 1'b1) ? DATA_OUT : NPN;
        RPN		 : next_state = (compute_done == 1'b1) ? DATA_OUT : RPN;
		SORT 	 : next_state = DATA_OUT;	
		DATA_OUT : next_state = (out_done == 1'b1)     ? IDLE : DATA_OUT;	
		default  : next_state = IDLE;
	endcase
end


always@(*) begin
	if(in_valid != 1'b1) begin
		case(mode_temp)
			2'd0 : begin // 6, 9, 12 datas => 2, 3, 4 group
				operand_pointer = 4'd0;
				//sort_order 		= 0;
				for(i=0 ; i<sorted_numbers ; i=i+1) begin
					case(operator_stack[i])
						3'b000 : operand_stack[i] = operand_stack[2*i] + operand_stack[2*i+1]; // a + b
						3'b001 : operand_stack[i] = operand_stack[2*i] - operand_stack[2*i+1]; // a - b
						3'b010 : operand_stack[i] = operand_stack[2*i] * operand_stack[2*i+1]; // a * b
						3'b011 : operand_stack[i] = operand_stack[2*i] + operand_stack[2*i+1]; // |a + b|
						default : operand_stack[i] = operand_stack[2*i];
					endcase
				end
			end
			2'd1 : begin	
				operand_pointer = 4'd0;
				//sort_order 		= 1;
				for(i=0 ; i<(sorted_numbers) ; i=i+1) begin
					case(operator_stack[i])
						3'b000 : operand_stack[i] = operand_stack[2*i] + operand_stack[2*i+1]; // a + b
						3'b001 : operand_stack[i] = operand_stack[2*i] - operand_stack[2*i+1]; // a - b
						3'b010 : operand_stack[i] = operand_stack[2*i] * operand_stack[2*i+1]; // a * b
						3'b011 : operand_stack[i] = operand_stack[2*i] + operand_stack[2*i+1]; // |a + b|
						default : operand_stack[i] = operand_stack[2*i];
					endcase
				end
			end
			2'd2 : begin
				
				
				
			end
			2'd3 : begin
				
				
				
			end
			default : begin
				
				
			end
		endcase
	end
	else begin
		// avoid latch 
		// RTL ignore
	end
end



// stack
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		operand_pointer  <= 4'd0;
		operator_pointer <= 4'd0; 
		for(i=0 ; i<12 ; i=i+1) begin
			operand_stack[i]  <= 4'd0;
			operator_stack[i] <= 3'd0;
		end
	end
	else if(in_valid == 1'b1) begin
		if(operator == 1'd0) begin
			operand_pointer  <= (operator == 1'd0) ? (operand_pointer  + 4'd1) : operand_pointer;
			operand_stack[operand_pointer] <= in;
		end
		else begin
			operator_pointer <= (operator == 1'd1) ? (operator_pointer + 4'd1) : operator_pointer;
			operator_stack[operator_pointer] <= in;
		end
	end
	else begin
		operand_pointer  <= 4'd0;
		operator_pointer <= 4'd0; 
		operand_stack[operand_pointer]   <= operand_stack[operand_pointer];
		operator_stack[operator_pointer] <= operator_stack[operator_pointer];
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
		compute_done <= 1'b0;
		operand_pointer  <= 4'd0;
		for(i=0 ; i<12 ; i=i+1) begin
			operand_stack[i]  <= 3'd0;
			operator_stack[i] <= 3'd0;
		end
	end
	else begin
		case(state)
			IDLE : begin
				out_valid 	 <= 1'd0;
				out		  	 <= 32'd0;
				mode_temp 	 <= mode;
				compute_done <= 1'b0;
			end
			DATA_IN : begin
				
				
			end
			PREFIX : begin 
				
				
			end
			POSTFIX	 : begin	
				
				
			end
			DATA_OUT : begin
				out_valid 		<= (operand_pointer < sorted_numbers) ? 1'b1 : 1'b0;
				out 			<= (mode_temp == 1'b0) ? (out_array[sorted_numbers - operand_pointer -1]) : (out_array[operand_pointer]);
				operand_pointer <= operand_pointer + 1;
			end
			default : begin
				
				
			end
		endcase
	end
end

assign out_done = (state == DATA_OUT && operand_pointer == sorted_numbers-1) ? 1'b1 : 1'b0;


// sort
wire signed [31:0] max_1, max_2, max_3;
wire signed [31:0] min_1, min_2, min_3;
wire signed [31:0] first, second, thrid, fourth; // 4 groups sort
	
wire signed [31:0] first_3, second_3, thrid_3;   // 3 groups sort

assign max_1 = (operand_stack[0] > operand_stack[1]) ? operand_stack[0] : operand_stack[1];
assign min_1 = (operand_stack[0] > operand_stack[1]) ? operand_stack[1] : operand_stack[0];

// for 3 groups sort
assign first_3  = (max_1 > operand_stack[2]) ? max_1 : operand_stack[2];
assign second_3 = (max_1 > operand_stack[2]) ? ((min_1 > operand_stack[2]) ? min_1 : operand_stack[2]) : max_1;
assign thrid_3  = (min_1 > operand_stack[2]) ? operand_stack[2] : min_1;


// for 4 groups sort
assign max_2 = (operand_stack[2] > operand_stack[3]) ? operand_stack[2] : operand_stack[3];
assign min_2 = (operand_stack[2] > operand_stack[3]) ? operand_stack[3] : operand_stack[2];

assign first  = (max_1 > max_2) ? max_1 : max_2;
assign max_3  = (max_1 > max_2) ? max_2 : max_1;

assign fourth = (min_1 > min_2) ? min_2 : min_1;
assign min_3  = (min_1 > min_2) ? min_1 : min_2;

assign second = (max_3 > min_3) ? max_3 : min_3;
assign thrid  = (max_3 > min_3) ? min_3 : max_3;


// output data array
assign out_array[0] = (sorted_numbers == 2) ? min_1   : 
					  (sorted_numbers == 3) ? thrid_3 : fourth;
					  
assign out_array[1] = (sorted_numbers == 2) ? max_1   : 
					  (sorted_numbers == 3) ? second_3 : thrid;
					  
assign out_array[2] = (sorted_numbers == 2) ? 32'd0   : 
					  (sorted_numbers == 3) ? first_3 : second;	
					  
assign out_array[3] = (sorted_numbers == 2) ? 32'd0   : 
					  (sorted_numbers == 3) ? 32'd0   : first;
					  

assign sorted_numbers = (in_cycle_count+1)/3;

// bubble sort
/*
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
			operand_stack[i-1] <= (operand_stack[i-1] > operand_stack[i]) ? operand_stack[i]   : operand_stack[i-1]; // smaller
			operand_stack[i]   <= (operand_stack[i-1] > operand_stack[i]) ? operand_stack[i-1] : operand_stack[i];   // larger
		end
	end
	else if(sort_flag & sort_idx) begin
		for(i=2 ; i<sorted_numbers ; i=i+2)begin
			operand_stack[i-1] <= (operand_stack[i-1] > operand_stack[i]) ? operand_stack[i]   : operand_stack[i-1];
			operand_stack[i]   <= (operand_stack[i-1] > operand_stack[i]) ? operand_stack[i-1] : operand_stack[i];
		end
	end
end
*/




endmodule
