// guassian blur control module

module blur_control (
input clk,
input reset,
input [7:0] data_in,
input in_en,
output reg [199:0] data_out,
output reg [8:0] rows_written,
output [9:0] cols_written,
output reg out_en
);

parameter MAX_COL = 10'd644;
parameter TARGET_NUM_DATA = 12'd3220;
parameter MAX_ROW = 9'd484;

reg [9:0] wr_col_num, rd_col_num;
reg [2:0] wr_current_buff, rd_current_buff;
reg [6:0] wr_buff_en, rd_buff_en;
wire [39:0] MK0_read, MK1_read, MK2_read, MK3_read, MK4_read, MK5_read;
reg rd_en, rd_state, rows_written_flag;
reg [11:0] total_written_data;
// start w/ varibles zeroed out to prevent errors
initial
begin
	wr_col_num <= 0;
	rd_col_num <= 0;
	wr_current_buff <= 0;
	rd_buff_en <= 0;
	total_written_data <= 0;
	rd_en <= 0;
	rows_written_flag <= 0;
	rows_written = 0;
end

assign cols_written = wr_col_num;
// tracks total num of written pixel to track when to start conv
always @(posedge clk)
begin
	if(reset)
	begin 
		total_written_data <= 0;
	end
	else 
	begin
		if(in_en && !rd_en)
		begin
			total_written_data <= total_written_data + 1'b1;
		end
		else if(!in_en && rd_en)
		begin
			total_written_data <= total_written_data - 1'b1;
		end
		else
		begin
			total_written_data <= total_written_data;
		end
	end
end

// tracks amount of pixels written
always @(posedge clk)
begin 
	if(reset)
	begin
		wr_col_num <= 0;
	end
	else
	begin
		if((wr_col_num == MAX_COL) && (in_en))
		begin
			wr_col_num <= 0;
		end
		else if (in_en)
		begin
			wr_col_num <= wr_col_num + 1'b1;
		end
		else 
		begin
			wr_col_num <= wr_col_num;
		end
	end
