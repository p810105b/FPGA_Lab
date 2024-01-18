// 2023 FPGA
// FIANL : Polish Notation(PN)
//
// -----------------------------------------------------------------------------
// ©Communication IC & Signal Processing Lab 716
// -----------------------------------------------------------------------------
// Author : HSUAN-YU LIN
// File   : TESTBED.v
// Create : 2023-02-27 13:19:54
// Revise : 2023-02-27 13:19:54
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
//#################### Write your own code location ############################## 
`define INPUT       "C:/Users/p8101/Desktop/input.txt"
`define OUTPUT      "C:/Users/p8101/Desktop/output.txt" 
`define OP          "C:/Users/p8101/Desktop/operator.txt"

//#################### Don't touch  ############################## 
`timescale 10ns/1ps
`define CYCLE 10
`define RTL

//`define SDFFILE    "./Netlist/PN_SYN.sdf" 
/*
`ifdef RTL
  `include "PN.v"
`endif

`ifdef GATE
  `include "./Netlist/PN_SYN.v"
`endif
*/

module TESTBED (
    clk,
    rst_n,
    mode,
    operator,
    in,
    in_valid,
    out_valid,
    out
);

//input
output reg clk = 0;
output reg rst_n;
output reg [1:0] mode;
output reg operator;
output reg [2:0] in;
output reg in_valid;

//output
input  wire out_valid;
input  wire signed [31:0] out;

//integer 
integer d,o; //d:data input;o:output
integer input_file,output_file,op_file;
integer gap,in_num,i;
integer patnum = 1000,pat,TIMES;
integer cycles,out_cnt,total_cycles=0;
integer error =0;
integer fail = 0;
integer seed = 87;

//reg
reg signed [31:0] golden_out;
reg [2:0] mode_tmp;

/*
initial begin
  `ifdef RTL
	$fsdbDumpfile("PN.fsdb");
	$fsdbDumpvars(0,"+mda");
  `endif
  `ifdef GATE
      	$sdf_annotate(`SDFFILE, inst_PN);
    	$fsdbDumpfile("Netlist/PN_SYN.fsdb");
	$fsdbDumpvars(0,"+mda"); 
  `endif
end
*/

`ifdef RTL
    PN inst_PN
        (
            .clk       (clk),
            .rst_n     (rst_n),
            .mode      (mode),
            .operator  (operator),
            .in        (in),
            .in_valid  (in_valid),
            .out_valid (out_valid),
            .out       (out)
        );

`endif


`ifdef GATE
    PN inst_PN
        (
            .clk       (clk),
            .rst_n     (rst_n),
            .mode      (mode),
            .operator  (operator),
            .in        (in),
            .in_valid  (in_valid),
            .out_valid (out_valid),
            .out       (out)
        );
`endif

//clk
always
begin
  #(`CYCLE/2) clk = ~clk;
end

//main
initial begin
    rst_n = 1;
    in_valid = 0;
    set_initail_task;
    reset_signal_task;
    //in_file;
    input_file  = $fopen(`INPUT,"r");
    op_file     = $fopen(`OP,"r");
    output_file = $fopen(`OUTPUT,"r");
    delay_task;
    //pattern loop
    for(pat=0;pat<patnum;pat=pat+1) begin
        first_state_error_check;
        input_task;
        wait_out_valid;
        output_task;
        delay_task;
    end
    $fclose(input_file);
    $fclose(output_file);
    $fclose(op_file);
    if(error == 0) YOU_PASS_task;
    else fail_task;
end 

task set_initail_task;begin
    mode = 2'bx;
    operator = 1'bx;
    in = 3'bx;
end
endtask

task reset_signal_task; begin 
    @(negedge clk); rst_n=0;
    #(`CYCLE/2);
    if((out_valid !== 'd0)||(out !== 'd0)) begin
        $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                                              fail (1)                                                                          ");
        $display ("                                                      Error Reset output signal !!                                                              ");
        $display ("                                                                                                                                                ");
        $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
        repeat(2) @(negedge clk);
        $finish;
    end
    @(negedge clk); rst_n=1;
end 
endtask

