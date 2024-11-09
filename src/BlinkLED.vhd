LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY BlinkLED IS
    PORT (
        CLK_50M : IN STD_LOGIC;
        LED : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
    );
END ENTITY BlinkLED;

ARCHITECTURE Behavioral OF BlinkLED IS
    SIGNAL counter : unsigned(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL led_pattern : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000001";
BEGIN
    PROCESS (CLK_50M)
    BEGIN
        IF rising_edge(CLK_50M) THEN
            -- Set delay for LED scrolling effect
            IF counter > 50000000/6 THEN
                counter <= (OTHERS => '0');

                -- Shift LED pattern left; wrap around at the end
                IF led_pattern = "100000" THEN
                    led_pattern <= "000001";
                ELSE
                    led_pattern <= led_pattern(4 DOWNTO 0) & '0';
                END IF;
            ELSE
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;

    LED <= led_pattern;
END ARCHITECTURE Behavioral;