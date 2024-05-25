library verilog;
use verilog.vl_types.all;
entity sobel_conv is
    port(
        pixel0          : in     vl_logic_vector(7 downto 0);
        pixel1          : in     vl_logic_vector(7 downto 0);
        pixel2          : in     vl_logic_vector(7 downto 0);
        pixel3          : in     vl_logic_vector(7 downto 0);
        pixel4          : in     vl_logic_vector(7 downto 0);
        pixel5          : in     vl_logic_vector(7 downto 0);
        pixel6          : in     vl_logic_vector(7 downto 0);
        pixel7          : in     vl_logic_vector(7 downto 0);
        pixel8          : in     vl_logic_vector(7 downto 0);
        op_val          : out    vl_logic_vector(7 downto 0)
    );
end sobel_conv;
