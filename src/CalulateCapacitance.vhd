library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CalculateCapacitance is
    Port (
        clk          : IN STD_LOGIC;           -- 50 MHz clock
        reset        : IN STD_LOGIC;           -- reset button
        start_charge : IN STD_LOGIC;           -- signal when capacitor starts charging
        rctrigger    : IN STD_LOGIC;           -- signal when capacitor reaches 63.2%
        LED_MICRO    : OUT STD_LOGIC;          -- LED indicator for microfarad range
        LED_PICO     : OUT STD_LOGIC;          -- LED indicator for picofarad range
        display_val  : OUT INTEGER;            -- Output to 7-segment display
        reset_mode   : OUT STD_LOGIC           -- Output to reset 7-segment display
    );
end CalculateCapacitance;

architecture Behavioral of CalculateCapacitance is
    constant clk_freq : INTEGER := 50000000;       -- 50 MHz clock frequency
    signal clock_counter : INTEGER RANGE 0 TO 50000000 := 0;
    signal start_time : INTEGER := 0;
    signal end_time : INTEGER := 0;
    signal captured : BOOLEAN := FALSE;            -- Flag to allow single capture of end_time
begin

    -- Process to handle interval timing and display logic
    process (clk, reset)
    begin
        if reset = '0' then
            reset_mode <= '1';
            clock_counter <= 0;
            start_time <= 0;
            end_time <= 0;
            captured <= FALSE;
            display_val <= 0;
        elsif rising_edge(clk) then
            reset_mode <= '0';
            clock_counter <= clock_counter + 1;

            -- Capture start_time when start_charge goes high
            if start_charge = '1' then
                start_time <= clock_counter;
                captured <= FALSE;                 -- Reset capture flag for next cycle
            end if;

            -- Capture end_time only once when rctrigger goes high
            if rctrigger = '1' and not captured then
                end_time <= clock_counter;
                display_val <= end_time - start_time;   -- Update display_val once
                captured <= TRUE;                  -- Set flag to prevent further captures
            end if;
        end if;
    end process;

    -- Debugging LEDs to show signal states
    LED_MICRO <= start_charge;
    LED_PICO <= rctrigger;
end Behavioral;
