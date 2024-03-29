LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY time_clk_500ms IS
    PORT (
        clk     :       IN std_logic;
        clk_500ms  :       OUT std_logic := '0'
    );
END time_clk_500ms;

ARCHITECTURE logic of time_clk_500ms IS
    SIGNAL count    :       unsigned(21 DOWNTO 0) := '0';
    SIGNAL temp     :       std_logic := '0';
BEGIN
    PROCESS(clk)
        BEGIN
            IF (rising_edge(clk)) THEN
                IF (count =  "1001100010010110011111") THEN 
                    count <= '0';
                    IF (temp = '0') THEN
                        clk_500ms <= '1';
                        temp <= '1';
                    ELSE
                        clk_500ms <= '0';
                        temp <= '0';
                    END IF;
                ELSE 
                    count <= count + 1;
                END IF;
            END IF;
        END PROCESS;
END logic;

