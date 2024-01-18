
`timescale 1ns/1ps
`define CYCLE 10

module tb_tenthirty ();

    reg  clk = 0;
    reg  rst_n;
    reg  sw;
    reg  btn_m; //bottom middle
    reg  btn_r; //bottom right
	wire btn_m_pluse;
	wire btn_r_pluse;
	wire [7:0] seg7_sel;
	wire [7:0] seg7;   
	wire [7:0] seg7_l; 
	wire [2:0] led;
	wire [2:0] state;
	wire [2:0] next_state;
	wire pip;
	wire player_done;
	wire dealer_done;
	wire [3:0] number;
	wire [3:0] picked_number;
	wire [2:0] pick_times;
	wire [5:0] player_total;
	wire [5:0] dealer_total;
	wire winner;
	wire [3:0] int_part;
	wire [2:0] round;
	wire [7:0] inhand_cards_0;
	wire [7:0] inhand_cards_1;
	wire [7:0] inhand_cards_2;
	wire [7:0] inhand_cards_3;
	wire [7:0] inhand_cards_4;
	wire player_pass_flag;
	wire dealer_pass_flag;
	
//clk
always
begin
  #(`CYCLE/2) clk = ~clk;
end

//================================================================
//   d_clk
//================================================================
//frequency division
reg [24:0] counter; 
wire d_clk = counter[5];//clk;//remember to change your tenthirty.v
//wire d_clk   = counter[24];

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
    end
end

//integer
integer gap;

initial begin
  rst_n = 1;
  set_initaial;
  gap = $urandom_range(1,5);
  repeat(gap)@(negedge clk); rst_n = 0; repeat(gap)@(negedge clk); rst_n = 1;
  
  //---------------round 1---------------//
  // player : 10+0.5
  repeat(gap)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  // dealer : 8+2
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // compare : player win 0
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  //---------------round 2---------------//
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  // player : 2+2+7
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // dealer 0.5+6
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // compare : dealer win 1
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;

  
  //---------------round 3---------------//
  // player : 5+1+4
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  // dealer : 0.5+10
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // compare : dealer win 1
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  //---------------round 4---------------//
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  // player : 0.5+0.5+1+5+0.5
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
	
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // dealer 3+1+1+1+0.5
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // compare : player win 0
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  
  //---------------reset---------------//
  repeat(2)@(negedge clk); rst_n = 0; repeat(2)@(negedge clk); ;rst_n = 1;
  repeat(3)@(negedge d_clk); 
  
  //---------------round 1---------------//
  // player : 10+0.5+8
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  // dealer : 2+2
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // compare : dealer win 1
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  //---------------round 2---------------//
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  // player : 2+7
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // dealer 0.5+6+5
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  repeat(2)@(negedge d_clk); btn_m = 1; repeat(3)@(negedge d_clk); btn_m = 0;
  
  // compare : player win 0
  repeat(2)@(negedge d_clk); btn_r = 1; repeat(3)@(negedge d_clk); btn_r = 0;
  
  
  repeat(6)@(negedge d_clk);
  
  /*
  btn_m = 0;
  btn_r = 0;
  #10
  rst_n = 0;
  #10
  rst_n = 1;
  #10
  //---------------round 1---------------//
  // player : 10+0.5
  #13 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #41 btn_r = 1; #30 btn_r = 0;
  
  // dealer : 8+2
  #23 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  // compare : player win 0
  #41 btn_r = 1; #30 btn_r = 0;
  
  
  //---------------round 2---------------//
  #40 btn_r = 1; #30 btn_r = 0;
  
  // player : 2+2+7
  #23 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  // dealer 0.5+6
  #40 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  // compare : dealer win 1
  #42 btn_r = 1; #30 btn_r = 0;

  
  //---------------round 3---------------//
  // player : 5+1+4
  #40 btn_r = 1; #30 btn_r = 0;
  
  #13 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #42 btn_r = 1; #30 btn_r = 0;
  
  // dealer : 0.5+10
  #23 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  // compare : dealer win 1
  #42 btn_r = 1; #30 btn_r = 0;
  
  //---------------round 4---------------//
  #40 btn_r = 1; #30 btn_r = 0;
  
  // player : 0.5+0.5+1+5+0.5
  #23 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
	
  #20 btn_m = 1; #30 btn_m = 0;
  
  // dealer 3+1+1+1+0.5
  #40 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #40 btn_m = 1; #30 btn_m = 0;
  
  #40 btn_m = 1; #30 btn_m = 0;
  
  #40 btn_m = 1; #30 btn_m = 0;
  
  // compare : player win 0
  #42 btn_r = 1; #30 btn_r = 0;
  
  #50
  
  //---------------reset---------------//
  #10
  rst_n = 0;
  #10
  rst_n = 1;
  #10
  //---------------round 1---------------//
  // player : 10+0.5+8
  #13 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #41 btn_r = 1; #30 btn_r = 0;
  
  // dealer : 2+2
  #23 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  // compare : dealer win 1
  #41 btn_r = 1; #30 btn_r = 0;
  
  //---------------round 2---------------//
  #40 btn_r = 1; #30 btn_r = 0;
  
  // player : 2+7
  #20 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  // dealer 0.5+6+5
  #40 btn_r = 1; #30 btn_r = 0;
  
  #40 btn_m = 1; #30 btn_m = 0;
  
  #20 btn_m = 1; #30 btn_m = 0;
  
  #40 btn_m = 1; #30 btn_m = 0;
  
  // compare : player win 0
  #42 btn_r = 1; #30 btn_r = 0;
  
  #30
  
  */
  
  $finish;
end

	tenthirty inst_tenthirty
		(
			.clk      (clk),
			.rst_n    (rst_n),
			.btn_m    (btn_m),
			.btn_r    (btn_r),
			.seg7_sel (seg7_sel),
			.seg7     (seg7),
			.seg7_l   (seg7_l),
			.led      (led),
			.state    (state),
			.next_state(next_state),
			.pip(pip),
			.player_done(player_done),
			.dealer_done(dealer_done),
			.number(number),
			.picked_number(picked_number),
			.pick_times(pick_times),
			.player_total(player_total),
			.dealer_total(dealer_total),
			.winner(winner),
			.int_part(int_part),
			.round(round),
			.inhand_cards_0(inhand_cards_0),
			.inhand_cards_1(inhand_cards_1),
			.inhand_cards_2(inhand_cards_2),
			.inhand_cards_3(inhand_cards_3),
			.inhand_cards_4(inhand_cards_4),
			.btn_m_pluse(btn_m_pluse),
			.btn_r_pluse(btn_r_pluse), 
			.player_pass_flag(player_pass_flag), 
			.dealer_pass_flag(dealer_pass_flag)
		);


task set_initaial();
	//sw    = 0;
	btn_m = 0;
	btn_r = 0;
endtask

endmodule
