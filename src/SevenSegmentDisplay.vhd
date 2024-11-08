LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.MATH_REAL.ALL;
ENTITY SevenSegmentDisplay IS
    PORT (
        clk : IN STD_LOGIC; -- Clock input for multiplexing
        input_int : IN INTEGER RANGE 0 TO 50000000; -- Integer input
        reset_mode : IN STD_LOGIC; -- Signal to trigger "rSEt" display
        wait_mode : IN STD_LOGIC; -- Signal to trigger "wait" display
        decimal_point : IN INTEGER RANGE 0 TO 4; -- Decimal point position (0-3)
        digit1, digit2, digit3, digit4 : OUT STD_LOGIC; -- Digit control for transistors
        a, b, c, d, e, f, g, dp : OUT STD_LOGIC -- Segment outputs
    );
END ENTITY SevenSegmentDisplay;

ARCHITECTURE Behavioral OF SevenSegmentDisplay IS
    SIGNAL current_digit : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL digit_value : INTEGER RANGE 0 TO 9 := 0;
    SIGNAL display_data : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL counter : INTEGER := 0;
    CONSTANT MAX_COUNT : INTEGER := 1000; -- Faster refresh rate for less flicker

    -- Digit decoding for 7-segment display (active high)
    FUNCTION decode_digit(digit : INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE digit IS
            WHEN 0 => RETURN "1111110"; -- Display "0"
            WHEN 1 => RETURN "0110000"; -- Display "1"
            WHEN 2 => RETURN "1101101"; -- Display "2"
            WHEN 3 => RETURN "1111001"; -- Display "3"
            WHEN 4 => RETURN "0110011"; -- Display "4"
            WHEN 5 => RETURN "1011011"; -- Display "5"
            WHEN 6 => RETURN "1011111"; -- Display "6"
            WHEN 7 => RETURN "1110000"; -- Display "7"
            WHEN 8 => RETURN "1111111"; -- Display "8"
            WHEN 9 => RETURN "1111011"; -- Display "9"
            WHEN OTHERS => RETURN "0000000"; -- Blank/error
        END CASE;
    END FUNCTION;

    -- Custom function to decode "rSEt"
    FUNCTION decode_rSEt(index : INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE index IS
            WHEN 0 => RETURN "0000101"; -- 'r' custom pattern
            WHEN 1 => RETURN "1011011"; -- 'S' pattern (similar to '5')
            WHEN 2 => RETURN "1001111"; -- 'E' pattern
            WHEN 3 => RETURN "0001111"; -- 't' custom pattern
            WHEN OTHERS => RETURN "0000000"; -- Blank/error
        END CASE;
    END FUNCTION;

BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            -- Counter for multiplexing timing
            IF counter = MAX_COUNT THEN
                counter <= 0;

                -- Update digit being displayed
                current_digit <= (current_digit + 1) MOD 4;

                -- Check if reset_mode is active to display "rSEt"
                IF reset_mode = '1' THEN
                    display_data <= decode_rSEt(current_digit);

                    -- Turn off all digits briefly
                    digit1 <= '0';
                    digit2 <= '0';
                    digit3 <= '0';
                    digit4 <= '0';

                    -- Control transistors for each digit in "rSEt" mode
                    IF current_digit = 0 THEN
                        digit1 <= '1';
                        digit2 <= '0';
                        digit3 <= '0';
                        digit4 <= '0';
                    ELSIF current_digit = 1 THEN
                        digit1 <= '0';
                        digit2 <= '1';
                        digit3 <= '0';
                        digit4 <= '0';
                    ELSIF current_digit = 2 THEN
                        digit1 <= '0';
                        digit2 <= '0';
                        digit3 <= '1';
                        digit4 <= '0';
                    ELSE
                        digit1 <= '0';
                        digit2 <= '0';
                        digit3 <= '0';
                        digit4 <= '1';
                    END IF;

                    dp <= '0'; -- No decimal point in "rSEt" mode

                -- Check if wait_mode is active to display "wait"
                ELSIF wait_mode = '1' THEN

                    -- Turn off all digits briefly
                    digit1 <= '0';
                    digit2 <= '0';
                    digit3 <= '0';
                    digit4 <= '0';
                    CASE current_digit IS
                        WHEN 0 => display_data <= "0101011"; -- 'w' custom pattern
                        WHEN 1 => display_data <= "1110111"; -- 'a' custom pattern
                        WHEN 2 => display_data <= "0010000"; -- 'i' custom pattern
                        WHEN 3 => display_data <= "0001111"; -- 't' custom pattern
                        WHEN OTHERS => display_data <= "0000000"; -- Blank/error
                    END CASE;

                    -- Control transistors for each digit in "wait" mode
                    IF current_digit = 0 THEN
                        digit1 <= '1';
                        digit2 <= '0';
                        digit3 <= '0';
                        digit4 <= '0';
                    ELSIF current_digit = 1 THEN
                        digit1 <= '0';
                        digit2 <= '1';
                        digit3 <= '0';
                        digit4 <= '0';
                    ELSIF current_digit = 2 THEN
                        digit1 <= '0';
                        digit2 <= '0';
                        digit3 <= '1';
                        digit4 <= '0';
                    ELSE
                        digit1 <= '0';
                        digit2 <= '0';
                        digit3 <= '0';
                        digit4 <= '1';
                    END IF;

                    dp <= '0'; -- No decimal point in "wait" mode

                ELSE
                    -- Turn off all digits briefly
                    digit1 <= '0';
                    digit2 <= '0';
                    digit3 <= '0';
                    digit4 <= '0';
                    IF input_int < 10000 THEN
                        CASE current_digit IS
                            WHEN 3 => digit_value <= (input_int / 1000) MOD 10; -- Leftmost digit
                            WHEN 0 => digit_value <= (input_int / 100) MOD 10;
                            WHEN 1 => digit_value <= (input_int / 10) MOD 10;
                            WHEN 2 => digit_value <= (input_int / 1) MOD 10; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;

                    ELSIF (input_int >= 10000 and input_int < 100000) THEN
                        -- Normal operation: Extract each digit from truncated integer
                        CASE current_digit IS
                            WHEN 3 => digit_value <= (input_int / 10000) MOD 10; -- Leftmost digit
                            WHEN 0 => digit_value <= (input_int / 1000) MOD 10;
                            WHEN 1 => digit_value <= (input_int / 100) MOD 10;
                            WHEN 2 => digit_value <= (input_int / 10) MOD 10; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;
                    
                    ELSIF (input_int >= 100000 and input_int < 1000000) THEN
                    -- Normal operation: Extract each digit from truncated integer
                        CASE current_digit IS
                            WHEN 3 => digit_value <= (input_int / 100000) MOD 10; -- Leftmost digit
                            WHEN 0 => digit_value <= (input_int / 10000) MOD 10;
                            WHEN 1 => digit_value <= (input_int / 1000) MOD 10;
                            WHEN 2 => digit_value <= (input_int / 100) MOD 10; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;
                    
                    ELSIF (input_int >= 1000000 and input_int < 10000000) THEN
                    -- Normal operation: Extract each digit from truncated integer
                        CASE current_digit IS
                            WHEN 3 => digit_value <= (input_int / 1000000) MOD 10; -- Leftmost digit
                            WHEN 0 => digit_value <= (input_int / 100000) MOD 10;
                            WHEN 1 => digit_value <= (input_int / 10000) MOD 10;
                            WHEN 2 => digit_value <= (input_int / 1000) MOD 10; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;

                    ELSIF (input_int >= 10000000 and input_int < 100000000) THEN
                    -- Normal operation: Extract each digit from truncated integer
                        CASE current_digit IS
                            WHEN 3 => digit_value <= (input_int / 10000000) MOD 10; -- Leftmost digit
                            WHEN 0 => digit_value <= (input_int / 1000000) MOD 10;
                            WHEN 1 => digit_value <= (input_int / 100000) MOD 10;
                            WHEN 2 => digit_value <= (input_int / 10000) MOD 10; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;

                    ELSIF (input_int >= 100000000 and input_int < 1000000000) THEN
                    -- Normal operation: Extract each digit from truncated integer
                        CASE current_digit IS
                            WHEN 3 => digit_value <= (input_int / 100000000) MOD 10; -- Leftmost digit
                            WHEN 0 => digit_value <= (input_int / 10000000) MOD 10;
                            WHEN 1 => digit_value <= (input_int / 1000000) MOD 10;
                            WHEN 2 => digit_value <= (input_int / 100000) MOD 10; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;

                    ELSIF (input_int >= 1000000000) THEN
                    -- Display E
                        CASE current_digit IS
                            WHEN 3 => digit_value <= 2; -- Leftmost digit
                            WHEN 0 => digit_value <= 0;
                            WHEN 1 => digit_value <= 0;
                            WHEN 2 => digit_value <= 0; -- Rightmost digit
                            WHEN OTHERS => digit_value <= 0;
                        END CASE;

                    END IF;
                    -- Control transistors for each digit
                    IF current_digit = 0 THEN
                        digit1 <= '1';
                        digit2 <= '0';
                        digit3 <= '0';
                        digit4 <= '0';
                    ELSIF current_digit = 1 THEN
                        digit1 <= '0';
                        digit2 <= '1';
                        digit3 <= '0';
                        digit4 <= '0';
                    ELSIF current_digit = 2 THEN
                        digit1 <= '0';
                        digit2 <= '0';
                        digit3 <= '1';
                        digit4 <= '0';
                    ELSE
                        digit1 <= '0';
                        digit2 <= '0';
                        digit3 <= '0';
                        digit4 <= '1';
                    END IF;

                    -- Decode digit to 7-segment display
                    display_data <= decode_digit(digit_value);

                    -- Set decimal point if needed
                    IF current_digit = decimal_point THEN
                        dp <= '1'; -- Active high for decimal point
                    ELSE
                        dp <= '0';
                    END IF;

                END IF;
            ELSE
            counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Map display data to 7-segment output segments
    a <= display_data(6);
    b <= display_data(5);
    c <= display_data(4);
    d <= display_data(3);
    e <= display_data(2);
    f <= display_data(1);
    g <= display_data(0);

END ARCHITECTURE Behavioral;