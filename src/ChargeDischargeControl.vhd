LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ChargeDischargeControl IS
    PORT (
        CLK_50M : IN STD_LOGIC; -- 50 MHz clock input
        CHARGE : OUT STD_LOGIC; -- Output to control charge
        DISCHARGE : OUT STD_LOGIC; -- Output to control discharge
        reset : IN STD_LOGIC -- Reset signal
    );
END ENTITY ChargeDischargeControl;

ARCHITECTURE Behavioral OF ChargeDischargeControl IS
    TYPE state_type IS (IDLE, DISCHARGE_HIGH, DISCHARGE_LOW, CHARGE_HIGH, CHARGE_LOW);
    SIGNAL state : state_type := IDLE;
    SIGNAL counter : unsigned(24 DOWNTO 0) := (OTHERS => '0'); -- Counter for delays
BEGIN
    PROCESS (CLK_50M, reset)
    BEGIN
        IF reset = '0' THEN
            state <= IDLE;
            counter <= (OTHERS => '0');
        ELSIF rising_edge(CLK_50M) THEN
            CASE state IS
                WHEN IDLE =>
                    -- Initialize outputs
                    CHARGE <= '0';
                    DISCHARGE <= '0';
                    state <= DISCHARGE_HIGH;

                WHEN DISCHARGE_HIGH =>
                    DISCHARGE <= '1';
                    IF counter = 5000000 THEN -- 100 ms delay
                        counter <= (OTHERS => '0');
                        state <= DISCHARGE_LOW;
                    ELSE
                        counter <= counter + 1;
                    END IF;

                WHEN DISCHARGE_LOW =>
                    DISCHARGE <= '0';
                    IF counter = 500000 THEN -- 10 ms delay
                        counter <= (OTHERS => '0');
                        state <= CHARGE_HIGH;
                    ELSE
                        counter <= counter + 1;
                    END IF;

                WHEN CHARGE_HIGH =>
                    CHARGE <= '0';
                    IF counter = 25000000 THEN -- 500 ms delay
                    -- IF counter = 11250000 THEN -- 225 ms delay (test)
                    -- IF counter = 500000 THEN -- 10 ms delay (test2)
                        counter <= (OTHERS => '0');
                        state <= CHARGE_LOW;
                    ELSE
                        counter <= counter + 1;
                    END IF;

                WHEN CHARGE_LOW =>
                    CHARGE <= '1';
                    IF counter = 500000 THEN -- 10 ms delay
                        counter <= (OTHERS => '0');
                        state <= DISCHARGE_HIGH;
                    ELSE
                        counter <= counter + 1;
                    END IF;

                WHEN OTHERS =>
                    state <= IDLE;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;