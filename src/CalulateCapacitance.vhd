LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY CalculateCapacitance IS
    PORT (
        clk : IN STD_LOGIC; -- 50 MHz clock signal
        reset : IN STD_LOGIC; -- Reset signal
        -- start_charge : IN STD_LOGIC; -- Signal to start charging the capacitor
        -- rctrigger : IN STD_LOGIC; -- Signal that indicates voltage has reached a certain level
        -- capacitance : OUT INTEGER; -- Calculated capacitance value (in picofarads for example)
        time_debug : OUT INTEGER -- Debug signal to output count value
    );
END CalculateCapacitance;

ARCHITECTURE Behavioral OF CalculateCapacitance IS
    CONSTANT R : INTEGER := 500; -- Fixed resistance value in ohms
    CONSTANT CLK_FREQ : INTEGER := 50000000; -- 50 MHz clock frequency
    CONSTANT CLK_PERIOD_NS : INTEGER := 20; -- Clock period in nanoseconds (50 MHz -> 20 ns per cycle)

    SIGNAL counter : unsigned(31 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            time_debug <= 0;

        ELSIF rising_edge(clk) THEN
            IF counter > 50000000 THEN
                counter <= (OTHERS => '0');
                time_debug <= time_debug + 1;
            ELSE
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;