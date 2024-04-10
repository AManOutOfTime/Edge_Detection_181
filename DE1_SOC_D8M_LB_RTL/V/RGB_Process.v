module RGB_Process(
	input  Icontrol1,
	input  Icontrol2,
	input  rIenable,
	input  gIenable,
	input  bIenable,
	input  brightLevel,
	input  clk_slow,
	input  [7:0] raw_VGA_R,
	input  [7:0] raw_VGA_G,
	input  [7:0] raw_VGA_B,
	input  [12:0] row,
	input  [12:0] col,

	output reg [7:0] o_VGA_R,
	output reg [7:0] o_VGA_G,
	output reg [7:0] o_VGA_B
);

  reg [7:0] midpoint =           8'b10000000;
  reg [7:0] redGray =            8'b00000000;
  reg [7:0] greenGray =          8'b00000000;
  reg [7:0] blueGray =           8'b00000000;
  reg [7:0] intensityTotal =     8'b00000000;
  reg [7:0] intensityTotalNew =  8'b00000000;
  reg [7:0] intensityDiff =      8'b00000000;
  reg [7:0] redAdd =             8'b00000000;
  reg [7:0] greenAdd =           8'b00000000;
  reg [7:0] blueAdd =            8'b00000000;
  int dFactor;
  int iFactor;
//reg [15:0] square_width = 8;
//reg [15:0] square_height = 8;
//reg [15:0] center_row;
//reg [15:0] center_col;
//reg [15:0] square_top;
//reg [15:0] square_bottom;
//reg [15:0] square_left;
//reg [15:0] square_right;

always @(*)begin

//	center_row = 240; 
//   center_col = 320;
//	square_top = center_row - (square_height >> 1);
//   square_bottom = center_row + (square_height >> 1);
//   square_left = center_col - (square_width >> 1);
//   square_right = center_col + (square_width >> 1);
dFactor = (Icontrol2 == 0 && Icontrol1 == 0)? 14/16:
          (Icontrol2 == 0 && Icontrol1 == 1)? 12/16:
			 (Icontrol2 == 1 && Icontrol1 == 0)? 10/16:
			 (Icontrol2 == 1 && Icontrol1 == 1)? 8/16:1;
			 
iFactor = (Icontrol2 == 0 && Icontrol1 == 0)? 16/16:
          (Icontrol2 == 0 && Icontrol1 == 1)? 18/16:
			 (Icontrol2 == 1 && Icontrol1 == 0)? 20/16:
			 (Icontrol2 == 1 && Icontrol1 == 1)? 22/16:1;			 
			 

if (row >= 13'd0 && row < 13'd5 && col>=13'd0 && col < 13'd5) begin ///up left - red 
	o_VGA_R = 8'b11111111;
	o_VGA_G = 8'b00000000;
	o_VGA_B = 8'b00000000;
end

else if (row >= 13'd0 && row < 13'd5 && col>=13'd613 && col < 13'd617) begin //up right - Green 
	o_VGA_R = 8'b00000000;
	o_VGA_G = 8'b11111111;
	o_VGA_B = 8'b00000000;

end

else if (row >= 13'd474 && row < 13'd478 && col>=13'd0 && col < 13'd5) begin //bottom left - Blue
	o_VGA_R = 8'b00000000;
	o_VGA_G = 8'b00000000;
	o_VGA_B = 8'b11111111;
	
end

	
//else if (row >= square_top && row <= square_bottom && col >= square_left && col <= square_right) begin
//      o_VGA_R   = 8'h00;
//      o_VGA_G = 8'hff;
//      o_VGA_B  = 8'h00;
//end

else if (row < 13'd478 && col < 13'd617) begin
	//convert RGB to grayscale
	redGray = raw_VGA_R*(.2126);
	greenGray = raw_VGA_G*(.7152);
	blueGray = raw_VGA_B*(.0722);
	intensityTotal = redGray + greenGray + blueGray;
	//check intensityTotal against midpoint
	intensityTotalNew = (intensityTotal < midpoint)? (intensityTotal*dFactor):(intensityTotal*iFactor);
	//find difference between old intensity and new intensity
	intensityDiff = (intensityTotalNew < intensityTotal) intensityTotal - intensityTotalNew: intensityTotalNew - intensityTotal;
	//calculate proportion of change of each channel
	redAdd = intensityDiff/4.7037;
	greenAdd = intensityDiff/1.3982;
	blueAdd = intensityDiff/13.85;
	raw_VGA_R = (brightLevel == 1)? raw_VGA_R + redAdd:raw_VGA_R;
	raw_VGA_G = (brightLevel == 1)? raw_VGA_G + greenAdd:raw_VGA_G;
	raw_VGA_B = (brightLevel == 1)? raw_VGA_B + blueAdd:raw_VGA_B;
	
end

else begin //camera out of the range should always be 0
	o_VGA_R = 8'b000000000;
	o_VGA_G = 8'b000000000;
	o_VGA_B = 8'b000000000;

	end
end


////cursor controller
//always @(posedge clk_slow) begin
//	if (cursRight) begin
//		square_right <= square_right + 4;
//		square_left <= square_left + 4;
//		
//    end 
//	 else if (cursLeft) begin
//		square_right <= square_right - 4;
//		square_left <= square_left - 4;
//	end 
//	else if (cursDown) begin
//		square_top <= square_top + 4;
//      square_bottom <= square_bottom + 4;
//	end 
//	else if (cursUp) begin
//		square_top <= square_top - 4;
//      square_bottom <= square_bottom - 4;
//	end
//	else begin
//		square_right <= square_right;
//		square_left <= square_left;
//		square_top <= square_top;
//		square_bottom <= square_bottom;
//	end
//end

endmodule
