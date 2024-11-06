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
    constant R : INTEGER := 510;                   -- Resistance value in ohms
    signal clock_counter : INTEGER RANGE 0 TO 50000000 := 0;
    signal start_time : INTEGER := 0;
    signal end_time : INTEGER := 0;
    signal time_interval : INTEGER := 0;
    signal prev_charge_state : STD_LOGIC := '0';
    signal prev_rctrigger_state : STD_LOGIC := '0';
begin

    -- Process to handle interval timing and display logic
    process (clk, reset)
    begin
        if reset = '0' then
            reset_mode <= '1';
            clock_counter <= 0;
            start_time <= 0;
            end_time <= 0;
            time_interval <= 0;
            display_val <= 0;
            prev_charge_state <= '0';
            prev_rctrigger_state <= '0';

        elsif rising_edge(clk) then
            reset_mode <= '0';
            clock_counter <= clock_counter + 1;
            
            -- Detect falling edge of start_charge signal
            if (start_charge = '1' and prev_charge_state = '0') then
                start_time <= clock_counter;
            end if;

            -- Detect rising edge of rctrigger signal
            if (rctrigger = '1' and prev_rctrigger_state = '0') then
                end_time <= clock_counter;
            end if;

            -- Calculate time interval (convert clock to seconds)
            if end_time > start_time then
                time_interval <= (end_time - start_time) / clk_freq;
            end if;

            -- Calculate capacitance value
            display_val <= time_interval / R;

            -- Update previous states AFTER edge detection
            prev_charge_state <= start_charge;
            prev_rctrigger_state <= rctrigger;
            
        end if;
    end process;

    -- Debugging LEDs to show signal states
    LED_MICRO <= start_charge;
    LED_PICO <= rctrigger;
end Behavioral;
