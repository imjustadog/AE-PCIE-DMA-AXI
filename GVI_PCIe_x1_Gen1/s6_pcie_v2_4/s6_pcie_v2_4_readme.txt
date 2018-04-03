                Core name: Xilinx Spartan-6 Integrated
                           Block for PCI Express
                Version: 2.4
                Release: 13.4
                Release Date: January 18, 2012


================================================================================

This document contains the following sections:

1. Introduction
2. New Features
3. Supported Devices
4. Resolved Issues
5. Known Issues
6. Technical Support
7. Core Release History
8. Legal Disclaimer

================================================================================


1. INTRODUCTION

For installation instructions for this release, please go to:

   http://www.xilinx.com/ipcenter/coregen/ip_update_install_instructions.htm

For system requirements:

   http://www.xilinx.com/ipcenter/coregen/ip_update_system_requirements.htm

This file contains release notes for the Xilinx LogiCORE IP Spartan-6
Integrated Block for PCI Express(R) v2.4 solution. For the latest core
updates, see the product page at:

  http://www.xilinx.com/products/ipcenter/S6_PCI_Express_Block.htm


2. NEW FEATURES

  - ISE 13.4 software support

3. SUPPORTED DEVICES

The following device families are supported by the core for this release.

Spartan-6 XC LX/LXT 
Spartan-6 XA LX/LXT
Spartan-6 XQ LX/LXT       


4. RESOLVED ISSUES

   - cfg_err_posted signal modification not updated in User Guide
     o CR 622845

   - Test selections are not updated in user guide
     o CR 624052

   - Figures 6-25 and 6-26 is not correctly representing transactions on the cfg_err interface
     o CR 624245

     Figures have been updated to show correct timing and signaling

   - User Guide incorrectly references ACS in user guide 
     o CR 614643

     ACS is a PCI Express Spec v2.x defined signal and should not be referenced in the user guide. Reference removed.

   - User Guide does not state the parity error enable bit is hardwired to 1'b0
     o CR 624053

   - m_axis_rx_tuser bits are not fully defined in user guide
     o CR 612526

   - cfg_rd_en and cfg_pm_wake incorrectly listed as active low in User Guide
     o CR 618973

5. KNOWN ISSUES

The following are known issues for v2.4 of this core at time of release:

- N/A

The most recent information, including known issues, workarounds, and
resolutions for this version is provided in the IP Release Notes Guide
located at

  www.xilinx.com/support/documentation/user_guides/xtp025.pdf


6. TECHNICAL SUPPORT

To obtain technical support, create a WebCase at www.xilinx.com/support.
Questions are routed to a team with expertise using this product.

Xilinx provides technical support for use of this product when used
according to the guidelines described in the core documentation, and
cannot guarantee timing, functionality, or support of this product for
designs that do not follow specified guidelines.


7. CORE RELEASE HISTORY

Date        By            Version      Description
================================================================================
01/18/2012  Xilinx, Inc.  2.4          ISE 13.4 support
06/22/2011  Xilinx, Inc.  2.3          ISE 13.2 support
12/14/2010  Xilinx, Inc.  2.2          ISE 12.4 support
09/21/2010  Xilinx, Inc.  2.1          ISE 12.3 support
09/21/2010  Xilinx, Inc.  1.4          ISE 12.3 support
07/23/2010  Xilinx, Inc.  1.3 rev 1    ISE 12.2 support
04/19/2010  Xilinx, Inc.  1.3          ISE 12.1 support
03/09/2010  Xilinx, Inc.  1.2 rev 1    ISE 11.5 support
09/16/2009  Xilinx, Inc.  1.2          ISE 11.3 support
06/24/2009  Xilinx, Inc.  1.1          Initial release
================================================================================


8. LEGAL DISCLAIMER

(c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.

This file contains confidential and proprietary information
of Xilinx, Inc. and is protected under U.S. and
international copyright and other intellectual property
laws.

DISCLAIMER
This disclaimer is not a license and does not grant any
rights to the materials distributed herewith. Except as
otherwise provided in a valid license issued to you by
Xilinx, and to the maximum extent permitted by applicable
law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
(2) Xilinx shall not be liable (whether in contract or tort,
including negligence, or under any other theory of
liability) for any loss or damage of any kind or nature
related to, arising under or in connection with these
materials, including for any direct, or any indirect,
special, incidental, or consequential loss or damage
(including loss of data, profits, goodwill, or any type of
loss or damage suffered as a result of any action brought
by a third party) even if such damage or loss was
reasonably foreseeable or Xilinx had been advised of the
possibility of the same.

CRITICAL APPLICATIONS
Xilinx products are not designed or intended to be fail-
safe, or for use in any application requiring fail-safe
performance, such as life-support or safety devices or
systems, Class III medical devices, nuclear facilities,
applications related to the deployment of airbags, or any
other applications that could lead to death, personal
injury, or severe property or environmental damage
(individually and collectively, "Critical
Applications"). Customer assumes the sole risk and
liability of any use of Xilinx products in Critical
Applications, subject only to applicable laws and
regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
PART OF THIS FILE AT ALL TIMES.
