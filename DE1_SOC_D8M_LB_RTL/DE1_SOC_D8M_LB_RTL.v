//=============================================================================
// This module is the top-level template module for hardware to control a
// camera and VGA video interface.
// 
// 2022/03/02  Written [Ziyuan Dong]
// 2022/05/03  Added HEX ports; Added LED, KEY, SW and HEX logic [Ziyuan Dong]
//=============================================================================

module DE1_SOC_D8M_LB_RTL (
	// remove dumb color pixel testers in conrers
	// remove on switch lighting code

   //--- 50 MHz clock from DE1-SoC board
   input          CLOCK_50,

   //--- 10 Switches
   input    [9:0] SW,

   //--- 4 Push buttons
   input    [3:0] KEY,
 
   //--- 10 LEDs
   output   [9:0] LEDR,

   //--- 6 7-segment hexadecimal displays
   output   [7:0] HEX0,                 // seven segment digit 0
   output   [7:0] HEX1,                 // seven segment digit 1
   output   [7:0] HEX2,                 // seven segment digit 2
   output   [7:0] HEX3,                 // seven segment digit 3
   output   [7:0] HEX4,                 // seven segment digit 4
   output   [7:0] HEX5,                 // seven segment digit 5

   //--- VGA    
   output         VGA_BLANK_N,
   output  [7:0]  VGA_B,
   output         VGA_CLK,              // 25 MHz derived from MIPI_PIXEL_CLK
   output  [7:0]  VGA_G,
   output reg     VGA_HS,
   output  [7:0]  VGA_R,
   output         VGA_SYNC_N,
   output reg     VGA_VS,

   //--- GPIO_1, GPIO_1 connect to D8M-GPIO 
   inout          CAMERA_I2C_SCL,
   inout          CAMERA_I2C_SDA,
   output         CAMERA_PWDN_n,
   output         MIPI_CS_n,
   inout          MIPI_I2C_SCL,
   inout          MIPI_I2C_SDA,
   output         MIPI_MCLK,            // unknown use
   input          MIPI_PIXEL_CLK,       // 25 MHz clock from camera
   input   [9:0]  MIPI_PIXEL_D,
   input          MIPI_PIXEL_HS,   
   input          MIPI_PIXEL_VS,
   output         MIPI_REFCLK,          // 20 MHz from video_pll.v
   output         MIPI_RESET_n
);

//=============================================================================
// reg and wire declarations
//=============================================================================


	wire           orequest;
   wire           VGA_CLK_25M;
   wire           RESET_N; 
	reg				mon_reset;
	wire           Icontrol1;
	wire           Icontrol2;
	wire           rIenable;
	wire           gIenable;
	wire           bIenable;
	wire           brightLevel;
	wire				edge_en, blur_5x5_en, blur_11x11_en;
	wire    [7:0]  raw_VGA_R;
   wire    [7:0]  raw_VGA_G;
   wire    [7:0]  raw_VGA_B;
	wire	  [7:0]  test_hex; // enable states
//	assign HEX0 = test_hex; // enable states
//	wire [7:0] hex_sync, hex_next_sync, hex_conv, hex_next_conv;
//	assign HEX1 = hex_sync;
//	assign HEX2 = hex_next_sync;
//	assign HEX3 = hex_conv;
//	assign HEX4 = hex_next_conv;

	wire 	[7:0]  fil_proc_R;
	wire 	[7:0]  fil_proc_G;
	wire 	[7:0]  fil_proc_B;
	reg 	[7:0]  reg_fil_proc_R;
	reg 	[7:0]  reg_fil_proc_G;
	reg 	[7:0]  reg_fil_proc_B;
	wire 	[7:0]  curs_ol__input_R;
	wire 	[7:0]  curs_ol__input_G;
	wire 	[7:0]  curs_ol__input_B;
	wire [7:0] in_blur_R;
	wire [7:0] in_blur_G;
	wire [7:0] in_blur_B;
	wire [7:0] blurred_R;
	wire [7:0] blurred_G;
	wire [7:0] blurred_B;
	reg [7:0] reg_blur_R;
	reg [7:0] reg_blur_G;
	reg [7:0] reg_blur_B;
	reg [7:0] reg_blurred_R;
	reg [7:0] reg_blurred_G;
	reg [7:0] reg_blurred_B;
	wire [7:0] 	 blur_output;
	reg  [7:0]   reg_blur_input, reg_blur_output;
	reg	blur_en; 
	wire [8:0] rows_written;
	wire [9:0] cols_written;
	// inputs to edge.v
	reg [7:0] input_edge_R;
	reg [7:0] input_edge_G;
	reg [7:0] input_edge_B;
	// outputs of edge.v
	wire [7:0] edged_R;
	wire [7:0] edged_G;
	wire [7:0] edged_B;
	wire [9:0] cycle_count;
	
	
   wire    [7:0]  sCCD_R;
   wire    [7:0]  sCCD_G;
   wire    [7:0]  sCCD_B; 
   wire   [12:0]  x_count,col; 
   wire   [12:0]  y_count,row; 
	
