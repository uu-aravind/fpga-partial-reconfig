// Copyright (c) 2001-2017 Intel Corporation
//  
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//  
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//  
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

`timescale 1 ps / 1 ps
`default_nettype none

// This module acts as the persona top level wrapper to the pr core
// For this instance it is the basic dso persona.

module basic_dsp_persona_stp_top 
   (
      input wire         pr_region_clk , 
      input wire         pr_logic_rst , 

      // Signaltap Interface
      input wire           tck ,
      input wire           tms ,
      input wire           tdi ,
      input wire           vir_tdi ,
      input wire           ena ,
      output wire          tdo ,
      // DDR4 interface
      input wire           emif_avmm_waitrequest , 
      input wire [511:0]   emif_avmm_readdata , 
      input wire           emif_avmm_readdatavalid , 
      output reg [4:0]     emif_avmm_burstcount , 
      output reg [511:0]   emif_avmm_writedata , 
      output reg [24:0]    emif_avmm_address , 
      output reg           emif_avmm_write , 
      output reg           emif_avmm_read , 
      output reg [63:0]    emif_avmm_byteenable , 
      output reg           emif_avmm_debugaccess ,

      input wire           pr_handshake_start_req ,
      output reg           pr_handshake_start_ack ,
      input wire           pr_handshake_stop_req ,
      output reg           pr_handshake_stop_ack ,
      output wire          freeze_pr_region_avmm ,

      // AVMM interface
      output reg           pr_region_avmm_waitrequest , 
      output reg [31:0]    pr_region_avmm_readdata , 
      output reg           pr_region_avmm_readdatavalid, 
      input wire [0:0]     pr_region_avmm_burstcount , 
      input wire [31:0]    pr_region_avmm_writedata , 
      input wire [15:0]    pr_region_avmm_address , 
      input wire           pr_region_avmm_write , 
      input wire           pr_region_avmm_read , 
      input wire [3:0]     pr_region_avmm_byteenable , 
      input wire           pr_region_avmm_debugaccess    
   );


   // HPR Address Registers Preservation
   reg [1:0] hpr_upper_addr /* synthesis preserve */;


   always_ff @(posedge pr_region_clk) begin
       hpr_upper_addr = pr_region_avmm_address[15:14];
   end
   always_ff @(posedge pr_region_clk) begin
         pr_handshake_start_ack <=1'b0;
         pr_handshake_stop_ack <=1'b0;
         if (  pr_handshake_start_req == 1'b0 ) begin
            pr_handshake_start_ack <= 1'b1;
         end
         // Active high SW reset
         if (  pr_handshake_stop_req == 1'b1 ) begin
            pr_handshake_stop_ack <=1'b1;
         end
   end
   
   assign freeze_pr_region_avmm = 1'b0;

    // PR Logic instantiation
    //
   basic_dsp_persona u_pr_core
   (
      .pr_region_clk                    ( pr_region_clk ),                
      .pr_logic_rst                     ( pr_logic_rst ),                 
      // DDR4 interface
      .emif_avmm_waitrequest            ( emif_avmm_waitrequest ),        
      .emif_avmm_readdata               ( emif_avmm_readdata ),           
      .emif_avmm_readdatavalid          ( emif_avmm_readdatavalid ),      
      .emif_avmm_burstcount             ( emif_avmm_burstcount ),         
      .emif_avmm_writedata              ( emif_avmm_writedata ),          
      .emif_avmm_address                ( emif_avmm_address ),            
      .emif_avmm_write                  ( emif_avmm_write ),              
      .emif_avmm_read                   ( emif_avmm_read ),               
      .emif_avmm_byteenable             ( emif_avmm_byteenable ),         
      .emif_avmm_debugaccess            ( emif_avmm_debugaccess ),        


      // AVMM interface
      .pr_region_avmm_waitrequest       ( pr_region_avmm_waitrequest ),    
      .pr_region_avmm_readdata          ( pr_region_avmm_readdata ),      
      .pr_region_avmm_readdatavalid     ( pr_region_avmm_readdatavalid ),  
      .pr_region_avmm_burstcount        ( pr_region_avmm_burstcount ),    
      .pr_region_avmm_writedata         ( pr_region_avmm_writedata),      
      .pr_region_avmm_address           ( pr_region_avmm_address[13:0] ),       
      .pr_region_avmm_write             ( pr_region_avmm_write ),         
      .pr_region_avmm_read              ( pr_region_avmm_read ),          
      .pr_region_avmm_byteenable        ( pr_region_avmm_byteenable ),    
      .pr_region_avmm_debugaccess       ( pr_region_avmm_debugaccess )    
   );
   // Signal Tap JTAG host used for
   // signaltap within pr region.
   sld_jtag_bridge_host u_sld_jtag_host (
      .tck     ( tck ),
      .tms     ( tms ),
      .tdi     ( tdi ),
      .vir_tdi ( vir_tdi ),
      .ena     ( ena ),
      .tdo     ( tdo )
   );
endmodule
