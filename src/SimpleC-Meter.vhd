LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SimpleC_Meter IS
    PORT (
        RESET : IN STD_LOGIC;
        CLK_OUT : OUT STD_LOGIC
    );
END ENTITY SimpleC_Meter;

ARCHITECTURE Structural OF SimpleC_Meter IS
    COMPONENT Gowin_OSC
        PORT (
            oscout : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    gowin_osc1 : Gowin_OSC
    PORT MAP(
        oscout => CLK_OUT
    );

END ARCHITECTURE Structural;