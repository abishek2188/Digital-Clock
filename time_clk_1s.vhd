LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY time_clk_1s IS
    PORT (
        clk     :       IN std_logic;
        clk_1s  :       OUT std_logic := '0';
    );
END time_clk_1s;

ARCHITECTURE logic of time_clk_1s IS
    SIGNAL count    :       std_logic_vector(23 DOWNTO 0) := '0';
    SIGNAL temp     :       std_logic := '0';
BEGIN
    PROCESS(clk)
        BEGIN
            IF (rising_edge(clk)) THEN
                IF (count =  "010011000100101101000000") THEN 
                    count <= '0';
                    IF (temp = '0') THEN
                        clk_1s <= '1';
                    ELSE
                        clk_1s <= '0';
                    END IF;
                ELSE 
                    count <= count + 1;
                END IF;
            END IF;
        END PROCESS;
END logic;
