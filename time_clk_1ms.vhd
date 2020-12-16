LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY time_clk_1ms IS
    PORT (
        clk         :       IN std_logic;
        clk_1ms     :       OUT std_logic := '0'
    );
END time_clk_1ms;

ARCHITECTURE logic of time_clk_1ms IS
    SIGNAL count    :       std_logic_vector(13 DOWNTO 0) := '0';
    SIGNAL temp     :       std_logic := '0';
BEGIN
    PROCESS(clk)
        BEGIN
            IF (rising_edge(clk)) THEN
                IF (count = "01001110000111") THEN 
                    count <= "00000000000000";
                    IF (temp = '0') THEN
                        clk_1ms <= '1';
                    ELSE
                        clk_1ms <= '0';
                    END IF;
                ELSE 
                    count <= count + 1;
                END IF;
            END IF;
        END PROCESS;
END logic;
