// Richard Nadolny

// Module implementing the user-controlled paddle
// Inputs:
//  - clk: clock for the circuit
//  - reset: reset signal
//  - inLt: user input move left
//  - inRt: user input move right
//  - edgeLt: detects if paddle is at the playfield edge left
//  - edgeRt: detects if paddle is at playfield edge right
//  - nextLt: detects status of left neighbor LED
//  - nextRt: detects status of left neighbor LED
//  - nextNorth: detects status of north neighbor LED
// Outputs:
//  - on: true/lit if paddle occupies thius LED space
//  - loss: true when ball passes paddle, exits the game, and game is lost.
module general_paddle(on, loss, clk, reset, inLt, inRt, edgeLt, edgeRt, nextLt, nextRt, nextNorth);
	input logic clk, reset; 
	input logic inLt, inRt, edgeLt, edgeRt, nextLt, nextRt, nextNorth;
	output logic on, loss;
	logic moveLt, moveRt, ball_enter;
	
	PDR pushLt(clk, inLt, moveLt);
	PDR pushRt(clk, inRt, moveRt);
	PDR detectNorth(clk, nextNorth, ball_enter); 
	
	enum {dark, lit, lose} ps, ns;
	
	always_comb begin
		case (ps)
			dark: if((nextLt & moveRt) | (nextRt & moveLt)) ns <= lit;
				else if (ball_enter) ns <= lose;
				else ns <= dark;
			lit: if((~nextLt & moveRt & ~edgeRt) | (~nextRt & moveLt & ~edgeLt)) ns <= dark;
				else ns <= lit;
			lose: ns <= lose;
		endcase
	end
	
	assign on = (ps == lit);
	assign loss = (ps == lose);
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= dark;
		else 
			ps <= ns;
	end		

endmodule

module general_paddle_testbench();
	logic on, loss, clk, reset, inLt, inRt, edgeLt, edgeRt, nextLt, nextRt, nextNorth;
	
	general_paddle dut(on, loss, clk, reset, inLt, inRt, edgeLt, edgeRt, nextLt, nextRt, nextNorth);
	
	parameter clk_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(clk_PERIOD/2) clk <= ~clk;
	end	
	
	initial begin
																													@(posedge clk);
		reset <= 1;																								@(posedge clk);
																													@(posedge clk);
		reset <= 0;	nextLt <= 0; nextRt <= 0; nextNorth <= 0; edgeLt <= 0; edgeRt <= 0;	@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 0; inRt <= 0;																				@(posedge clk);
																													@(posedge clk);
		nextLt <= 1;																							@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 0;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 0;																								@(posedge clk);
																													@(posedge clk);
		nextLt <= 0;																							@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		reset <= 1; nextLt <= 0; nextRt <= 0; inLt <= 0; inRt <= 0;								@(posedge clk);
																													@(posedge clk);
		reset <=0;																								@(posedge clk);
																													@(posedge clk);
		nextRt <= 1;																							@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 0;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 0;																								@(posedge clk);
																													@(posedge clk);
		nextRt <= 0;																							@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		reset <= 1;	nextLt <= 1; nextRt <= 0; inLt <= 0; inRt <= 0; edgeRt <= 1;			@(posedge clk);
																													@(posedge clk);
		reset <= 0;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inRt <= 0;																								@(posedge clk);
																													@(posedge clk);
		nextLt <= 0;																							@(posedge clk);
																													@(posedge clk);
		inRt <= 1;																								@(posedge clk);
																													@(posedge clk);
		reset <= 1;	nextLt <= 0; nextRt <= 1; inLt <= 0; inRt <= 0; edgeLt <= 1; edgeRt <= 0;		@(posedge clk);
																													@(posedge clk);
		reset <= 0;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 0;																								@(posedge clk);
																													@(posedge clk);
		nextRt <= 0;																							@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		reset <= 1;	nextLt <= 0; nextRt <= 1; inLt <= 0; inRt <= 0; edgeLt <= 0; edgeRt <= 0;		@(posedge clk);
																													@(posedge clk);
		reset <=	0;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		inLt <= 0;																								@(posedge clk);
																													@(posedge clk);
		nextNorth <= 1;																						@(posedge clk);
																													@(posedge clk);
		nextNorth <= 0; nextRt <= 0;																		@(posedge clk);
																													@(posedge clk);
		inLt <= 1;																								@(posedge clk);
																													@(posedge clk);
		nextNorth <= 1;																						@(posedge clk);
																													@(posedge clk);
																													@(posedge clk);
																													@(posedge clk);
		$stop;	
	end
endmodule
