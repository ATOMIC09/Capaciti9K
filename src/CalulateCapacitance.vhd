LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY CalculateCapacitance IS
    PORT (
        clk : IN STD_LOGIC; -- 50 MHz clock
        reset : IN STD_LOGIC; -- reset button
        start_charge : IN STD_LOGIC; -- signal when capacitor starts charging
        rctrigger : IN STD_LOGIC; -- signal when capacitor reaches 63.2%
        LED_MICRO : OUT STD_LOGIC; -- LED indicator for microfarad range
        LED_NANO : OUT STD_LOGIC; -- LED indicator for picofarad range
        display_val : OUT INTEGER; -- Output to 7-segment display
        reset_mode : OUT STD_LOGIC; -- Output to reset 7-segment display
        wait_mode : OUT STD_LOGIC; -- Output to wait 7-segment display
        decimal_point : OUT INTEGER RANGE 0 TO 4
    );
END CalculateCapacitance;

ARCHITECTURE Behavioral OF CalculateCapacitance IS
    CONSTANT clk_freq : INTEGER := 50000000; -- 50 MHz clock frequency
    CONSTANT R : INTEGER := 498; -- Resistance value in ohms
    SIGNAL clock_counter : INTEGER RANGE 0 TO 50000000 := 0;
    SIGNAL start_time : INTEGER := 0;
    SIGNAL end_time : INTEGER := 0;
    SIGNAL time_interval : INTEGER := 0;
    SIGNAL prev_charge_state : STD_LOGIC := '0';
    SIGNAL prev_rctrigger_state : STD_LOGIC := '0';
    SIGNAL capacitor_value : INTEGER := 0;
BEGIN

    -- Process to handle interval timing and display logic
    PROCESS (clk, reset)
    BEGIN
        IF reset = '0' THEN
            reset_mode <= '1';
            wait_mode <= '0';
            clock_counter <= 0;
            start_time <= 0;
            end_time <= 0;
            time_interval <= 0;
            display_val <= 0;
            prev_charge_state <= '1';
            prev_rctrigger_state <= '0';
            decimal_point <= 4;
            capacitor_value <= 0;

        ELSIF rising_edge(clk) THEN
            reset_mode <= '0';
            wait_mode <= '0';
            clock_counter <= clock_counter + 1;

            -- Detect falling edge of start_charge signal
            IF (start_charge = '0' AND prev_charge_state = '1') THEN
                start_time <= clock_counter;
            END IF;

            -- Detect rising edge of rctrigger signal
            IF (rctrigger = '1' AND prev_rctrigger_state = '0') THEN
                end_time <= clock_counter;
            END IF;

            -- Calculate time interval (convert clock to nanoseconds)
            IF end_time > start_time THEN
                time_interval <= (end_time - start_time) * 20;
            END IF;

            -- Calculate capacitance value from tau = RC
            -- Original capacitance value in nanofarads
            IF time_interval > 0 THEN
                capacitor_value <= (time_interval / R);
            END IF;

            -- Delay the 7 segment display update
            IF (clock_counter MOD 5000000 = 0) THEN -- 0.1 second delay
                -- Convert capacitance value to microfarads
                IF capacitor_value > 1000 THEN
                    display_val <= capacitor_value / 1000;
                    decimal_point <= 3;
                ELSE
                    display_val <= capacitor_value;
                    decimal_point <= 4;
                END IF;
            END IF;

            -- Set LED indicators based on capacitance range
            IF capacitor_value > 1000 THEN
                LED_MICRO <= '1';
                LED_NANO <= '0';
            ELSIF capacitor_value > 0 THEN --
                LED_MICRO <= '0';
                LED_NANO <= '1';
            ELSE
                LED_MICRO <= '0';
                LED_NANO <= '0';
                wait_mode <= '1';
            END IF;

            -- Update previous states AFTER edge detection
            prev_charge_state <= start_charge;
            prev_rctrigger_state <= rctrigger;

        END IF;
    END PROCESS;

    -- Debugging LEDs to show signal states
    -- LED_MICRO <= start_charge;
    -- LED_NANO <= rctrigger;
END Behavioral;