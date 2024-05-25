module trial_buffer #(
    parameter WIDTH = 8,       // Width of each pixel
    parameter HEIGHT = 480,    // Number of rows
    parameter LENGTH = 640,    // Number of columns
    parameter DEPTH = WIDTH * HEIGHT * LENGTH // Total number of bits
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout,
    output wire full,
    output wire empty
);

    reg [WIDTH-1:0] mem [0:DEPTH-1] /* synthesis ramstyle = "no_rw_check, M10K" */;
    reg [31:0] wr_ptr;
    reg [31:0] rd_ptr;
    reg [31:0] cnt;

    assign full = (cnt == DEPTH);
    assign empty = (cnt == 0);

    assign dout = (rd_en && !empty) ? mem[rd_ptr] : {WIDTH{1'b0}};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            cnt <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= (wr_ptr + 1) % DEPTH;
                cnt <= cnt + 1;
            end
            if (rd_en && !empty) begin
                rd_ptr <= (rd_ptr + 1) % DEPTH;
                cnt <= cnt - 1;
            end
        end
    end

endmodule