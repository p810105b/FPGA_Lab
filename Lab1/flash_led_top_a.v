`timescale 1ps / 1ps
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
	output reg [15:0]led
);

//====== Register ======
reg [24:0] count;

wire d_clk;

//====== frequency division ======
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count <= 0;
    else
        count <= count + 1;
end

assign d_clk = count[20];

//====== LED light control ======
always@(posedge d_clk or negedge rst_n) 
begin
    if(!rst_n)
        led <= 16'b1000_0001_0000_0001;
    else begin
        case(btn_c)
            0 : begin
                    if(led[7:0] != 8'b1000_0000)
                        begin
                            led[7:0] <= led[7:0] << 1;
                        end
                    else 
                        begin
                            led[7:0] <= 8'b0000_0001;
                        end

                    if(led[11:8] != 4'b1000)
                        begin
                            led[11:8] <= led[11:8] << 1;
                        end
                    else 
                        begin
                            led[11:8] <= 4'b0001;
                        end

                    if(led[15:12] != 4'b0001)
                        begin
                            led[15:12] <= led[15:12] >> 1;
                        end
                    else 
                        begin
                            led[15:12] <= 4'b1000;
                        end
                end
            1 : begin
                    if(led[7:0] != 8'b0000_0001)
                        begin
                            led[7:0] <= led[7:0] >> 1;
                        end
                    else 
                        begin
                            led[7:0] <= 8'b1000_0000;
                        end

                    if(led[11:8] != 4'b0001)
                        begin
                            led[11:8] <= led[11:8] >> 1;
                        end
                    else 
                        begin
                            led[11:8] <= 4'b1000;
                        end

                    if(led[15:12] != 4'b1000)
                        begin
                            led[15:12] <= led[15:12] << 1;
                        end
                    else 
                        begin
                            led[15:12] <= 4'b0001;
                        end
                end
        endcase
    end
end

//====== end module ======
endmodule