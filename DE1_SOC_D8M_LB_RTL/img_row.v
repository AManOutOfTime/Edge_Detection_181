// model row save as ram
// write one pixel at a time to line
// size of img is 640x480
// img_row is 640 slots with ea slot being 12 bits for use calc purposes
// need 3 pixels at a time from a row for convolution
// 3 pixel output

// return sequence of bits relative to ea step of convolution
module img_row(

					input CLOCK_50, 
					input rst, 
					input [11:0] in_data, 
					input wr_en, 
					input rd_en,
					
					output [35:0] out_data 

					);
					
					
	// 2d memory 
	// 3 rows of 640
	
	// storage
	reg [11:0] row [639:0] /* synthesis ramstyle = "M10K" */; 
	
	

	
	reg [9:0] wr_ptr; // log2(memory_depth)
	reg [9:0] rd_ptr; // log2(memory_depth)
	
	
	// read operation
	// pixel at rd_ptr concatenated with next 2 pixels
	assign out_data = {row[rd_ptr], row[rd_ptr+1], row[rd_ptr+2]}; // output 36 bits at once
	
	always@(posedge CLOCK_50) begin
		if(rst) begin
			rd_ptr <= 0;
		end
		else if(rd_en) begin
			rd_ptr <= rd_ptr + 1; // inc by 1 not 3 so convolution can occur
		end
	end
	
	// write operation
	always@(posedge CLOCK_50) begin
		if(rst) begin
			wr_ptr <= 0;
		end
		else if(wr_en) begin
			wr_ptr <= wr_ptr + 1;
		end
		if(wr_en) begin
			row[wr_ptr] <= in_data;
		end
	end
	
	
					
endmodule