`timescale 1ns / 1ps

module tb_edge_detect();

    // Parameters
    parameter IMG_WIDTH = 640;
    parameter IMG_HEIGHT = 480;
    parameter CLK_PERIOD = 10;

    // Clock and reset
    reg clk;
    reg rst;

    // Image buffers
    reg [7:0] img_in [0:(IMG_WIDTH*IMG_HEIGHT*3)-1];
    reg [7:0] img_out [0:(IMG_WIDTH*IMG_HEIGHT*3)-1];

    // DUT interface
    reg [7:0] in_R, in_G, in_B;
    reg [12:0] row, col;
    wire [7:0] done_edge_R, done_edge_G, done_edge_B;
    reg edge_en;
    wire [9:0] cycles;
    wire vga_rst;

    // Instantiate DUT
    edge_detect dut (
        .clk(clk),
        .in_R(in_R),
        .in_G(in_G),
        .in_B(in_B),
        .row(row),
        .col(col),
        .edge_en(edge_en),
        .edge_R_out(done_edge_R),
        .edge_G_out(done_edge_G),
        .edge_B_out(done_edge_B),
        .cycles(cycles),
        .vga_reset(vga_rst)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end
	integer r, c;
    // Test procedure
    initial begin
        // Initialize signals
        rst = 1;
        edge_en = 0;
        in_R = 0;
        in_G = 0;
        in_B = 0;
        row = 0;
        col = 0;

        // Load input image
        $readmemh("C:/Users/amaan/Documents/WinterQtr2024/EEC181A/final/Edge_Detection_181/DE1_SOC_D8M_LB_RTL/input_image.hex", img_in);

		#CLK_PERIOD;
        // Release reset
        rst = 0;
		#CLK_PERIOD;

        edge_en=1;
        for (r = 0; r < IMG_HEIGHT; r = r + 1) begin
            for ( c = 0; c < IMG_WIDTH; c = c + 1) begin
                row = r;
                col = c;
                in_R = img_in[(r * IMG_WIDTH + c)*3];
                in_G = img_in[(r * IMG_WIDTH + c)*3 +1];
                in_B = img_in[(r * IMG_WIDTH + c)*3 +2];
				#CLK_PERIOD;

            end
        end
		for (r = 0; r < IMG_HEIGHT; r = r + 1) begin
            for ( c = 0; c < IMG_WIDTH; c = c + 1) begin
                row = r;
                col = c;
                in_R = img_in[(r * IMG_WIDTH + c)*3];
                in_G = img_in[(r * IMG_WIDTH + c)*3 +1];
                in_B = img_in[(r * IMG_WIDTH + c)*3 +2];
				#CLK_PERIOD;

            end
        end
		for (r = 0; r < IMG_HEIGHT; r = r + 1) begin
            for ( c = 0; c < IMG_WIDTH; c = c + 1) begin
                row = r;
                col = c;
                in_R = img_in[(r * IMG_WIDTH + c)*3];
                in_G = img_in[(r * IMG_WIDTH + c)*3 +1];
                in_B = img_in[(r * IMG_WIDTH + c)*3 +2];
                #CLK_PERIOD;
					  if (vga_rst) begin
					  img_out[(r * IMG_WIDTH + c)*3 ] <= done_edge_R;
					  img_out[(r * IMG_WIDTH + c)*3 +1] <= done_edge_R;
					  img_out[(r * IMG_WIDTH + c)*3 +2] <= done_edge_R;
					  end
            end
        end
		  // Write output image
            $writememh("output_image.hex", img_out);
				$display("clock cycles: %d", cycles);
            $end;
		$finish;
    end

endmodule