// convolution of 5x5 kernal for Gaussian blur

module convolution (
input clk,
input [199:0] pixel_data,
input conv_en,
output reg [7:0] conv_data,
output reg conv_valid
);

integer index;
reg [7:0] kernal [24:0]; // 5x5 kernal
reg [15:0] mult_data [24:0];
reg [15:0] sum_data = 0;
reg [15:0] final_data;
reg mult_valid, add_valid;

initial // sets the gaussian kernal value
begin
	kernal[0] = 8'd1;
	kernal[1] = 8'd4;
	kernal[2] = 8'd6;
	kernal[3] = 8'd4;
	kernal[4] = 8'd1;
	kernal[5] = 8'd4;
	kernal[6] = 8'd16;
	kernal[7] = 8'd24;
	kernal[8] = 8'd16;
	kernal[9] = 8'd4;
	kernal[10] = 8'd6;
	kernal[11] = 8'd24;
	kernal[12] = 8'd36;
	kernal[13] = 8'd24;
	kernal[14] = 8'd6;
	kernal[15] = 8'd4;
	kernal[16] = 8'd16;
	kernal[17] = 8'd24;
	kernal[18] = 8'd16;
	kernal[19] = 8'd4;
	kernal[20] = 8'd1;
	kernal[21] = 8'd4;
	kernal[22] = 8'd6;
	kernal[23] = 8'd4;
	kernal[24] = 8'd1;
end

always @(posedge clk)
begin
	for(index = 0; index < 25; index = index + 1)
	begin
		mult_data[index] <= kernal[index] * pixel_data[index*8+:8];
	end
	mult_valid <= conv_en;
end


always @(*)
begin
	for(index = 0; index < 25; index = index + 1)
	begin
		sum_data = sum_data + mult_data[index];
	end
	add_valid <= mult_valid;
end


always @(posedge clk)
begin
	final_data <= sum_data;
end

always @(posedge clk)
begin
	conv_data <= final_data/256;
	conv_valid <= add_valid;
end

endmodule
