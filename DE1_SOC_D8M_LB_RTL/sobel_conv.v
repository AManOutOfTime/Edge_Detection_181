// assume 3x3 conv
module sobel_conv(
					// values from vga
					// P = 
					// [ 0 1 2 ]
					// [ 3 4 5 ]
					// [ 6 7 8 ]
					// unsigned
					input [7:0] pixel0, 
					input [7:0] pixel1, 
					input [7:0] pixel2, 
					input [7:0] pixel3, 
					input [7:0] pixel4, 
					input [7:0] pixel5, 
					input [7:0] pixel6, 
					input [7:0] pixel7, 
					input [7:0] pixel8, 
					output [7:0] op_val
);
					
					// original bit range of 8 bits: 0to255
					// kernel multiplies by 4 at max so extend to 10 bits: 0to1023
					// kernel utilizes negative values so extend to 11 bit signed: -1024to1023
					wire signed [10:0] Gy, Gx;
					// Gx = P *
					// [ -1 0 +1 ]
					// [ -2 0 +2 ]
					// [ -1 0 +1 ]
				
					// Gy = P *
					// [ -1 -2 -1 ]
					// [  0  0  0 ]
					// [ +1 +2 +1 ]
					
					// vector components
					assign Gx = pixel2 - pixel0 + ((pixel5 - pixel3) << 1) + pixel8 - pixel6;
					assign Gy = pixel6 - pixel0 + ((pixel7 - pixel1) << 1) + pixel8 - pixel2;

					// G = sqrt(Gx^2 + Gy^2)
					// squared values needs 2n bits -> 22 bits
					wire [21:0] Gx2, Gy2;
					wire [22:0] G2_sum;
					
					assign Gx2 = Gx * Gx; // now positive
					assign Gy2 = Gy * Gy; // now positive
					assign G2_sum = Gx2 + Gy2;
					
					// sqrt
					wire [10:0] pre_op_val; // 11 bits for sqrt(22bits
					
					sqrt_approx_23bit sqrt_mod(
						.radicand(G2_sum), 
						.sqrt(pre_op_val)
					);
					
					assign op_val = (pre_op_val>255) ? 8'd255 : pre_op_val[7:0];
					
					endmodule