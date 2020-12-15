library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main is
    port (
        clk             :   IN  std_logic;
        b1              :   IN  std_logic;
        b2              :   IN  std_logic;
        b3              :   IN  std_logic;
        b4              :   IN  std_logic;
        display_7seg    :   OUT std_logic_vector(27 DOWNTO 0);
        display_decimal :   OUT std_logic_vector(3 DOWNTO 0);
    );
end main;