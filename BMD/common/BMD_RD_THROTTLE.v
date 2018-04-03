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
//-- Filename: BMD_RD_THROTTLE.v
//--
//-- Description: Read Metering Unit.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define BMD_RD_THROTTLE_CPL_LIMIT 8

module BMD_RD_THROTTLE (
                         clk,
                         rst_n,

                         init_rst_i,
                         
                         mrd_start_i,
                         mrd_len_i,
                         mrd_cur_rd_count_i,

                         cpld_found_i,               
                         cpld_data_size_i,           
                         cpld_malformed_i,
                         cpld_data_err_i,

                         cfg_rd_comp_bound_i,

                         cpld_data_size_hwm,
                         cur_rd_count_hwm,
                         rd_metering_i,

                         mrd_start_o    

                       );

input                    clk;
input                    rst_n;

input                    init_rst_i;

input                    mrd_start_i;            // Start MRd Tx Command
input [31:0]             mrd_len_i;              // Memory Read Size Command (DWs)
input [15:0]             mrd_cur_rd_count_i;     // Current state of Tx Engine 

input [31:0]             cpld_found_i;           // Current CompletionDs found
input [31:0]             cpld_data_size_i;       // Current Completion data found
input                    cpld_malformed_i;       // Malformed Compltion found
input                    cpld_data_err_i;        // Compltion data error found

input                    cfg_rd_comp_bound_i;    // Programmed RCB = 0=64B or 1=128B

output [31:0]            cpld_data_size_hwm;     // HWMark for Completion Data (DWs)
output [15:0]            cur_rd_count_hwm;       // HWMark for Read Count Allowed

input                    rd_metering_i;

output                   mrd_start_o;            // Tx MRds

parameter                Tcq = 1;

wire                     mrd_start_o;
reg   [31:0]             cpld_data_size_hwm;     // HWMark for Completion Data (DWs)
reg   [15:0]             cur_rd_count_hwm;       // HWMark for Read Count Allowed

reg                      cpld_found;                 

/* Checking for received completions */

always @ ( posedge clk ) begin

  if (!rst_n ) begin

    cpld_found <= #(Tcq) 1'b0;

  end else begin

    if (init_rst_i)
      cpld_found <= #(Tcq) 1'b0;
    else if ((mrd_cur_rd_count_i == (cur_rd_count_hwm + 1'b1)) &&
             (cpld_data_size_i >= cpld_data_size_hwm))
      cpld_found <= #(Tcq) 1'b1;
    else
      cpld_found <= #(Tcq) 1'b0;

  end

end

/* Here cur_rd_count_hwm is driven so that the mrd_start_o can be modulated */

always @ ( posedge clk ) begin
                       
  if (!rst_n ) begin

    cpld_data_size_hwm <= #(Tcq) 32'hFFFF_FFFF;
    cur_rd_count_hwm <= #(Tcq) 15'h0;

  end else begin    

    if (init_rst_i) begin

      cpld_data_size_hwm <= #(Tcq) 32'hFFFF_FFFF;
      cur_rd_count_hwm <= #(Tcq) 15'h0;

    end else begin

      if (mrd_start_i) begin
   
        if (cur_rd_count_hwm == 15'h0) begin   // Initial burst

          if (!cfg_rd_comp_bound_i) begin                   // 64B RCB

            if ((mrd_len_i[10:0] == 1)) begin

              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0]; 

            end else if ((mrd_len_i[10:0] > 1) &&           // > 4B
                         (mrd_len_i[10:0] <= 16))  begin    // <= 64B

              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/2;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0]; 
  
            end else if ((mrd_len_i[10:0] > 16) &&          // > 64B
                         (mrd_len_i[10:0] <= 32))  begin    // <= 128B
  
              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/4;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0];
  
            end else if ((mrd_len_i[10:0] > 32) &&          // > 128B
                         (mrd_len_i[10:0] <= 64))  begin    // <= 256B
  
              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/4;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0]; 
  
            end else if ((mrd_len_i[10:0] > 64) &&          // > 256B
                         (mrd_len_i[10:0] <= 128))  begin   // <= 512B
  
              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/8;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0];
  
            end else begin

              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/8;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0];

            end

          end else begin                                  // 128B RCB
     
            if ((mrd_len_i[10:0] == 1)) begin

              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0]; 

            end else if ((mrd_len_i[10:0] > 1) &&           // > 4B
                         (mrd_len_i[10:0] <= 32))  begin    // <= 128B

              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/2;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0]; 
  
            end else if ((mrd_len_i[10:0] > 32) &&        // > 128B
                         (mrd_len_i[10:0] <= 64))  begin  // <= 256B
  
              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/4;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0];
  
            end else if ((mrd_len_i[10:0] > 64) &&        // > 256B
                         (mrd_len_i[10:0] <= 128))  begin // <= 512B
  
              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/4;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0];
  
            end else begin

              cur_rd_count_hwm <= #(Tcq) `BMD_RD_THROTTLE_CPL_LIMIT/8;
              cpld_data_size_hwm <= #(Tcq) mrd_len_i[10:0];

            end
  
          end
  
        end else begin  // (cur_rd_count_hwm > 15'h0) i.e. after the initial burst, now one at a time
  
          if (cpld_malformed_i || cpld_data_err_i) begin
     
            cpld_data_size_hwm <= #(Tcq) 32'hFFFF_FFFF;
            cur_rd_count_hwm <= #(Tcq) 15'h0;

          end else if (cpld_found == 1'b1) begin

            cur_rd_count_hwm <= #(Tcq) cur_rd_count_hwm + 1'b1;
            cpld_data_size_hwm <= #(Tcq) cpld_data_size_hwm + mrd_len_i[10:0];
  
          end
          
        end

      end

    end

  end

end

`ifdef READ_THROTTLE
assign mrd_start_o = (rd_metering_i == 0) ? mrd_start_i 
                                      : (mrd_start_i & (cur_rd_count_hwm  >= mrd_cur_rd_count_i));
`else
assign mrd_start_o = mrd_start_i;
`endif

endmodule // BMD_RD_THROTTLE

