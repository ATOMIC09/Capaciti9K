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

    SIGNAL truncated_input : INTEGER RANGE 0 TO 9999; -- Hold 4 most significant digits

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
            -- Limit input to 4 most significant digits
            IF input_int > 9999 THEN
                truncated_input <= input_int / 10**(INTEGER(log(real(input_int)) / log(10.0)) - 3);
            ELSE
                truncated_input <= input_int;
            END IF;

            -- Counter for multiplexing timing
            IF counter = MAX_COUNT THEN
                counter <= 0;

                -- Update digit being displayed
                current_digit <= (current_digit + 1) MOD 4;

                -- Check if reset_mode is active to display "rSEt"
                IF reset_mode = '1' THEN
                    display_data <= decode_rSEt(current_digit);

                    -- Control transistors for each digit in "rSEt" mode
                    IF current_digit = 0 THEN
                        digit1 <= '1'; digit2 <= '0'; digit3 <= '0'; digit4 <= '0';
                    ELSIF current_digit = 1 THEN
                        digit1 <= '0'; digit2 <= '1'; digit3 <= '0'; digit4 <= '0';
                    ELSIF current_digit = 2 THEN
                        digit1 <= '0'; digit2 <= '0'; digit3 <= '1'; digit4 <= '0';
                    ELSE
                        digit1 <= '0'; digit2 <= '0'; digit3 <= '0'; digit4 <= '1';
                    END IF;

                    dp <= '0'; -- No decimal point in "rSEt" mode

                ELSE
                    -- Normal operation: Extract each digit from truncated integer
                    CASE current_digit IS
                        WHEN 3 => digit_value <= (truncated_input / 1000) MOD 10; -- Leftmost digit
                        WHEN 0 => digit_value <= (truncated_input / 100) MOD 10;
                        WHEN 1 => digit_value <= (truncated_input / 10) MOD 10;
                        WHEN 2 => digit_value <= truncated_input MOD 10; -- Rightmost digit
                        WHEN OTHERS => digit_value <= 0;
                    END CASE;

                    -- Control transistors for each digit
                    IF current_digit = 0 THEN
                        digit1 <= '1'; digit2 <= '0'; digit3 <= '0'; digit4 <= '0';
                    ELSIF current_digit = 1 THEN
                        digit1 <= '0'; digit2 <= '1'; digit3 <= '0'; digit4 <= '0';
                    ELSIF current_digit = 2 THEN
                        digit1 <= '0'; digit2 <= '0'; digit3 <= '1'; digit4 <= '0';
                    ELSE
                        digit1 <= '0'; digit2 <= '0'; digit3 <= '0'; digit4 <= '1';
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
