library verilog;
use verilog.vl_types.all;
entity greyscale is
    port(
        in_R            : in     vl_logic_vector(7 downto 0);
        in_G            : in     vl_logic_vector(7 downto 0);
        in_B            : in     vl_logic_vector(7 downto 0);
        grey            : out    vl_logic_vector(7 downto 0)
    );
end greyscale;
