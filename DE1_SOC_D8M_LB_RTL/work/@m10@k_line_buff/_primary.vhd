library verilog;
use verilog.vl_types.all;
entity M10K_line_buff is
    port(
        clk             : in     vl_logic;
        in_data         : in     vl_logic_vector(7 downto 0);
        write_en        : in     vl_logic;
        read_en         : in     vl_logic;
        out_data        : out    vl_logic_vector(7 downto 0);
        data_flag       : out    vl_logic
    );
end M10K_line_buff;
