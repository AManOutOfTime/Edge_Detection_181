module sqrt_approx_23bit (
	input [22:0] radicand,
	output [10:0] sqrt
);
	
	reg [10:0] fin;
	reg [22:0] val;
	integer i;
	
	assign sqrt = fin;
	
	always@(radicand) begin
		fin = 0;
		val = radicand;
		for (i = 10; i >= 0; i = i - 1) begin
			// check if adding a 1 at ea bit place gets us closer to sqrt
			if( (fin+(1<<i))*(fin+(1<<i)) <= val )  begin
				fin = fin + (1<<i);
			end
		end
		
	end
	
endmodule