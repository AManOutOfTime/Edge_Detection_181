// Line Buffer for 5x5 blur module using M10K block memory

module row_buffer(
input clk,
input [7:0] data,
input write_en,
output [39:0] extended_data,
input read_en
);

reg [7:0] mem_block [643:0] /* synthesis ramstyle = M10K */;
reg [9:0] write_index;
reg [9:0] read_index;

integer i;

initial 
begin
	write_index = 0;
	read_index = 0;
	for(i = 0; i < 644; i = i + 1)
	begin
		mem_block[i] = 0;
	end
end

always @(posedge clk)
begin
	if(write_en)
	begin
		mem_block[(write_index + 10'd2)] <= data;
	end
end
//write port logic
always @(posedge clk)
begin
	if(write_en)
	begin 
		if(write_index == 10'd640)
		begin
			write_index = 10'd0;
		end
		else
		begin 
			write_index = write_index + 1'b1;
		end
	end
	else
	begin
		write_index = write_index;
	end
end

assign extended_data = {mem_block[read_index-2],mem_block[read_index-1],      //concatinated 5 pixels 
mem_block[read_index],mem_block[read_index+1],mem_block[read_index+2]}; //for 5x5 kernal
//read port logic
always @(posedge clk)
begin
	if(read_en)
	begin 
		if(read_index == 10'd640)
		begin
			read_index = 10'd2;
		end
		else
		begin
			read_index = read_index + 1;
		end
	end
	else
	begin
		read_index = read_index;
	end
end

endmodule
