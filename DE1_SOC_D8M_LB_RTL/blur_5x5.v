// gaussian blur top level module

module blur_5x5(
 input clk,
 input reset,
 input en,
 input [7:0] input_pixel,
 output rd_flag,
 output [7:0] output_pixel,
 output [8:0] rows_written,
 output [9:0] cols_written
);


wire [199:0] concatinated_data;
wire conv_en;

blur_control blur_con(.clk(clk), .reset(reset), .data_in(input_pixel), .in_en(en), .data_out(concatinated_data), 
.rows_written(rows_written), .cols_written(cols_written), .out_en(conv_en));
convolution conv(.clk(clk), .pixel_data(concatinated_data), .conv_en(conv_en), .conv_data(output_pixel), .conv_valid(rd_flag));


endmodule