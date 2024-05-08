module cursor(
		input  [7:0] raw_VGA_R, 
		input  [7:0] raw_VGA_G,  
		input  [7:0] raw_VGA_B, 
		input [9:0] SW,
		input [3:0] KEY,
		input [12:0] col, 
		input [12:0] row,
		input CLOCK_50, 
		output reg [7:0] curs_ol__input_R, 
		output reg [7:0] curs_ol__input_G, 
		output reg [7:0] curs_ol__input_B
	);

	// parameters for cursor control
	parameter H_LIMIT = 640;
	parameter V_LIMIT = 480;
	parameter VELOCITY = 4;
	parameter R = 4;
	parameter LENGTH = 5;

	parameter R_LILAC = 8'hc8;
	parameter G_LILAC = 8'ha2;
	parameter B_LILAC = 8'hc8;
	parameter R_OLIVE = 8'h00;
	parameter G_OLIVE = 8'hFF;
	parameter B_OLIVE = 8'h00;


	// parameters for cursor  rect drawing control
	parameter R_OFF = 2'd0;
	parameter R_READY = 2'd1;
	parameter R_LOCK1 = 2'd2;
	parameter R_LOCK2 = 2'd3;

	// rect check params
	parameter BORDER_WIDTH = 1;
	
	// clk slowdown var
	reg 	       c_clk;
	reg 	[21:0] count = 0;

	
	// cursor rect FSM states
	reg [1:0] rect_state = R_OFF;
	reg [1:0] rect_nstate;
	reg rect_draw_ready = 0;
	wire [12:0] rect_min_row, rect_max_row, rect_min_col, rect_max_col;
	wire rect_check;
	
	// intermediate RGB reg
	wire	[7:0]  cam_feed_VGA_R;
	wire	[7:0]  cam_feed_VGA_G;
	wire	[7:0]  cam_feed_VGA_B;
	reg		[7:0]  rect_feed_R;
	reg		[7:0]  rect_feed_G;
	reg		[7:0]  rect_feed_B;
	
	// cursor bounds
	reg   signed   [12:0] c_top = 13'd0238;
	reg   signed   [12:0] c_bottom = 13'd0242;
	reg   signed   [12:0] c_right = 13'd0322;
	reg   signed   [12:0] c_left = 13'd0318;
	
	// cursor rect lock points
	reg signed [12:0] p1_row, p1_col;
	reg signed [12:0] p2_row, p2_col;
	reg signed [12:0] fp1_row, fp1_col;
	reg signed [12:0] fp2_row, fp2_col;
	
	// plus center
	wire 	 [12:0] c_row;
	wire 	 [12:0] c_col;
	
	// cam_feed colors to input to the monitor (unless its part of the cursor)
	assign	cam_feed_VGA_R = raw_VGA_R;
	assign	cam_feed_VGA_G = raw_VGA_G;
	assign	cam_feed_VGA_B = raw_VGA_B;
	
	// calculate plus cursor center
	assign c_col = (c_left + c_right) >> 1; 
	assign c_row = (c_top + c_bottom) >> 1; 
	
	// curs rect bound check
	assign rect_min_row = (fp1_row < fp2_row) ? fp1_row : fp2_row;
	assign rect_max_row = (fp1_row > fp2_row) ? fp1_row : fp2_row;
	assign rect_min_col = (fp1_col < fp2_col) ? fp1_col : fp2_col;
	assign rect_max_col = (fp1_col > fp2_col) ? fp1_col : fp2_col;
	
	wire top_border = (row >= rect_min_row && row < rect_min_row + BORDER_WIDTH) && 
                  (col >= rect_min_col && col < rect_max_col);
	wire bottom_border = (row <= rect_max_row && row > rect_max_row - BORDER_WIDTH) &&
						 (col >= rect_min_col && col < rect_max_col);
	wire left_border = (col >= rect_min_col && col < rect_min_col + BORDER_WIDTH) && 
					   (row >= rect_min_row && row < rect_max_row);
	wire right_border = (col <= rect_max_col && col > rect_max_col - BORDER_WIDTH) && 
						(row >= rect_min_row && row < rect_max_row);
		
	assign rect_check = top_border || bottom_border || left_border || right_border;

	// cursor color control
	// input is rect_feed
	// output is curs_ol_input
	always @ (posedge CLOCK_50)
	begin
		if(~SW[0]) // if cursor is off just send out underlying rect_feed 
		begin
			curs_ol__input_R <= rect_feed_R;
			curs_ol__input_G <= rect_feed_G;
			curs_ol__input_B <= rect_feed_B;
		end
		else
		begin
			// plus for cursor
			// horizontal
			// indication draw rect mode is active
			if((col == c_col) && (row >= c_row - LENGTH/2) && (row <= c_row + LENGTH/2))
			begin
				curs_ol__input_R <= R_LILAC;
				curs_ol__input_G <= G_LILAC;
				curs_ol__input_B <= B_LILAC;
			end
			//vertical
			else if((row == c_row) && (col >= c_col - LENGTH/2) && (col <= c_col + LENGTH/2))
			begin
				curs_ol__input_R <= R_LILAC;
				curs_ol__input_G <= G_LILAC;
				curs_ol__input_B <= B_LILAC;
			end
			else // everywhere else that's not cursor should be rect_feed
			begin
				curs_ol__input_R <= rect_feed_R;
				curs_ol__input_G <= rect_feed_G;
				curs_ol__input_B <= rect_feed_B;
			end
			
			if(SW[5]) begin
				if(col == c_col && row == c_row) begin
					curs_ol__input_R <= R_OLIVE;
					curs_ol__input_G <= G_OLIVE;
					curs_ol__input_B <= B_OLIVE;		
				end
				else begin
				
					if(col == fp1_col && row == fp1_row) begin
						curs_ol__input_R <= R_OLIVE;
						curs_ol__input_G <= G_OLIVE;
						curs_ol__input_B <= B_OLIVE;
					end

					if(col == fp2_col && row == fp2_row) begin
						curs_ol__input_R <= R_OLIVE;
						curs_ol__input_G <= G_OLIVE;
						curs_ol__input_B <= B_OLIVE;

					end
				end
			end
			
		end		
	end
	
	// curs rect color control
	// input is cam_feed
	// output is rect_feed
	always @ (posedge CLOCK_50) 
	begin
		if(SW[0]) begin
			
			if(rect_draw_ready && rect_check) begin // draw transparent rectangle using fp bounds
				// pixel inside rectangle border defined by user
				// transparency color blending
				rect_feed_R <= (cam_feed_VGA_R + 8'd128) >> 1;
				rect_feed_G <= (cam_feed_VGA_G + 8'd128) >> 1;
				rect_feed_B <= (cam_feed_VGA_B + 8'd128) >> 1;
			end
			else begin
					rect_feed_R <= cam_feed_VGA_R;
					rect_feed_G <= cam_feed_VGA_G;
					rect_feed_B <= cam_feed_VGA_B;
			end
		end
		else begin
				rect_feed_R <= cam_feed_VGA_R;
				rect_feed_G <= cam_feed_VGA_G;
				rect_feed_B <= cam_feed_VGA_B;
		end
	end
	
	// combinatorial curs rect draw next state logic
	always @ (*) 
	begin
		if(SW[0]) // only allow rect drawing when cursor is on
		begin
		
				case(rect_state)
					R_OFF: begin // cannot draw
						rect_draw_ready = 0;
						if(~SW[5]) begin // prioritize off state as hard reset
							rect_nstate = R_OFF;
						end
						if(SW[5]) begin
							rect_nstate = R_READY;
						end
						else begin// ~SW[5] = 0, ~SW[6], SW[6]
							rect_nstate = R_OFF;
						end
					end
					R_READY: begin // can move cursor and lock p1
						rect_draw_ready = 0;
						if(~SW[5])  begin
							rect_nstate = R_OFF;
						end
						else if(SW[6]) begin
							rect_nstate = R_LOCK1;
						end
						else begin // SW[5], ~SW[6]
							rect_nstate = R_READY;
						end
					end
					R_LOCK1: begin // can move cursor and lock p2
						rect_draw_ready = 0;
						if(~SW[5]) begin
							rect_nstate = R_OFF;
						end
						else if(~SW[6]) begin
							rect_nstate = R_LOCK2;
						end
						else begin // SW[5], SW[6]
							rect_nstate = R_LOCK1;
						end
					end
					R_LOCK2: begin // display traced rectangle but still allow for pt1 remap
						rect_draw_ready = 1;
						if(~SW[5]) begin
							rect_nstate = R_OFF;
						end
						else if(SW[6]) begin
							rect_nstate = R_LOCK1;
						end
						else begin
							rect_nstate = R_LOCK2;
						end
					end
					default: begin
						rect_nstate = R_OFF;
					end
				endcase
		
		end
		else begin
			rect_nstate = R_OFF;
		end
	end

	// update curs rect bounds
	always @ (posedge CLOCK_50) begin
		case(rect_state)
			R_OFF: begin
				fp1_row <= 0;
				fp1_col <= 0;
				fp2_row <= 0;
				fp2_col <= 0;
			end
			R_READY: begin
				// tentative first rect corner
				p1_row <= c_row;
				p1_col <= c_col;
			end
			R_LOCK1: begin
				// lock in first rect corner
				fp1_row <= p1_row;
				fp1_col <= p1_col;
				// tentative second rect corner
				p2_row <= c_row;
				p2_col <= c_col;
			end
			R_LOCK2: begin
				// lock in second rect corner
				fp2_row <= p2_row;
				fp2_col <= p2_col;
				// tentative remake of first rect corner
				p1_row <= c_row;
				p1_col <= c_col;
			end
			default: begin
				fp1_row <= 0;
				fp1_col <= 0;
				fp2_row <= 0;
				fp2_col <= 0;
			end
		endcase
	end
	
	// cursor rect FSM next state
	always @ (posedge CLOCK_50) 
	begin
		rect_state <= #1 rect_nstate;
	end
	
	// slower clk control to allow for easier cursor movement
	always @ (posedge CLOCK_50)
	begin
		if(count[20] == 1'b1) 
		begin  
			c_clk <= 1'b1;
			count <= count + 1;
		end
		else 
		begin
			c_clk <= 1'b0;
			count <= count + 1;
		end
	end
	
	// max vert = 480 max horz = 640
	// changing cursor point (KEY[3] = left, KEY[2] = up, KEY[1] = down, KEY[0] = right)
	always @ (posedge c_clk) 
	begin
		if(~SW[0]) begin
			c_top <= 13'd0238;
			c_bottom <= 13'd0242;
			c_right <= 13'd0322;
			c_left <= 13'd0318;
		end
		else if(~KEY[3]) // left
		begin
			if(c_right <= 0 && c_left <= 0)
			begin
				c_right <= c_right + H_LIMIT;
				c_left <= c_left + H_LIMIT;
			end
			else
			begin
				c_right <= c_right - VELOCITY;
				c_left <= c_left - VELOCITY;
			end
		end
		else if(~KEY[2]) // up
		begin 	
			if(c_top <= 0 && c_bottom <= 0)
			begin
				c_top <= c_top + V_LIMIT;
				c_bottom <= c_bottom + V_LIMIT;
			end
			else
			begin
				c_top <= c_top - VELOCITY;
				c_bottom <= c_bottom - VELOCITY;
			end
		end
		else if(~KEY[1]) // down
		begin
			if(c_bottom >= V_LIMIT && c_top >= V_LIMIT)
			begin
				c_top <= c_top - V_LIMIT;
				c_bottom <= c_bottom - V_LIMIT;
			end
			else
			begin
				c_top <= c_top + VELOCITY;
				c_bottom <= c_bottom + VELOCITY;
			end
		end
		else if(~KEY[0]) // right
		begin
			if(c_right >= H_LIMIT && c_left >= H_LIMIT)
			begin
				c_right <= c_right - H_LIMIT;
				c_left <= c_left - H_LIMIT;
			end
			else
			begin
				c_right <= c_right + VELOCITY;
				c_left <= c_left + VELOCITY;
			end
		end
		else begin
			c_top <= c_top;
			c_bottom <= c_bottom;
			c_right <= c_right;
			c_left <= c_left;
		end
	end
	
endmodule