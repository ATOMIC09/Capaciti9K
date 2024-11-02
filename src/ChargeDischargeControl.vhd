library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ChargeDischargeControl is
    port (
        CLK_50M : in std_logic;          -- 50 MHz clock input
        CHARGE : out std_logic;          -- Output to control charge
        DISCHARGE : out std_logic        -- Output to control discharge
    );
end entity ChargeDischargeControl;

architecture Behavioral of ChargeDischargeControl is
    type state_type is (IDLE, DISCHARGE_HIGH, DISCHARGE_LOW, CHARGE_HIGH, CHARGE_LOW);
    signal state : state_type := IDLE;
    signal counter : unsigned(24 downto 0) := (others => '0'); -- Counter for delays
begin
    process (CLK_50M)
    begin
        if rising_edge(CLK_50M) then
            case state is
                when IDLE =>
                    -- Initialize outputs
                    CHARGE <= '0';
                    DISCHARGE <= '0';
                    state <= DISCHARGE_HIGH;
                
                when DISCHARGE_HIGH =>
                    DISCHARGE <= '1';
                    if counter = 5000000 then  -- 100 ms delay
                        counter <= (others => '0');
                        state <= DISCHARGE_LOW;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when DISCHARGE_LOW =>
                    DISCHARGE <= '0';
                    if counter = 500000 then  -- 10 ms delay
                        counter <= (others => '0');
                        state <= CHARGE_HIGH;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when CHARGE_HIGH =>
                    CHARGE <= '1';
                    if counter = 25000000 then  -- 500 ms delay
                        counter <= (others => '0');
                        state <= CHARGE_LOW;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when CHARGE_LOW =>
                    CHARGE <= '0';
                    if counter = 500000 then  -- 10 ms delay
                        counter <= (others => '0');
                        state <= DISCHARGE_HIGH;
                    else
                        counter <= counter + 1;
                    end if;
                    
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;
end architecture Behavioral;