//	reg [25:0] sec_counter = 0;
//	reg slow_clk;
//	reg [11:0] sample_cols, sample_rows;
//	always@(posedge CLOCK_50) begin
//		if(sec_counter[25] == 1'b1) begin
//			slow_clk <= 1'b1;
//			sec_counter <= sec_counter + 1;
//		end
//		else begin
//			slow_clk <= 1'b0;
//			sec_counter <= sec_counter + 1;
//		end
//	end
	
//	always@(posedge slow_clk) begin
//		sample_cols <= col[11:0];
//		sample_rows <= row[11:0];
//	end
//	
//	wire [3:0] dig0 = sample_cols[3:0];
//	wire [3:0] dig1 = sample_cols[7:4];
//	wire [3:0] dig2 = sample_cols[11:8];
//	wire [3:0] dig3 = sample_rows[3:0];
//	wire [3:0] dig4 = sample_rows[7:4];
//	wire [3:0] dig5 = sample_rows[11:8];
//	
//	seven_seg hex0(.in(dig0), .seg(HEX0));
//	seven_seg hex1(.in(dig1), .seg(HEX1));
//	seven_seg hex2(.in(dig2), .seg(HEX2));
//	seven_seg hex3(.in(dig3), .seg(HEX3));
//	seven_seg hex4(.in(dig4), .seg(HEX4));
//	seven_seg hex5(.in(dig5), .seg(HEX5));


	assign HEX0 = test_hex;
	
   wire           I2C_RELEASE ;  
   wire           CAMERA_I2C_SCL_MIPI; 
   wire           CAMERA_I2C_SCL_AF;
   wire           CAMERA_MIPI_RELAESE;
   wire           MIPI_BRIDGE_RELEASE;
  
   wire           LUT_MIPI_PIXEL_HS;
   wire           LUT_MIPI_PIXEL_VS;
   wire    [9:0]  LUT_MIPI_PIXEL_D;

//=======================================================
// Main body of code
//=======================================================

assign  LUT_MIPI_PIXEL_HS = MIPI_PIXEL_HS;
assign  LUT_MIPI_PIXEL_VS = MIPI_PIXEL_VS;
assign  LUT_MIPI_PIXEL_D  = MIPI_PIXEL_D ;


assign RESET_N = ~mon_reset; // 1'b1 
assign Icontrol1 = SW[1];
assign Icontrol2 = SW[2];
assign Icontrol3 = SW[3];
assign Icontrol4 = SW[4];

// mode assignment {SW[9], SW[8], SW[7]}
// 000 normal operation
// 001 brightLevel (greyscale/contrast)
// 010 
// 011 IMAGE SHARPEN
// 100 BLUR 5x5
// 101 BLUR 11x11
// 110 EDGE DETECT
// 111 DIGITAL ZOOM

// count convolution cycles, output range of 523776 to 512
assign LEDR = cycle_count;

