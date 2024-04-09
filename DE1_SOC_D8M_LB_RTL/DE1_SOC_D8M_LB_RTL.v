//=============================================================================
// This module is the top-level template module for hardware to control a
// camera and VGA video interface.
// 
// 2022/03/02  Written [Ziyuan Dong]
// 2022/05/03  Added HEX ports; Added LED, KEY, SW and HEX logic [Ziyuan Dong]
//=============================================================================

module DE1_SOC_D8M_LB_RTL (

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
//parameters for cursor control
parameter H_LIMIT = 478;
parameter V_LIMIT = 617;
parameter VELOCITY = 2;
parameter R = 4;
parameter LENGTH = 5;
//=============================================================================
// reg and wire declarations
//=============================================================================
   wire           orequest;
   wire    [7:0]  raw_VGA_R;
   wire    [7:0]  raw_VGA_G;
   wire    [7:0]  raw_VGA_B;

   wire           VGA_CLK_25M;
   wire           RESET_N; 
	wire           Icontrol1;
	wire           Icontrol2;
	wire           rIenable;
	wire           gIenable;
	wire           bIenable;
	wire           brightLevel;
	reg 	[21:0] count = 0;
	reg 	       c_clk;
	wire	[7:0]  final_VGA_R;
	wire	[7:0]  final_VGA_G;
	wire	[7:0]  final_VGA_B;
	reg 	[7:0]  input_R;
	reg 	[7:0]  input_G;
	reg 	[7:0]  input_B;
	reg 	[7:0]  next_input_R;
	reg 	[7:0]  next_input_G;
	reg 	[7:0]  next_input_B;
	// cursor bounds
	reg   signed	[12:0] c_top = 13'd0318;
	reg   signed   [12:0] c_bottom = 13'd0322;
	reg   signed   [12:0] c_right = 13'd0242;
	reg 	signed   [12:0] c_left = 13'd0238;
	// plus center
	wire 	 [12:0] c_row;
	wire 	 [12:0] c_col;
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

// calculate plus cursor center
assign c_row = (c_left + c_right) >> 1; 
assign c_col = (c_top + c_bottom) >> 1; 

// final colors to input to the monitor (unless its part of the cursor)
assign	final_VGA_R = raw_VGA_R;
assign	final_VGA_G = raw_VGA_G;
assign	final_VGA_B = raw_VGA_B;

assign RESET_N= ~SW[0]; 
assign Icontrol1 = SW[1];
assign Icontrol2 = SW[2];
assign bIenable = SW[3];
assign gIenable = SW[4];
assign rIenable = SW[5];
assign brightLevel = SW[6];

assign MIPI_RESET_n   = RESET_N;
assign CAMERA_PWDN_n  = RESET_N; 
assign MIPI_CS_n      = 1'b0; 

//--- Turn on LED[0] when SW[9] up
assign LEDR[0] = SW[9];

//--- Turn on HEX0[0] when KEY[3] pressed
assign  HEX0[0] = KEY[3];

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
	.rIenable(rIenable),
	.gIenable(gIenable),
	.bIenable(bIenable),
	.brightLevel(brightLevel),
  	.raw_VGA_R(input_R),
	.raw_VGA_G(input_G),
	.raw_VGA_B(input_B),
   .row      (row),
   .col      (col),
   .o_VGA_R  (VGA_R),
   .o_VGA_G  (VGA_G),
   .o_VGA_B  (VGA_B)
);

//--- VGA interface signals ---
assign VGA_CLK    = MIPI_PIXEL_CLK;           // GPIO clk
assign VGA_SYNC_N = 1'b0;

// orequest signals when an output from the camera is needed
assign orequest = ((x_count > 13'd0160 && x_count < 13'd0800 ) &&
                  ( y_count > 13'd0045 && y_count < 13'd0525));

// this blanking signal is active low
assign VGA_BLANK_N = ~((x_count < 13'd0160 ) || ( y_count < 13'd0045 ));
	
// cursor color control
always @ (*)
begin
	if(SW[9]) 
	begin
		next_input_R = final_VGA_R;
		next_input_G = final_VGA_G;
		next_input_B = final_VGA_B;
	end
	else
	begin
		// plus for cursor
		// horizontal
		if((col == c_col) && (row >= c_row - LENGTH/2) && (row <= c_row + LENGTH/2))
		begin
			next_input_R = 8'd255;
			next_input_G = 8'd0;
			next_input_B = 8'd255;
		end
		//vertical
		else if((row == c_row) && (col >= c_col - LENGTH/2) && (col <= c_col + LENGTH/2))
		begin
			next_input_R = 8'd255;
			next_input_G = 8'd0;
			next_input_B = 8'd255;
		end
		else
		begin
			next_input_R = final_VGA_R;
			next_input_G = final_VGA_G;
			next_input_B = final_VGA_B;
		end
	end		
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
	if(~KEY[3]) 
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
	if(~KEY[2])
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
	if(~KEY[1])
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
	if(~KEY[0])
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
end

// color state control
always @ (posedge CLOCK_50)
begin
	input_R <= #1 next_input_R;
	input_G <= #1 next_input_G;
	input_B <= #1 next_input_B;
end
// calculate col and row as an offset from the x and y counter values
assign col = x_count - 13'd0164;
assign row = y_count - 13'd0047;

endmodule
