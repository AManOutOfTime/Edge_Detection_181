module blur_tb;

    reg clk;
    reg en;
	 reg [7:0] red, green, blue;
    wire flag;
    wire [7:0] red_out, green_out, blue_out;

    // Instantiate the blur_5x5 module
    blur_5x5 blur (
        .clk(clk),
        .en(en),
        .input_pixel_R(red),
		  .input_pixel_G(green),
		  .input_pixel_B(blue),
        .output_pixel_R(red_out),
		  .output_pixel_G(green_out),
		  .output_pixel_B(blue_out),
		  .rd_flag(flag)
    );
	 
	 integer j;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
		  forever j = j + 1;
    end

    // Testbench variables
    integer i;
    reg [7:0] image_data [0:640*480*3-1]; // Assuming a 640x480 image
    reg [7:0] output_image_data [0:640*480*3-1]; // Output image data array

    initial begin
        en = 0;
        // Read BMP file using $readmemh
        $readmemh("input_image.hex", image_data);
        #10
        en = 1;
		end
		initial begin
			for (i = 0; i < 640*480; i = i + 1) begin
            // Input pixel data
				red = image_data[i*3];
            green = image_data[i*3 + 1];
				blue = image_data[i*3 + 2];
			end
		end
		
		initial begin
			if(flag) 
			begin
				for (i = 0; i < 640*480; i = i + 1) 
				begin
            // Capture the output pixel
            output_image_data[i*3] = red_out;
            output_image_data[i*3 + 1] = green_out;
            output_image_data[i*3 + 2] = blue_out;
				end
				
				#100
        
				// Write BMP file using $writememh
				$writememh("output_image.hex", output_image_data);

				$display("Image processing complete.");
				$display("clock cycles: %d", j);
				$stop;
			end
		end
			
endmodule