`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/20 13:02:41
// Design Name: 
// Module Name: display_spi_master
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


module display_spi_master(
        input wire clk,
        input wire rst_n,
        
        input wire i_start,
        
        
        output reg o_sclk,
        output reg o_mosi,
        output reg o_cs_n,
        output reg o_dc_n,
        output reg o_rst_n 
    );
     wire [7:0] w_data_setup;
     wire [7:0] w_data_send;
    reg r_start;
    reg r_pulse_en;
    reg [12:0] r_pulsecount;
    reg r_tick;
    reg  [2:0] r_state, r_next_state;
    reg [4:0] r_setup_count ;
    reg [22:0] r_count_100ms;
    reg [8:0] r_count_3us; 
    reg [2:0] r_dcount;
   
    reg [9:0] r_send_count;
    
    parameter RESET = 3'b000;
    parameter SETUP = 3'b001;
    parameter SEND = 3'b010; 
    parameter WAIT = 3'b011;
    parameter DONE = 3'b100;  
    
    
     
    always@(posedge clk) begin
    if(!rst_n) begin
    
    r_pulsecount <= 0;
    r_tick <= 0;
    o_sclk <= 1;
    r_start <= 0;
    end
    else begin
    if(i_start) r_start <= 1;
     if(r_start && r_pulse_en)  begin
        if(r_pulsecount == 6249) begin
          r_tick <= 1;
          r_pulsecount <= 0;
          o_sclk <= ~o_sclk;
          end
        else begin
          r_tick <= 0;
          r_pulsecount <= r_pulsecount +1;
         end
        end
      end
  end

 
 
 always@(posedge clk) begin
 if(!rst_n) begin 
 r_pulse_en <= 0;
 r_count_100ms <= 0;
 r_dcount <= 0;
 r_setup_count <= 0;
 r_send_count <= 0;
 o_rst_n <= 0;
 o_dc_n <=1;
 o_cs_n <=1;
 end
 else begin
    if(i_start) r_state <= RESET;
    if(r_state == RESET) begin
         r_count_100ms <= r_count_100ms +1;
          if(r_count_100ms < 4_000_000) o_rst_n<=0;
          else if(r_count_100ms >= 4_000_000 && r_count_100ms <5_000_000) o_rst_n <= 1;
          else if(r_count_100ms >= 5_000_000 && r_count_100ms <5_000_150) o_rst_n <=0;
           /*r_pulse_en <= 0;
           r_setup_count <= 1;
           r_count_100ms <= 0;*/
           else if(r_count_100ms >=5_000_150 && r_count_100ms <5_000_300) o_rst_n <= 1;
           else if(r_count_100ms == 5_000_300) begin
                             r_state <= SETUP;
                             r_pulse_en <= 1;
                             r_count_100ms <= 0;
                           //  o_sclk <= 1;
                             o_cs_n <= 0;
                             o_dc_n <= 0;
                             //o_sclk <= 1;
           end
     end

        if(r_tick && o_sclk) begin           
          if(r_state == SETUP ) begin
                r_dcount <= r_dcount + 1; 
                if(r_setup_count >= 0 && r_setup_count < 30) begin
                    if(r_dcount == 7) begin
                        r_setup_count <= r_setup_count + 1;
                        r_dcount<= 0;
                    end
                 end   
                else if(r_setup_count == 30) begin
                    if(r_dcount == 7)  begin
                        r_dcount <= 0;
                        r_state <= WAIT;
                        r_pulse_en <= 0;
                        o_cs_n <= 1;
                        o_dc_n <= 0;
                        //o_sclk <= 1;    
                    end
                end
           end
         else if(r_state == SEND) begin
              r_dcount <= r_dcount + 1;
              if(r_send_count >= 0 && r_send_count < 1023) begin
                    if(r_dcount == 7) begin
                        r_send_count <= r_send_count + 1;
                        r_dcount <= 0;
                    end
              end      
              else if(r_send_count == 1023) begin
                if(r_dcount == 7) begin
                    r_dcount <=0;
                    r_state <= DONE;
                    r_pulse_en <= 0;
                    o_cs_n <= 1; 
                    o_dc_n <= 1;
                   // o_sclk <= 1;
                end
             end  
         end 
        end 
       else if(r_tick && !o_sclk) begin
        if(r_state == SETUP) begin
            if(r_setup_count >= 0 && r_setup_count <= 30 ) begin
                case(r_dcount)
                3'd0: o_mosi <= w_data_setup[7];
                3'd1: o_mosi <= w_data_setup[6];
                3'd2: o_mosi <= w_data_setup[5];
                3'd3: o_mosi <= w_data_setup[4];
                3'd4: o_mosi <= w_data_setup[3];
                3'd5: o_mosi <= w_data_setup[2];
                3'd6: o_mosi <= w_data_setup[1];
                3'd7: o_mosi <= w_data_setup[0];
                default: o_mosi <= 0;
                 endcase
            end
             else o_mosi <= 0;
      end
       //if(r_state == SEND) 
       if(r_state == SEND) begin
        
            case(r_dcount)
            3'd0: o_mosi <= w_data_send[7];
            3'd1: o_mosi <= w_data_send[6];
            3'd2: o_mosi <= w_data_send[5];
            3'd3: o_mosi <= w_data_send[4];
            3'd4: o_mosi <= w_data_send[3];
            3'd5: o_mosi <= w_data_send[2];
            3'd6: o_mosi <= w_data_send[1];
            3'd7: o_mosi <= w_data_send[0];
            default: o_mosi <= 0;
             endcase
         end
      end
    if(r_state == WAIT) begin
       r_count_100ms <= r_count_100ms +1;
       if(r_count_100ms == 5_000_000) begin 
              r_state <= SEND;
              r_pulse_en <= 1;
              r_count_100ms <= 0;
            
              o_cs_n <= 0;
              o_dc_n <= 1;
             // o_sclk <= 1;
       end
    end
   //if(r_state == DONE) 
   end 
        
        
 end
     
     
     
/*always@(posedge clk) begin
 if(!rst_n) begin 
  o_cs_n <=1;
 o_dc_n <=0;
 end
 else begin
 
 if(r_setup_count == 0) o_cs_n <= 1;
 if(r_state == SETUP && r_setup_count == 1) begin
 o_cs_n <=1;
 o_dc_n <=0;
 end      
 else if(r_pulse_en && r_tick) begin
        if(!o_sclk) begin
case(r_next_state)
IDLE: begin
o_dc_n <= 1;
 o_cs_n <= 1;
end
SETUP: begin
if(r_next_state == SETUP && r_state == IDLE) o_dc_n <= 1;
else if ( r_setup_count == 0 && r_count_100ms >=0 && r_count_100ms < 4_999_999) o_cs_n <= 1;
else if (r_setup_count == 0 && r_count_3us >= 0 && r_count_3us <299) o_cs_n <= 1;
else if( r_count_3us == 299) o_cs_n <= 0;
else begin
o_dc_n <= 0;
o_cs_n <= 0;
if(r_next_state == SEND) o_dc_n <= 1;
end
end
SEND: begin
o_dc_n <= 1;
o_cs_n <= 0;
end
endcase
end
end
end

end*/

  
        
    assign w_data_setup =
            (r_setup_count ==  5'd0)? 8'hAE:
            (r_setup_count ==   5'd1)? 8'hD5: 
             (r_setup_count ==  5'd2)? 8'h90:
            (r_setup_count ==   5'd3)? 8'hA8:
            (r_setup_count ==   5'd4)? 8'h3F:
            (r_setup_count ==   5'd5)? 8'hD3:
            (r_setup_count ==   5'd6)? 8'h00:
            (r_setup_count ==   5'd7)? 8'h40:
            (r_setup_count ==   5'd8)? 8'hA1:
             (r_setup_count ==  5'd9)? 8'hC8:
            (r_setup_count ==   5'd10)? 8'hDA:
            (r_setup_count ==   5'd11)? 8'h12:
            (r_setup_count ==  5'd12)? 8'h81:
            (r_setup_count ==   5'd13)? 8'hB0:
            (r_setup_count ==   5'd14)? 8'hD9:
            (r_setup_count ==   5'd15)? 8'h22:
            //18
            (r_setup_count ==   5'd16)? 8'hDB:
            (r_setup_count ==   5'd17)? 8'h30:
            (r_setup_count ==   5'd18)? 8'hA4: //dsip on/off
            (r_setup_count ==   5'd19)? 8'hA6:
             (r_setup_count ==  5'd20)? 8'h20: //address mode command
            (r_setup_count ==   5'd21)? 8'h00: // Horizontal mode`
            (r_setup_count ==   5'd22)? 8'h21:
            (r_setup_count ==   5'd23)? 8'h00:
            (r_setup_count ==   5'd24)? 8'h7F:
            (r_setup_count ==   5'd25)? 8'h22:
            (r_setup_count ==   5'd26)? 8'h00:
            (r_setup_count ==   5'd27)? 8'h07:
            (r_setup_count ==   5'd28)? 8'h8D:
            (r_setup_count ==   5'd29)? 8'h14:
            (r_setup_count ==   5'd30)? 8'hAF:8'h00;      
      assign w_data_send =
             (r_send_count ==10'd37)? 8'h18:
             (r_send_count ==10'd36 || r_send_count ==10'd38)? 8'h20:
             (r_send_count ==10'd0 || r_send_count ==10'd4 || r_send_count ==10'd6 || r_send_count ==10'd12 || r_send_count ==10'd18 || r_send_count ==10'd35
              || r_send_count ==10'd39 || r_send_count ==10'd47 || r_send_count ==10'd53 || r_send_count ==10'd59)? 8'h7F:
             (r_send_count ==10'd1 || r_send_count ==10'd2 || r_send_count ==10'd3)? 8'h08:
             (r_send_count ==10'd7 || r_send_count ==10'd8 || r_send_count ==10'd9)? 8'h49:
             (r_send_count ==10'd10 || r_send_count ==10'd25 || r_send_count ==10'd26 || r_send_count ==10'd27 || r_send_count ==10'd42|| r_send_count ==10'd43
              || r_send_count ==10'd44 || r_send_count ==10'd60 || r_send_count ==10'd61)? 8'h41:
             (r_send_count ==10'd13 || r_send_count ==10'd14 || r_send_count ==10'd15 || r_send_count ==10'd16 || r_send_count ==10'd19|| r_send_count ==10'd20
              || r_send_count ==10'd21 || r_send_count ==10'd22 || r_send_count ==10'd54 || r_send_count ==10'd55 || r_send_count ==10'd56 || r_send_count ==10'd57)? 8'h40:
             (r_send_count ==10'd24|| r_send_count ==10'd28 || r_send_count ==10'd41 || r_send_count ==10'd45)? 8'h3E:
             (r_send_count ==10'd48)? 8'h09:
             (r_send_count ==10'd49)? 8'h19:
             (r_send_count ==10'd50)? 8'h29:
             (r_send_count ==10'd51)? 8'h46:
             (r_send_count ==10'd62)? 8'h22:
             (r_send_count ==10'd63)? 8'h1C:8'h00;
            
                   
            
       
/* always@(*) begin
 r_next_state = r_state;
 
 case(r_state)
 IDLE: begin

 if(r_start) r_next_state = SETUP;
 else r_next_state = IDLE;
 end

 
 SETUP: begin
 r_next_state =  SETUP;
 if(r_count_100ms == 399 && r_setup_count == 32) r_next_state = SEND; 
  end

//SEND
SEND: begin
r_next_state = SEND;
if(r_send_count == 10'd1023 && r_dcount == 7) r_next_state = IDLE;
end
endcase
end*/

        
        
endmodule
