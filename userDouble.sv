// Richard Nadolny

// Processes user input / button presses to reduce metastability
// Inputs:
//  - clk: circuit clock
//  - in: false when button is pressed
// Output:
//  - out: stablized user input
module userDouble(clk, in, out);
	input logic clk, in;
	output logic out;
	logic inter;
	
	always_ff @(posedge clk) begin
		inter <= ~in;
	end
	
	always_ff @(posedge clk) begin
		out <= inter;
	end
endmodule

// create module and test each case of switches
module userDouble_testbench();
	logic clk, in, out;
	
	userDouble dut(clk, in, out);
	
	parameter clk_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(clk_PERIOD/2) clk <= ~clk;
	end	

	initial begin
		in <= 0; 	@(posedge clk);
		  repeat(4) @(posedge clk);
		in <= 1; 	@(posedge clk);
		  repeat(4) @(posedge clk);
		in <= 0; 	@(posedge clk);
		  repeat(4) @(posedge clk);
		$stop;
	end
endmodule
