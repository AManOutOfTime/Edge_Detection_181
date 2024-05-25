library verilog;
use verilog.vl_types.all;
entity sqrt_approx_23bit is
    port(
        radicand        : in     vl_logic_vector(22 downto 0);
        sqrt            : out    vl_logic_vector(10 downto 0)
    );
end sqrt_approx_23bit;
