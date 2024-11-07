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
        LED_NANO     : OUT STD_LOGIC;          -- LED indicator for picofarad range
        display_val  : OUT INTEGER;            -- Output to 7-segment display
        reset_mode   : OUT STD_LOGIC;           -- Output to reset 7-segment display
        decimal_point : OUT INTEGER RANGE 0 TO 4
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
    signal capacitor_value : INTEGER := 0;
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
            prev_charge_state <= '1';
            prev_rctrigger_state <= '0';
            decimal_point <= 4;
            capacitor_value <= 0;

        elsif rising_edge(clk) then
            reset_mode <= '0';
            clock_counter <= clock_counter + 1;
            
            -- Detect falling edge of start_charge signal
            if (start_charge = '0' and prev_charge_state = '1') then
                start_time <= clock_counter;
            end if;

            -- Detect rising edge of rctrigger signal
            if (rctrigger = '1' and prev_rctrigger_state = '0') then
                end_time <= clock_counter;
            end if;

            -- Calculate time interval (convert clock to nanoseconds)
            if end_time > start_time then
                time_interval <= (end_time - start_time)*20;
            end if;

            -- Calculate capacitance value from tau = RC
            -- Original capacitance value in nanofarads
            if time_interval > 0 then
                capacitor_value <= (time_interval / R); 
            end if;

            -- Convert capacitance value to microfarads
            if capacitor_value > 1000 then
                display_val <= capacitor_value / 1000;
                decimal_point <= 3;
            else
                display_val <= capacitor_value;
                decimal_point <= 4;
            end if;

            -- Set LED indicators based on capacitance range
            if capacitor_value > 1000 then
                LED_MICRO <= '1';
                LED_NANO <= '0';
            else
                LED_MICRO <= '0';
                LED_NANO <= '1';
            end if;

            -- Update previous states AFTER edge detection
            prev_charge_state <= start_charge;
            prev_rctrigger_state <= rctrigger;
            
        end if;
    end process;

    -- Debugging LEDs to show signal states
    -- LED_MICRO <= start_charge;
    -- LED_NANO <= rctrigger;
end Behavioral;
