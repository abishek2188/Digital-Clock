LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;
        b1              :   IN  std_logic;
        b2              :   IN  std_logic;
        b3              :   IN  std_logic;
        b4              :   IN  std_logic;
        display_7seg    :   OUT std_logic_vector(27 DOWNTO 0);
        display_decimal :   OUT std_logic_vector(3 DOWNTO 0);
    );
END main;

ARCHITECTURE logic OF main is
    SIGNAL clk_1        :   std_logic := '0';
    SIGNAL count        :   std_logic_vector(13 DOWNTO 0) := "00000000000000";
BEGIN
    PROCESS(clk)
        BEGIN
            IF (rising_edge(clk)) THEN
                IF (count = "01001110000111") THEN 
                    count <= "00000000000000";
                    IF (clk_1 = '0') THEN
                        clk_1 <= '1';
                    ELSE
                        clk_1 <= '0';
                    END IF;
                ELSE 
                    count <= count + 1;
                END IF;
            END IF;
        END PROCESS;
    
        