task input_task; begin
    // first data input
    in_valid = 1;
    d  = $fscanf(input_file,"%d",TIMES);
    //input
    for(in_num=0;in_num < TIMES;in_num=in_num+1) begin
        if(out_valid!==0) begin
            // in_valid and out_valid should not be high at the same time.   
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                              fail (2)                                                                          ");
            $display ("                                          out_valid should not be raised when in_valid is high.                                                 ");
            $display ("                                                                                                                                                ");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)  @(negedge clk);
            $finish;
        end
        if (out!==0) begin
            // Out_data should be 0 when out_valid is low.
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                              fail (3)                                                                          ");
            $display ("                                             Out_data should be 0 when out_valid is low.                                                        ");
            $display ("                                                                                                                                                ");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)  @(negedge clk);
            $finish;
        end
        //data
        if(in_num == 0) begin
             d  = $fscanf(op_file   ,"%b",operator);
             d  = $fscanf(input_file,"%d",mode);
             d  = $fscanf(input_file,"%d",in);
             mode_tmp = mode;  
        end
        else begin
             mode = 2'bx;
             d  = $fscanf(op_file,"%b",operator);
             d  = $fscanf(input_file,"%d",in); 
        end
        @(negedge clk);
    end
    in_valid =    0;
    operator = 1'bx;
    in       = 3'bx;
end 
endtask

task check_out; begin
    if(out !== 'd0)begin
        $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                                              fail (3)                                                                          ");
        $display ("                                             Out_data should be 0 when out_valid is low.                                                        ");
        $display ("                                                                                                                                                ");
        $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
        repeat(2)@(negedge clk);
        $finish;
    end
end endtask

task wait_out_valid ; 
begin
    cycles = 0;
    while(out_valid !== 1)begin
        cycles = cycles + 1;
        check_out;
        if(cycles == 1000) begin
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                              fail (4)                                                                          ");
            $display ("                                             The execution latency are over 1000 cycles                                                         ");
            $display ("                                                                                                                                                ");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)@(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_cycles = total_cycles + cycles;
end 
endtask

task checkans; begin
    o = $fscanf(output_file,"%d",golden_out);
    if(out !== golden_out) begin
        Display_ans_task;
        fail = 1;
    end
    @(negedge clk);
    out_cnt = out_cnt + 1;
end endtask

task output_task;begin
    out_cnt = 0;
    if(out_valid === 1) begin
        if (mode_tmp[1]) begin
            checkans;
        end
        else begin
            for (i=0;i<TIMES/3;i=i+1) begin  
                checkans;
            end
        end
    end
    if (mode_tmp[1] && out_cnt == 2) begin
        fail_valid_display;
    end
    if (!mode_tmp[1] && out_cnt > TIMES/3) begin
        fail_valid_display;
    end
    if(fail) begin
        fail = 0;
        error = error + 1;
    end
end
endtask

task Display_ans_task; begin
    if (error == 3) begin
        if (fail == 0) begin
            $display ("                                                                                                                                                ");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("---------------------------------------------------  Your error is more than 3  ----------------------------------------------------------------");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                                                                                                ");
        end
    end
    if (error < 3) begin
        if (fail == 0) begin
            $display ("---------------------------------------------------- The number of %3d pattern -----------------------------------------------------------------",pat);
        end
        $display ("                                              mode is %1d; Your out %1d is %3d ; exp out : %3d ;                                                    ",mode_tmp, out_cnt, out, golden_out);
    end
end endtask

task YOU_PASS_task;
    begin
    $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
    $display ("                                                                                                                                                ");
    $display ("                                                         Congratulations!                                                                       ");
    $display ("                                                  You pass both of the state tasks!                                                                 ");
    $display ("                                                  Your execution cycles = %5d cycles                                                            ", total_cycles);
    $display ("                                                  Your clock period = %.1f ns                                                                   ", `CYCLE);
    $display ("                                                  Your total latency = %.1f ns                                                                  ", total_cycles*`CYCLE);
    $display ("                                                                                                                                                ");
    $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
    $finish;
    end
endtask

task fail_valid_display;
    begin
    $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
    $display ("                                                              fail (5)                                                                          ");
    $display ("                                               The out_valid is out of expectation                                                              ");
    $display ("                                                                                                                                                ");
    $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
    repeat(2)@(negedge clk);
    $finish;
    end
endtask

task fail_task;begin
    $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
    $display ("                                                                                                                                                ");
    $display ("                                           Sorry, you fail in the second state, you got %3d error                                               ",error);
    $display ("                                                                                                                                                ");
    $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
    repeat(2)@(negedge clk);
    $finish;
    end
endtask

task delay_task ; begin
    gap = $random(seed)%3 + 2;//2~4 
    repeat(gap) @(negedge clk);
end endtask

task first_state_error_check;
    if(pat == 500) begin
        if(error != 0) begin
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                                                                                                ");
            $display ("                                           Sorry, you fail in the first state, you got %3d error                                                ",error);
            $display ("                                                                                                                                                ");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            repeat(2)@(negedge clk);
            $finish;
        end
        else begin
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                                                                                                ");
            $display ("                                                         Congratulations!                                                                       ");
            $display ("                                                  You pass the first state task!                                                                ");
            $display ("                                                                                                                                                ");
            $display ("------------------------------------------------------------------------------------------------------------------------------------------------");
        end
    end
endtask


endmodule
