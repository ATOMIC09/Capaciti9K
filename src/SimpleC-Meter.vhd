LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY SimpleC_Meter IS
    PORT (
        TEST : IN STD_LOGIC;
        RESET : IN STD_LOGIC;
        RCTRIGGER : IN STD_LOGIC; -- Feedback from RC circuit
        CLK_IN_27M : IN STD_LOGIC; -- 27MHz clock input
        CLK_OUT_27M : OUT STD_LOGIC; -- 27MHz clock output
        CLK_OUT : OUT STD_LOGIC; -- 50MHz clock output
        CLK_OUTD : OUT STD_LOGIC; -- 1MHz clock output
        LED : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        LED1, LED2 : OUT STD_LOGIC; 
        CHARGE_TRIGGER : OUT STD_LOGIC; -- Charge trigger to RC circuit
        DISCHARGE_TRIGGER : OUT STD_LOGIC; -- Discharge trigger to RC circuit
        DIGIT1, DIGIT2, DIGIT3, DIGIT4 : OUT STD_LOGIC;
        A, B, C, D, E, F, G, DP : OUT STD_LOGIC
    );
END ENTITY SimpleC_Meter;

ARCHITECTURE Structural OF SimpleC_Meter IS
    SIGNAL clk_out_pll : STD_LOGIC;
    SIGNAL clk_outd_pll : STD_LOGIC;
    SIGNAL CAPACITANCE_CALCULATED : INTEGER;
    SIGNAL CAPACITANCE_CALCULATED_DP : INTEGER := 4;
    SIGNAL RESET_MODE : STD_LOGIC := '0';

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
            DISCHARGE : OUT STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT SevenSegmentDisplay
        PORT (
            clk : IN STD_LOGIC;
            reset_mode : IN STD_LOGIC;
            input_int : IN INTEGER RANGE 0 TO 50000000;
            decimal_point : IN INTEGER RANGE 0 TO 4;
            digit1, digit2, digit3, digit4 : OUT STD_LOGIC;
            a, b, c, d, e, f, g, dp : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT CalculateCapacitance
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            start_charge : IN STD_LOGIC;
            rctrigger : IN STD_LOGIC;
            LED_MICRO : OUT STD_LOGIC;
            LED_PICO : OUT STD_LOGIC;
            display_val : OUT INTEGER;
            reset_mode : OUT STD_LOGIC
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
        DISCHARGE => DISCHARGE_TRIGGER,
        reset => RESET
    );

    seven_segment : SevenSegmentDisplay
    PORT MAP(
        clk => clk_outd_pll,
        reset_mode => RESET_MODE,
        input_int => CAPACITANCE_CALCULATED,
        decimal_point => CAPACITANCE_CALCULATED_DP,
        digit1 => DIGIT1,
        digit2 => DIGIT2,
        digit3 => DIGIT3,
        digit4 => DIGIT4,
        a => A,
        b => B,
        c => C,
        d => D,
        e => E,
        f => F,
        g => G,
        dp => DP
    );

    calculate_capacitance : CalculateCapacitance
    PORT MAP(
        clk => clk_out_pll,
        reset => RESET,
        start_charge => CHARGE_TRIGGER,
        rctrigger => RCTRIGGER,
        LED_MICRO => LED1,
        LED_PICO => LED2,
        display_val => CAPACITANCE_CALCULATED,
        reset_mode => RESET_MODE
    );

    CLK_OUT <= clk_out_pll;
    CLK_OUTD <= clk_outd_pll;
    CLK_OUT_27M <= CLK_IN_27M;
END ARCHITECTURE Structural;