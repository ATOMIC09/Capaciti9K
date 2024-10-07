-- Create a counter for measure the capacitor
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Counter is
    Port ( 
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Counter;

architecture Behavioral of Counter is
    signal count : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            count <= (others => '0');
        elsif rising_edge(CLK) then
            count <= count + 1;
        end if;
    end process;
    COUNT <= count;
end Behavioral;