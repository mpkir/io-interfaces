
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2024 09:06:34 PM
// Design Name: 
// Module Name: aliasv_tester
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



//module aliasv ( .PLUS(w), .MINUS(w) );
//
//  inout   w;
//  wire    w;
//
//endmodule
//
//
//module aliasv_opt3 ( w, w );
//
//  inout   w;
//  wire    w;
//
//endmodule


module aliasv ( w, w );

  inout   w;
  wire    w;

endmodule


// --------------------------------------------------------------
module my_ibuff(
  input iopad_fs_in,
  output fs_in
);

  IBUF IBUF_inst (
    .O(fs_in),      // 1-bit output: Buffer output
    .I(iopad_fs_in) // 1-bit input: Buffer input
  );

endmodule
// --------------------------------------------------------------


// --------------------------------------------------------------
module my_wrap(
  input   condition,
  inout   [2:0] iopad_fs_in,
  output  [2:0] iopad_ns_out
);

wire          some_sig;
wire  [2:0]   some_iopads;

// aliasv the_alias(.MINUS(iopad_fs_in[1]), .PLUS(some_iopads[1]));
aliasv an_alias  (iopad_fs_in[1], some_iopads[1]);

my_ibuff the_ibuff( .iopad_fs_in(iopad_fs_in[1]), .fs_in(some_sig) );

assign iopad_ns_out[1] = some_sig & condition;

endmodule
// --------------------------------------------------------------



// --------------------------------------------------------------
module aliasv_tester(
  input   condition,
  input   iopad_fs_in, // Unsupported named port connection association : .MINUS(iopad_fs_in) where formal is alias port
//  inout   iopad_fs_in,
  output  iopad_ns_out
);

wire [2:0] all_iopad_fs_in;
wire [2:0] all_iopad_ns_out;

assign iopad_ns_out = all_iopad_ns_out[1];

genvar i;
generate
  for(i=0; i<=2; i=i+1) begin
    if (i == 1)
      aliasv an_alias(iopad_fs_in, all_iopad_fs_in[i]);
  end
endgenerate

my_wrap wrap_1 (
  .condition(condition),
  .iopad_fs_in(all_iopad_fs_in),
  .iopad_ns_out(all_iopad_ns_out)
);

endmodule
// --------------------------------------------------------------


// --------------------------------------------------------------

module aliasv_tester_tb ();

logic condition;
// logic iopad_fs_in;
wire iopad_fs_in;
wire iopad_ns_out;

logic iopad_fs_in_driver;

assign iopad_fs_in = iopad_fs_in_driver;

aliasv_tester DUT (
  .condition(condition),
  .iopad_fs_in(iopad_fs_in),
  .iopad_ns_out(iopad_ns_out)
);

initial begin

  condition   = 0;
  iopad_fs_in_driver = 0;

  #10
  condition   = 0;
  iopad_fs_in_driver = 1;

  #10
  condition   = 1;
  iopad_fs_in_driver = 1;

  #10
  condition   = 1;
  iopad_fs_in_driver = 0;

end

endmodule
// --------------------------------------------------------------