// greyscale/contrast enable
assign brightLevel = (~SW[9] && ~SW[8] && SW[7]);
// EDGE DETECT enable
assign edge_en = (SW[9] && SW[8] && ~SW[7]);
// BLUR 5x5
assign blur_5x5_en = {SW[9] && ~SW[8] && ~SW[7]};
// BLUR 11x11
assign blur_11x11_en = {SW[9] && ~SW[8] && SW[7]};
// orequest sync
wire o_sync;
assign o_sync = {edge_en || blur_5x5_en || blur_11x11_en};


assign MIPI_RESET_n   = RESET_N;
assign CAMERA_PWDN_n  = RESET_N; 
assign MIPI_CS_n      = 1'b0; 


//------ MIPI BRIDGE  I2C SETTING--------------- 
MIPI_BRIDGE_CAMERA_Config cfin(
   .RESET_N           ( RESET_N ), 
   .CLK_50            ( CLOCK_50), 
   .MIPI_I2C_SCL      ( MIPI_I2C_SCL ), 
   .MIPI_I2C_SDA      ( MIPI_I2C_SDA ), 
   .MIPI_I2C_RELEASE  ( MIPI_BRIDGE_RELEASE ),
   .CAMERA_I2C_SCL    ( CAMERA_I2C_SCL ),
   .CAMERA_I2C_SDA    ( CAMERA_I2C_SDA ),
   .CAMERA_I2C_RELAESE( CAMERA_MIPI_RELAESE )
);
 
