// Richard Nadolny 

//pulse detection register. Fires on rising and falling edges
// Inputs:
//  - clk: clock for the circuit
//  - in: input signal
// Outputs:
//  - out: true on signal edges
module PDR(clk, in, out);
	input logic clk, in;
	output logic out;
	logic delay;
	
	always_ff @(posedge clk) begin
		delay <= in;
	end
	
	xor(out, in, delay);

endmodule

module PDR_testbench();
	logic clk, in, out;
	
	PDR dut(clk, in, out);
	
	parameter clk_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(clk_PERIOD/2) clk <= ~clk;
	end	
	
	initial begin
	
		in <= 0;				@(posedge clk);
				  repeat(3) @(posedge clk);
		in <= 1; 		   @(posedge clk);
								@(posedge clk);
		in <= 0; 			@(posedge clk);
								@(posedge clk);
		in <= 1; 			@(posedge clk);
				  repeat(3) @(posedge clk);
		in <= 0;				@(posedge clk);
								@(posedge clk);
		$stop;				
	end 
endmodule