end
//controls when to switch between active M10K block 
always @(posedge clk)
begin
	if(reset)
	begin
		wr_current_buff <= 0;
		rows_written_flag <= 0;
	end
	else
	begin
		if((wr_col_num == MAX_COL) && (in_en) && (wr_current_buff == 3'd5))
		begin
			wr_current_buff <= 0;
		end
		else if((wr_col_num == MAX_COL) && (in_en))
		begin
			wr_current_buff <= wr_current_buff + 1'b1;
			rows_written_flag <= 1'b1;
		end
		else
		begin
			wr_current_buff <= wr_current_buff;
			rows_written_flag <= 1'b0;
		end
	end
end
// tracks amount of rows written in current frame
always @(rows_written_flag)
begin
	if(rows_written == MAX_ROW)
	begin
		rows_written = 0;
	end
	else
	begin
		rows_written = rows_written + 1'b1;
	end
end
//controls which M10K block is being written to
always @(*)
begin
	wr_buff_en = 6'd0;
	wr_buff_en[wr_current_buff] = in_en;
end
// tracks amount of pixels read
always @(posedge clk)
begin
	if(reset)
	begin
		rd_col_num <= 0;
	end
	else
	begin
		if((rd_col_num == MAX_COL) && (rd_en))
		begin
			rd_col_num <= 0;
		end
		else if(rd_en)
		begin
			rd_col_num <= rd_col_num + 1'b1;
		end
		else 
		begin
			rd_col_num <= rd_col_num;
		end
	end
end
//controls which state of read the buffers should be in
always @(posedge clk)
begin
	if(reset)
	begin
		rd_current_buff <= 0;
	end	
	else 
	begin
		if((rd_col_num == MAX_COL) && (rd_en))
		begin
			rd_current_buff <= rd_current_buff + 1'b1;
		end
		else if ((rd_col_num == MAX_COL) && (rd_en) && (rd_current_buff == 3'd5))
		begin
			rd_current_buff <= 0;
		end
		else
		begin
			rd_current_buff <= rd_current_buff;
		end
	end
end
//combines the 5 different line buffer pixels into one data value for conv later
always @ (*)
begin
	case (rd_current_buff)
		3'd0:
		begin
			data_out = {MK4_read,MK3_read,MK2_read,MK1_read,MK0_read};
		end
		3'd1:
		begin
			data_out = {MK5_read,MK4_read,MK3_read,MK2_read,MK1_read};
		end
		3'd2:
		begin
			data_out = {MK0_read,MK5_read,MK4_read,MK3_read,MK2_read};
		end
		3'd3:
		begin
			data_out = {MK1_read,MK0_read,MK5_read,MK4_read,MK3_read};
		end
		3'd4:
		begin
			data_out = {MK2_read,MK1_read,MK0_read,MK5_read,MK4_read};
		end
		3'd5:
		begin
			data_out = {MK3_read,MK2_read,MK1_read,MK0_read,MK5_read};
		end
	endcase
end
// FSM for read state
always @(posedge clk)
begin
	if(reset) 
	begin
		rd_state <= 0;
		rd_en <= 0;
	end
	else
	begin
		case(rd_state)
			//idle state
			1'b0: 
			begin
				if(total_written_data >= TARGET_NUM_DATA)
				begin
					rd_en <= 1'b1;
					rd_state <= rd_state + 1'b1;
				end
			end
			//read state
			1'b1:
			begin
				if(rd_col_num == MAX_COL)
				begin
					rd_state <= 0;
					rd_en <= 0;
				end
			end
		endcase
	end
end
// what M10K blocks should be read during each read state
always @(*)
begin
	case (rd_current_buff)
	3'd0:
		begin
			rd_buff_en[5] = 0;
			rd_buff_en[4] = rd_en;
			rd_buff_en[3] = rd_en;	
			rd_buff_en[2] = rd_en;
			rd_buff_en[1] = rd_en;
			rd_buff_en[0] = rd_en;
		end
		3'd1:
		begin
			rd_buff_en[5] = rd_en;
			rd_buff_en[4] = rd_en;
			rd_buff_en[3] = rd_en;	
			rd_buff_en[2] = rd_en;
			rd_buff_en[1] = rd_en;
			rd_buff_en[0] = 0;
		end
		3'd2:
		begin
			rd_buff_en[5] = rd_en;
			rd_buff_en[4] = rd_en;
			rd_buff_en[3] = rd_en;	
			rd_buff_en[2] = rd_en;
			rd_buff_en[1] = 0;
			rd_buff_en[0] = rd_en;
		end
		3'd3:
		begin
			rd_buff_en[5] = rd_en;
			rd_buff_en[4] = rd_en;
			rd_buff_en[3] = rd_en;	
			rd_buff_en[2] = 0;
			rd_buff_en[1] = rd_en;
			rd_buff_en[0] = rd_en;
		end
		3'd4:
		begin
			rd_buff_en[5] = rd_en;
			rd_buff_en[4] = rd_en;
			rd_buff_en[3] = 0;	
			rd_buff_en[2] = rd_en;
			rd_buff_en[1] = rd_en;
			rd_buff_en[0] = rd_en;
		end
		3'd5:
		begin
			rd_buff_en[5] = rd_en;
			rd_buff_en[4] = 0;
			rd_buff_en[3] = rd_en;	
			rd_buff_en[2] = rd_en;
			rd_buff_en[1] = rd_en;
			rd_buff_en[0] = rd_en;
		end
	endcase
end


row_buffer MK0 (.clk(clk), .reset(reset), .data(data_in), .write_en(wr_buff_en[0]), .extended_data(MK0_read), .read_en(rd_buff_en[0]));
row_buffer MK1 (.clk(clk), .reset(reset), .data(data_in), .write_en(wr_buff_en[1]), .extended_data(MK1_read), .read_en(rd_buff_en[1]));
row_buffer MK2 (.clk(clk), .reset(reset), .data(data_in), .write_en(wr_buff_en[2]), .extended_data(MK2_read), .read_en(rd_buff_en[2]));
row_buffer MK3 (.clk(clk), .reset(reset), .data(data_in), .write_en(wr_buff_en[3]), .extended_data(MK3_read), .read_en(rd_buff_en[3]));
row_buffer MK4 (.clk(clk), .reset(reset), .data(data_in), .write_en(wr_buff_en[4]), .extended_data(MK4_read), .read_en(rd_buff_en[4]));
row_buffer MK5 (.clk(clk), .reset(reset), .data(data_in), .write_en(wr_buff_en[5]), .extended_data(MK5_read), .read_en(rd_buff_en[5]));
 
endmodule 