//-- Video PLL --- 
video_pll MIPI_clk(
   .refclk   ( CLOCK_50 ),                    // 50MHz clock 
   .rst      ( 1'b0 ),     
   .outclk_0 ( MIPI_REFCLK )                  // 20MHz clock
);

//--- D8M RAWDATA to RGB ---
D8M_SET   ccd (
   .RESET_SYS_N  ( RESET_N ),
   .CLOCK_50     ( CLOCK_50 ),
   .CCD_DATA     ( LUT_MIPI_PIXEL_D [9:0]),
   .CCD_FVAL     ( LUT_MIPI_PIXEL_VS ),       // 60HZ
   .CCD_LVAL     ( LUT_MIPI_PIXEL_HS ),        
   .CCD_PIXCLK   ( MIPI_PIXEL_CLK),           // 25MHZ from camera
   .READ_EN      (orequest),
   .VGA_HS       ( VGA_HS ),
   .VGA_VS       ( VGA_VS ),
   .X_Cont       ( x_count),
   .Y_Cont       ( y_count), 
   .sCCD_R       ( raw_VGA_R ),
   .sCCD_G       ( raw_VGA_G ),
   .sCCD_B       ( raw_VGA_B )
);

reg pipe1_orequest;
// pipeline stage 1
always@(posedge VGA_CLK) begin
	if(o_sync) begin
		if(orequest) begin
			pipe1_orequest <= orequest;
			input_edge_R <= raw_VGA_R;
			input_edge_G <= raw_VGA_G;
			input_edge_B <= raw_VGA_B;
		end
	end
	else begin
		input_edge_R <= raw_VGA_R;
		input_edge_G <= raw_VGA_G;
		input_edge_B <= raw_VGA_B;
	end
end

wire pipe2_orequest;
wire firs_pix;
// edge detection
edge_detect edger(
	.firs_pix(firs_pix),
	.x(x_count),
	.y(y_count),
	.clk(VGA_CLK),
	.in_R(input_edge_R), 
	.edge_R_out(edged_R),
	.in_G(input_edge_G), 
	.edge_G_out(edged_G),
	.in_B(input_edge_B), 
	.edge_B_out(edged_B),
	.edge_en(edge_en),
	.cycles(cycle_count),
	.vga_reset(),
	.oreq(pipe2_orequest),
	.valid_pixel(pipe1_orequest),
	.hex(test_hex)
//	.hex_sync_state(hex_sync),
//	.hex_next_sync_state(hex_next_sync),
//	.hex_conv_state(hex_conv),
//	.hex_next_conv_state(hex_next_conv)
	
);	

reg pipe3_firs_pix;
reg pipe3_orequest;
reg [7:0] reg_edged_R, reg_edged_B, reg_edged_G;
// pipeline stage 2
always@(posedge VGA_CLK) begin
	if(o_sync) begin
		if(pipe2_orequest) begin
			if(firs_pix)
				pipe3_firs_pix <= firs_pix;
			pipe3_orequest <= pipe2_orequest;
			reg_edged_R <= edged_R;
			reg_edged_G <= edged_G;
			reg_edged_B <= edged_B;
		end
	end
	else begin
		reg_edged_R <= edged_R;
		reg_edged_G <= edged_G;
		reg_edged_B <= edged_B;
	end
end

//--- Processes the raw RGB pixel data
RGB_Process p1 (
	.Icontrol1(Icontrol1),
	.Icontrol2(Icontrol2),
	.Icontrol3(Icontrol3),
	.Icontrol4(Icontrol4),
	.brightLevel(brightLevel),
  	.raw_VGA_R(reg_edged_R),
	.raw_VGA_G(reg_edged_G),
	.raw_VGA_B(reg_edged_B),
   .row      (row),
   .col      (col),
   .o_VGA_R  (fil_proc_R),
   .o_VGA_G  (fil_proc_G),
   .o_VGA_B  (fil_proc_B)
);

reg pipe4_firs_pix;
reg pipe4_orequest;
// pipeline stage 3
always@(posedge VGA_CLK) begin
	if(o_sync) begin
		if(pipe3_orequest) begin
			if(pipe3_firs_pix)
				pipe4_firs_pix <= pipe3_firs_pix;
			pipe4_orequest <= pipe3_orequest;
			reg_fil_proc_R <= fil_proc_R;
			reg_fil_proc_G <= fil_proc_G;
			reg_fil_proc_B <= fil_proc_B;
		end
	end
	else begin
		reg_fil_proc_R <= fil_proc_R;
		reg_fil_proc_G <= fil_proc_G;
		reg_fil_proc_B <= fil_proc_B;
	end
end


//--- Process monitor cursor
cursor c_proc(
	.raw_VGA_R(reg_fil_proc_R), 
	.raw_VGA_G(reg_fil_proc_G),  
	.raw_VGA_B(reg_fil_proc_B),  
	.SW(SW), 
	.KEY(KEY), 
	.col(col), 
	.row(row),
	.CLOCK_50(VGA_CLK), 
	.curs_ol__input_R(curs_ol__input_R), 
	.curs_ol__input_G(curs_ol__input_G), 
	.curs_ol__input_B(curs_ol__input_B)
					);
					
reg pipe5_firs_pix;
reg pipe5_orequest;		
reg 	[7:0]  reg_curs_ol__input_R;
reg 	[7:0]  reg_curs_ol__input_G;
reg 	[7:0]  reg_curs_ol__input_B;
//cursor output to VGA input wires
// pipeline stage 4
always @ (posedge VGA_CLK) begin
	if(o_sync) begin
		if(pipe4_orequest) begin
			if(pipe4_firs_pix)
				pipe5_firs_pix <= pipe4_firs_pix;
			pipe5_orequest <= pipe4_orequest;
			reg_curs_ol__input_R <= curs_ol__input_R;
			reg_curs_ol__input_G <= curs_ol__input_G;
			reg_curs_ol__input_B <= curs_ol__input_B;
		end
	end
	else begin
		reg_curs_ol__input_R <= curs_ol__input_R;
		reg_curs_ol__input_G <= curs_ol__input_G;
		reg_curs_ol__input_B <= curs_ol__input_B;
	end
end

reg [7:0] interm_R, interm_G, interm_B;
always@(posedge VGA_CLK) begin
	interm_R <= reg_curs_ol__input_R;
	interm_G <= reg_curs_ol__input_G;
	interm_B <= reg_curs_ol__input_B;
end

reg active = 1'b0;
reg [1:0] firs_pix_state, next_firs_pix_state;
always@(posedge VGA_CLK) begin
	firs_pix_state <= next_firs_pix_state;
end
// calc next state
always@(*) begin
	if(o_sync) begin
		case(firs_pix_state)
			2'd0: begin // OFF
				if(pipe5_firs_pix && pipe5_orequest)
					next_firs_pix_state = 2'd2;
				else if(pipe5_orequest)
					next_firs_pix_state = 2'd1;
				else
					next_firs_pix_state = 2'd0;
			end
			2'd1: begin // IDLE
				if(pipe5_firs_pix)
					next_firs_pix_state = 2'd2;
				else if(pipe5_orequest)
					next_firs_pix_state = 2'd1;
				else
					next_firs_pix_state = 2'd0;
			end
			2'd2: begin // ACTIVE
				if(pipe5_orequest)
					next_firs_pix_state = 2'd2;
				else
					next_firs_pix_state = 2'd0;
			end
			default: begin
				next_firs_pix_state = 2'd0;
			end
		endcase
	end
	else
		next_firs_pix_state = 2'd0;
end
always@(*) begin
	if(o_sync) begin
		case(firs_pix_state)
			2'd0: active = 1'b0;
			2'd1: active = 1'b0;
			2'd2: active = 1'b1;
			default: active = 1'b0;
		endcase
	end
	else
		active = 1'b0;
end

reg display_ready = 1'b0;
reg [1:0] disp_state, next_disp_state;
always@(posedge VGA_CLK) begin
	disp_state <= next_disp_state;
end
always@(*) begin
	if(o_sync) begin
		case(disp_state)
			2'd0: begin // OFF 
				if(active) begin
					next_disp_state = 2'd1;
				end
				else
					next_disp_state = 2'd0;
			end
			2'd1: begin // MON_RESET
				if(~active)
					next_disp_state = 2'd0;
				else
					next_disp_state = 2'd2;
			end
			2'd2: begin // OUTPUT
				if(~active)
					next_disp_state = 2'd0;
				else
					next_disp_state = 2'd2;
			end
			default:
				next_disp_state = 2'd0;
		endcase
	end
	else
		next_disp_state = 2'd0;
end
always@(*) begin // disp_ready and mon_reset
	if(o_sync) begin
		case(disp_state)
			2'd0: begin
				mon_reset = 0;
				display_ready = 0;
			end
			2'd1: begin
				mon_reset = 1;
				display_ready = 0;
			end
			2'd2: begin
				mon_reset = 0;
				display_ready = 1;
			end
			default: begin
				mon_reset = 0;
				display_ready = 0;
			end
		endcase
	end
	else
		mon_reset = 0;
		display_ready = 0;
end

wire read_flag;
assign read_flag = (display_ready && orequest);

wire [23:0] fifo_wr_in, fifo_rd_out;
assign fifo_wr_in = {interm_R, interm_G, interm_B};
assign VGA_R = (o_sync) ? fifo_rd_out[23:16] : reg_curs_ol__input_R;
assign VGA_G = (o_sync) ? fifo_rd_out[15:8]  : reg_curs_ol__input_G;
assign VGA_B = (o_sync) ? fifo_rd_out[7:0]   : reg_curs_ol__input_B;
asyn_fifo_2048 slow(
	.data(fifo_wr_in),
	.clock(VGA_CLK),
	.rdreq(read_flag),
	.wrreq(active),
	.q(fifo_rd_out),
	.empty(),
	.full()
);

// connect cursor out direct to VGA
//assign VGA_R = reg_curs_ol__input_R;
//assign VGA_G = reg_curs_ol__input_G;
//assign VGA_B = reg_curs_ol__input_B;
					
//--- Module to Handle 5x5 Gaussian Blur (greyscale, only need one input color pixel value bc R=G=B)
// blur module inputs
// CLOCK_50
// reset
// enable
// inputR
// inputG
// inputB
// ready_flag
// output_pixel

/*
blur_5x5 blur(
	.clk(VGA_CLK), 
	.en(blur_en),
	.input_pixel_R(reg_blur_R),
	.input_pixel_G(reg_blur_G),
	.input_pixel_B(reg_blur_B),
	.output_pixel_R(blurred_R), 
	.output_pixel_G(blurred_G),
	.output_pixel_B(blurred_B),
	.rd_flag(read_flag)
);
*/


		

		








//--- VGA interface signals ---
// VGA CLK = MIPI PIXEL CLK
assign VGA_CLK    = MIPI_PIXEL_CLK;           // GPIO clk
assign VGA_SYNC_N = 1'b0;
//if greyscale enabled and blur switch high


// orequest signals when an output from the camera is needed
assign orequest = ((x_count > 13'd0160 && x_count < 13'd0800 ) &&
                  ( y_count > 13'd0045 && y_count < 13'd0525));

// this blanking signal is active low
assign VGA_BLANK_N = ~((x_count < 13'd0160 ) || ( y_count < 13'd0045 ));

// removed reg from curs_ol_input below

/*
wire [23:0] fifo_wr_in, fifo_rd_out;
assign fifo_wr_in = {curs_ol__input_R, curs_ol__input_G, curs_ol__input_B};
assign VGA_R = edge_en ? fifo_rd_out[23:16] : curs_ol__input_R;
assign VGA_G = edge_en ? fifo_rd_out[15:8]  : curs_ol__input_G;
assign VGA_B = edge_en ? fifo_rd_out[7:0]   : curs_ol__input_B;
asyn_fifo slow(
	.data(fifo_wr_in),
	.rdclk(VGA_CLK),
	.rdreq(edge_en),
	.wrclk(VGA_CLK),
	.wrreq(edge_en),
	.q(fifo_rd_out),
	.rdempty(),
	.wrfull()
);
*/





// connect output of edge to blur
//assign in_blur_R = reg_edged_R;
//assign in_blur_G = reg_edged_G;
//assign in_blur_B = reg_edged_B;


// register module wires
// raw to RGB_Process module






////blur output to reg
//always @(posedge CLOCK_50)
//begin
//	if(read_flag)
//	begin
//		reg_blur_output <= blur_output;
//	end
//	else
//	begin
//		reg_blur_output <= 0;
//	end
//end

//RGB_Process output to cursor module input
/*
always @ (posedge VGA_CLK) begin
	if(SW[9] && ~SW[8] && SW[7])
	begin
		//deal with 0's padding on inputs for 2 rows and two cols
		blur_en <= 1'b1;
		if((((0 <= rows_written) && (rows_written < 2)) || ((482 < rows_written) && (rows_written <= 484))) || 
		(((0 <= cols_written) && (cols_written < 2)) || ((642 < cols_written) && (cols_written <= 644))))
		begin
		reg_blur_R <= 8'b0;
		reg_blur_G <= 8'b0;
		reg_blur_B <= 8'b0;
		end
		else
		begin
		reg_blur_R <= in_blur_R;
		reg_blur_G <= in_blur_G;
		reg_blur_B <= in_blur_B;
		end
		if(read_flag) begin // if new value ready
			reg_blurred_R <= blurred_R;
		end
		else begin // else old val
			reg_blurred_R <= reg_blurred_R;
		end
		if(read_flag) begin // if new value ready
			reg_blurred_G <= blurred_G;
		end
		else begin // else old val
			reg_blurred_G <= reg_blurred_G;
		end
		if(read_flag) begin // if new value ready
			reg_blurred_B <= blurred_B;
		end
		else begin // else old val
			reg_blurred_B <= reg_blurred_B;
		end
	end
	else
	begin
		blur_en <= 1'b0;
		reg_blurred_R <= in_blur_R;
		reg_blurred_G <= in_blur_G;
		reg_blurred_B <= in_blur_B;
	end
end
*/
	
// generate the horizontal and vertical sync signals
always @(*) begin
   if ((x_count >= 13'd0002 ) && ( x_count <= 13'd0097))
      VGA_HS = 1'b0;
   else
      VGA_HS = 1'b1;

   if ((y_count >= 13'd0013 ) && ( y_count <= 13'd0014))
      VGA_VS = 1'b0;
   else
      VGA_VS = 1'b1;
end

// calculate col and row as an offset from the x and y counter values
assign col = x_count - 13'd0164;
assign row = y_count - 13'd0047;

endmodule
