library ieee;
ieee.std_logic_1164.all;
ieee.std_logic_arith.all;
ieee.std_logic_unsigned.all;

entity SimpleC-Meter is
    port (
        CLK   : in std_logic;
        SEVENSEG_DIGIT_1, SEVENSEG_DIGIT_2, SEVENSEG_DIGIT_3, SEVENSEG_DIGIT_4, SEVENSEG_DIGIT_5, SEVENSEG_DIGIT_6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    );
end entity;

architecture Behavioal of SimpleC-Meter is

begin

    

end architecture;