library verilog;
use verilog.vl_types.all;
entity img_row is
    port(
        zero_fill       : in     vl_logic;
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        in_data         : in     vl_logic_vector(7 downto 0);
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic;
        pixelA          : out    vl_logic_vector(7 downto 0);
        pixelB          : out    vl_logic_vector(7 downto 0);
        pixelC          : out    vl_logic_vector(7 downto 0)
    );
end img_row;
