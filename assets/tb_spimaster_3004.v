`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/03 09:33:31
// Design Name: 
// Module Name: tb_spimaster_3004
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_spimaster_3004();
            reg clk;
            reg rst_n;
            reg r_i_start;
           
            reg r_miso;
            
            reg r_toggle_ch0;
            reg r_toggle_ch1;
            reg r_toggle_ch2;
            
            wire w_cs_n;
            wire w_sclk;
            wire w_mosi;
           
  
 spimaster_mcp3004 U0( .clk(clk), .rst_n(rst_n), .i_start(r_i_start),  .i_miso(r_miso), 
                           .i_toggle_ch0(r_toggle_ch0), .i_toggle_ch1(r_toggle_ch1), .i_toggle_ch2(r_toggle_ch2),
                         .o_cs_n(w_cs_n), .o_sclk(w_sclk), .o_mosi(w_mosi));
 initial begin 
 clk = 0;
 forever #1 clk = ~clk;
 end
 
 reg[9:0] adc_value;
 integer bit_index;
 
 always@(*) begin
    case(U0.r_ch_count)
        2'd0: adc_value = 10'b11_1000_1101;
        2'd1: adc_value = 10'b00_1111_1010;
        2'd2: adc_value = 10'b10_1010_1110;
        endcase 
 end
 
 initial begin
 r_miso = 0;
 bit_index = 0;
 
 end        
 
 always@(posedge w_sclk) begin
    if(!w_cs_n &&  U0.r_state == U0.S5) begin
     r_miso <= adc_value[bit_index];
     
     if(bit_index == 9) bit_index <= 0;
     else bit_index <= bit_index + 1;
     end
  end                 
 
 initial begin
 rst_n = 0;
 r_i_start = 0;

 
 r_toggle_ch0 =1;
 r_toggle_ch1 =1;
 r_toggle_ch2 =1;
 #20;
 rst_n = 1;
 #20;
 r_i_start =1;   
 #10;
 r_i_start =0;  
 #2000000;
 $finish;
 end                    
endmodule
