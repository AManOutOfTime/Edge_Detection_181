// Line Buffer module using M10K block memory

module M10K_line_buff(
input clk,
input [7:0] in_data,
input write_en,
input read_en,
output [7:0] out_data,
output data_flag
);

reg [7:0] mem_block [1023:0] /* synthesis ramstyle = M10K */;
reg [9:0] write_index;
reg [9:0] read_index;

initial 
begin
	write_index = 0;
	read_index = 0;
end

assign data_flag = (write_index == read_index) ? 1'b0 : 1'b1;

always @(posedge clk)
begin
	if(write_en)
	begin
		mem_block[write_index] <= in_data;
	end
end
//write port logic
always @(posedge clk)
begin
	if(write_en)
	begin
		write_index <= write_index + 1'b1;
	end
	else
	begin
		write_index <= write_index;
	end
end

assign out_data = mem_block[read_index];
//read port logic
always @(posedge clk)
begin
	if (read_en)
	begin
		read_index <= read_index + 1'b1;
	end
	else
	begin
		read_index <= read_index;
	end
end

endmodule