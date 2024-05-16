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
	wire           Icontrol1;
	wire           Icontrol2;
	wire           rIenable;
	wire           gIenable;
	wire           bIenable;
	wire           brightLevel;
	wire    [7:0]  raw_VGA_R;
   wire    [7:0]  raw_VGA_G;
   wire    [7:0]  raw_VGA_B;
	reg    [7:0]  reg_raw_VGA_R;
   reg    [7:0]  reg_raw_VGA_G;
   reg    [7:0]  reg_raw_VGA_B;
	wire 	[7:0]  fil_proc_R;
	wire 	[7:0]  fil_proc_G;
	wire 	[7:0]  fil_proc_B;
	reg 	[7:0]  reg_fil_proc_R;
	reg 	[7:0]  reg_fil_proc_G;
	reg 	[7:0]  reg_fil_proc_B;
	wire 	[7:0]  curs_ol__input_R;
	wire 	[7:0]  curs_ol__input_G;
	wire 	[7:0]  curs_ol__input_B;
	reg 	[7:0]  reg_curs_ol__input_R;
	reg 	[7:0]  reg_curs_ol__input_G;
	reg 	[7:0]  reg_curs_ol__input_B;
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
	wire read_flag_R;
	wire read_flag_G;
	wire read_flag_B;
	wire [8:0] rows_written;
	wire [9:0] cols_written;
	
   wire    [7:0]  sCCD_R;
   wire    [7:0]  sCCD_G;
   wire    [7:0]  sCCD_B; 
   wire   [12:0]  x_count,col; 
   wire   [12:0]  y_count,row; 
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


assign RESET_N= 1; 
assign Icontrol1 = SW[1];
assign Icontrol2 = SW[2];
assign Icontrol3 = SW[3];
assign Icontrol4 = SW[4];

// mode assignment {SW[9], SW[8], SW[7]}
// 000 normal operation
// 001 brightLevel
// 010
// 011
// 100
// 101 BLUR
// 110
// 111

// greyscale/contrast enable
assign brightLevel = {~SW[9], ~SW[8], SW[7]};

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

//--- Processes the raw RGB pixel data
RGB_Process p1 (
	.Icontrol1(Icontrol1),
	.Icontrol2(Icontrol2),
	.Icontrol3(Icontrol3),
	.Icontrol4(Icontrol4),
	.brightLevel(brightLevel),
  	.raw_VGA_R(reg_blurred_R),
	.raw_VGA_G(reg_blurred_G),
	.raw_VGA_B(reg_blurred_B),
   .row      (row),
   .col      (col),
   .o_VGA_R  (fil_proc_R),
   .o_VGA_G  (fil_proc_G),
   .o_VGA_B  (fil_proc_B)
);

//--- Module to Handle 5x5 Gaussian Blur (greyscale, only need one input color pixel value bc R=G=B)
blur_5x5 G_R(
	.clk(CLOCK_50),
	.reset(1'b0),
	.en(blur_en),
	.input_pixel(reg_blur_R),
	.rd_flag(read_flag_R),
	.output_pixel(blurred_R),
	.rows_written(rows_written_R),
	.cols_written(cols_written_R)
);

blur_5x5 G_G(
	.clk(CLOCK_50),
	.reset(1'b0), 
	.en(blur_en), 
	.input_pixel(reg_blur_G), 
	.rd_flag(read_flag_G),
	.output_pixel(blurred_G),
	.rows_written(rows_written_G),
	.cols_written(cols_written_G)
);

blur_5x5 G_B(
	.clk(CLOCK_50),
	.reset(1'b0), 
	.en(blur_en), 
	.input_pixel(reg_blur_B), 
	.rd_flag(read_flag_B),
	.output_pixel(blurred_B),
	.rows_written(rows_written_B),
	.cols_written(cols_written_B)
);

//--- Process monitor cursor
cursor c_proc(
	.raw_VGA_R(reg_fil_proc_R), 
	.raw_VGA_G(reg_fil_proc_G),  
	.raw_VGA_B(reg_fil_proc_B),  
	.SW(SW), 
	.KEY(KEY), 
	.col(col), 
	.row(row),
	.CLOCK_50(CLOCK_50), 
	.curs_ol__input_R(curs_ol__input_R), 
	.curs_ol__input_G(curs_ol__input_G), 
	.curs_ol__input_B(curs_ol__input_B)
					);

//--- VGA interface signals ---
assign VGA_CLK    = MIPI_PIXEL_CLK;           // GPIO clk
assign VGA_SYNC_N = 1'b0;
//if greyscale enabled and blur switch high


// orequest signals when an output from the camera is needed
assign orequest = ((x_count > 13'd0160 && x_count < 13'd0800 ) &&
                  ( y_count > 13'd0045 && y_count < 13'd0525));

// this blanking signal is active low
assign VGA_BLANK_N = ~((x_count < 13'd0160 ) || ( y_count < 13'd0045 ));

// connect cursor out direct to VGA
assign VGA_R = reg_curs_ol__input_R;
assign VGA_G = reg_curs_ol__input_G;
assign VGA_B = reg_curs_ol__input_B;

// register module wires
// raw to RGB_Process module
always @ (posedge CLOCK_50) begin
	reg_raw_VGA_R <= raw_VGA_R;
	reg_raw_VGA_G <= raw_VGA_G;
	reg_raw_VGA_B <= raw_VGA_B;
end

always@(posedge CLOCK_50) begin
	reg_fil_proc_R <= fil_proc_R;
	reg_fil_proc_G <= fil_proc_G;
	reg_fil_proc_B <= fil_proc_B;
end

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

always @ (posedge CLOCK_50) begin
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
		reg_blur_R <= raw_VGA_R;
		reg_blur_G <= raw_VGA_G;
		reg_blur_B <= raw_VGA_B;
		end
		if(read_flag_R) begin // if new value ready
			reg_blurred_R <= blurred_R;
		end
		else begin // else old val
			reg_blurred_R <= reg_blurred_R;
		end
		if(read_flag_G) begin // if new value ready
			reg_blurred_G <= blurred_G;
		end
		else begin // else old val
			reg_blurred_G <= reg_blurred_G;
		end
		if(read_flag_B) begin // if new value ready
			reg_blurred_B <= blurred_B;
		end
		else begin // else old val
			reg_blurred_B <= reg_blurred_B;
		end
	end
	else
	begin
		blur_en <= 1'b0;
		reg_blurred_R <= raw_VGA_R;
		reg_blurred_G <= raw_VGA_G;
		reg_blurred_B <= raw_VGA_B;
	end
end
//cursor output to VGA input wires
always @ (posedge CLOCK_50) begin
	reg_curs_ol__input_R <= curs_ol__input_R;
	reg_curs_ol__input_G <= curs_ol__input_G;
	reg_curs_ol__input_B <= curs_ol__input_B;
end
	
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
