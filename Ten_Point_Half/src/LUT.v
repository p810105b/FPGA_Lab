module LUT (
    input  clk,    // Clock
    input  rst_n,  // Asynchronous reset active low
    input  pip,
    output reg [3:0] number
);

//Poker_mem
reg [3:0] poker_mem [0:51];
//pointer
reg [5:0] pointer;

//integer
integer i;

//================================================================
//   OUTPUT
//================================================================

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        number <= 'd0;
    end 
    else if (pip) begin
        number <= poker_mem[pointer];
    end
    else begin
        number <= 'd0;
    end
end

//================================================================
//   LUT
//================================================================

//pointer
always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        pointer <= 'd0;
    end 
    else begin
        if(pip) begin
            pointer <= pointer + 'd1;
        end
    end
end

//poker_mem
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0;i<52;i=i+1) begin
            poker_mem[i] <= 'd0;
        end
    end 
    else begin
        //poker_mem[{:2d}] <= 4'd{cb}; 
        poker_mem[ 0] <= 4'd10; 
        poker_mem[ 1] <= 4'd10 ; 
        poker_mem[ 2] <= 4'd8 ; 
        poker_mem[ 3] <= 4'd2 ; 
        poker_mem[ 4] <= 4'd2 ; 
        poker_mem[ 5] <= 4'd2 ; 
        poker_mem[ 6] <= 4'd7 ; 
        poker_mem[ 7] <= 4'd11; 
        poker_mem[ 8] <= 4'd6 ; 
        poker_mem[ 9] <= 4'd5 ; 
        poker_mem[10] <= 4'd1 ; 
        poker_mem[11] <= 4'd4 ; 
        poker_mem[12] <= 4'd13; 
        poker_mem[13] <= 4'd10; 
        poker_mem[14] <= 4'd11; 
        poker_mem[15] <= 4'd13; 
        poker_mem[16] <= 4'd1 ; 
        poker_mem[17] <= 4'd5 ; 
        poker_mem[18] <= 4'd12; 
        poker_mem[19] <= 4'd3 ; 
        poker_mem[20] <= 4'd1 ; 
        poker_mem[21] <= 4'd1 ; 
        poker_mem[22] <= 4'd1 ; 
        poker_mem[23] <= 4'd13; 
        poker_mem[24] <= 4'd12; 
        poker_mem[25] <= 4'd3 ; 
        poker_mem[26] <= 4'd4 ; 
        poker_mem[27] <= 4'd7 ; 
        poker_mem[28] <= 4'd7 ; 
        poker_mem[29] <= 4'd9 ; 
        poker_mem[30] <= 4'd11; 
        poker_mem[31] <= 4'd4 ; 
        poker_mem[32] <= 4'd12 ; 
        poker_mem[33] <= 4'd13 ; 
        poker_mem[34] <= 4'd1 ; 
        poker_mem[35] <= 4'd12; 
        poker_mem[36] <= 4'd3; 
        poker_mem[37] <= 4'd9; 
        poker_mem[38] <= 4'd5; 
        poker_mem[39] <= 4'd12; 
        poker_mem[40] <= 4'd2; 
        poker_mem[41] <= 4'd10; 
        poker_mem[42] <= 4'd12; 
        poker_mem[43] <= 4'd2; 
        poker_mem[44] <= 4'd1; 
        poker_mem[45] <= 4'd13; 
        poker_mem[46] <= 4'd1; 
        poker_mem[47] <= 4'd4; 
        poker_mem[48] <= 4'd8; 
        poker_mem[49] <= 4'd9; 
        poker_mem[50] <= 4'd7; 
        poker_mem[51] <= 4'd11; 
    end
end

endmodule

