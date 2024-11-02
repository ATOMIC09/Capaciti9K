LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY SimpleC_Meter IS
    PORT (
        RESET : IN STD_LOGIC;
        CLK_IN_27M : IN STD_LOGIC;
        CLK_OUT_27M : OUT STD_LOGIC;
        CLK_OUT : OUT STD_LOGIC;
        CLK_OUTD : OUT STD_LOGIC;
        LED : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        CHARGE_TRIGGER : OUT STD_LOGIC;
        DISCHARGE_TRIGGER : OUT STD_LOGIC
    );
END ENTITY SimpleC_Meter;

ARCHITECTURE Structural OF SimpleC_Meter IS
    SIGNAL clk_out_pll : STD_LOGIC;
    SIGNAL clk_outd_pll : STD_LOGIC;

    COMPONENT Gowin_rPLL
        PORT (
            clkout : OUT STD_LOGIC;
            clkoutd : OUT STD_LOGIC;
            clkin : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT BlinkLED
        PORT (
            CLK_50M : IN STD_LOGIC;
            LED : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ChargeDischargeControl
        PORT (
            CLK_50M : IN STD_LOGIC;
            CHARGE : OUT STD_LOGIC;
            DISCHARGE : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    gowin_pll1 : Gowin_rPLL
    PORT MAP(
        clkout => clk_out_pll,
        clkoutd => clk_outd_pll,
        clkin => CLK_IN_27M
    );

    blink_led : BlinkLED
    PORT MAP(
        CLK_50M => clk_out_pll,
        LED => LED
    );

    charge_discharge : ChargeDischargeControl
    PORT MAP(
        CLK_50M => clk_out_pll,
        CHARGE => CHARGE_TRIGGER,
        DISCHARGE => DISCHARGE_TRIGGER
    );

    CLK_OUT <= clk_out_pll;
    CLK_OUTD <= clk_outd_pll;
    CLK_OUT_27M <= CLK_IN_27M;
END ARCHITECTURE Structural;