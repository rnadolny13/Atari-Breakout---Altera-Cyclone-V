// Richard Nadolny

// Top-level module that defines the I/Os for the DE-1 SoC board	
	
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, GPIO_1, SW); 	
	input  logic         CLOCK_50; // 50MHz clock.	
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	output logic  [9:0]  LEDR; 		
	input  logic  [3:0]  KEY; // True when not pressed, False when pressed	
	input  logic  [9:0]  SW; 	
	output logic [35:0] GPIO_1;
	
	 /* Standard LED Driver instantiation - set once and 'forget it'. 
		 See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	 LEDDriver Driver(.CLK(clkSelect), .RST(RST), .EnableCount(1'b1), .RedPixels(RedPixels), .GrnPixels(GrnPixels), .GPIO_1(GPIO_1));
	 
	 
	 /* LED board test submodule - paints the board with a static pattern.
	    Replace with your own code driving RedPixels and GrnPixels.
		 
	 	 KEY0      : Reset
		 =================================================================== */
//	 LED_test test(.RST(~KEY[3]), .RedPixels(RedPixels), .GrnPixels(GrnPixels));
	
	logic[31:0] div_clk;
	parameter whichClock = 14;	// clock[15]
	clock_divider cdiv (.clock(CLOCK_50),	
                       .reset(reset),	
                       .divided_clocks(div_clk));		
	
	// Clock selection; allows for easy switching between sim and board clocks
	logic clkSelect;

	// Detect when we're in Quartus and use the divided clock,
	// otherwise assume we're in ModelSim and use the fast clock
	`ifdef ALTERA_RESERVED_QIS
	    assign clkSelect = div_clk[whichClock]; // for board
	`else
	    assign clkSelect = CLOCK_50; // for simulation
	`endif	
	
	userDouble left(.clk(clkSelect), .in(KEY[1]), .out(inLt));
	userDouble right(.clk(clkSelect), .in(KEY[0]), .out(inRt));
	
	logic reset, inLt, inRt; // wires
	assign reset = SW[9]; // reset assignment
	assign LEDR[0] = reset;
	
//	logic [31:0] clk;
//	logic SYSTEM_CLOCK;
//	 
//	clock_divider divider(.clock(CLOCK_50), .divided_clocks(clk));
//	 
//	assign SYSTEM_CLOCK = clk[14]; // 1526 Hz clock signal
	
	/* Set up LED board driver
	    ================================================================== */
	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	 logic RST;                   // reset - toggle this on startup
	 logic[2:0] BDR [15:0][15:0];
	 
	 assign RST = ~KEY[0];
	 	 
	 logic[15:0] lose;
	 logic slowClock;
	 
	 counter slow(slowClock, clkSelect);
	 
	 genvar i;
	 generate
		for (i=0;i<16;i++) begin : paddle
			if (i==0) 
				general_paddle PER(.on(RedPixels[15][0]), .loss(lose[i]), .clk(clkSelect), .reset, .inLt, .inRt, 
					.edgeLt(RedPixels[15][15]), .edgeRt(RedPixels[15][0]), .nextLt(RedPixels[15][1]), .nextRt(0), 
					.nextNorth(RedPixels[14][0]));
			else if (i==15)
				general_paddle PEL(.on(RedPixels[15][15]), .loss(lose[i]), .clk(clkSelect), .reset, .inLt, .inRt, 
					.edgeLt(RedPixels[15][15]), .edgeRt(RedPixels[15][0]), .nextLt(0), .nextRt(RedPixels[15][14]), 
					.nextNorth(RedPixels[14][15]));
			else if (i>3 && i<12)
				middle_paddle mid(.on(RedPixels[15][i]), .loss(lose[i]), .clk(clkSelect), .reset, .inLt, .inRt,
					.edgeLt(RedPixels[15][15]), .edgeRt(RedPixels[15][0]), .nextLt(RedPixels[15][i+1]), 
					.nextRt(RedPixels[15][i-1]), .nextNorth(RedPixels[14][i]));
			else 
				general_paddle gen(.on(RedPixels[15][i]), .loss(lose[i]), .clk(clkSelect), .reset, .inLt, .inRt,
					.edgeLt(RedPixels[15][15]), .edgeRt(RedPixels[15][0]), .nextLt(RedPixels[15][i+1]), 
					.nextRt(RedPixels[15][i-1]), .nextNorth(RedPixels[14][i]));
			end
	  endgenerate
	  	  
	  BO2 BO(.ball_on(GrnPixels[8][8]), .ballDirOut(BDR[8][8]), .clk(slowClock), 
                    .reset, .detN(GrnPixels[7][8]), .detNE(GrnPixels[7][7]), .detE(GrnPixels[8][7]), 
                    .detSE(GrnPixels[9][7]), .detS(GrnPixels[9][8]), .detSW(GrnPixels[9][9]), .detW(GrnPixels[8][9]), 
                    .detNW(GrnPixels[7][9]), 
                    .ballDirIn_N(BDR[7][8]), .ballDirIn_NE(BDR[7][7]), .ballDirIn_E(BDR[8][7]), 
                    .ballDirIn_SE(BDR[9][7]), .ballDirIn_S(BDR[9][8]), .ballDirIn_SW(BDR[9][9]), .ballDirIn_W(BDR[8][9]), 
                    .ballDirIn_NW(BDR[7][9]), .brickDetN(RedPixels[7][8]), .brickDetNE(RedPixels[7][7]), 
                    .brickDetE(RedPixels[8][7]), .brickDetSE(RedPixels[9][7]), .brickDetS(RedPixels[9][8]), 
                    .brickDetSW(RedPixels[9][9]), .brickDetW(RedPixels[8][9]), .brickDetNW(RedPixels[7][9]));
	  
genvar gpfr, gpfc;
generate
    for(gpfc=0;gpfc<16;gpfc++) begin : playfieldCol
        for(gpfr=4;gpfr<15;gpfr++) begin : playfieldRow
        if(gpfc == 0)
            GPF4 RE(.ball_on(GrnPixels[gpfr][0]), .ballDirOut(BDR[gpfr][0]), .clk(slowClock), 
                .reset, .detN(GrnPixels[gpfr-1][0]), .detNE(0), .detE(0), .detSE(0), .detS(GrnPixels[gpfr+1][0]),
                .detSW(GrnPixels[gpfr+1][1]), .detW(GrnPixels[gpfr][1]), .detNW(GrnPixels[gpfr-1][1]), 
                .ballDirIn_N(BDR[gpfr-1][0]), .ballDirIn_NE(0), .ballDirIn_E(0), .ballDirIn_SE(0), 
                .ballDirIn_S(BDR[gpfr+1][0]), .ballDirIn_SW(BDR[gpfr+1][1]), .ballDirIn_W(BDR[gpfr][1]), 
                .ballDirIn_NW(BDR[gpfr-1][1]), .brickDetN(RedPixels[gpfr-1][0]), .brickDetNE(0), 
                .brickDetE(0), .brickDetSE(0), .brickDetS(RedPixels[gpfr+1][0]), .brickDetSW(RedPixels[gpfr+1][1]),
                .brickDetW(RedPixels[gpfr][1]), .brickDetNW(RedPixels[gpfr-1][1]));
        else if(gpfc == 15)
            GPF4 LE(.ball_on(GrnPixels[gpfr][15]), .ballDirOut(BDR[gpfr][15]), .clk(slowClock), 
                .reset, .detN(GrnPixels[gpfr-1][15]), .detNE(GrnPixels[gpfr-1][14]), .detE(GrnPixels[gpfr][14]), 
                .detSE(GrnPixels[gpfr+1][14]), .detS(GrnPixels[gpfr+1][15]), .detSW(0), .detW(0), .detNW(0), 
                .ballDirIn_N(BDR[gpfr-1][15]), .ballDirIn_NE(BDR[gpfr-1][14]), .ballDirIn_E(BDR[gpfr][14]), 
                .ballDirIn_SE(BDR[gpfr+1][14]), .ballDirIn_S(BDR[gpfr+1][15]), .ballDirIn_SW(0), .ballDirIn_W(0), 
                .ballDirIn_NW(0), .brickDetN(RedPixels[gpfr-1][15]), .brickDetNE(RedPixels[gpfr-1][14]), 
                .brickDetE(RedPixels[gpfr][14]), .brickDetSE(RedPixels[gpfr+1][14]), .brickDetS(RedPixels[gpfr+1][15]), 
                .brickDetSW(0), .brickDetW(0), .brickDetNW(0));
        else if(!((gpfc==8)&&(gpfr==8)))
				 GPF4 mid(.ball_on(GrnPixels[gpfr][gpfc]), .ballDirOut(BDR[gpfr][gpfc]), .clk(slowClock), 
					  .reset, .detN(GrnPixels[gpfr-1][gpfc]), .detNE(GrnPixels[gpfr-1][gpfc-1]), .detE(GrnPixels[gpfr][gpfc-1]), 
					  .detSE(GrnPixels[gpfr+1][gpfc-1]), .detS(GrnPixels[gpfr+1][gpfc]), .detSW(GrnPixels[gpfr+1][gpfc+1]), 
					  .detW(GrnPixels[gpfr][gpfc+1]), .detNW(GrnPixels[gpfr-1][gpfc+1]), 
					  .ballDirIn_N(BDR[gpfr-1][gpfc]), .ballDirIn_NE(BDR[gpfr-1][gpfc-1]), .ballDirIn_E(BDR[gpfr][gpfc-1]), 
					  .ballDirIn_SE(BDR[gpfr+1][gpfc-1]), .ballDirIn_S(BDR[gpfr+1][gpfc]), .ballDirIn_SW(BDR[gpfr+1][gpfc+1]), 
					  .ballDirIn_W(BDR[gpfr][gpfc+1]), 
					  .ballDirIn_NW(BDR[gpfr-1][gpfc+1]), .brickDetN(RedPixels[gpfr-1][gpfc]), .brickDetNE(RedPixels[gpfr-1][gpfc-1]), 
					  .brickDetE(RedPixels[gpfr][gpfc-1]), .brickDetSE(RedPixels[gpfr+1][gpfc-1]), .brickDetS(RedPixels[gpfr+1][gpfc]), 
					  .brickDetSW(RedPixels[gpfr+1][gpfc+1]), .brickDetW(RedPixels[gpfr][gpfc+1]), .brickDetNW(RedPixels[gpfr-1][gpfc+1]));
            end
        end
    endgenerate
    
    genvar bc, br;
    generate
        for(bc=0;bc<16;bc++) begin : brickCol
            for(br=0;br<4;br++) begin : brickRow
            if((bc==15)&&(br==0))
                brick2 TLC(.ball_on(GrnPixels[0][15]), .ballDirOut(BDR[0][15]), .brick_on(RedPixels[0][15]), .clk(slowClock), 
                    .reset, .detN(0), .detNE(0), .detE(GrnPixels[0][14]), 
                    .detSE(GrnPixels[1][14]), .detS(GrnPixels[1][15]), .detSW(0), .detW(0), 
                    .detNW(0), .ballDirIn_N(0), .ballDirIn_NE(0), .ballDirIn_E(BDR[0][14]), 
                    .ballDirIn_SE(BDR[1][14]), .ballDirIn_S(BDR[1][15]), .ballDirIn_SW(0), .ballDirIn_W(0), 
                    .ballDirIn_NW(0), .brickDetN(1), .brickDetNE(1), 
                    .brickDetE(RedPixels[0][14]), .brickDetSE(RedPixels[1][14]), .brickDetS(RedPixels[1][15]), 
                    .brickDetSW(1), .brickDetW(1), .brickDetNW(1));
            else if((bc==0)&&(br==0))
                brick2 TRC(.ball_on(GrnPixels[0][0]), .ballDirOut(BDR[0][0]), .brick_on(RedPixels[0][0]), .clk(slowClock), 
                    .reset, .detN(0), .detNE(0), .detE(0), 
                    .detSE(0), .detS(GrnPixels[1][0]), .detSW(GrnPixels[1][1]), .detW(GrnPixels[0][1]), 
                    .detNW(0), .ballDirIn_N(0), .ballDirIn_NE(0), .ballDirIn_E(0), 
                    .ballDirIn_SE(0), .ballDirIn_S(BDR[1][0]), .ballDirIn_SW(BDR[1][1]), .ballDirIn_W(BDR[0][1]), 
                    .ballDirIn_NW(0), .brickDetN(1), .brickDetNE(1), 
                    .brickDetE(1), .brickDetSE(1), .brickDetS(RedPixels[1][0]), 
                    .brickDetSW(RedPixels[1][1]), .brickDetW(RedPixels[0][1]), .brickDetNW(1));
            else if (br==0)
                brick2 top(.ball_on(GrnPixels[0][bc]), .ballDirOut(BDR[0][bc]), .brick_on(RedPixels[0][bc]), .clk(slowClock), 
                    .reset, .detN(0), .detNE(0), .detE(GrnPixels[0][bc-1]), 
                    .detSE(GrnPixels[1][bc-1]), .detS(GrnPixels[1][bc]), .detSW(GrnPixels[1][bc+1]), .detW(GrnPixels[0][bc+1]), 
                    .detNW(0), .ballDirIn_N(0), .ballDirIn_NE(0), .ballDirIn_E(BDR[0][bc-1]), 
                    .ballDirIn_SE(BDR[1][bc-1]), .ballDirIn_S(BDR[1][bc]), .ballDirIn_SW(BDR[1][bc+1]), .ballDirIn_W(BDR[0][bc+1]), 
                    .ballDirIn_NW(0), .brickDetN(1), .brickDetNE(1), 
                    .brickDetE(RedPixels[0][bc-1]), .brickDetSE(RedPixels[1][bc-1]), .brickDetS(RedPixels[1][bc]), 
                    .brickDetSW(RedPixels[1][bc+1]), .brickDetW(RedPixels[0][bc+1]), .brickDetNW(1));
            else if(bc==0)
                brick2 RE(.ball_on(GrnPixels[br][0]), .ballDirOut(BDR[br][0]), .brick_on(RedPixels[br][0]), .clk(slowClock), 
                    .reset, .detN(GrnPixels[br-1][0]), .detNE(0), .detE(0), .detSE(0), .detS(GrnPixels[br+1][0]), 
                    .detSW(GrnPixels[br+1][1]), .detW(GrnPixels[br][1]), 
                    .detNW(GrnPixels[br-1][1]), .ballDirIn_N(BDR[br-1][0]), .ballDirIn_NE(0), .ballDirIn_E(0), 
                    .ballDirIn_SE(0), .ballDirIn_S(BDR[br+1][0]), .ballDirIn_SW(BDR[br+1][1]), .ballDirIn_W(BDR[br][1]), 
                    .ballDirIn_NW(BDR[br-1][1]), .brickDetN(RedPixels[br-1][0]), .brickDetNE(1), 
                    .brickDetE(1), .brickDetSE(1), .brickDetS(RedPixels[br+1][0]), 
                    .brickDetSW(RedPixels[br+1][1]), .brickDetW(RedPixels[br][1]), .brickDetNW(RedPixels[br-1][1]));
            else if(bc==15)
                brick2 LE(.ball_on(GrnPixels[br][15]), .ballDirOut(BDR[br][15]), .brick_on(RedPixels[br][15]), .clk(slowClock), 
                    .reset, .detN(GrnPixels[br-1][15]), .detNE(GrnPixels[br-1][14]), .detE(GrnPixels[br][14]), .detSE(GrnPixels[br+1][14]), 
                    .detS(GrnPixels[br+1][15]), .detSW(0), .detW(0), 
                    .detNW(0), .ballDirIn_N(BDR[br-1][15]), .ballDirIn_NE(BDR[br-1][14]), .ballDirIn_E(BDR[br][14]), 
                    .ballDirIn_SE(BDR[br+1][14]), .ballDirIn_S(BDR[br+1][15]), .ballDirIn_SW(0), .ballDirIn_W(0), 
                    .ballDirIn_NW(0), .brickDetN(RedPixels[br-1][15]), .brickDetNE(RedPixels[br-1][14]), 
                    .brickDetE(RedPixels[br][14]), .brickDetSE(RedPixels[br+1][14]), .brickDetS(RedPixels[br+1][15]), 
                    .brickDetSW(1), .brickDetW(1), .brickDetNW(1));
            else 
                brick2 mid(.ball_on(GrnPixels[br][bc]), .ballDirOut(BDR[br][bc]), .brick_on(RedPixels[br][bc]), .clk(slowClock), 
                    .reset, .detN(GrnPixels[br-1][bc]), .detNE(GrnPixels[br-1][bc-1]), .detE(GrnPixels[br][bc-1]), 
                    .detSE(GrnPixels[br+1][bc-1]), 
                    .detS(GrnPixels[br+1][bc]), .detSW(GrnPixels[br+1][bc+1]), .detW(GrnPixels[br][bc+1]), 
                    .detNW(GrnPixels[br-1][bc+1]), .ballDirIn_N(BDR[br-1][bc]), .ballDirIn_NE(BDR[br-1][bc-1]), .ballDirIn_E(BDR[br][bc-1]), 
                    .ballDirIn_SE(BDR[br+1][bc-1]), .ballDirIn_S(BDR[br+1][bc]), .ballDirIn_SW(BDR[br+1][bc+1]), .ballDirIn_W(BDR[br][bc+1]), 
                    .ballDirIn_NW(BDR[br-1][bc+1]), .brickDetN(RedPixels[br-1][bc]), .brickDetNE(RedPixels[br-1][bc-1]), 
                    .brickDetE(RedPixels[br][bc-1]), .brickDetSE(RedPixels[br+1][bc-1]), .brickDetS(RedPixels[br+1][bc]), 
                    .brickDetSW(RedPixels[br+1][bc+1]), .brickDetW(RedPixels[br][bc+1]), .brickDetNW(RedPixels[br-1][bc+1]));
				end
			end
		endgenerate
	
	
endmodule		

module DE1_SoC_testbench();

endmodule
