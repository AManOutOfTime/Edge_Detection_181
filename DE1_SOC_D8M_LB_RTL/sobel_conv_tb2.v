`timescale 1ns / 1ps

module sobel_conv_tb2;

  // Inputs
  reg [7:0] pixel0;
  reg [7:0] pixel1;
  reg [7:0] pixel2;
  reg [7:0] pixel3;
  reg [7:0] pixel4;
  reg [7:0] pixel5;
  reg [7:0] pixel6;
  reg [7:0] pixel7;
  reg [7:0] pixel8;

  // Outputs
  wire [7:0] op_val;

  // Instantiate the Unit Under Test (UUT)
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

  initial begin
    // Initialize Inputs
    pixel0 = 8'd0;
    pixel1 = 8'd0;
    pixel2 = 8'd0;
    pixel3 = 8'd62;
    pixel4 = 8'd62;
    pixel5 = 8'd62;
    pixel6 = 8'd62;
    pixel7 = 8'd62;
    pixel8 = 8'd62;

    // Wait 100 ns for global reset to finish
    #100;
        
    // Display the result
    $display("Output value: %d", op_val);
    
    // Add more test vectors if needed
    // ...

    // Finish the simulation
    #100;
    $finish;
  end
      
endmodule