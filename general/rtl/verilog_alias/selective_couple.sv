
`timescale 1ns / 1ps

// Module Name: selective_couple


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
module selective_couple
#(
	parameter 								MAX_WIDTH 		= 24,
	parameter 								SMALLEST_MSB 	= 24,
	parameter 								LARGEST_LSB 	= 24,
	parameter [MAX_WIDTH-1:0] VALID_BITS 		= '1
)
(
  inout [MAX_WIDTH-1:0] 						larger_source,
  inout [SMALLEST_MSB:LARGEST_LSB] 	smaller_source
);


  genvar ii;
	generate
	  for(ii=LARGEST_LSB; ii<=SMALLEST_MSB; ii=ii+1) begin
	    if (VALID_BITS[ii] == 1)
	      aliasv couple(smaller_source[ii], larger_source[ii]);
	  end
	endgenerate


endmodule
// --------------------------------------------------------------


// --------------------------------------------------------------
module my_wrap(
  input   condition,
  inout   [23:0] iopad_fs_in,
  output  [23:0] iopad_ns_out
);


assign iopad_ns_out = iopad_fs_in & {24{condition}};

endmodule
// --------------------------------------------------------------


// --------------------------------------------------------------
module selective_couple_DUT
(
  input   condition,
  input   [8:8]	iopad_fs_rx_in,
  output  [8:8]	iopad_ns_tx_out
);

wire [23:0] all_iopad_fs_rx_in;
wire [23:0] all_iopad_ns_tx_out;


selective_couple  
#(
	.MAX_WIDTH(24),
	.SMALLEST_MSB(8),
	.LARGEST_LSB(8),
	.VALID_BITS(24'h00_0100)
)
	fs_couple 
	( 
		.larger_source(all_iopad_fs_rx_in), 
		.smaller_source(iopad_fs_rx_in)
	);

selective_couple  
#(
	.MAX_WIDTH(24),
	.SMALLEST_MSB(8),
	.LARGEST_LSB(8),
	.VALID_BITS(24'h00_0100)
)
	ns_couple 
	( 
		.larger_source(all_iopad_ns_tx_out), 
		.smaller_source(iopad_ns_tx_out)
	);
	

my_wrap  the_wrap ( .condition(condition), .iopad_fs_in(all_iopad_fs_rx_in), .iopad_ns_out(all_iopad_ns_tx_out) );


endmodule
// --------------------------------------------------------------


// --------------------------------------------------------------

module selective_couple_tester_tb ();

logic condition;
// logic iopad_fs_in;
wire [8:8] iopad_fs_in;			// I *think* leaving off the [8:8] made a difference (?)
wire [8:8] iopad_ns_out;

logic iopad_fs_in_driver;

assign iopad_fs_in = iopad_fs_in_driver;


selective_couple_DUT DUT (
  .condition(condition),
  .iopad_fs_rx_in(iopad_fs_in),
  .iopad_ns_tx_out(iopad_ns_out)
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
