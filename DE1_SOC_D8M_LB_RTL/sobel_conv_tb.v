module sobel_conv_tb;

    // Inputs
    reg [7:0] pixel0, pixel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8;

    // Outputs
    wire [7:0] op_val;

    // Instantiate the sobel_conv module
    sobel_conv uut (
        .pixel0(pixel0),
        .pixel1(pixel1),
        .pixel2(pixel2),
        .pixel3(pixel3),
        .pixel4(pixel4),
        .pixel5(pixel5),
        .pixel6(pixel6),
        .pixel7(pixel7),
        .pixel8(pixel8),
        .op_val(op_val)
    );

    // Golden reference calculation function
    function [7:0] golden_reference;
        input [7:0] p0, p1, p2, p3, p5, p6, p7, p8;
        reg signed [10:0] gx, gy;
        reg signed [21:0] gx2, gy2;
        reg [22:0] g2_sum;
        reg [10:0] sqrt_val;
        integer i;
        begin
            gx = (p2 - p0) + ((p5 - p3) << 1) + (p8 - p6);
            gy = (p6 - p0) + ((p7 - p1) << 1) + (p8 - p2);
            gx2 = gx * gx;
            gy2 = gy * gy;
            g2_sum = gx2 + gy2;
            
            // Square root approximation (same as sqrt_approx_23bit module)
            sqrt_val = 0;
            for (i = 10; i >= 0; i = i - 1) begin
                if ((sqrt_val + (1 << i)) * (sqrt_val + (1 << i)) <= g2_sum) begin
                    sqrt_val = sqrt_val + (1 << i);
                end
            end

            golden_reference = (sqrt_val > 255) ? 8'hff : sqrt_val[7:0];
        end
    endfunction

    // Testbench procedure
    initial begin
        // Initialize test vectors
        pixel0 = 8'hff; pixel1 = 8'h00; pixel2 = 8'hff;
        pixel3 = 8'h00; pixel4 = 8'h00; pixel5 = 8'h00;
        pixel6 = 8'hff; pixel7 = 8'h00; pixel8 = 8'hff;
        #10;
        compare_results;

        pixel0 = 8'h10; pixel1 = 8'h20; pixel2 = 8'h30;
        pixel3 = 8'h40; pixel4 = 8'h50; pixel5 = 8'h60;
        pixel6 = 8'h70; pixel7 = 8'h80; pixel8 = 8'h90;
        #10;
        compare_results;

        pixel0 = 8'h80; pixel1 = 8'h80; pixel2 = 8'h80;
        pixel3 = 8'h80; pixel4 = 8'h80; pixel5 = 8'h80;
        pixel6 = 8'h80; pixel7 = 8'h80; pixel8 = 8'h80;
        #10;
        compare_results;

        // Add more test vectors as needed

        // Finish the simulation
        $finish;
    end

    // Compare the results with the golden reference
    task compare_results;
        reg [7:0] expected;
        begin
            expected = golden_reference(pixel0, pixel1, pixel2, pixel3, pixel5, pixel6, pixel7, pixel8);
            if (op_val !== expected) begin
                $display("Mismatch: Input = %h %h %h %h %h %h %h %h, Expected = %h, Got = %h", 
                          pixel0, pixel1, pixel2, pixel3, pixel5, pixel6, pixel7, pixel8, expected, op_val);
            end else begin
                $display("Match: Input = %h %h %h %h %h %h %h %h, Output = %h", 
                          pixel0, pixel1, pixel2, pixel3, pixel5, pixel6, pixel7, pixel8, op_val);
            end
        end
    endtask

endmodule