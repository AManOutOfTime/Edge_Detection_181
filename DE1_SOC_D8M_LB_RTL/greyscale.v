module greyscale(
		input [7:0] in_R, 
		input [7:0] in_G, 
		input [7:0] in_B, 
		output [7:0] grey
);

	// 16 bit due to multiplication overflow
	wire [15:0] intermediate;
	
	// luminance formula (NTSC formula): greyscale = 0.299*R + 0.587*G + 0.114*B)
	// R: 77/256 = 0.3
	// G: 150/256 = 0.5859375
	// B: 29/256 = 0.11328125
	assign intermediate = (in_R*77) + (in_G*150) + (in_B*29);
	
	// 8 bit value by dividing by 256 = shaving off 8 bits. 
	// 2^8 = 256
	// >> 8 = /256
	assign grey = intermediate[15:8]; 


endmodule