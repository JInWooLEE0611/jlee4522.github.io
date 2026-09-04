`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/06 12:28:52
// Design Name: 
// Module Name: apb3_slave
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


module apb3_slave(
  input wire pclk,
  input wire preset_n,
  
  input [31:0] i_paddr,
  input wire i_psel,
  input wire i_penable,
  input wire i_pwrite,
  input wire [31:0] i_pwdata,
  
  output reg [31:0] o_prdata,
  output reg o_pready,
  output reg o_pslverr
    );
    reg [31:0] data_arr[15:0];
    reg [1:0] r_state;
    
    parameter IDLE = 2'd0;
    parameter SETUP = 2'd1;
    parameter ACCESS = 2'd2;
    integer i;
    
   reg [1:0] r_count ;
    
 //   o_pready condition
     always@(posedge pclk) begin
  if(!preset_n) begin
   r_count <= 0;
  o_pready <=0;
  end
  else begin
    o_pready <= 1'b0;
   r_count <=0;
  if(i_penable) begin
   r_count <= r_count +1;
   if(r_count == 2'd2) o_pready <= 1'b1;
   else if(r_count  == 2'd3) begin
   o_pready <= 1'b0;
 end
   end
   end 
    end
  
    //FSM
  always@(posedge pclk) begin
  if(!preset_n) begin
  r_state <= IDLE;
  for( i = 0; i < 16; i = i+1)  begin 
   data_arr[i] <= 32'h0000_0000; end
   end
   else begin
  

  
   case(r_state)
  
   IDLE: begin
   if(i_psel) r_state <= SETUP;
   else r_state <= IDLE;
    end
   
   
   SETUP: r_state <= ACCESS;

   
   ACCESS:begin
   if(!i_penable && o_pready && i_psel) r_state <= SETUP;
   else if(!i_psel) r_state <= IDLE;
   else if(i_penable && o_pready && i_psel) r_state <= ACCESS; 
   end
   endcase;
   
   end
   end
   
   //WRITE - REGISTER NECCESSARY
   
   always@(posedge pclk) begin
   
    if(i_psel && i_penable && i_pwrite && (r_count==2)) begin
        case(i_paddr)
        32'h1000_2000: data_arr[0] <= i_pwdata;
        32'h1000_2004: data_arr[1] <= i_pwdata;
        32'h1000_2008: data_arr[2] <= i_pwdata;
        32'h1000_200C: data_arr[3] <= i_pwdata;
        32'h1000_2010: data_arr[4] <= i_pwdata;
        32'h1000_2014: data_arr[5] <= i_pwdata;
        32'h1000_2018: data_arr[6] <= i_pwdata;
        32'h1000_201C: data_arr[7] <= i_pwdata;
        32'h1000_2020: data_arr[8] <= i_pwdata;
        32'h1000_2024: data_arr[9] <= i_pwdata;
        32'h1000_2028: data_arr[10] <= i_pwdata;
        32'h1000_202C: data_arr[11] <= i_pwdata;
        32'h1000_2030: data_arr[12] <= i_pwdata;
        32'h1000_2034: data_arr[13] <= i_pwdata;
        32'h1000_2038: data_arr[14] <= i_pwdata;
        32'h1000_203C: data_arr[15] <= i_pwdata;
        endcase;
        end
        end
   
   
   //READ - REGISTER FREE -> combinational
   always@(*) begin
     if(!preset_n) o_prdata = 32'h0000_0000;
  
    if(i_psel && i_penable && !i_pwrite && o_pready) begin
        case(i_paddr)
        32'h1000_2000: o_prdata = data_arr[0] ;
        32'h1000_2004: o_prdata = data_arr[1] ;
        32'h1000_2008: o_prdata = data_arr[2] ;
        32'h1000_200C: o_prdata = data_arr[3] ;
        32'h1000_2010: o_prdata = data_arr[4] ;
        32'h1000_2014: o_prdata = data_arr[5] ;
        32'h1000_2018: o_prdata = data_arr[6] ;
        32'h1000_201C: o_prdata = data_arr[7] ;
        32'h1000_2020: o_prdata = data_arr[8] ;
        32'h1000_2024: o_prdata = data_arr[9] ;
        32'h1000_2028: o_prdata = data_arr[10] ;
        32'h1000_202C: o_prdata = data_arr[11] ;
        32'h1000_2030: o_prdata = data_arr[12] ;
        32'h1000_2034: o_prdata = data_arr[13] ;
        32'h1000_2038: o_prdata = data_arr[14] ;
        32'h1000_203C: o_prdata = data_arr[15] ;
        endcase;
        end
        end
   
   
   // ERROR RESPONSE
   always@(*) begin
   o_pslverr = 1'b0;
   
   if((i_psel && i_penable && i_pwrite && o_pready)||
      (i_psel && i_penable && !i_pwrite && o_pready)) begin
     case(i_paddr)
        32'h1000_2000, 
        32'h1000_2004,
        32'h1000_2008,
        32'h1000_200C,
        32'h1000_2010,
        32'h1000_2014,
        32'h1000_2018,
        32'h1000_201C,
        32'h1000_2020,
        32'h1000_2024,
        32'h1000_2028,
        32'h1000_202C,
        32'h1000_2030,
        32'h1000_2034,
        32'h1000_2038,
        32'h1000_203C: o_pslverr = 1'b0;
        default:o_pslverr = 1'b1;
        endcase;
   end
   end

   
   
    endmodule 
   
   
    

