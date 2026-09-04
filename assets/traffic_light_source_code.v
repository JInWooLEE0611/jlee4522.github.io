`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/19 09:45:39
// Design Name: 
// Module Name: integrated_light_controller
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


module light_controller_onboard(
        input wire clk,
        input wire i_t_start,
        input wire rst_n,
        
        output wire  o_car_ns_red,
        output wire  o_car_ns_yellow,
        output wire  o_car_ns_green,
        output wire  o_car_ns_left,
        
        output wire o_ped_ew_green,
        output wire o_ped_ew_red,
        
        
        output wire o_car_ew_red,
        output wire o_car_ew_yellow,
        output wire o_car_ew_green,
        output wire o_car_ew_left,
        
        output wire  o_ped_ns_green,
        output wire  o_ped_ns_red
      

    );
   light_controller_fsm U_NS( .clk(clk), .i_start(i_t_start), .rst_n(rst_n), .o_car_red(o_car_ns_red), .o_car_yellow(o_car_ns_yellow), .o_car_green(o_car_ns_green), .o_car_left(o_car_ns_left), .o_ped_green(o_ped_ns_green), .o_ped_red(o_ped_ns_red), .i_phase(1'b1)); 
    light_controller_fsm U_EW( .clk(clk), .i_start(i_t_start), .rst_n(rst_n), .o_car_red(o_car_ew_red), .o_car_yellow(o_car_ew_yellow),.o_car_green(o_car_ew_green),.o_car_left(o_car_ew_left), .o_ped_green(o_ped_ew_green), .o_ped_red(o_ped_ew_red), .i_phase(1'b0)); 
 endmodule

module light_controller_fsm(
        input wire clk,
        input wire i_start,
        input wire rst_n,
        
        input wire i_phase,
        
        output reg o_car_red,
        output reg o_car_yellow,
        output reg o_car_green,
        output reg o_car_left,
        
        output reg o_ped_green,
        output reg o_ped_red
        
    );
    reg [2:0] r_state, r_next_state;
    reg [31:0] r_count;
    reg r_start;
    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011; 
    parameter S4 = 3'b100;
    parameter S5 = 3'b101;
    parameter S6 = 3'b110;
    
    parameter cycle = 32'd25000000;
    
    
    always@(posedge clk) begin
  
    if (i_start) r_start<= 1'b1;
    
    if(!rst_n) begin
         r_count<=32'd0;
         r_state <=S0;
         r_start <= 1'b0;
                end
    else begin
    if(!r_start && i_phase) begin
             r_count <= 32'd4294967295; // 32'd-1 
             
                                 end
    else if(!r_start && !i_phase) begin 
             r_count <= 32'd849999999; //34cycle -1
             
                                 end
    else if (r_start) begin
            
            r_state <= r_next_state;
            if(r_count == 32'd1699999999) r_count <= 32'd0;
            else if(r_count < 32'd1699999999) r_count <= r_count + 32'd1;
            else r_count <= 32'd0;
                      end 
                         end
                     
  
    end
   
   always@(*) begin
r_next_state = r_state;
   case(r_state)
   S0 : begin
        if(r_start && i_phase) r_next_state = S1;
        else if(r_start && !i_phase) r_next_state = S4;      
        end
         
   S1 : if(r_count == 20*cycle - 32'd1) r_next_state = S2;
  
   S2 : begin
        if(r_count == 22*cycle - 32'd1) r_next_state = S3;
        else if(r_count == 34*cycle -32'd1) r_next_state = S4;
        end   
        
   S3 : if(r_count == 32*cycle - 32'd1) r_next_state = S2;

   S4 : begin   
        if(r_count == 48*cycle -32'd1 || r_count == 50*cycle -32'd1 || r_count == 52*cycle - 32'd1 ) r_next_state = S5;
        else if( r_count == 53*cycle) r_next_state = S6; 
        end 
        
   S5 : if(r_count == 49*cycle-32'd1 || r_count == 51*cycle - 32'd1 || r_count == 53*cycle - 32'd1) r_next_state = S4; 
   S6 : if(r_count == 32'd1699999999) r_next_state = S1;
  
   endcase;
   
 end  
 //OUTPUT LOGIC
 always@(*) begin 
 o_car_red = o_car_red;
      o_car_yellow = o_car_yellow;
      o_car_green = o_car_green;
      o_car_left = o_car_left;
      o_ped_red = o_ped_red;
      o_ped_green = o_ped_green;
 case(r_state)
 S0 :begin 
      o_car_red = 1'b0;
      o_car_green = 1'b0;
      o_car_yellow = 1'b0;
      o_car_left = 1'b0;
      o_ped_red = 1'b0;
      o_ped_green = 1'b0;
      end
  S1 :begin 
      o_car_red = 1'b0;
      o_car_green = 1'b1;
      o_car_yellow = 1'b0;
      o_car_left = 1'b0;
      o_ped_red = 1'b1;
      o_ped_green = 1'b0;
      end
  S2 :begin 
       o_car_red = 1'b0;
      o_car_green = 1'b0;
      o_car_yellow = 1'b1;
      o_car_left = 1'b0;
      o_ped_red = 1'b1;
      o_ped_green = 1'b0;
      end 
 S3 :begin 
      o_car_red = 1'b0;
      o_car_green = 1'b0;
      o_car_yellow = 1'b0;
      o_car_left = 1'b1;
      o_ped_red = 1'b1;
      o_ped_green = 1'b0;
      end 
 S4 :begin 
       o_car_red = 1'b1;
      o_car_green = 1'b0;
      o_car_yellow = 1'b0;
      o_car_left = 1'b0;
      o_ped_red = 1'b0;
      o_ped_green = 1'b1;
      end
 S5 :begin 
       o_car_red = 1'b1;
      o_car_green = 1'b0;
      o_car_yellow = 1'b0;
      o_car_left = 1'b0;
      o_ped_red = 1'b0;
      o_ped_green = 1'b0;
      end     
 S6 :begin 
       o_car_red = 1'b1;
      o_car_green = 1'b0;
      o_car_yellow = 1'b0;
      o_car_left = 1'b0;
      o_ped_red = 1'b1;
      o_ped_green = 1'b0;
      end
      
    
      endcase;
 end
 
 
 endmodule
