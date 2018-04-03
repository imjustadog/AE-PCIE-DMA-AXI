//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: BMD_TO_CTRL.v
//--
//-- Description: Turn-off Control Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module BMD_TO_CTRL    (

                        clk,
                        rst_n,

                        req_compl_i,    
                        compl_done_i,  

                        cfg_to_turnoff_n,
                        cfg_turnoff_ok_n

                        );

    input               clk;
    input               rst_n;
 
    input               req_compl_i;
    input               compl_done_i;

    input               cfg_to_turnoff_n;
    output              cfg_turnoff_ok_n;

    reg                 trn_pending;
    reg                 cfg_turnoff_ok_n;


    /*
     *  Check if completion is pending
     */

    always @ ( posedge clk ) begin

      if (!rst_n ) begin

        trn_pending <= 0;

      end else begin 

        if (!trn_pending && req_compl_i)
            
          trn_pending <= 1'b1;
          
        else if (compl_done_i)

          trn_pending <= 1'b0;

      end

    end
   
    /*
     *  Turn-off OK if requested and no transaction is pending
     */

    always @ ( posedge clk ) begin

      if (!rst_n ) begin

        cfg_turnoff_ok_n <= 1'b1;

      end else begin

        if ( !cfg_to_turnoff_n  && !trn_pending ) 
          cfg_turnoff_ok_n <= 1'b0;
        else 
          cfg_turnoff_ok_n <= 1'b1;

      end

    end
    

endmodule // BMD_TO_CTRL

