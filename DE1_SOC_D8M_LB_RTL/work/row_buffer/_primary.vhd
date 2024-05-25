library verilog;
use verilog.vl_types.all;
entity row_buffer is
    port(
        clk             : in     vl_logic;
        data            : in     vl_logic_vector(7 downto 0);
        write_en        : in     vl_logic;
        extended_data   : out    vl_logic_vector(39 downto 0);
        read_en         : in     vl_logic
    );
end row_buffer;
