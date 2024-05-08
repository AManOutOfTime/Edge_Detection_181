module RGB_Process(
	input  Icontrol1,
	input  Icontrol2,
	input  Icontrol3,
	input  Icontrol4,
	input  brightLevel,
	input  [7:0] raw_VGA_R,
	input  [7:0] raw_VGA_G,
	input  [7:0] raw_VGA_B,
	input  [12:0] row,
	input  [12:0] col,

	output reg [7:0] o_VGA_R,
	output reg [7:0] o_VGA_G,
	output reg [7:0] o_VGA_B
);

  reg [15:0] midpoint =                16'b0000000010000000;
  reg [15:0] redGray =                 16'b0000000000000000;
  reg [15:0] greenGray =               16'b0000000000000000;
  reg [15:0] blueGray =                16'b0000000000000000;
  reg [15:0] intensityTotal =          16'b0000000000000000;
  reg [15:0] intensityTotalNew =       16'b0000000000000000;
  reg [15:0] intensityDiff =           16'b0000000000000000;
  reg [15:0] redAdd =                  16'b0000000000000000;
  reg [15:0] greenAdd =                16'b0000000000000000;
  reg [15:0] blueAdd =                 16'b0000000000000000;
  reg [22:0] calcmIntensity =   23'b00000000000000000000000;
  reg [15:0] meanIntensity =           16'b0000000000000000;

always @(*)begin		 


if (row < 13'd478 && col < 13'd617) begin
	//convert RGB to grayscale
	redGray = ((raw_VGA_R*1063)/5000);
	greenGray = ((raw_VGA_G*447)/625);
	blueGray = ((raw_VGA_B*361)/5000);
	intensityTotal = redGray + greenGray + blueGray;
	//mean intensity calculation
	calcmIntensity = calcmIntensity + intensityTotal;
//	if (row == 13'd477 && col == 13'd616) begin
//		meanIntensity = calcmIntensity / 19'b1000111101111001000;
//	end
	
	meanIntensity = 16'b0000000010000000;
	
	//check intensityTotal against midpoint
	intensityTotalNew = (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd16)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd16)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd17)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd17)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd18)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd18)/16'd16): 
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd19)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd19)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd20)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd20)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd21)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd21)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd22)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd22)/16'd16): 
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd23)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd23)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd24)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd24)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd25)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd25)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd26)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd26)/16'd16): 
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd27)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd27)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd28)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd28)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd29)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd29)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 0 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd30)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd30)/16'd16): 
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 1 && (intensityTotal > meanIntensity))?  (((intensityTotal*16'd31)/16'd16) > 8'b11111111)? 8'b11111111:((intensityTotal*16'd31)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 0)?  (((intensityTotal*16'd16)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd16)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 1)?  (((intensityTotal*16'd15)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd15)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 0)?  (((intensityTotal*16'd14)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd14)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 1)?  (((intensityTotal*16'd13)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd13)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 0)?  (((intensityTotal*16'd12)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd12)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 1)?  (((intensityTotal*16'd11)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd11)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 0)?  (((intensityTotal*16'd10)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd10)/16'd16):
							  (Icontrol4 == 0 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 1)?  (((intensityTotal*16'd9)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd9)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 0)?  (((intensityTotal*16'd8)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd8)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 0 && Icontrol1 == 1)?  (((intensityTotal*16'd7)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd7)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 0)?  (((intensityTotal*16'd6)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd6)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 0 && Icontrol2 == 1 && Icontrol1 == 1)?  (((intensityTotal*16'd5)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd5)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 0)?  (((intensityTotal*16'd4)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd4)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 0 && Icontrol1 == 1)?  (((intensityTotal*16'd3)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd3)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 0)?  (((intensityTotal*16'd2)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd2)/16'd16):
							  (Icontrol4 == 1 && Icontrol3 == 1 && Icontrol2 == 1 && Icontrol1 == 1)?  (((intensityTotal*16'd1)/16'd16) < 8'b00000000)? 8'b00000000:((intensityTotal*16'd1)/16'd16):((intensityTotal*16'd16)/16'd16);
							  
	//find difference between old intensity and new intensity
	o_VGA_R = (brightLevel == 1)? (intensityTotalNew > 8'b11111111)? 8'b11111111:intensityTotalNew:raw_VGA_R;
   o_VGA_G = (brightLevel == 1)? (intensityTotalNew > 8'b11111111)? 8'b11111111:intensityTotalNew:raw_VGA_G;
   o_VGA_B = (brightLevel == 1)? (intensityTotalNew > 8'b11111111)? 8'b11111111:intensityTotalNew:raw_VGA_B;
//	intensityDiff = (intensityTotalNew < intensityTotal)? intensityTotal - intensityTotalNew: intensityTotalNew - intensityTotal;
//	//calculate proportion of change of each channel
//	redAdd = (intensityDiff*1000)/(4000 + 737);
//	greenAdd = (intensityDiff*5000)/(5000 + 1991);
//	blueAdd = (intensityDiff*20)/(260 + 17);
//	o_VGA_R = (brightLevel == 1)? ((raw_VGA_R + redAdd) > 8'b11111111)? 8'b11111111:(raw_VGA_R + redAdd):raw_VGA_R;
//	o_VGA_G = (brightLevel == 1)? ((raw_VGA_G + greenAdd) > 8'b11111111)? 8'b11111111:(raw_VGA_G + greenAdd):raw_VGA_G;
//	o_VGA_B = (brightLevel == 1)? ((raw_VGA_B + blueAdd) > 8'b11111111)? 8'b11111111:(raw_VGA_B + blueAdd):raw_VGA_B;
	
end

else begin //camera out of the range should always be 0
	o_VGA_R = 8'b000000000;
	o_VGA_G = 8'b000000000;
	o_VGA_B = 8'b000000000;

	end
end

endmodule
