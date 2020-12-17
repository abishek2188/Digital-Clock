LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY time_clk_2ms IS
    PORT (
        clk         :       IN std_logic;
        clk_2ms     :       OUT std_logic := '0'
    );
END time_clk_2ms;

ARCHITECTURE logic of time_clk_2ms IS
    SIGNAL count    :       unsigned(14 DOWNTO 0) := '0';
    SIGNAL temp     :       std_logic := '0';
BEGIN
    PROCESS(clk)
        BEGIN
            IF (rising_edge(clk)) THEN
                IF (count = "100111000011111") THEN 
                    count <= "000000000000000";
                    IF (temp = '0') THEN
                        clk_2ms <= '1';
                        temp <= '1';
                    ELSE
                        clk_2ms <= '0';
                        temp <= '0';
                    END IF;
                ELSE 
                    count <= count + 1;
                END IF;
            END IF;
        END PROCESS;
END logic;
END architecture;
