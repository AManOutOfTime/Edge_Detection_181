// gaussian blur top level module

module blur_5x5(
 input clk,
 input en,
 input [7:0] input_pixel_R,
 input [7:0] input_pixel_G,
 input [7:0] input_pixel_B,
 output [7:0] output_pixel_R,
 output [7:0] output_pixel_B,
 output [7:0] output_pixel_G,
 output rd_flag
);


wire [199:0] concatinated_data_R, concatinated_data_G, concatinated_data_B;
wire conv_en_R, conv_en_G, conv_en_B;
wire [8:0] rows_written_R, rows_written_G, rows_written_B;
wire rd_flag_R, rd_flag_B, rd_flag_G, data_flag_R, data_flag_G, data_flag_B; 
wire [7:0] conv_R, conv_G, conv_B;

//buffer output RGB values to insure same RGB values are mantained for each pixel
M10K_line_buff M10K_R(
	.clk(clk),
	.in_data(conv_R),
	.write_en(rd_flag_R),
	.read_en(rd_flag),
	.out_data(output_pixel_R),
	.data_flag(data_flag_R)
);

M10K_line_buff M10K_G(
	.clk(clk),
	.in_data(conv_G),
	.write_en(rd_flag_G),
	.read_en(rd_flag),
	.out_data(output_pixel_G),
	.data_flag(data_flag_G)
);

M10K_line_buff M10K_B(
	.clk(clk),
	.in_data(conv_B),
	.write_en(rd_flag_B),
	.read_en(rd_flag),
	.out_data(output_pixel_B),
	.data_flag(data_flag_B)
);

blur_control blur_con_R(
	.clk(clk),
	.data_in(input_pixel_R), 
	.in_en(en), 
	.data_out(concatinated_data_R), 
	.rows_written(rows_written_R)
);
convolution MAC_R(
	.clk(clk),
	.en(rd_flag_R),	
	.pixel_data(concatinated_data_R),  
	.conv_data(conv_R)
);

blur_control blur_con_G(
	.clk(clk),
	.data_in(input_pixel_G), 
	.in_en(en), 
	.data_out(concatinated_data_G), 
	.rows_written(rows_written_G) 
);
convolution MAC_G(
	.clk(clk),
	.en(rd_flag_G),	
	.pixel_data(concatinated_data_G), 
	.conv_data(conv_G)
);

blur_control blur_con_B(
	.clk(clk), 
	.data_in(input_pixel_B), 
	.in_en(en), 
	.data_out(concatinated_data_B), 
	.rows_written(rows_written_B)
);
convolution MAC_B(
	.clk(clk), 
	.en(rd_flag_B),
	.pixel_data(concatinated_data_B),  
	.conv_data(conv_B)
);


assign rd_flag = ((rd_flag_R | data_flag_R) & (rd_flag_G | data_flag_G) & (rd_flag_B | data_flag_B));
assign rd_flag_R = (rows_written_R >= 5) ? 1'b1 : 1'b0;
assign rd_flag_G = (rows_written_G >= 5) ? 1'b1 : 1'b0;
assign rd_flag_B = (rows_written_B >= 5) ? 1'b1 : 1'b0;

endmodule