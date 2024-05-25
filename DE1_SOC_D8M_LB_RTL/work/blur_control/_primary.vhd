library verilog;
use verilog.vl_types.all;
entity blur_control is
    generic(
        MAX_COL         : vl_logic_vector(0 to 9) := (Hi1, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        MAX_ROW         : vl_logic_vector(0 to 8) := (Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        MAX_DATA_READ   : vl_logic_vector(0 to 11) := (Hi1, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        data_in         : in     vl_logic_vector(7 downto 0);
        in_en           : in     vl_logic;
        data_out        : out    vl_logic_vector(199 downto 0);
        rows_written    : out    vl_logic_vector(8 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MAX_COL : constant is 1;
    attribute mti_svvh_generic_type of MAX_ROW : constant is 1;
    attribute mti_svvh_generic_type of MAX_DATA_READ : constant is 1;
end blur_control;
