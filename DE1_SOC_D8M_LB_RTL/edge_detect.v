module edge_detect(
			input row, 
			input col,
			input clk,
			input edge_en,
			input [7:0] in_R, 
			input [7:0] in_G, 
			input [7:0] in_B, 
			output [7:0] edge_R_out, 
			output [7:0] edge_G_out, 
			output [7:0] edge_B_out,
			output [9:0] cycles,
			output vga_reset
		);
		
		wire [7:0] insert_zero;
		assign insert_zero = 8'b0;
		wire [7:0] inter_in_R;
		wire [7:0] inter_in_G;
		wire [7:0] inter_in_B;
		wire [7:0] inter_grey;
			
		// output wires for edge detection
		wire [7:0] done_edge_R, done_edge_G, done_edge_B;
		assign edge_R_out = done_edge_R;
		assign edge_G_out = done_edge_G;
		assign edge_B_out = done_edge_B;
		wire [7:0] edge_out; // will be split into R, G, and B
		
		/* reg/wire for M10K img row buffers */
		// when done using buffer, reset it before wr_en == 1
		reg [3:0] rst_buff;
		reg [3:0] rd_buff_en;
		reg [3:0] wr_buff_en;
		reg [3:0] zero_fill_buff;
		// read out buffer data
		wire [7:0] buff0_pixelA, 
					 buff1_pixelA,
					 buff2_pixelA, 
					 buff3_pixelA,
					 buff0_pixelB, 
					 buff1_pixelB,
					 buff2_pixelB, 
					 buff3_pixelB,
					 buff0_pixelC, 
					 buff1_pixelC,
					 buff2_pixelC, 
					 buff3_pixelC;
					 
		// wire/reg for sobel conv calcs
		reg [7:0] sobel_in_pixel0, 
					sobel_in_pixel1, 
					sobel_in_pixel2, 
					sobel_in_pixel3, 
					sobel_in_pixel4, 
					sobel_in_pixel5, 
					sobel_in_pixel6, 
					sobel_in_pixel7, 
					sobel_in_pixel8;	
					
		greyscale grey(
			.in_R(inter_in_R), 
			.in_G(inter_in_G), 
			.in_B(inter_in_B), 
			.grey(inter_grey)
		);
		
		assign inter_in_R = in_R;
		assign inter_in_G = in_G;
		assign inter_in_B = in_B;
		
		// row buffers
		img_row M10K_0(.zero_fill(zero_fill_buff[0]), .clk(clk), .rst(rst_buff[0]), .in_data(inter_grey), .wr_en(wr_buff_en[0]), .rd_en(rd_buff_en[0]), .pixelA(buff0_pixelA), .pixelB(buff0_pixelB), .pixelC(buff0_pixelC));
		img_row M10K_1(.zero_fill(zero_fill_buff[1]), .clk(clk), .rst(rst_buff[1]), .in_data(inter_grey), .wr_en(wr_buff_en[1]), .rd_en(rd_buff_en[1]), .pixelA(buff1_pixelA), .pixelB(buff1_pixelB), .pixelC(buff1_pixelC));
		img_row M10K_2(.zero_fill(zero_fill_buff[2]), .clk(clk), .rst(rst_buff[2]), .in_data(inter_grey), .wr_en(wr_buff_en[2]), .rd_en(rd_buff_en[2]), .pixelA(buff2_pixelA), .pixelB(buff2_pixelB), .pixelC(buff2_pixelC));
		img_row M10K_3(.zero_fill(zero_fill_buff[3]), .clk(clk), .rst(rst_buff[3]), .in_data(inter_grey), .wr_en(wr_buff_en[3]), .rd_en(rd_buff_en[3]), .pixelA(buff3_pixelA), .pixelB(buff3_pixelB), .pixelC(buff3_pixelC));
		
		// convolution module
		sobel_conv sob(
			.pixel0(sobel_in_pixel0),
			.pixel1(sobel_in_pixel1),
			.pixel2(sobel_in_pixel2),
			.pixel3(sobel_in_pixel3),
			.pixel4(sobel_in_pixel4),
			.pixel5(sobel_in_pixel5),
			.pixel6(sobel_in_pixel6),
			.pixel7(sobel_in_pixel7),
			.pixel8(sobel_in_pixel8),
			.op_val(edge_out)
			
		);
		
		
		
		// FSM for pixel syncing
		parameter OFF = 2'd0;
		parameter IDLE = 2'd1;
		parameter ACTIVE = 2'd2;
		reg [1:0] sync_state = OFF;
		reg [1:0] next_sync_state;
		reg synced = 1'b0;
		// sync state progression
		always@(posedge clk) begin
			sync_state <= next_sync_state;
		end
		
		// sync state output calcs
		// value of synced changes immediately upon entry into new state
		always@(*) begin
			case(sync_state)
				OFF: begin
					synced = 0;
				end
				IDLE: begin
					synced = 0;
				end
				ACTIVE: begin // pixel is 0,0
					synced = 1; // when sync actually turns on  pixel is 1,0
				end
				default: begin
					synced = 0;
				end
			endcase
		end
		
		// sync state outputs
		always@(*) begin
			case(sync_state) 
				// send out original pixels
				OFF: begin
					if(edge_en)
						next_sync_state = IDLE;
					else
						next_sync_state = OFF;
				end
				// still send out original pixels
				// wait until row=0, col=0 to start saving pixels
				IDLE: begin
					if(~edge_en)
						next_sync_state = OFF;
					else if(col == 638 && row == 479) // takes 2 cycles to actuallly process sync
						next_sync_state = ACTIVE; // next pixel at 0,0 should be ready to be saved
					else
						next_sync_state = IDLE;
				end
				ACTIVE: begin // now keep on while edge_en on
					if(edge_en)
						next_sync_state = ACTIVE;
					else
						next_sync_state = OFF;
				end
				default: begin // should never be here
					next_sync_state = OFF;
				end
			endcase
		end
		
		
		
		// FSM for convolution control
		parameter MAX_DISP_ROWS = 480;
		parameter MAX_DISP_COLS = 640;
		parameter INIT_ROWS = 2;
		// FSM states
		parameter INIT = 3'd0;
		parameter INIT_BUFF = 3'd1;
		parameter SET0 = 3'd2; // RD: 0,1,2 | WR: 3
		parameter SET1 = 3'd3; // RD: 1,2,3 | WR: 0
		parameter SET2 = 3'd4; // RD: 2,3,0 | WR: 1
		parameter SET3 = 3'd5; // RD: 3,0,1 | WR: 2
		
		
		reg [2:0] conv_state = INIT;
		reg [2:0] next_conv_state;
		// reg [9:0] curr_op_row_count;
		reg [8:0] curr_buff_wr_count;
		//reg [9:0] rows_wr_to_buff;
		// reg [8:0] cols_wr_to_buff;
		//reg [9:0] rows_rd_from_buff;
		//reg [8:0] cols_rd_from_buff;
		reg [9:0] curr_row_to_disp;
		//reg [8:0] cols_to_disp;
		//reg [9:0] rd_ptr_ct;
		//reg [9:0] wr_ptr_ct;
		reg first_conv_done = 0;
		//reg [18:0] pixels_to_disp;
		reg [1:0] init_curr_buff;
		reg buff_done = 0;
		// [3:0] rst_buff
		// [3:0] rd_buff_en
		// [3:0] wr_buff_en
		// [3:0] zero_fill_buff
		
		
		// outputs of buffers:
		// buff0_pixelA, buff0_pixelB, buff0_pixelC
		// buff1_pixelA, buff1_pixelB, buff1_pixelC
		// buff2_pixelA, buff2_pixelB, buff2_pixelC 
		// buff3_pixelA, buff3_pixelB, buff3_pixelC
		
		// just have to adjust what these take in
		// inputs of sobel conv module
		// sobel_in_pixel0, sobel_in_pixel1, sobel_in_pixel2,
		// sobel_in_pixel3, sobel_in_pixel4, sobel_in_pixel5, 
		// sobel_in_pixel6, sobel_in_pixel7, sobel_in_pixel8;		

		// monitor syncing
		// used to reset monitor to pixel 0,0
		reg vga_rst_req = 1'b0;
		reg vga_synced = 1'b0;
		assign vga_reset = vga_rst_req;
		
		// 640x480 => 642x482
		// convolution on image 642 x 482 to account for padding
		// next state progress
		always@(posedge clk) begin
			conv_state <= next_conv_state;
		end
		// only conv next state calc and flag setting
		always@(*) begin
			case(conv_state)
				INIT: begin
					// if edging and syncing activate
					// start reading in row 0 and col 0
					if(edge_en && synced) 
						// synced actually turns on when
						next_conv_state = INIT_BUFF;
					else
						next_conv_state = INIT;
				end
				INIT_BUFF: begin
					if(~edge_en)
						next_conv_state = INIT;
					else if(buff_done)
						next_conv_state = SET0;
					else
						next_conv_state = INIT_BUFF;
				end
				SET0: begin // RD: 0,1,2 | WR: 3
					if(~edge_en)
						next_conv_state = INIT;
					else if(buff_done)
						next_conv_state = SET1;
					else
						next_conv_state = SET0;
				end
				SET1: begin // RD: 1,2,3 | WR: 0
					if(~edge_en)
						next_conv_state = INIT;
					else if(buff_done)
						next_conv_state = SET2;
					else
						next_conv_state = SET1;
				end
				SET2: begin // RD: 2,3,0 | WR: 1
					if(~edge_en)
						next_conv_state = INIT;
					else if(buff_done)
						next_conv_state = SET3;
					else
						next_conv_state = SET2;
				end
				SET3: begin // RD: 3,0,1 | WR: 2
					if(~edge_en)
						next_conv_state = INIT;
					else if(buff_done)
						next_conv_state = SET0;
					else
						next_conv_state = SET3;
				end
				default: begin
					next_conv_state = INIT;
				end
			endcase
		end
		// conv wr buffer enabling
		always@(*) begin
			case(conv_state)
				INIT: begin
					wr_buff_en = 4'b0000;
				end
				INIT_BUFF: begin
					case(init_curr_buff)
						2'd0: wr_buff_en = 4'b0010;
						2'd1: wr_buff_en = 4'b0100;
						default: wr_buff_en = 4'b0000;
					endcase
				end
				SET0: begin // write buff3
					wr_buff_en = 4'b1000;
				end
				SET1: begin // write buff0
					wr_buff_en = 4'b0001;
				end
				SET2: begin // write buff1
					wr_buff_en = 4'b0010;
				end
				SET3: begin // write buff2
					wr_buff_en = 4'b0100;
				end
				default: begin
					wr_buff_en = 4'b0000;
				end
			endcase
		end
		// conv rd buffer enabling
		always@(*) begin
			case(conv_state)
				INIT: begin
					rd_buff_en = 4'b0000;
				end
				INIT_BUFF: begin
					rd_buff_en = 4'b0000;
				end
				SET0: begin
					rd_buff_en = 4'b0111;
				end
				SET1: begin
					rd_buff_en = 4'b1110;
				end
				SET2: begin
					rd_buff_en = 4'b1101;
				end
				SET3: begin
					rd_buff_en = 4'b1011;
				end
				default: begin
					rd_buff_en = 4'b0000;
				end
			endcase
		end
		// conv output redirection
		always@(*) begin
			case(conv_state)
				INIT: begin
					// first row
					sobel_in_pixel0 = insert_zero;
					sobel_in_pixel1 = insert_zero;
					sobel_in_pixel2 = insert_zero;
					// second row 
					sobel_in_pixel3 = insert_zero;
					sobel_in_pixel4 = insert_zero;
					sobel_in_pixel5 = insert_zero;
					// third row
					sobel_in_pixel6 = insert_zero;
					sobel_in_pixel7 = insert_zero;
					sobel_in_pixel8 = insert_zero;
				end
				INIT_BUFF: begin
					// first row
					sobel_in_pixel0 = insert_zero;
					sobel_in_pixel1 = insert_zero;
					sobel_in_pixel2 = insert_zero;
					// second row 
					sobel_in_pixel3 = insert_zero;
					sobel_in_pixel4 = insert_zero;
					sobel_in_pixel5 = insert_zero;
					// third row
					sobel_in_pixel6 = insert_zero;
					sobel_in_pixel7 = insert_zero;
					sobel_in_pixel8 = insert_zero;
				end
				SET0: begin // RD: 0,1,2 | WR: 3
					if(curr_row_to_disp == 0) begin
						// first row
						sobel_in_pixel0 = insert_zero;
						sobel_in_pixel1 = insert_zero;
						sobel_in_pixel2 = insert_zero;
						// second row 
						sobel_in_pixel3 = buff1_pixelA;
						sobel_in_pixel4 = buff1_pixelB;
						sobel_in_pixel5 = buff1_pixelC;
						// third row
						sobel_in_pixel6 = buff2_pixelA;
						sobel_in_pixel7 = buff2_pixelB;
						sobel_in_pixel8 = buff2_pixelC;
					end
					else if(curr_row_to_disp == 639) begin
						// first row
						sobel_in_pixel0 = buff0_pixelA;
						sobel_in_pixel1 = buff0_pixelB;
						sobel_in_pixel2 = buff0_pixelC;
						// second row 
						sobel_in_pixel3 = buff1_pixelA;
						sobel_in_pixel4 = buff1_pixelB;
						sobel_in_pixel5 = buff1_pixelC;
						// third row
						sobel_in_pixel6 = insert_zero;
						sobel_in_pixel7 = insert_zero;
						sobel_in_pixel8 = insert_zero;
					end
					else begin
						// first row
						sobel_in_pixel0 = buff0_pixelA;
						sobel_in_pixel1 = buff0_pixelB;
						sobel_in_pixel2 = buff0_pixelC;
						// second row 
						sobel_in_pixel3 = buff1_pixelA;
						sobel_in_pixel4 = buff1_pixelB;
						sobel_in_pixel5 = buff1_pixelC;
						// third row
						sobel_in_pixel6 = buff2_pixelA;
						sobel_in_pixel7 = buff2_pixelB;
						sobel_in_pixel8 = buff2_pixelC;
					end
				end
				SET1: begin // RD: 1,2,3 | WR: 0
					if(curr_row_to_disp == 0) begin
						// first row
						sobel_in_pixel0 = insert_zero;
						sobel_in_pixel1 = insert_zero;
						sobel_in_pixel2 = insert_zero;
						// second row 
						sobel_in_pixel3 = buff2_pixelA;
						sobel_in_pixel4 = buff2_pixelB;
						sobel_in_pixel5 = buff2_pixelC;
						// third row
						sobel_in_pixel6 = buff3_pixelA;
						sobel_in_pixel7 = buff3_pixelB;
						sobel_in_pixel8 = buff3_pixelC;
					end
					else if(curr_row_to_disp == 639) begin
						// first row
						sobel_in_pixel0 = buff1_pixelA;
						sobel_in_pixel1 = buff1_pixelB;
						sobel_in_pixel2 = buff1_pixelC;
						// second row 
						sobel_in_pixel3 = buff2_pixelA;
						sobel_in_pixel4 = buff2_pixelB;
						sobel_in_pixel5 = buff2_pixelC;
						// third row
						sobel_in_pixel6 = insert_zero;
						sobel_in_pixel7 = insert_zero;
						sobel_in_pixel8 = insert_zero;
					end
					else begin
						// first row
						sobel_in_pixel0 = buff1_pixelA;
						sobel_in_pixel1 = buff1_pixelB;
						sobel_in_pixel2 = buff1_pixelC;
						// second row 
						sobel_in_pixel3 = buff2_pixelA;
						sobel_in_pixel4 = buff2_pixelB;
						sobel_in_pixel5 = buff2_pixelC;
						// third row
						sobel_in_pixel6 = buff3_pixelA;
						sobel_in_pixel7 = buff3_pixelB;
						sobel_in_pixel8 = buff3_pixelC;
					end
				end
				SET2: begin // RD: 2,3,0 | WR: 1
					if(curr_row_to_disp == 0) begin
						// first row
						sobel_in_pixel0 = insert_zero;
						sobel_in_pixel1 = insert_zero;
						sobel_in_pixel2 = insert_zero;
						// second row 
						sobel_in_pixel3 = buff3_pixelA;
						sobel_in_pixel4 = buff3_pixelB;
						sobel_in_pixel5 = buff3_pixelC;
						// third row
						sobel_in_pixel6 = buff0_pixelA;
						sobel_in_pixel7 = buff0_pixelB;
						sobel_in_pixel8 = buff0_pixelC;
					end
					else if(curr_row_to_disp == 639) begin
						// first row
						sobel_in_pixel0 = buff2_pixelA;
						sobel_in_pixel1 = buff2_pixelB;
						sobel_in_pixel2 = buff2_pixelC;
						// second row 
						sobel_in_pixel3 = buff3_pixelA;
						sobel_in_pixel4 = buff3_pixelB;
						sobel_in_pixel5 = buff3_pixelC;
						// third row
						sobel_in_pixel6 = insert_zero;
						sobel_in_pixel7 = insert_zero;
						sobel_in_pixel8 = insert_zero;
					end
					else begin
						// first row
						sobel_in_pixel0 = buff2_pixelA;
						sobel_in_pixel1 = buff2_pixelB;
						sobel_in_pixel2 = buff2_pixelC;
						// second row 
						sobel_in_pixel3 = buff3_pixelA;
						sobel_in_pixel4 = buff3_pixelB;
						sobel_in_pixel5 = buff3_pixelC;
						// third row
						sobel_in_pixel6 = buff0_pixelA;
						sobel_in_pixel7 = buff0_pixelB;
						sobel_in_pixel8 = buff0_pixelC;
					end
				end
				SET3: begin // RD: 3,0,1 | WR: 2
					if(curr_row_to_disp == 0) begin
						// first row
						sobel_in_pixel0 = insert_zero;
						sobel_in_pixel1 = insert_zero;
						sobel_in_pixel2 = insert_zero;
						// second row 
						sobel_in_pixel3 = buff0_pixelA;
						sobel_in_pixel4 = buff0_pixelB;
						sobel_in_pixel5 = buff0_pixelC;
						// third row
						sobel_in_pixel6 = buff1_pixelA;
						sobel_in_pixel7 = buff1_pixelB;
						sobel_in_pixel8 = buff1_pixelC;
					end
					else if(curr_row_to_disp == 639) begin
						// first row
						sobel_in_pixel0 = buff3_pixelA;
						sobel_in_pixel1 = buff3_pixelB;
						sobel_in_pixel2 = buff3_pixelC;
						// second row 
						sobel_in_pixel3 = buff0_pixelA;
						sobel_in_pixel4 = buff0_pixelB;
						sobel_in_pixel5 = buff0_pixelC;
						// third row
						sobel_in_pixel6 = insert_zero;
						sobel_in_pixel7 = insert_zero;
						sobel_in_pixel8 = insert_zero;
					end
					else begin
						// first row
						sobel_in_pixel0 = buff3_pixelA;
						sobel_in_pixel1 = buff3_pixelB;
						sobel_in_pixel2 = buff3_pixelC;
						// second row 
						sobel_in_pixel3 = buff0_pixelA;
						sobel_in_pixel4 = buff0_pixelB;
						sobel_in_pixel5 = buff0_pixelC;
						// third row
						sobel_in_pixel6 = buff1_pixelA;
						sobel_in_pixel7 = buff1_pixelB;
						sobel_in_pixel8 = buff1_pixelC;
					end
				end
				default: begin
					// first row
					sobel_in_pixel0 = insert_zero;
					sobel_in_pixel1 = insert_zero;
					sobel_in_pixel2 = insert_zero;
					// second row 
					sobel_in_pixel3 = insert_zero;
					sobel_in_pixel4 = insert_zero;
					sobel_in_pixel5 = insert_zero;
					// third row
					sobel_in_pixel6 = insert_zero;
					sobel_in_pixel7 = insert_zero;
					sobel_in_pixel8 = insert_zero;
				end
			endcase
		end
		// check if buffers are full
		always@(*) begin
			case(conv_state)
				INIT: begin
					buff_done = 0;
				end
				INIT_BUFF: begin
					if(init_curr_buff+1 >= INIT_ROWS && curr_buff_wr_count+1 >= MAX_DISP_COLS)
						buff_done = 1;
					else
						buff_done = 0;
				end
				SET0: begin
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS)
						buff_done = 1;
					else 
						buff_done = 0;
				end
				SET1: begin
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS)
						buff_done = 1;
					else 
						buff_done = 0;
				end
				SET2: begin
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS)
						buff_done = 1;
					else 
						buff_done = 0;
				end
				SET3: begin
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS)
						buff_done = 1;
					else 
						buff_done = 0;
				end
				default: begin
					buff_done = 0;
				end
			endcase
		end
		// conv curr state action and update counter/flags
		always@(posedge clk) begin
			case(conv_state)
				INIT: begin
					// reset everything
					curr_buff_wr_count <= 0;
					curr_row_to_disp <= 0;
					first_conv_done <= 0;
					init_curr_buff <= 2'd0; // start by loading buffer 1 with row0
					vga_rst_req <= 1'b0;
					vga_synced <= 1'b0;
					// vga_reset_req
					// vga_synced
					
					
					rst_buff <= 4'b0000; // use zero fill to reset
					zero_fill_buff <= 4'b1111;
					// all buffs initialized as zero buffs
					// buff0 is ready to be read from (padded 0s)	
				end
				INIT_BUFF: begin
					// assume entering with init_curr_buff = 1
					// assume starting with pixel 0,0
					// once buff_done triggered move onto SET0
					
					// turn off zero_fill/reset
					zero_fill_buff <= 4'b0000;
					// setup buff1 and buff2
					
					/* start counting pixel read in from 0 to 
						determine when to move to next buffer */
					// check if we reached row3 to move on if necessary
					// don't want to lose pixel next cycle
					// if statement just incremented curr_buff_wr_count to 641
					if(init_curr_buff+1 >= INIT_ROWS && curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
					
						// first 2 buffers are ready for primetime
						curr_buff_wr_count <= 0;
						/* will recieve pixel 641 of row 2 AKA pixel 1 of row 3
							next clock cycle */
						// sync up monitor to start outputting processed pixels
						vga_rst_req <= 1'b1;	
					end
					else if(curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						// buffer filled
						// curr_buff_wr_count = 639
						/* need to put next pixel somewhere
						 so as not to lose it */
						 
						// let's load up next buffer
						// move on to loading row2 or exiting if found row3
						init_curr_buff <= init_curr_buff + 1;
						curr_buff_wr_count <= 0;
					end
					else begin
						// still in range
						curr_buff_wr_count <= curr_buff_wr_count + 1;
					end
					
				end
				SET0: begin // RD 0,1,2 | WR: 3
					
					// turn off monitor rst if on
					vga_rst_req <= 1'b0;
					vga_synced <= 1'b1;
					// synced for pixel 0,0 on first entrance
					// curr_row_to_disp = 0 for first entrance
					
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						// on pixel 639
						curr_buff_wr_count <= 0;
						curr_row_to_disp <= curr_row_to_disp + 1;
					end
					else begin
						curr_buff_wr_count <= curr_buff_wr_count + 1;
					end
							
					if(curr_row_to_disp+1 == MAX_DISP_ROWS && curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						first_conv_done <= 1;
						curr_row_to_disp <= 0;
					end

					
				end
				SET1: begin // RD: 1,2,3 | WR: 0
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						// on pixel 639
						curr_buff_wr_count <= 0;
						curr_row_to_disp <= curr_row_to_disp + 1;
					end
					else begin
						curr_buff_wr_count <= curr_buff_wr_count + 1;
					end
							
					if(curr_row_to_disp+1 == MAX_DISP_ROWS && curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						first_conv_done <= 1;
						curr_row_to_disp <= 0;
					end
				end
				SET2: begin // RD: 2,3,0 | WR: 1
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						// on pixel 639
						curr_buff_wr_count <= 0;
						curr_row_to_disp <= curr_row_to_disp + 1;
					end
					else begin
						curr_buff_wr_count <= curr_buff_wr_count + 1;
					end
							
					if(curr_row_to_disp+1 == MAX_DISP_ROWS && curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						first_conv_done <= 1;
						curr_row_to_disp <= 0;
					end
				end
				SET3: begin // RD: 3,0,1 | WR: 2
					if(curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						// on pixel 639
						curr_buff_wr_count <= 0;
						curr_row_to_disp <= curr_row_to_disp + 1;
					end
					else begin
						curr_buff_wr_count <= curr_buff_wr_count + 1;
					end
							
					if(curr_row_to_disp+1 == MAX_DISP_ROWS && curr_buff_wr_count+1 >= MAX_DISP_COLS) begin
						first_conv_done <= 1;
						curr_row_to_disp <= 0;
					end
				end
				default: begin
					curr_buff_wr_count <= 0;
					curr_row_to_disp <= 0;
					first_conv_done <= 0;
					buff_done <= 0;
					init_curr_buff <= 2'd0;
					zero_fill_buff <= 4'b1111;
				end
			endcase
		end

		
		// count time needed to finish edge_detect convolution:
		// FSM for cycle count
		parameter EDGE_OFF = 2'd0;
		parameter ON_CONV = 2'd1;
		parameter ON_FINISH = 2'd2;
		reg [1:0] count_state = EDGE_OFF; 
		reg [1:0] next_count_state;
		reg [18:0] cycle_count = 0;
		reg [9:0] cycle_output = 0;
		reg first_flag = 1;
		// next state progress
		always@(posedge clk) begin
			count_state <= next_count_state;
		end
		// cycle count next state calc
		always@(*) begin
			case(count_state) 
				EDGE_OFF: begin
					if(edge_en)
						next_count_state = ON_CONV;
					else
						next_count_state = EDGE_OFF;
				end
				ON_CONV: begin
					if(~edge_en)
						next_count_state = EDGE_OFF;
					else if(first_conv_done)
						next_count_state = ON_FINISH;
					else
						next_count_state = ON_CONV;
				end
				ON_FINISH: begin
					if(edge_en)
						next_count_state = ON_FINISH;
					else
						next_count_state = EDGE_OFF;
				end
				default: begin
					next_count_state =  EDGE_OFF;
				end
			endcase
		end
		// cycle count state output and calcs
		always@(posedge clk) begin
			case(count_state)
				EDGE_OFF: begin
					cycle_count <= 0;
				end
				ON_CONV: begin
					cycle_count <= cycle_count + 1;
				end
				ON_FINISH: begin
					cycle_count <= cycle_count;
				end
				default: begin
					cycle_count <= cycle_count;
				end
			endcase
		end
		// LED cycles output
		always@(*) begin
			case(count_state)
				EDGE_OFF: begin
					cycle_output = 0;
				end
				ON_CONV: begin
					cycle_output = 0;
				end
				ON_FINISH: begin
					cycle_output = cycle_count[18:9];
				end
				default: begin
					cycle_output = 0;
				end
			endcase
		end
		
		assign cycles = cycle_output;
		
		
		// sync output to vga signals later
		// bypass output when edge_detect off
		// while not synced for reading in row0, col0 and on pixels
		// send out unprocessed data
		// feed done_edge into buffer for display syncing
		assign done_edge_R = (edge_en ) ? edge_out : inter_in_R;
		assign done_edge_G = (edge_en ) ? edge_out : inter_in_G;
		assign done_edge_B = (edge_en ) ? edge_out : inter_in_B;
		
		
		
		
endmodule