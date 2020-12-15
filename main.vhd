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
    COMPONENT time_clk_1s IS
        PORT (
            clk     :       IN std_logic;
            clk_1s  :       OUT std_logic := '0';
        );
    END COMPONENT;

    COMPONENT time_clk_1ms IS
        PORT (
            clk         :       IN std_logic;
            clk_1ms     :       OUT std_logic := '0';
        );
    END COMPONENT;

    SIGNAL clk_1ms          :   std_logic := '0';
    SIGNAL clk_1s           :   std_logic := '0';
BEGIN
    create_1s_clock: time_clk_1s port map (clk, clk_1s);
    create_1ms_clock: time_clk_1ms port map (clk, clk_1ms);
            

        