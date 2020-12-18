LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY time_clk_8ms IS
    PORT (
        clk         :       IN std_logic; --input clock of the board 10MHz
        clk_8ms     :       OUT std_logic := '0' --output clock of 125hz
    );
END time_clk_8ms;

ARCHITECTURE logic of time_clk_8ms IS
    SIGNAL count    :       unsigned(16 DOWNTO 0) := '0'; --counter used for n modulo counter
    SIGNAL temp     :       std_logic := '0'; --temp holds the value of clock of 125hz which is used during execution, as clk_8ms can't be used
BEGIN
    PROCESS(clk)    --triggered when clk changes
        BEGIN
            IF (rising_edge(clk)) THEN  --process only runs on rising edge of clk
                IF (count = "1001110000111111") THEN --if count = 39999(10M/(125*2) - 1), count is made zero and clk_8ms and temp flipped
                    count <="0000000000000000";
                    IF (temp = '0') THEN --if temp was 0, then clk_8ms was also 0, and thus both are flipped and vice versa for if temp was 1
                        clk_8ms <= '1';
                        temp <= '1';
                    ELSE
                        clk_8ms <= '0';
                        temp <= '0';
                    END IF;
                ELSE 
                    count <= count + 1; -- else count is increased by 1
                END IF;
            END IF;
        END PROCESS;
END logic;

