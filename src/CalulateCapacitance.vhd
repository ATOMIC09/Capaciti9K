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
        reset_mode   : OUT STD_LOGIC;           -- Output to reset 7-segment display
        capacitance   : OUT INTEGER            -- Output to capacitance display
    );
end CalculateCapacitance;

architecture Behavioral of CalculateCapacitance is
    constant clk_freq : INTEGER := 50000000;       -- 50 MHz clock frequency
    constant R : INTEGER := 500;                  -- Resistance value in ohms
    signal clock_counter : INTEGER RANGE 0 TO 50000000 := 0;
    signal start_time : INTEGER := 0;
    signal end_time : INTEGER := 0;
    signal captured : BOOLEAN := FALSE;            -- Flag to allow single capture of end_time
    signal prev_start_charge : STD_LOGIC := '0';   -- Previous state of start_charge
    signal prev_rctrigger : STD_LOGIC := '0';      -- Previous state of rctrigger
    signal time_interval : INTEGER := 0;           -- Time interval between start and end
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
            prev_start_charge <= '0';
            prev_rctrigger <= '0';
        elsif rising_edge(clk) then
            reset_mode <= '0';
            clock_counter <= clock_counter + 1;

            -- Detect rising edge of start_charge
            if (start_charge = '1' and prev_start_charge = '0') then
                start_time <= clock_counter;
                captured <= FALSE;                 -- Reset capture flag for next cycle
            end if;
            prev_start_charge <= start_charge;

            -- Detect rising edge of rctrigger
            if (rctrigger = '1' and prev_rctrigger = '0' and not captured) then
                end_time <= clock_counter;

                -- Calculate the time in microseconds
                display_val <= (end_time - start_time)*20/1000/R;

                captured <= TRUE;                  -- Set flag to prevent further captures
            end if;
            prev_rctrigger <= rctrigger;
        end if;
    end process;

    -- Debugging LEDs to show signal states
    LED_MICRO <= start_charge;
    LED_PICO <= rctrigger;
end Behavioral;
