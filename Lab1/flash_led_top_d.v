`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCHU EE Lab716
// Engineer:
//
// Module Name: flash_led_top
// Project Name:
// Target Devices:
// Versions: 1.0
// Tool Versions: Vivado 2018.2
//////////////////////////////////////////////////////////////////////////////////

//====== module ======
module flash_led_top(
    input clk,
    input rst_n,
    input btn_c,
    output [15:0] led
);

//====== Register ======
reg [15:0] led;
reg [24:0] count;

wire d_clk;

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count <= 0;
    else
        count <= count + 1;
end

assign d_clk = count[23];

//====== LED light control ======
always@(posedge d_clk or negedge rst_n) begin
    if(!rst_n)
        led <= 16'b1000_0000_0000_0000;
    else begin
        case(btn_c)
            0 : begin
                if(led != 16'b0000_0000_0000_0001)begin
                    led <= led >> 1;
                end
                else begin
                    led <= 16'b1000_0000_0000_0000;
                end
            end
            1 : begin
                if(led != 16'b1000_0000_0000_0000)begin
                    led <= led << 1'b1;
                end
                else begin
                    led <= 16'b0000_0000_0000_0001;
                end
            end
        endcase
    end
end

//====== end module ======
endmodule 