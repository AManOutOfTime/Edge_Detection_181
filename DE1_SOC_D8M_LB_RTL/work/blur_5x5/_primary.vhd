library verilog;
use verilog.vl_types.all;
entity blur_5x5 is
    port(
        clk             : in     vl_logic;
        en              : in     vl_logic;
        input_pixel_R   : in     vl_logic_vector(7 downto 0);
        input_pixel_G   : in     vl_logic_vector(7 downto 0);
        input_pixel_B   : in     vl_logic_vector(7 downto 0);
        output_pixel_R  : out    vl_logic_vector(7 downto 0);
        output_pixel_B  : out    vl_logic_vector(7 downto 0);
        output_pixel_G  : out    vl_logic_vector(7 downto 0);
        rd_flag         : out    vl_logic
    );
end blur_5x5;
