library verilog;
use verilog.vl_types.all;
entity tb_edge_detect is
    generic(
        IMG_WIDTH       : integer := 640;
        IMG_HEIGHT      : integer := 480;
        CLK_PERIOD      : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IMG_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of IMG_HEIGHT : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end tb_edge_detect;
