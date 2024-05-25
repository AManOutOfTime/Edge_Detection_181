library verilog;
use verilog.vl_types.all;
entity convolution is
    port(
        clk             : in     vl_logic;
        en              : in     vl_logic;
        pixel_data      : in     vl_logic_vector(199 downto 0);
        conv_data       : out    vl_logic_vector(7 downto 0)
    );
end convolution;
