// Richard Nadolny

// general playfield module, detects and determines ball direction, collisions. 
// Inputs: 
//  - clk: circuit clock to time the module
//  - reset: reset signal
//  - detX: compass direction, detecting if the neighboring LED is activated
//  - ballDirIn_X: compass direction, detecting the input ball direction of each neighboring LED
//  - brickDetX: compass direction, detecting the brick status of each neighboring LED
// Outputs:
//  - ball_on: true if ball is passing through this LED / module
//  - ballDirOut: direction the ball is traveling exiting this LED / module
module GPF4(ball_on, ballDirOut, clk, reset, detN, detNE, detE, detSE, detS, detSW,
			detW, detNW, ballDirIn_N, ballDirIn_NE, ballDirIn_E, ballDirIn_SE,
			ballDirIn_S, ballDirIn_SW, ballDirIn_W, ballDirIn_NW, brickDetN, brickDetNE, brickDetE, 
			brickDetSE, brickDetS, brickDetSW, brickDetW, brickDetNW);
			
		input logic clk, reset;
		input logic detN, detNE, detE, detSE, detS, detSW, detW, detNW;
		input logic brickDetN, brickDetNE, brickDetE, 
			brickDetSE, brickDetS, brickDetSW, brickDetW, brickDetNW;
		input logic[2:0] ballDirIn_N, ballDirIn_NE, ballDirIn_E, ballDirIn_SE,
			ballDirIn_S, ballDirIn_SW, ballDirIn_W, ballDirIn_NW;
		output logic[2:0] ballDirOut;
		output logic ball_on;
		logic enterN, enterNE, enterE, enterSE, enterS, enterSW, enterW, enterNW;
		logic north, northeast, east, southeast, south, southwest, west, northwest;
		logic DCN, DCNE, DCE, DCSE, DCS, DCSW, DCW, DCNW;
		
		// pulse detection for when ball enters from a compass direction.
		PDR ball_north(clk, detN, enterN);
		PDR ball_northeast(clk, detNE, enterNE);
		PDR ball_east(clk, detE, enterE);
		PDR ball_southeast(clk, detSE, enterSE);
		PDR ball_south(clk, detS, enterS);
		PDR ball_southwest(clk, detSW, enterSW);
		PDR ball_west(clk, detW, enterW);
		PDR ball_northwest(clk, detNW, enterNW);
		
		// detect direction change 
		Dir_PDR DPN(reset, clk, ballDirIn_N, DCN);
		Dir_PDR DPNE(reset, clk, ballDirIn_NE, DCNE);
		Dir_PDR DPE(reset, clk, ballDirIn_E, DCE);
		Dir_PDR DPSE(reset, clk, ballDirIn_SE, DCSE);
		Dir_PDR DPS(reset, clk, ballDirIn_S, DCS);
		Dir_PDR DPSW(reset, clk, ballDirIn_SW, DCSW);
		Dir_PDR DPW(reset, clk, ballDirIn_W, DCW);
		Dir_PDR DPNW(reset, clk, ballDirIn_NW, DCNW);
		
		// detect when ball enters from compass direction and is traveling towards this LED / module
		assign north = enterN & (ballDirIn_N == 3'b000);
		assign northeast = enterNE & (ballDirIn_NE == 3'b001);
		assign east = enterE & (ballDirIn_E == 3'b010);
		assign southeast = enterSE & (ballDirIn_SE == 3'b011);
		assign south = enterS & (ballDirIn_S == 3'b100);
		assign southwest = enterSW & (ballDirIn_SW == 3'b101);
		assign west = enterW & (ballDirIn_W == 3'b110);
		assign northwest = enterNW & (ballDirIn_NW == 3'b111);
		
		// dffs
		enum {dark, lit} ps=dark, ns;
		enum {S, SW, W, NW, N, NE, E, SE} bdps, bdns;
		
	always_comb begin
		 ns <= ps;
		 bdns <= bdps;
		 
		 case (ps)
			  dark: begin
					// NORTH entry (ball traveling south)
					if(north) begin
						 ns <= lit;
						 if(brickDetS & brickDetSE & brickDetSW)      bdns <= N;   // flat wall
						 else if(brickDetS & brickDetSE)              bdns <= NW;  // two brick edge
						 else if(brickDetS & brickDetSW)              bdns <= NE;  // two brick edge
						 else if(brickDetS)                           bdns <= N;   // single brick
						 else                                         bdns <= S;   // pass through
					end
					
					// SOUTH entry (ball traveling north)
					else if(south) begin
						 ns <= lit;
						 if(brickDetN & brickDetNE & brickDetNW)      bdns <= S;   // flat wall
						 else if(brickDetN & brickDetNE)              bdns <= SW;  // two brick edge
						 else if(brickDetN & brickDetNW)              bdns <= SE;  // two brick edge
						 else if(brickDetN)                           bdns <= S;   // single brick
						 else                                         bdns <= N;   // pass through
					end
					
					// EAST entry (ball traveling west)
					else if(east) begin
						 ns <= lit;
						 if(brickDetW & brickDetNW & brickDetSW)      bdns <= E;   // flat wall
						 else if(brickDetW & brickDetNW)              bdns <= SE;  // two brick edge
						 else if(brickDetW & brickDetSW)              bdns <= NE;  // two brick edge
						 else if(brickDetW)                           bdns <= E;   // single brick
						 else                                         bdns <= W;   // pass through
					end
					
					// WEST entry (ball traveling east)
					else if(west) begin
						 ns <= lit;
						 if(brickDetE & brickDetNE & brickDetSE)      bdns <= W;   // flat wall
						 else if(brickDetE & brickDetNE)              bdns <= SW;  // two brick edge
						 else if(brickDetE & brickDetSE)              bdns <= NW;  // two brick edge
						 else if(brickDetE)                           bdns <= W;   // single brick
						 else                                         bdns <= E;   // pass through
					end
					
					// NORTHEAST entry (ball traveling southwest)
					else if(northeast) begin
						 ns <= lit;
						 if(brickDetS & brickDetW)                    bdns <= NE;  // both axes, straight back
						 else if(brickDetS)                           bdns <= NW;  // S axis flip
						 else if(brickDetW)                           bdns <= SE;  // W axis flip
						 else                                         bdns <= SW;  // pass through
					end
					
					// SOUTHWEST entry (ball traveling northeast)
					else if(southwest) begin
						 ns <= lit;
						 if(brickDetN & brickDetE)                    bdns <= SW;  // both axes, straight back
						 else if(brickDetN)                           bdns <= SE;  // N axis flip
						 else if(brickDetE)                           bdns <= NW;  // E axis flip
						 else                                         bdns <= NE;  // pass through
					end
					
					// NORTHWEST entry (ball traveling southeast)
					else if(northwest) begin
						 ns <= lit;
						 if(brickDetS & brickDetE)                    bdns <= NW;  // both axes, straight back
						 else if(brickDetS)                           bdns <= NE;  // S axis flip
						 else if(brickDetE)                           bdns <= SW;  // E axis flip
						 else                                         bdns <= SE;  // pass through
					end
					
					// SOUTHEAST entry (ball traveling northwest)
					else if(southeast) begin
						 ns <= lit;
						 if(brickDetN & brickDetW)                    bdns <= SE;  // both axes, straight back
						 else if(brickDetN)                           bdns <= SW;  // N axis flip
						 else if(brickDetW)                           bdns <= NE;  // W axis flip
						 else                                         bdns <= NW;  // pass through
					end
					
					else ns <= dark;
			  end
			  
			  lit: ns <= dark;
			  
		 endcase
	end    

// direction change combinational... irrelevant?
    
//            // DC path (direction change, one cycle delayed)
//            else if(DCN & (ballDirIn_N == 3'b000)) begin
//                ns <= lit;
//                if(brickDetS)  bdns <= N;
//                else           bdns <= S;
//            end
//            
//            else if(DCNE & (ballDirIn_NE == 3'b001)) begin
//                ns <= lit;
//                if(brickDetS | brickDetW)  bdns <= NE;
//                else                       bdns <= SW;
//            end
//            
//            else if(DCE & (ballDirIn_E == 3'b010)) begin
//                ns <= lit;
//                if(brickDetW)  bdns <= E;
//                else           bdns <= W;
//            end
//            
//            else if(DCSE & (ballDirIn_SE == 3'b011)) begin
//                ns <= lit;
//                if(brickDetN | brickDetW)  bdns <= SE;
//                else                       bdns <= NW;
//            end
//            
//            else if(DCS & (ballDirIn_S == 3'b100)) begin
//                ns <= lit;
//                if(brickDetN)  bdns <= S;
//                else           bdns <= N;
//            end
//            
//            else if(DCSW & (ballDirIn_SW == 3'b101)) begin
//                ns <= lit;
//                if(brickDetN | brickDetE)  bdns <= SW;
//                else                       bdns <= NE;
//            end
//            
//            else if(DCW & (ballDirIn_W == 3'b110)) begin
//                ns <= lit;
//                if(brickDetE)  bdns <= W;
//                else           bdns <= E;
//            end
//            
//            else if(DCNW & (ballDirIn_NW == 3'b111)) begin
//                ns <= lit;
//                if(brickDetS | brickDetE)  bdns <= NW;
//                else                       bdns <= SE;
//            end
//            
//            else ns <= dark;
//        end
//        
//        lit: ns <= dark;
//        
//    endcase
//end
		
// evaluate dff
		always_ff @(posedge clk) begin
			if (reset) begin
				ps <= dark;
				bdps <= S;
			end 
			
			else begin
				ps <= ns;
				bdps <= bdns;
			end
		end

		//assign outputs
		assign ball_on = (ps == lit);
//		assign ballDirOut = bdps;
		
		always_comb begin
			if (bdps == N) ballDirOut <= 3'b100;
			else if (bdps == NE) ballDirOut <= 3'b101;
			else if (bdps == E) ballDirOut <= 3'b110;
			else if (bdps == SE) ballDirOut <= 3'b111;
			else if (bdps == S) ballDirOut <= 3'b000;
			else if (bdps == SW) ballDirOut <= 3'b001;
			else if (bdps == W) ballDirOut <= 3'b010;
			else ballDirOut <= 3'b011;
		end
		
endmodule

module GPF4_testbench();
				
    logic clk, reset;
    logic detN, detNE, detE, detSE, detS, detSW, detW, detNW;
    logic brickDetN, brickDetNE, brickDetE, 
        brickDetSE, brickDetS, brickDetSW, brickDetW, brickDetNW;
    logic[2:0] ballDirIn_N, ballDirIn_NE, ballDirIn_E, ballDirIn_SE,
        ballDirIn_S, ballDirIn_SW, ballDirIn_W, ballDirIn_NW;
    logic[2:0] ballDirOut;
    logic ball_on;		
    
    GPF4 dut(ball_on, ballDirOut, clk, reset, detN, detNE, detE, detSE, detS, detSW,
        detW, detNW, ballDirIn_N, ballDirIn_NE, ballDirIn_E, ballDirIn_SE,
        ballDirIn_S, ballDirIn_SW, ballDirIn_W, ballDirIn_NW, brickDetN, brickDetNE, brickDetE, 
        brickDetSE, brickDetS, brickDetSW, brickDetW, brickDetNW);

    parameter clk_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(clk_PERIOD/2) clk <= ~clk;
    end

    // task to reset all signals to known state
    task reset_all;
        begin
            reset <= 1;
            detN <= 0; detNE <= 0; detE <= 0; detSE <= 0;
            detS <= 0; detSW <= 0; detW <= 0; detNW <= 0;
            brickDetN <= 0; brickDetNE <= 0; brickDetE <= 0; brickDetSE <= 0;
            brickDetS <= 0; brickDetSW <= 0; brickDetW <= 0; brickDetNW <= 0;
            ballDirIn_N <= 3'b000; ballDirIn_NE <= 3'b001; 
            ballDirIn_E <= 3'b010; ballDirIn_SE <= 3'b011;
            ballDirIn_S <= 3'b100; ballDirIn_SW <= 3'b101;
            ballDirIn_W <= 3'b110; ballDirIn_NW <= 3'b111;
            @(posedge clk);
            @(posedge clk);
            reset <= 0;
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    // task to send ball from a direction with a given direction value
    // and set brick conditions, then observe output
    task send_ball;
        input logic det_n, det_ne, det_e, det_se, det_s, det_sw, det_w, det_nw;
        input logic[2:0] dir_n, dir_ne, dir_e, dir_se, dir_s, dir_sw, dir_w, dir_nw;
        input logic b_n, b_ne, b_e, b_se, b_s, b_sw, b_w, b_nw;
        begin
            brickDetN <= b_n; brickDetNE <= b_ne; brickDetE <= b_e; brickDetSE <= b_se;
            brickDetS <= b_s; brickDetSW <= b_sw; brickDetW <= b_w; brickDetNW <= b_nw;
            ballDirIn_N <= dir_n; ballDirIn_NE <= dir_ne; ballDirIn_E <= dir_e; 
            ballDirIn_SE <= dir_se; ballDirIn_S <= dir_s; ballDirIn_SW <= dir_sw;
            ballDirIn_W <= dir_w; ballDirIn_NW <= dir_nw;
            detN <= det_n; detNE <= det_ne; detE <= det_e; detSE <= det_se;
            detS <= det_s; detSW <= det_sw; detW <= det_w; detNW <= det_nw;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    initial begin
        reset_all();

        // =====================================================
        // CARDINAL PASS-THROUGH TESTS (no bricks)
        // =====================================================

        // TEST 1: north entry, no bricks, expect ball_on=1 ballDirOut=S(000)
        send_ball(1,0,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // TEST 2: south entry, no bricks, expect ball_on=1 ballDirOut=N(100)
        send_ball(0,0,0,0,1,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // TEST 3: east entry, no bricks, expect ball_on=1 ballDirOut=W(010)
        send_ball(0,0,1,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // TEST 4: west entry, no bricks, expect ball_on=1 ballDirOut=E(110)
        send_ball(0,0,0,0,0,0,1,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // =====================================================
        // DIAGONAL PASS-THROUGH TESTS (no bricks)
        // =====================================================

        // TEST 5: northeast entry, no bricks, expect ball_on=1 ballDirOut=SW(001)
        send_ball(0,1,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // TEST 6: southwest entry, no bricks, expect ball_on=1 ballDirOut=NE(101)
        send_ball(0,0,0,0,0,1,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // TEST 7: northwest entry, no bricks, expect ball_on=1 ballDirOut=SE(111)
        send_ball(0,0,0,0,0,0,0,1,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // TEST 8: southeast entry, no bricks, expect ball_on=1 ballDirOut=NW(011)
        send_ball(0,0,0,1,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,0,0);
        reset_all();

        // =====================================================
        // CARDINAL SINGLE BRICK BOUNCE TESTS
        // =====================================================

        // TEST 9: north entry, single brick south, expect ballDirOut=N(100)
        send_ball(1,0,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,1,0,0,0);
        reset_all();

        // TEST 10: south entry, single brick north, expect ballDirOut=S(000)
        send_ball(0,0,0,0,1,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,0,0,0,0,0,0,0);
        reset_all();

        // TEST 11: east entry, single brick west, expect ballDirOut=E(110)
        send_ball(0,0,1,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,1,0);
        reset_all();

        // TEST 12: west entry, single brick east, expect ballDirOut=W(010)
        send_ball(0,0,0,0,0,0,1,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,1,0,0,0,0,0);
        reset_all();

        // =====================================================
        // CARDINAL TWO-BRICK EDGE DEFLECTION TESTS
        // =====================================================

        // TEST 13: north entry, brickS+brickSE, expect ballDirOut=NW(011)
        send_ball(1,0,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,1,1,0,0,0);
        reset_all();

        // TEST 14: north entry, brickS+brickSW, expect ballDirOut=NE(101)
        send_ball(1,0,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,1,1,0,0);
        reset_all();

        // TEST 15: south entry, brickN+brickNE, expect ballDirOut=SW(001)
        send_ball(0,0,0,0,1,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,1,0,0,0,0,0,0);
        reset_all();

        // TEST 16: south entry, brickN+brickNW, expect ballDirOut=SE(111)
        send_ball(0,0,0,0,1,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,0,0,0,0,0,0,1);
        reset_all();

        // TEST 17: east entry, brickW+brickNW, expect ballDirOut=SE(111)
        send_ball(0,0,1,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,1,1);
        reset_all();

        // TEST 18: east entry, brickW+brickSW, expect ballDirOut=NE(101)
        send_ball(0,0,1,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,1,1,0);
        reset_all();

        // TEST 19: west entry, brickE+brickNE, expect ballDirOut=SW(001)
        send_ball(0,0,0,0,0,0,1,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,1,1,0,0,0,0,0);
        reset_all();

        // TEST 20: west entry, brickE+brickSE, expect ballDirOut=NW(011)
        send_ball(0,0,0,0,0,0,1,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,1,1,0,0,0,0);
        reset_all();

        // =====================================================
        // CARDINAL FLAT WALL TESTS (3 bricks, bounce straight back)
        // =====================================================

        // TEST 21: north entry, brickS+brickSE+brickSW, expect ballDirOut=N(100)
        send_ball(1,0,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,1,1,1,0,0);
        reset_all();

        // TEST 22: south entry, brickN+brickNE+brickNW, expect ballDirOut=S(000)
        send_ball(0,0,0,0,1,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,1,0,0,0,0,0,1);
        reset_all();

        // TEST 23: east entry, brickW+brickNW+brickSW, expect ballDirOut=E(110)
        send_ball(0,0,1,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,1,1,1);
        reset_all();

        // TEST 24: west entry, brickE+brickNE+brickSE, expect ballDirOut=W(010)
        send_ball(0,0,0,0,0,0,1,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,1,1,1,0,0,0,0);
        reset_all();

        // =====================================================
        // DIAGONAL SINGLE BRICK V-PATTERN TESTS
        // =====================================================

        // TEST 25: northeast entry, brickN only, expect ballDirOut=SE(111)
        // V pattern: N axis flip, keep E component → SE
        send_ball(0,1,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,0,0,0,0,0,0,0);
        reset_all();

        // TEST 26: northeast entry, brickE only, expect ballDirOut=NW(011)
        // V pattern: E axis flip, keep N component → NW
        send_ball(0,1,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,1,0,0,0,0,0);
        reset_all();

        // TEST 27: northeast entry, brickN+brickE, expect ballDirOut=SW(001)
        // both axes blocked, straight back
        send_ball(0,1,0,0,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,0,1,0,0,0,0,0);
        reset_all();

        // TEST 28: northwest entry, brickN only, expect ballDirOut=SW(001)
        // V pattern: N axis flip, keep W component → SW
        send_ball(0,0,0,0,0,0,0,1,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,0,0,0,0,0,0,0);
        reset_all();

        // TEST 29: northwest entry, brickW only, expect ballDirOut=NE(101)
        // V pattern: W axis flip, keep N component → NE
        send_ball(0,0,0,0,0,0,0,1,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,1,0);
        reset_all();

        // TEST 30: northwest entry, brickN+brickW, expect ballDirOut=SE(111)
        // both axes blocked, straight back
        send_ball(0,0,0,0,0,0,0,1,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  1,0,0,0,0,0,1,0);
        reset_all();

        // TEST 31: southeast entry, brickS only, expect ballDirOut=NE(101)
        // V pattern: S axis flip, keep E component → NE
        send_ball(0,0,0,1,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,1,0,0,0);
        reset_all();

        // TEST 32: southeast entry, brickE only, expect ballDirOut=SW(001)
        // V pattern: E axis flip, keep S component → SW
        send_ball(0,0,0,1,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,1,0,0,0,0,0);
        reset_all();

        // TEST 33: southeast entry, brickS+brickE, expect ballDirOut=NW(011)
        // both axes blocked, straight back
        send_ball(0,0,0,1,0,0,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,1,0,1,0,0,0);
        reset_all();

        // TEST 34: southwest entry, brickS only, expect ballDirOut=NW(011)
        // V pattern: S axis flip, keep W component → NW
        send_ball(0,0,0,0,0,1,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,1,0,0,0);
        reset_all();

        // TEST 35: southwest entry, brickW only, expect ballDirOut=SE(111)
        // V pattern: W axis flip, keep S component → SE
        send_ball(0,0,0,0,0,1,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,0,0,1,0);
        reset_all();

        // TEST 36: southwest entry, brickS+brickW, expect ballDirOut=NE(101)
        // both axes blocked, straight back
        send_ball(0,0,0,0,0,1,0,0,  3'b000,3'b001,3'b010,3'b011,3'b100,3'b101,3'b110,3'b111,  0,0,0,0,1,0,1,0);
        reset_all();

        $stop;
    end
endmodule
