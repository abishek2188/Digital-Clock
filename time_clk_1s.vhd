LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY time_clk_1s IS
    PORT (
        clk     :       IN std_logic;   --input clock of the board 10MHz
        clk_1s  :       OUT std_logic := '0'    --output clock of 1hz
    );
END time_clk_1s;

ARCHITECTURE logic of time_clk_1s IS
    SIGNAL count    :       unsigned(23 DOWNTO 0) := '0';   --counter used for n modulo counter
    SIGNAL temp     :       std_logic := '0';   --temp holds the value of clock of 1hz which is used during execution, as clk_1s can't be used
BEGIN
    PROCESS(clk)    --triggered when clk changes
        BEGIN
            IF (rising_edge(clk)) THEN  --process only runs on rising edge of clk
                IF (count =  "010011000100101100111111") THEN   --if count = 4999999(10M/(1*2) - 1), count is made zero and clk_1s and temp flipped
                    count <= '0';
                    IF (temp = '0') THEN --if temp was 0, then clk_1ms was also 0, and thus both are flipped and vice versa for if temp was 1
                        clk_1s <= '1';
                        temp <= '1';
                    ELSE
                        clk_1s <= '0';
                        temp <= '0';
                    END IF;
                ELSE 
                    count <= count + 1; -- else count is increased by 1
                END IF;
            END IF;
        END PROCESS;
END logic;

