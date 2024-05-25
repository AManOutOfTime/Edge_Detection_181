module sqrt_approx_tb;

    // Inputs
    reg [22:0] in;

    // Outputs
    wire [10:0] out;

    // Instantiate the sqrt_approx module
    sqrt_approx_23bit uut (
        .radicand(in),
        .sqrt(out)
    );

    // Testbench procedure
    initial begin
        // Display the results
        $monitor("in = %d, out = %d", in, out);

        // Apply test cases
        in = 23'd0; #10; // Square root of 0
        in = 23'd1; #10; // Square root of 1
        in = 23'd4; #10; // Square root of 4
        in = 23'd9; #10; // Square root of 9
        in = 23'd16; #10; // Square root of 16
        in = 23'd25; #10; // Square root of 25
        in = 23'd36; #10; // Square root of 36
        in = 23'd49; #10; // Square root of 49
        in = 23'd64; #10; // Square root of 64
        in = 23'd81; #10; // Square root of 81
        in = 23'd100; #10; // Square root of 100
        in = 23'd121; #10; // Square root of 121
        in = 23'd144; #10; // Square root of 144
        in = 23'd169; #10; // Square root of 169
        in = 23'd196; #10; // Square root of 196
        in = 23'd225; #10; // Square root of 225
        in = 23'd256; #10; // Square root of 256
        in = 23'd1024; #10; // Square root of 1024
        in = 23'd2048; #10; // Square root of 2048
        in = 23'd4096; #10; // Square root of 4096
        in = 23'd8192; #10; // Square root of 8192
        in = 23'd16384; #10; // Square root of 16384
        in = 23'd32768; #10; // Square root of 32768
        in = 23'd65536; #10; // Square root of 65536
        in = 23'd131072; #10; // Square root of 131072
        in = 23'd262144; #10; // Square root of 262144
        in = 23'd524288; #10; // Square root of 524288
        in = 23'd1048576; #10; // Square root of 1048576
        in = 23'd2097152; #10; // Square root of 2097152 (maximum value for 23 bits) 
		  in = 23'd7; #10;
		  in = 23'd33; #10;
		  in = 23'd141; #10;
		  in = 23'd200; #10;
		  

    end

endmodule