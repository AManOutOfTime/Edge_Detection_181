library verilog;
use verilog.vl_types.all;
entity edge_detect is
    generic(
        OFF             : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        IDLE            : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        ACTIVE          : vl_logic_vector(0 to 1) := (Hi1, Hi0);
        MAX_DISP_ROWS   : integer := 480;
        MAX_DISP_COLS   : integer := 640;
        INIT_ROWS       : integer := 2;
        INIT            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        INIT_BUFF       : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        SET0            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        SET1            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        SET2            : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        SET3            : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1);
        EDGE_OFF        : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        ON_CONV         : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        ON_FINISH       : vl_logic_vector(0 to 1) := (Hi1, Hi0)
    );
    port(
        row             : in     vl_logic_vector(12 downto 0);
        col             : in     vl_logic_vector(12 downto 0);
        clk             : in     vl_logic;
        edge_en         : in     vl_logic;
        in_R            : in     vl_logic_vector(7 downto 0);
        in_G            : in     vl_logic_vector(7 downto 0);
        in_B            : in     vl_logic_vector(7 downto 0);
        edge_R_out      : out    vl_logic_vector(7 downto 0);
        edge_G_out      : out    vl_logic_vector(7 downto 0);
        edge_B_out      : out    vl_logic_vector(7 downto 0);
        cycles          : out    vl_logic_vector(9 downto 0);
        vga_reset       : out    vl_logic;
        hex             : out    vl_logic_vector(7 downto 0);
        hex_sync_state  : out    vl_logic_vector(7 downto 0);
        hex_next_sync_state: out    vl_logic_vector(7 downto 0);
        hex_conv_state  : out    vl_logic_vector(7 downto 0);
        hex_next_conv_state: out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OFF : constant is 1;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of ACTIVE : constant is 1;
    attribute mti_svvh_generic_type of MAX_DISP_ROWS : constant is 1;
    attribute mti_svvh_generic_type of MAX_DISP_COLS : constant is 1;
    attribute mti_svvh_generic_type of INIT_ROWS : constant is 1;
    attribute mti_svvh_generic_type of INIT : constant is 1;
    attribute mti_svvh_generic_type of INIT_BUFF : constant is 1;
    attribute mti_svvh_generic_type of SET0 : constant is 1;
    attribute mti_svvh_generic_type of SET1 : constant is 1;
    attribute mti_svvh_generic_type of SET2 : constant is 1;
    attribute mti_svvh_generic_type of SET3 : constant is 1;
    attribute mti_svvh_generic_type of EDGE_OFF : constant is 1;
    attribute mti_svvh_generic_type of ON_CONV : constant is 1;
    attribute mti_svvh_generic_type of ON_FINISH : constant is 1;
end edge_detect;
