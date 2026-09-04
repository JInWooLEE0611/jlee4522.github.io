`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/02 10:54:15
// Design Name: 
// Module Name: spimaster_mcp3008
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


module spimaster_mcp3004(
            input wire clk,
            input wire rst_n,
            input wire i_start,
          
            input wire i_miso,
            
            input wire i_toggle_ch0,
            input wire i_toggle_ch1,
            input wire i_toggle_ch2,
            
            output reg o_cs_n,
            output reg o_sclk,
            output reg o_mosi,
      
            output reg i_led0,
            output reg i_led1,
            output reg i_led2
        
    );
    
    reg r_start;
    reg [2:0] r_state;
    reg [2:0] r_ch_count;
    reg [3:0] r_sel_count;
    reg [4:0] r_bit_count;
     
    reg [4:0] r_sel_shift;
    reg [9:0] r_adc_shift;
    
    reg [11:0] clk_count;
    reg sclk_tick;
    
           reg [9:0] r_ch0_data;
           reg [9:0] r_ch1_data;
           reg [9:0] r_ch2_data;
    
    parameter ch0 = 2'd0;
    parameter ch1 = 2'd1;
    parameter ch2 = 2'd2;
    
    parameter S0 = 3'd0; //Idle, send [5bit cell] if start
    
    parameter S1 = 3'd1; // SEND command code ONE BY ONE
    parameter S2 = 3'd2; // SEND command code ONE BY ONE
    parameter S3 = 3'd3; // SEND command code ONE BY ONE
    
    parameter S4 = 3'd4; //t_sample & null -MOSI
    parameter S5 = 3'd5; //read the data - RECIEVE 10bit-ADC signal
    parameter S6 = 3'd6;  // select hannel-memory reg,save, send [10bit cell]  
        
        
    always@(posedge clk) begin 
i_led0 <=(r_ch0_data < 10'd900); //active low 
i_led1 <= (r_ch1_data < 10'd900);
i_led2 <= (r_ch2_data < 10'd900);
end
 
    always@(posedge clk) begin
    if(!rst_n) r_start <= 0;
     else begin
      if(i_start) r_start <= 1;  
    else r_start <= r_start;
    end
    end
    
    //clktick
    always@(posedge clk) begin
   if(!rst_n) begin
    clk_count <= 0;
    sclk_tick <= 0; 
    end
    else if(r_start && r_state != 0) begin
        if(clk_count == 12'd2499) begin
            clk_count <= 0;
            sclk_tick <= 1;
        end
        else begin
            clk_count <= clk_count + 1;
            sclk_tick <= 0;
            end
            end
      else begin
        clk_count <= 0;
        sclk_tick <= 0;
        end
      end
    
    
   

    
   //FSM
   always@(posedge clk) begin
   if (!rst_n) begin
       
       
        o_sclk <= 1;
        o_cs_n <= 1;
        o_mosi <= 0;
         r_state <= S0;
        
        r_ch_count <= 0;
        
        
        r_sel_count <= 0;
        r_bit_count <= 0;
        r_sel_shift <= 0; //cell initialize
        r_adc_shift <= 0; //cell initialize
    end 
    
    
    else begin
        if(r_start) 
        
     case(r_state)
     S0: begin
     r_state<=S0;
        o_cs_n <= 1;
        o_sclk <= 1;
        o_mosi <= 0;
       r_sel_count <= 0;
       o_sclk <= 1'b1;
            
            case(r_ch_count)
                ch0: begin
                o_cs_n <= 0;
                r_sel_shift <= {1'b1,1'b1,1'b1,ch0}; // 5bit {start,single,D2,D1,D0)
                r_state <= S1;
                end
                ch1:  begin
                o_cs_n <= 0;
                r_sel_shift <= {1'b1,1'b1,1'b1,ch1}; // 5bit {start,single,D2,D1,D0)
                r_state <= S2;
                end
                ch2:  begin
                o_cs_n <= 0;
                r_sel_shift <= {1'b1,1'b1,1'b1,ch2}; // 5bit {start,single,D2,D1,D0)
                r_state <= S3;
                end
           endcase;          
           end
                

    S1: begin  
    o_cs_n <= 0;
     
    if(sclk_tick) begin
        o_sclk <= ~o_sclk;
            if (o_sclk == 1'b1) begin
         r_sel_count<= r_sel_count+1;
        
          o_mosi <= r_sel_shift[4];
    r_sel_shift <= {r_sel_shift[3:0],1'b0};
 
    if(r_sel_count == 3'd4) begin 
    r_state <= S4;
    r_sel_count <= 0; 
    end 
    else r_state <= S1; 
    end
     end
         end
    
    
    //////////////
     S2: begin
      o_cs_n <= 0;
      if(sclk_tick) begin   
        o_sclk <= ~o_sclk;
            if(o_sclk == 1'b1) begin
         r_sel_count<= r_sel_count+1;
      
    o_mosi <= r_sel_shift[4];
    r_sel_shift <= {r_sel_shift[3:0],1'b0};
    
    if(r_sel_count == 3'd4) begin 
    r_state <= S4;
    r_sel_count <= 0;
     end 
    else r_state <= S2; end
    end
    end
           

///////
    S3: begin //
    o_cs_n <= 0;
      if(sclk_tick) begin   
        o_sclk <= ~o_sclk;
            if(o_sclk == 1'b1) begin
    r_sel_count<= r_sel_count+1;
    
    o_mosi <= r_sel_shift[4];
    r_sel_shift <= {r_sel_shift[3:0],1'b0};
    
    if(r_sel_count == 3'd4) begin 
    r_state <= S4;
    r_sel_count <= 0;
     end 
    else r_state <= S3; 
    end
    end
    end
    
    
    
    
    
    ///////
    S4: begin
    
    o_cs_n <= 0;
   
    if(sclk_tick) begin   
        o_sclk <= ~o_sclk;
            if(o_sclk == 1'b1) begin
     if(r_sel_count == 3'd2) begin
    r_bit_count <= 0; 
    r_state <= S5; end 
    else begin
     r_state <= S4;
    r_sel_count <= r_sel_count+1; end
    end
    end
    end
    
    
   ////// 
    S5: begin
    o_cs_n <= 0;
    
     if(sclk_tick) begin   
        o_sclk <= ~o_sclk;
            if(o_sclk == 1'b1) begin
   r_bit_count<=r_bit_count+1;
     

   r_adc_shift <= {r_adc_shift[8:0],i_miso};
   
   if(r_bit_count == 4'd9) begin
   r_bit_count <= 0;
   r_state <= S6; end
   else r_state <= S5;
    end
    end
    end
  
  
  ///////    
   S6: begin
  
  o_cs_n <= 1;
  r_state <= S0; 
  
   case(r_ch_count)
   ch0: begin
   if(i_toggle_ch0) r_ch0_data <= r_adc_shift;
   else r_ch0_data <= r_ch0_data;
   r_ch_count <= ch1; 
   end
   ch1: begin
   if(i_toggle_ch1) r_ch1_data <= r_adc_shift;
   else r_ch1_data <= r_ch1_data;
   r_ch_count <= ch2;
   end
   ch2: begin
   if(i_toggle_ch2) r_ch2_data <= r_adc_shift;
   else r_ch2_data <= r_ch2_data;
   r_ch_count <= ch0;
   end
   endcase;
  
  end
   
  endcase;
  end
  
  
end
   

            
       
endmodule
