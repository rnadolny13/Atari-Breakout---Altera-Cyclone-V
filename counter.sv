// Richard Nadolny

// Counter module to act as secondary, slow clock
// Inputs:
//  - clk: clock for the circuit
// Outputs:
//  - out: true every 16th clock cycle.
module counter(out, clk);
	input logic clk;
	output logic out;
	
	enum{zero, one, two, three, four, five, six, seven, eight, nine, ten, ele, twe, thirt, fourt, fift} ps=zero, ns;
	
	always_comb begin
		case(ps)
			zero: ns <= one;
			one: ns <= two;
			two: ns <= three;
			three: ns <= four;
			four: ns <= five;
			five: ns <= six;
			six: ns <= seven;
			seven: ns <= eight;
			eight: ns <= nine;
			nine: ns <= ten;
			ten: ns <= ele;
			ele: ns <= twe;
			twe: ns <= thirt;
			thirt: ns <= fourt;
			fourt: ns <= fift;
			fift: ns <= zero;
		endcase
	end
	
	always_ff @(posedge clk) begin
		ps <= ns;
	end
	
	assign out = (ps == fift);	

endmodule


module counter_testbench();

	logic clk, out;
	
	counter dut(out, clk);
	
		parameter clk_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(clk_PERIOD/2) clk <= ~clk;
	end	

	initial begin
		repeat(33)@(posedge clk);
		$stop;
	end
endmodule
