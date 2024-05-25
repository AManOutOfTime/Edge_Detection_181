// Line Buffer module using M10K block memory

module row_buffer(
input clk,
input reset,
input [7:0] data,
input write_en,
output [39:0] extended_data,
input read_en
);

reg [7:0] mem_block [1023:0] /* synthesis ramstyle = "M10K" */; // M10K memory block
reg [9:0] write_index;
reg [9:0] read_index;

always @(posedge clk)
begin
	if(write_en)
	begin
		mem_block[write_index] <= data;
	end
end
//write port logic
always @(posedge clk)
begin
	if(reset)
	begin 
		write_index <= 10'd0;
	end
	else
	begin
		write_index <= write_index + 1'b1;
	end
end

assign extended_data = {mem_block[read_index],mem_block[read_index+1],      //concatinated 5 pixels 
mem_block[read_index+2],mem_block[read_index+3],mem_block[read_index+4]}; //for 5x5 kernal
//read port logic
always @(posedge clk)
begin
	if(reset)
	begin 
		read_index <= 10'd0;
	end
	else if (read_en)
	begin
		read_index <= read_index + 1'b1;
	end
	else
	begin
		read_index <= read_index;
	end
end

endmodule
