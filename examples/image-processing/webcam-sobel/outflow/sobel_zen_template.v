
// Efinity Top-level template
// Version: 2026.1.132
// Date: 2026-11-02 16:19

// Copyright (C) 2013 - 2026 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as sobel_zen.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  sobel_zen
//     #4)  Insert design content.


module sobel_zen
(
  (* syn_peri_port = 0 *) input clk_pad,
  (* syn_peri_port = 0 *) input btn1,
  (* syn_peri_port = 0 *) input uart_rx,
  (* syn_peri_port = 0 *) input clk,
  (* syn_peri_port = 0 *) output uart_tx,
  (* syn_peri_port = 0 *) output led1,
  (* syn_peri_port = 0 *) output led2
);


endmodule

