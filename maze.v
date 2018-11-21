module maze(
		SW,
		KEY,
		LEDR,
		HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
		CLOCK_50,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B);   						//	VGA Blue[9:0]);

	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output [9:0] LEDR;
	input CLOCK_50;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire reset;
	assign reset = SW[9];

	/*wire en;
	assign en = SW[8];
*/
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [7:0] y;
	wire plot;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(~reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y[6:0]),
			.plot(plot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "bg3.mif";

	wire slow_clock;
	
	RateDivider divider(
		.interval(27'd300),
		.reset(reset),
		.en(1'b1),
		.clock_50(CLOCK_50),
		.reduced_clock(slow_clock)
		);

	HexDisplay hex0(
		.hex_digit(beans_ate[3:0]),
		.segments(HEX0)
		);
	HexDisplay hex1(
		.hex_digit(beans_ate[6:3]),
		.segments(HEX1)
		);
		reg en;
		reg stop;
		reg [27:0] Ni;
		 reg [27:0] No;
		 reg [7:0] Q;
		initial begin
		Ni=28'b0000000000000011000001111111;
		No=28'b0;
		Q=8'd19;
		en=1;
		stop=0;
		end
		
 always @ (posedge CLOCK_50)
 begin
	if(No==Ni)
	begin
	No<=0;
	en<=1;
	end
	else
	en<=0;
	No<=No+1;

 end	
 

	
	
	
	
	

	always @ (posedge reset, posedge CLOCK_50)
	begin
	if(reset)
	Q<=8'd30;
	else if (en&&!stop)
	Q<=Q-1;
	else if(!Q)
	stop<=1;
	end 
		HexDisplay hex2(
		.hex_digit(Q[3:0]),
		.segments(HEX2)
		);
	HexDisplay hex3(
		.hex_digit(Q[7:4]),
		.segments(HEX3)
		);
	HexDisplay hex4(
		.hex_digit(life),
		.segments(HEX4)
		);		
	wire[6:0] beans_ate;
	wire timer;
	wire [3:0] life;
	MainModule main_module(
		.move_up(~KEY[1]),
		.move_down(~KEY[2]),
		.move_left(~KEY[3]),
		.move_right(~KEY[0]),
		.clock_50(CLOCK_50),
		.slow_clock(slow_clock),
		.reset(reset),
		.timer(Q),
		.vga_colour(colour),
		.vga_x(x),
		.vga_y(y),
		.vga_plot(plot),
		.beans_ate(beans_ate),
		.lifeCount(life),
		.debug_leds(LEDR));

endmodule

module MainModule(
	input move_up,
	input move_down,
	input move_left,
	input move_right,
	input clock_50,
	input slow_clock,
	input reset,
	input [7:0] timer,
	output [2:0] vga_colour,
	output [7:0] vga_x,
	output [7:0] vga_y,
	output vga_plot,
	output reg [6:0] beans_ate,
	output reg [3:0] lifeCount,
	//output reg [8:0] colour,
	output [9:0] debug_leds);

		// The states in FSM
		
	
	
		
	localparam
				maze_TRY_EAT = 6'd0,
				maze_EAT_WAIT = 6'd1,
				maze_EAT = 6'd2,
				maze_GET_TARGET		= 6'd3,
				maze_GET_MAP_SPRITE 	= 6'd4,
				maze_WAIT				= 6'd5,
				maze_SET_POS			= 6'd6,

				GHOST1_GET_TARGET		= 6'd7,
				GHOST1_GET_MAP_SPRITE	= 6'd8,
				GHOST1_WAIT				= 6'd9,
				GHOST1_SET_POS			= 6'd10,

				GHOST2_GET_TARGET		= 6'd11,
				GHOST2_GET_MAP_SPRITE	= 6'd12,
				GHOST2_WAIT				= 6'd13,
				GHOST2_SET_POS			= 6'd14,

				GHOST3_GET_TARGET		= 6'd15,
				GHOST3_GET_MAP_SPRITE	= 6'd16,
				GHOST3_WAIT				= 6'd17,
				GHOST3_SET_POS			= 6'd18,

				GHOST4_GET_TARGET		= 6'd19,
				GHOST4_GET_MAP_SPRITE	= 6'd20,
				GHOST4_WAIT				= 6'd21,
				GHOST4_SET_POS			= 6'd22,
				
				GHOST5_GET_TARGET		= 6'd23,
				GHOST5_GET_MAP_SPRITE	= 6'd24,
				GHOST5_WAIT				= 6'd25,
				GHOST5_SET_POS			= 6'd26,
				
				GHOST6_GET_TARGET		= 6'd27,
				GHOST6_GET_MAP_SPRITE	= 6'd28,
				GHOST6_WAIT				= 6'd29,
				GHOST6_SET_POS			= 6'd30,

				GHOST7_GET_TARGET		= 6'd31,
				GHOST7_GET_MAP_SPRITE	= 6'd32,
				GHOST7_WAIT				= 6'd33,
				GHOST7_SET_POS			= 6'd34,				
				
				START_DISPLAY			= 6'd35,
				VIEW_DISPLAY			= 6'd36,
				STOP_DISPLAY			= 6'd37,
				
				END_GAME					= 6'd38,
				PRE=6'd39;
	
	// The coordinates of each character (it is 9 bit so that it can do signed operations)
	reg [8:0] maze_vga_x, ghost1_vga_x, ghost2_vga_x, ghost3_vga_x, ghost4_vga_x, ghost5_vga_x, ghost6_vga_x, ghost7_vga_x; 
	reg [8:0] maze_vga_y, ghost1_vga_y, ghost2_vga_y, ghost3_vga_y, ghost4_vga_y, ghost5_vga_y, ghost6_vga_y, ghost7_vga_y; 

	// The directions of each character
	reg [1:0] maze_dx, ghost1_dx, ghost2_dx, ghost3_dx, ghost4_dx, ghost5_dx, ghost6_dx, ghost7_dx; 
	reg [1:0] maze_dy, ghost1_dy, ghost2_dy, ghost3_dy, ghost4_dy, ghost5_dy, ghost6_dy, ghost7_dy; 

	// The target x and y coordinates for a character (it is 9 bit so that it can do signed operations)
	reg [8:0] target_x;
	reg [8:0] target_y;
	
	reg [4:0] char_map_x;
	reg [4:0] char_map_y;
	
	reg is_hit_maze;
	
	
	// The pins that go to the map
	reg [4:0] map_x;
	reg [4:0] map_y;
	reg [2:0] sprite_data_in;
	wire [2:0] sprite_data_out;
	reg map_readwrite; //0 for read, 1 for write

	// To start/stop the display controller
	reg reset_display;
	reg start_display = 1'b0;
	reg finished_display = 1'b0;
	reg [27:0] counter = 28'd0;
	wire is_display_running;
	wire [4:0] display_map_x, display_map_y;
	reg [27:0] wait1;
	// The current state in FSM
	reg [5:0] cur_state;
	reg pass;
	reg [3:0] passcount;
	assign debug_leds[5:0] = cur_state;
	reg key;
	initial begin
		beans_ate = 7'd0;
		map_x = 4'b0;//?????????????????????
		map_y = 4'b0;
		sprite_data_in = 3'b000;

		maze_vga_x = 9'd10;
		maze_vga_y = 9'd5;

		ghost1_vga_x = 9'd25; // Moves up and down on (5, 3)
		ghost1_vga_y = 9'd15;

		ghost2_vga_x = 9'd50; // Moves left and right on (10, 3)
		ghost2_vga_y = 9'd15;

		ghost3_vga_x = 9'd10; // Moves up and down on (15, 9)????
		ghost3_vga_y = 9'd95;

		ghost4_vga_x = 9'd65; // Moves left and right on (13, 19)
		ghost4_vga_y = 9'd95;

		ghost5_vga_x = 9'd75; // Moves left and right on (13, 19)
		ghost5_vga_y = 9'd5;
		
		
		ghost6_vga_x = 9'd95; // Moves left and right on (13, 19)
		ghost6_vga_y = 9'd5;
		
		ghost7_vga_x = 9'd40; // Moves left and right on (13, 19)
		ghost7_vga_y = 9'd55;
		
		maze_dx = 2'd0;
		maze_dy = 2'd0;

		ghost1_dx = 2'b00;
		ghost1_dy = 2'b10;

		ghost2_dx = 2'b01;
		ghost2_dy = 2'b00;

		ghost3_dx = 2'b01;
		ghost3_dy = 2'b00;

		ghost4_dx = 2'b10;
		ghost4_dy = 2'b00;
		
		ghost5_dx = 2'b00;
		ghost5_dy = 2'b01;
		
		ghost6_dx = 2'b00;
		ghost6_dy = 2'b01;

		ghost7_dx = 2'b01;
		ghost7_dy = 2'b00;		
		
		cur_state = PRE;
		target_x = 9'd0;
		target_y = 9'd0;
		is_hit_maze = 1'b0;
		beans_ate = 7'd0;
		lifeCount=4'd3;
		reset_display = 1'b1;
		wait1=28'b0;
		pass=1'b0;
		passcount=4'b0;
		key=1'b0;
		
	end
		/*reg en;
		reg stop;
		reg [27:0] Ni;
		 reg [27:0] No;
		 reg [7:0] Q;
		initial begin
		Ni=28'b0000000000000011000001111111;
		No=28'b0;
		Q=8'd19;
		en=1;
		stop=0;
		end
		
	 always @ (posedge CLOCK_50)
	 begin
		if(No==Ni)
		begin
		No<=0;
		en<=1;
		end
		else
		en<=0;
		No<=No+1;

	 end	
	
	

	always @ (posedge reset, posedge CLOCK_50)
	begin
	if(reset)
	Q<=8'd30;
	else if (en&&!stop)
	Q<=Q-1;
	else if(!Q)
	stop<=1;
	end*/
	

	
	wire Wdata, Wwren; 
  wire [5:0]BGcolour;
  wire [5:0]resetBG;
  assign Wdata = 1'b0;
  assign Wwren = 1'b0;
  wire[14:0]Waddress;
  reg [7:0]wirex;
  reg [6:0]wirey;
  assign Waddress = (wirey * 8'd160) + wirex; 
  
  reg endScreenEnable;
	reg bgEnable;
	reg StartEnable;
	wire [14:0]countOUT,countBG, countStart;
	wire [5:0] PGcolour, StartColour;
   wire [6:0]wy,wyBG, wyStart;
	wire [7:0]wx,wxBG, wxStart;
	
	
	PGcolour pg(
	.data(0),
	.wren(0),
	.address(countOUT),
	.clock(clk),
	.q(PGcolour));
	
	

	
	always @(posedge slow_clock, posedge reset) 
	begin
		if (reset == 1'b1) begin
			beans_ate <= 7'd0;
			sprite_data_in <= 3'b000;

			maze_vga_x <= 9'd10;
			maze_vga_y <= 9'd5;

			ghost1_vga_x <= 9'd25; // Moves up and down on (5, 3)
			ghost1_vga_y <= 9'd15;

			ghost2_vga_x <= 9'd50; // Moves left and right on (10, 3)
			ghost2_vga_y <= 9'd15;

			ghost3_vga_x <= 9'd10; // Moves up and down on (15, 9)
			ghost3_vga_y <= 9'd95;

			ghost4_vga_x <= 9'd65; // Moves left and right on (13, 19)
			ghost4_vga_y <= 9'd95;
			

			ghost5_vga_x <= 9'd75; // Moves left and right on (13, 19)
			ghost5_vga_y <= 9'd5;
			
			ghost6_vga_x <= 9'd95; // Moves left and right on (13, 19)
			ghost6_vga_y <= 9'd5;

			ghost7_vga_x <= 9'd40; // Moves left and right on (13, 19)
			ghost7_vga_y <= 9'd55;
			
			maze_dx <= 2'd0;
			maze_dy <= 2'd0;

			ghost1_dx <= 2'b00;
			ghost1_dy <= 2'b10;

			ghost2_dx <= 2'b01;
			ghost2_dy <= 2'b00;

			ghost3_dx <= 2'b01;
			ghost3_dy <= 2'b00;

			ghost4_dx <= 2'b10;
			ghost4_dy <= 2'b00;

			ghost5_dx <= 2'b00;
			ghost5_dy <= 2'b01;
			
			ghost6_dx <= 2'b00;
			ghost6_dy <= 2'b01;
		

			ghost7_dx <= 2'b01;
			ghost7_dy <= 2'b00;
			
				pass<=1'b0;
				passcount<=4'b0;
			wait1<=28'b0;
			cur_state <= PRE;
			target_x <= 9'd0;
			target_y <= 9'd0;
			is_hit_maze <= 1'b0;
			lifeCount<=4'd3;
			key<=1'b0;
		end
		
		else if (!timer) begin
			cur_state <= END_GAME;
		end
		
		else begin
			case (cur_state)
				// ---------------------------------------------------------------------------
				// ============================ maze ======================================
				// ---------------------------------------------------------------------------
				PRE:
				begin
				if (move_up||move_down||move_right||move_left)
				cur_state<=maze_GET_TARGET;
				else 
				cur_state<=PRE;
				end
				
				maze_TRY_EAT:
					begin
						char_map_x <= maze_vga_x / 9'd5;
						char_map_y <= maze_vga_y / 9'd5;
						map_readwrite <= 1'b0;
						cur_state <= maze_EAT_WAIT;
					end
				maze_EAT_WAIT: cur_state <= maze_EAT;
				maze_EAT:
					begin
						case (sprite_data_out)
						3'b001: // Blue or gray tile
						begin
							beans_ate <= beans_ate + 7'd1;
							sprite_data_in <= 3'b000;
							map_readwrite <= 1'b1;
						end
						
						3'b010: // Blue or gray tile
						begin
							beans_ate <= beans_ate + 7'd1;	
							sprite_data_in <= 3'b000;
							map_readwrite <= 1'b1;					
						end	
						
						3'b100: // Blue or gray tile
						begin
							key<=1'b1;	
							sprite_data_in <= 3'b000;
							map_readwrite <= 1'b1;					
						end
						
						default:
						begin
							beans_ate <= beans_ate;	
						end
						endcase
						cur_state <= maze_GET_TARGET; 
					end
				maze_GET_TARGET:
				begin
			
					cur_state <= maze_GET_MAP_SPRITE;
				
					if(move_up)
						maze_dy <= 2'b10;
					else if(move_down)
						maze_dy <= 2'b01;
					else if(move_left)
						maze_dx <= 2'b10;
					else if(move_right)
						maze_dx <= 2'b01;
					else
						begin
							maze_dx <= 2'b00;
							maze_dy <= 2'b00;
						end
						
					case (maze_dx)
						2'b01: target_x <= maze_vga_x + 9'd1;//takes maze current pos and moves right	
						2'b10: target_x <= maze_vga_x - 9'd1;//takes maze current pos and moves left	
						default: target_x <= maze_vga_x;	
					endcase
					
					case (maze_dy)
						2'b01: target_y <= maze_vga_y + 9'd1;//moves down
						2'b10: target_y <= maze_vga_y - 9'd1;//moves up
						default: target_y <= maze_vga_y;
					endcase
					
				end
				
				
				maze_GET_MAP_SPRITE:
				begin
					case(maze_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;//////////////////////????????????????
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(maze_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					
					map_readwrite <= 1'b0;
					cur_state <= maze_WAIT;				
				end
				maze_WAIT:
				begin
	
					cur_state <= maze_SET_POS;

				end

				maze_SET_POS:
				begin
					
					case (sprite_data_out)
						3'b011: // Blue tile
						begin
							maze_vga_x <= maze_vga_x;
							maze_vga_y <= maze_vga_y;
							maze_dx <= 2'd0;
							maze_dy <= 2'd0;
						end
						
						
						default: // A black tile
						begin
							maze_vga_x <= target_x;
							maze_vga_y <= target_y;
						end
					endcase
					if (maze_vga_x==9'd95&&maze_vga_y==9'd95&&key==1'b1)
					cur_state <= END_GAME;
					else
					cur_state <= GHOST1_GET_TARGET;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 1 ======================================
				// ---------------------------------------------------------------------------
				GHOST1_GET_TARGET:
				begin
					cur_state <= GHOST1_GET_MAP_SPRITE;
					/*if(move_up)
						ghost1_dy <= 2'b10;
					else if(move_down)
						ghost1_dy <= 2'b01;
					else if(move_left)
						ghost1_dx <= 2'b10;
					else if(move_right)
						ghost1_dx <= 2'b01;
					else
						begin
							ghost1_dx <= 2'b00;
							ghost1_dy <= 2'b00;
						end
					*/	

					case (ghost1_dx)
						2'b01: target_x <= ghost1_vga_x + 9'd1;	
						2'b10: target_x <= ghost1_vga_x - 9'd1;	
						default: target_x <= ghost1_vga_x;	
					endcase
					
					case (ghost1_dy)
						2'b01: target_y <= ghost1_vga_y + 9'd1;
						2'b10: target_y <= ghost1_vga_y - 9'd1;
						default: target_y <= ghost1_vga_y;
					endcase
				end
				GHOST1_GET_MAP_SPRITE:
				begin
				case(ghost1_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
				case(ghost1_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST1_WAIT;
				end
					

					
				GHOST1_WAIT:
				begin
					cur_state <= GHOST1_SET_POS;
				end
				
				GHOST1_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost1_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost1_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
						pass<=1'b1;
					end
					else if (sprite_data_out == 3'b011) begin // A grey tile, negate directions
						ghost1_dx <= ~ghost1_dx;
						ghost1_dy <= ~ghost1_dy;
					end

					else begin
						if(pass==1'b1)begin
						passcount<=passcount+1;
						end
						if(passcount==4'b1111)begin//0011000001111111
						pass<=1'b0;
						passcount<=4'b0;
						end
						is_hit_maze <= 1'b0;
						
						ghost1_vga_x <= target_x;
						ghost1_vga_y <= target_y;						
					end
					//if(is_hit_maze==1'b0)
					cur_state <= GHOST2_GET_TARGET;
					//else
					//cur_state <= maze_DODGE;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 2 ======================================
				// ---------------------------------------------------------------------------
				GHOST2_GET_TARGET:
				begin
					cur_state <= GHOST2_GET_MAP_SPRITE;
					/*if(move_up)
						ghost2_dy <= 2'b10;
					else if(move_down)
						ghost2_dy <= 2'b01;
					else if(move_left)
						ghost2_dx <= 2'b10;
					else if(move_right)
						ghost2_dx <= 2'b01;
					else
						begin
							ghost2_dx <= 2'b00;
							ghost2_dy <= 2'b00;
						end
						
					*/
					case (ghost2_dx)
						2'b01: target_x <= ghost2_vga_x + 9'd1;	
						2'b10: target_x <= ghost2_vga_x - 9'd1;	
						default: target_x <= ghost2_vga_x;	
					endcase
					
					case (ghost2_dy)
						2'b01: target_y <= ghost2_vga_y - 9'd1;
						2'b10: target_y <= ghost2_vga_y + 9'd1;
						default: target_y <= ghost2_vga_y;
					endcase
					

				end
				GHOST2_GET_MAP_SPRITE:
				begin
					case(ghost2_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost2_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST2_WAIT;
				end			
				
				GHOST2_WAIT:
				begin
					cur_state <= GHOST2_SET_POS;
				end

				GHOST2_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost2_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost2_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						pass<=1'b1;
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
					end
					
					else if (sprite_data_out == 3'b011) begin // A grey tile, negate directions makes ghost to flip direction between grey tiles
						ghost2_dx <= ~ghost2_dx;
						ghost2_dy <= ~ghost2_dy;
					end

					else begin
					
					if(pass==1'b1)begin
					passcount<=passcount+1;
					end
					
					if(passcount==4'b1111)begin//0011000001111111
					pass<=1'b0;
					passcount<=4'b0;
					end
					
						is_hit_maze <= 1'b0;
						ghost2_vga_x <= target_x;
						ghost2_vga_y <= target_y;						
					end
					
					//if(is_hit_maze==1'b0)
					cur_state <= GHOST3_GET_TARGET;
					//else
					//cur_state <= maze_DODGE;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 3 ======================================
				// ---------------------------------------------------------------------------
				GHOST3_GET_TARGET:
				begin
					cur_state <= GHOST3_GET_MAP_SPRITE;
					/*if(move_up)
						ghost3_dy <= 2'b10;
					else if(move_down)
						ghost3_dy <= 2'b01;
					else if(move_left)
						ghost3_dx <= 2'b10;
					else if(move_right)
						ghost3_dx <= 2'b01;
					else
						begin
							ghost3_dx <= 2'b00;
							ghost3_dy <= 2'b00;
						end
					*/	

					case (ghost3_dx)
						2'b01: target_x <= ghost3_vga_x + 9'd1;	
						2'b10: target_x <= ghost3_vga_x - 9'd1;	
						default: target_x <= ghost3_vga_x;	
					endcase
					
					case (ghost3_dy)
						2'b01: target_y <= ghost3_vga_y - 9'd1;
						2'b10: target_y <= ghost3_vga_y + 9'd1;
						default: target_y <= ghost3_vga_y;
					endcase
				end
				GHOST3_GET_MAP_SPRITE:
				begin
				begin
					case(ghost3_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost3_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST3_WAIT;
				end			

				end
				GHOST3_WAIT:
				begin
					cur_state <= GHOST3_SET_POS;
				end
				GHOST3_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost3_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost3_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						pass<=1'b1;
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
					end
					else if (sprite_data_out == 3'b011) begin // A grey tile, negate directions
						ghost3_dx <= ~ghost3_dx;
						ghost3_dy <= ~ghost3_dy;
					end

					else begin
					if(pass==1'b1)begin
					passcount<=passcount+1;
					end
					
					if(passcount==4'b1111)begin//0011000001111111
					pass<=1'b0;
					passcount<=4'b0;
					end
						is_hit_maze <= 1'b0;
						ghost3_vga_x <= target_x;
						ghost3_vga_y <= target_y;						
					end

					////if(is_hit_maze==1'b0)
					cur_state <= GHOST4_GET_TARGET;
					//else
					//cur_state <= maze_DODGE;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 4 ======================================
				// ---------------------------------------------------------------------------
				GHOST4_GET_TARGET:
				begin
					cur_state <= GHOST4_GET_MAP_SPRITE;

					/*if(move_up)
						ghost4_dy <= 2'b10;
					else if(move_down)
						ghost4_dy <= 2'b01;
					else if(move_left)
						ghost4_dx <= 2'b10;
					else if(move_right)
						ghost4_dx <= 2'b01;
					else
						begin
							ghost4_dx <= 2'b00;
							ghost4_dy <= 2'b00;
						end
						
*/
					case (ghost4_dx)
						2'b01: target_x <= ghost4_vga_x + 9'd1;	
						2'b10: target_x <= ghost4_vga_x - 9'd1;	
						default: target_x <= ghost4_vga_x;	
					endcase
					
					case (ghost4_dy)
						2'b01: target_y <= ghost4_vga_y + 9'd1;
						2'b10: target_y <= ghost4_vga_y - 9'd1;
						default: target_y <= ghost4_vga_y;
					endcase
				end
				GHOST4_GET_MAP_SPRITE:
				begin
					case(ghost4_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost4_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST4_WAIT;
				end			
				
				GHOST4_WAIT:
				begin
					cur_state <= GHOST4_SET_POS;
				end
				GHOST4_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost4_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost4_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						pass<=1'b1;
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
					end
					else if (sprite_data_out == 3'b011) begin // A blue tile, negate directions
						ghost4_dx <= ~ghost4_dx;
						ghost4_dy <= ~ghost4_dy;
					end

					else begin
					if(pass==1'b1)begin
					passcount<=passcount+1;
					end
					
					if(passcount==4'b1111)begin//0011000001111111
					pass<=1'b0;
					passcount<=4'b0;
					end
						is_hit_maze <= 1'b0;
						ghost4_vga_x <= target_x;
						ghost4_vga_y <= target_y;						
					end
					
					//if(is_hit_maze==1'b0)
					cur_state <= GHOST5_GET_TARGET;
					//else
					//cur_state <= maze_DODGE;
				end
				GHOST5_GET_TARGET:
				begin
					cur_state <= GHOST5_GET_MAP_SPRITE;

					case (ghost5_dx)
					2'b01: target_x <= ghost5_vga_x + 9'd1;	
					2'b10: target_x <= ghost5_vga_x - 9'd1;	
					default: target_x <= ghost5_vga_x;	
					endcase

					case (ghost5_dy)
					2'b01: target_y <= ghost5_vga_y + 9'd1;
					2'b10: target_y <= ghost5_vga_y - 9'd1;
					default: target_y <= ghost5_vga_y;
					endcase

					/*if(move_up)
						ghost5_dy <= 2'b10;
					else if(move_down)
						ghost5_dy <= 2'b01;
					else if(move_left)
						ghost5_dx <= 2'b10;
					else if(move_right)
						ghost5_dx <= 2'b01;
					else
						begin
							ghost5_dx <= 2'b00;
							ghost5_dy <= 2'b00;
						end
						

					case (ghost5_dx)
						2'b01: target_x <= ghost5_vga_x + 9'd1;	
						2'b10: target_x <= ghost5_vga_x - 9'd1;	
						default: target_x <= ghost5_vga_x;	
					endcase
					
					case (ghost5_dy)
						2'b01: target_y <= ghost5_vga_y + 9'd1;
						2'b10: target_y <= ghost5_vga_y - 9'd1;
						default: target_y <= ghost5_vga_y;
					endcase*/
				end
				GHOST5_GET_MAP_SPRITE:
				begin
					case(ghost5_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost5_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST5_WAIT;
				end			
				
				GHOST5_WAIT:
				begin
					cur_state <= GHOST5_SET_POS;
				end
				GHOST5_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost5_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost5_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						pass<=1'b1;
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
					end
					else if (sprite_data_out == 3'b011) begin // A blue tile, negate directions
						ghost5_dx <= ~ghost5_dx;
						ghost5_dy <= ~ghost5_dy;
					end

					else begin
					if(pass==1'b1)begin
					passcount<=passcount+1;
					end
					
					if(passcount==4'b1111)begin//0011000001111111
					pass<=1'b0;
					passcount<=4'b0;
					end
						is_hit_maze <= 1'b0;
						ghost5_vga_x <= target_x;
						ghost5_vga_y <= target_y;						
					end
					
					//if(is_hit_maze==1'b0)
					cur_state <= GHOST6_GET_TARGET;
					//else
					//cur_state <= maze_DODGE;
				end
				GHOST6_GET_TARGET:
				begin
					cur_state <= GHOST6_GET_MAP_SPRITE;

					case (ghost6_dx)
					2'b01: target_x <= ghost6_vga_x + 9'd1;	
					2'b10: target_x <= ghost6_vga_x - 9'd1;	
					default: target_x <= ghost6_vga_x;	
					endcase

					case (ghost6_dy)
					2'b01: target_y <= ghost6_vga_y + 9'd1;
					2'b10: target_y <= ghost6_vga_y - 9'd1;
					default: target_y <= ghost6_vga_y;
					endcase

					/*if(move_up)
						ghost5_dy <= 2'b10;
					else if(move_down)
						ghost5_dy <= 2'b01;
					else if(move_left)
						ghost5_dx <= 2'b10;
					else if(move_right)
						ghost5_dx <= 2'b01;
					else
						begin
							ghost5_dx <= 2'b00;
							ghost5_dy <= 2'b00;
						end
						

					case (ghost5_dx)
						2'b01: target_x <= ghost5_vga_x + 9'd1;	
						2'b10: target_x <= ghost5_vga_x - 9'd1;	
						default: target_x <= ghost5_vga_x;	
					endcase
					
					case (ghost5_dy)
						2'b01: target_y <= ghost5_vga_y + 9'd1;
						2'b10: target_y <= ghost5_vga_y - 9'd1;
						default: target_y <= ghost5_vga_y;
					endcase*/
				end
				GHOST6_GET_MAP_SPRITE:
				begin
					case(ghost6_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost6_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST6_WAIT;
				end			
				
				GHOST6_WAIT:
				begin
					cur_state <= GHOST6_SET_POS;
				end
				GHOST6_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost6_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost6_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						pass<=1'b1;
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
					end
					else if (sprite_data_out == 3'b011) begin // A blue tile, negate directions
						ghost6_dx <= ~ghost6_dx;
						ghost6_dy <= ~ghost6_dy;
					end

					else begin
					if(pass==1'b1)begin
					passcount<=passcount+1;
					end
					
					if(passcount==4'b1111)begin//0011000001111111
					pass<=1'b0;
					passcount<=4'b0;
					end
						is_hit_maze <= 1'b0;
						ghost6_vga_x <= target_x;
						ghost6_vga_y <= target_y;						
					end
					
					//if(is_hit_maze==1'b0)
					cur_state <= GHOST7_GET_TARGET;
					//else
					//cur_state <= maze_DODGE;
				end
				GHOST7_GET_TARGET:
				begin
					cur_state <= GHOST7_GET_MAP_SPRITE;

					case (ghost7_dx)
					2'b01: target_x <= ghost7_vga_x + 9'd1;	
					2'b10: target_x <= ghost7_vga_x - 9'd1;	
					default: target_x <= ghost7_vga_x;	
					endcase

					case (ghost7_dy)
					2'b01: target_y <= ghost7_vga_y + 9'd1;
					2'b10: target_y <= ghost7_vga_y - 9'd1;
					default: target_y <= ghost7_vga_y;
					endcase

					/*if(move_up)
						ghost5_dy <= 2'b10;
					else if(move_down)
						ghost5_dy <= 2'b01;
					else if(move_left)
						ghost5_dx <= 2'b10;
					else if(move_right)
						ghost5_dx <= 2'b01;
					else
						begin
							ghost5_dx <= 2'b00;
							ghost5_dy <= 2'b00;
						end
						

					case (ghost5_dx)
						2'b01: target_x <= ghost5_vga_x + 9'd1;	
						2'b10: target_x <= ghost5_vga_x - 9'd1;	
						default: target_x <= ghost5_vga_x;	
					endcase
					
					case (ghost5_dy)
						2'b01: target_y <= ghost5_vga_y + 9'd1;
						2'b10: target_y <= ghost5_vga_y - 9'd1;
						default: target_y <= ghost5_vga_y;
					endcase*/
				end
				GHOST7_GET_MAP_SPRITE:
				begin
					case(ghost7_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost7_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST7_WAIT;
				end			
				
				GHOST7_WAIT:
				begin
					cur_state <= GHOST7_SET_POS;
				end
				GHOST7_SET_POS:
				begin
					if (maze_vga_x / 9'd5 == ghost7_vga_x / 9'd5 && maze_vga_y / 9'd5 == ghost7_vga_y / 9'd5&&pass==1'b0) 
					begin // If hit maze
						pass<=1'b1;
						is_hit_maze <= 1'b1;
						lifeCount<=lifeCount-1;
					end
					else if (sprite_data_out == 3'b011) begin // A blue tile, negate directions
						ghost7_dx <= ~ghost7_dx;
						ghost7_dy <= ~ghost7_dy;
					end

					else begin
					if(pass==1'b1)begin
					passcount<=passcount+1;
					end
					
					if(passcount==4'b1111)begin//0011000001111111
					pass<=1'b0;
					passcount<=4'b0;
					end
						is_hit_maze <= 1'b0;
						ghost7_vga_x <= target_x;
						ghost7_vga_y <= target_y;						
					end
					
					//if(is_hit_maze==1'b0)
					cur_state <= START_DISPLAY;
					//else
					//cur_state <= maze_DODGE;
				end				
				// ---------------------------------------------------------------------------
				// ============================ DISPLAY ======================================
				// ---------------------------------------------------------------------------
				START_DISPLAY:
				begin
					reset_display <= 1'b0;
					start_display <= 1'b1;
					counter <= 28'd0;
					cur_state <= VIEW_DISPLAY;
				end
				VIEW_DISPLAY:
				begin
					reset_display <= 1'b0;
					
					if (start_display == 1'b1) begin
						counter <= counter + 28'd1;
						start_display <= 1'b0;
						cur_state <= VIEW_DISPLAY;
					end
					else if (start_display == 1'b0 && counter <= 28'd11300) begin////?
						counter <= counter + 28'd1;
						cur_state <= VIEW_DISPLAY;
					end
					else if (start_display == 1'b0 && counter > 28'd11300)begin
						counter <= 28'd0;
						cur_state <= STOP_DISPLAY;
					end
				end
				STOP_DISPLAY:
				begin
					reset_display <= 1'b1;
					counter <= 28'd0;
					
					if (lifeCount==4'd0) begin
						cur_state <= END_GAME;
					end
					else begin
						cur_state <= maze_TRY_EAT;
					end
				end
				
				END_GAME:
				begin
				
						
			endScreenEnable <= 1'b1;
			

	
	
					// reset_display <= 1'b1;
				//	c[5:0] <=  PGcolour;
					counter <= 28'd0;
					
					
				end
			endcase			
		end
	end
	
	always @(*)
	begin
		if (cur_state == VIEW_DISPLAY) begin
			map_x = display_map_x;
			map_y = display_map_y;
		end
		else begin
			map_x = char_map_x;
			map_y = char_map_y;
		end
	end
	
		
	// The map, containing map data
	MapController map(
		.map_x(map_x),
		.map_y(map_y),
		.sprite_data_in(sprite_data_in),
		.sprite_data_out(sprite_data_out),
		.readwrite(map_readwrite),
		.clock_50(clock_50));

	DisplayController display_controller(
		.en(1'b1),
		.map_x(display_map_x),
		.map_y(display_map_y),
		.sprite_type(sprite_data_out),
		
		.maze_orientation({move_left,move_right,move_up,move_down}),		
		.maze_vga_x(maze_vga_x[7:0]),
		.maze_vga_y(maze_vga_y[7:0]),
		
		.ghost1_vga_x(ghost1_vga_x[7:0]),
		.ghost1_vga_y(ghost1_vga_y[7:0]),
		
		.ghost2_vga_x(ghost2_vga_x[7:0]),
		.ghost2_vga_y(ghost2_vga_y[7:0]),
		
		.ghost3_vga_x(ghost3_vga_x[7:0]),
		.ghost3_vga_y(ghost3_vga_y[7:0]),
		
		.ghost4_vga_x(ghost4_vga_x[7:0]),
		.ghost4_vga_y(ghost4_vga_y[7:0]),
		.ghost5_vga_x(ghost5_vga_x[7:0]),
		.ghost5_vga_y(ghost5_vga_y[7:0]),
		.ghost6_vga_x(ghost6_vga_x[7:0]),
		.ghost6_vga_y(ghost6_vga_y[7:0]),
		.ghost7_vga_x(ghost7_vga_x[7:0]),
		.ghost7_vga_y(ghost7_vga_y[7:0]),
		.vga_plot(vga_plot),
		.vga_x(vga_x),
		.vga_y(vga_y),
		.vga_color(vga_colour),
		.reset(reset_display || reset),
		.clock_50(clock_50),
		.is_display_running(is_display_running));
		
endmodule
module gameOverDisplay(gameOver, reset, clock, x, y, colour, plot, eraseCount);
	input reset;
	input gameOver;
	input clock;
	
	//Wires needed for signals between control path and data path
	wire [12:0]drawCount;
	output [12:0]eraseCount;
	wire [2:0]currentstate;
	controlOver gameOverControl(gameOver, reset, drawCount, eraseCount, clock, currentstate);
	
	output [8:0]x;
	output [7:0]y;
	output [2:0]colour;
	output plot;
	dataOver gameOverData(currentstate, clock, x, y, colour, plot, drawCount, eraseCount, eraseOver);

endmodule

/*****Game Over Image Control*****/
module controlOver(gameOver, reset, drawCount, eraseCount, clock, currentstate);
	input gameOver;
	input reset;
	input [12:0]drawCount;
	input [12:0]eraseCount;
	input clock;

parameter [2:0] erase = 3'b000, draw = 3'b001, done1 = 3'b010, done2 = 3'b011;
	
	reg [2:0]nextstate;
	always @ (*)
	begin
		case(currentstate)
			erase:
			begin
				if (eraseCount == 13'b1111111111111)
					nextstate = done1;
				else
					nextstate = erase;
			end
			draw:
			begin
				if (drawCount == 13'b1111111111111)
					nextstate = done2;
				else
					nextstate = draw;
			end
			done1:
				if(gameOver == 1)
					nextstate = draw;
				else
					nextstate = done1;
			
			done2:
					nextstate = done2;
		endcase
	end
	
	output reg [2:0]currentstate;
	//State Flip-flop
	always @ (posedge clock)
	begin
		if (reset == 1)
			currentstate <= erase;
		else
			currentstate <= nextstate;
	end
endmodule

/*****Game Over Image Data*****/
module dataOver(currentstate, clock, x, y, colour, plot, drawCount, eraseCount, eraseOver);
	input clock;
	input [2:0]currentstate;
	output reg [8:0]x;
	output reg [7:0]y;
	output reg [2:0]colour;
	output reg plot;
	output [12:0]drawCount;
	output [12:0]eraseCount;
	output reg eraseOver;
	
parameter [2:0] erase = 3'b000, draw = 3'b001, done1 = 3'b010, done2 = 3'b011;
	
	reg drawStart;
	reg eraseStart;
	//Output logic
	always @ (*)
	begin
		case(currentstate)
			erase:
			begin
				eraseOver = 0;
				drawStart = 0;
				eraseStart = 1;
			end
			draw:
			begin
				eraseOver = 0;
				drawStart = 1;
				eraseStart = 0;
			end
			done1:
			begin
				eraseOver = 1;
				drawStart = 0;
				eraseStart = 0;
			end
			done2:
			begin
				eraseOver = 0;
				drawStart = 0;
				eraseStart = 0;
			end
			
			default:
			begin
				eraseOver = 0;
				drawStart = 0;
				eraseStart = 0;
			end
		endcase
	end
	
	always @ (*)
	begin
		if (drawStart == 1)
		begin
			x = 9'd100 + drawCount[6:0];
			y = 8'd55 + drawCount[12:7];
			colour = q;
			plot = 1;
		end
		else if (eraseStart == 1)
		begin
			x = 9'd100 + eraseCount[6:0];
			y = 8'd55 + eraseCount[12:7];
			colour = 3'b111;
			plot = 1;
		end
		else
			plot = 0;
	end
	
	wire [2:0]data;
	wire wren;
	assign wren = 0;
	wire [2:0]q;
	GameOver (drawCount[12:0], clock, data, wren, q);
	drawOverCounter myDraw(drawStart, clock, drawCount);
	eraseOverCounter myErawe(eraseStart, clock, eraseCount);
endmodule


/***Draw Counter***/
module drawOverCounter(trigger, clock, counting);
	input trigger;
	input clock;
	output reg [12:0]counting;
	
	always @ (posedge clock)
	begin
		if (trigger == 1)
			counting <= counting + 1'b1;
		else
			counting <= 13'b0;
	end
endmodule

/***Erase Counter***/
module eraseOverCounter(trigger, clock, counting);
	input trigger;
	input clock;
	output reg [12:0]counting;
	
	always @ (posedge clock)
	begin
		if (trigger == 1)
			counting <= counting + 1'b1;
		else
			counting <= 13'b0;
	end
endmodule



