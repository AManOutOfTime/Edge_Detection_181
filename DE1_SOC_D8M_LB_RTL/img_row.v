// model row save as ram
// write one pixel at a time to line
// size of img is 640x480
// img_row is 640 slots with ea slot being 12 bits for use calc purposes
// need 3 pixels at a time from a row for convolution
// 3 pixel output

// return sequence of bits relative to ea step of convolution
module img_row(
					input zero_fill, // if on fills entire buffer with zeroes
					input clk, 
					input rst, 
					input [7:0] in_data, 
					input wr_en, 
					// every clk increment ptr 
					// and send out new set of adjacent row pixels
					input rd_en,
					
					// returns 3 adjacent row pixels
					output [7:0] pixelA, pixelB, pixelC

					);
					
				
	
	// storage
	// 640 pixels + 2 extra pixels for padding
	reg [7:0] row [1023:0] /* synthesis ramstyle = "no_rw_check, M10K" */; 
	reg [9:0] wr_ptr; // log2(memory_depth)
	reg [9:0] rd_ptr; // log2(memory_depth)
	
	// initialize all val in M10K as 0
	integer i;
	initial begin
		for (i = 0; i < 642; i = i + 1) begin
			row[i] = 8'd0;
		end
		wr_ptr = 10'd1; // prevent padding from being overwritten
		rd_ptr = 10'd0; // allow rd out of padding
	end
	
	// read operation
	// send out adjacent pixels
	assign pixelA = row[rd_ptr];
	assign pixelB = row[rd_ptr+1];
	assign pixelC = row[rd_ptr+2];
	
	// zero fill also does a reset automatically
	// however normal reset takes precedence if both signals HIGH
	// read ptr operation
	always@(posedge clk) begin
		if(rst) begin
			rd_ptr <= 10'd0;
		end
		else if (zero_fill) begin
			rd_ptr <= 10'd0;
		end
		else if(rd_en) begin
			rd_ptr <= rd_ptr + 1; // inc by 1 not 3 so convolution can occur
		end
		else begin
			rd_ptr <= rd_ptr;
		end
	end
	
	// write operation
	always@(posedge clk) begin
	
		// reset logic
		if(rst) begin
			wr_ptr <= 10'd1; // start writing at word 1
		end
		
		// zero fill logic
		else if (zero_fill) begin // fill all storage with zeroes
			for (i = 0; i < 642; i = i + 1) begin
				row[i] <= 8'd0;
			end
			wr_ptr <= 10'd1;
		end
		
		// wr enable logic => write in and ptr update
		else if(wr_en) begin
			// extra protection to protect padding vals
			if (wr_ptr <= 10'd640) begin
				row[wr_ptr] <= in_data;
			end
			if(wr_ptr < 10'd640) begin // protect padding
				wr_ptr <= wr_ptr + 1;
			end
		end
		
		// default behavior
		else begin
			wr_ptr <= wr_ptr;
		end
		
	end
	
	
					
endmodule