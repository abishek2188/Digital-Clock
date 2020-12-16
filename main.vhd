LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;
        b1, b2, b3, b4  :   IN  std_logic;
        display_7seg    :   OUT std_logic_vector(27 DOWNTO 0);
        display_decimal :   OUT std_logic_vector(3 DOWNTO 0)
    );
END main;

ARCHITECTURE logic OF main is
    COMPONENT time_clk_1s IS
        PORT (
            clk     :       IN std_logic;
            clk_1s  :       OUT std_logic := '0'
        );
    END COMPONENT;

    COMPONENT time_clk_1ms IS
        PORT (
            clk         :       IN std_logic;
            clk_1ms     :       OUT std_logic := '0'
        );
    END COMPONENT;
    TYPE state_type IS (time_hour_min, time_min_sec, change_hour, change_min);
    TYPE state_type1 IS (display_time, change_time);
    SIGNAL state1                                               :   state_type1;
    SIGNAL state                                                :   state_type;
    SIGNAL clk_1ms                                              :   std_logic := '0';
    SIGNAL clk_1s                                               :   std_logic := '0';
    SIGNAL minute, temp_minute, second, temp_second, hour, temp_hour     :   std_logic_vector(6 DOWNTO 0) := '0';
    SIGNAL refresh                                              :   std_logic_vector(1 DOWNTO 0) := '0';

BEGIN
    create_1s_clock: time_clk_1s port map (clk, clk_1s);
    create_1ms_clock: time_clk_1ms port map (clk, clk_1ms);
    PROCESS(clk_1s)
        BEGIN
            CASE state1 IS
                WHEN display_time =>
                    IF rising_edge(clk_1s) THEN
                        second <= second + 1;
                        IF (second = "111100") THEN
                            second <= '0';
                            minute <= minute + 1;
                            IF (minute = "111100") THEN
                                minute <= '0';
                                hour <= hour + 1;
                                IF (hour = "011000") THEN
                                    hour <= '0';
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                WHEN change_time =>
            END CASE;
        END PROCESS;
    PROCESS(clk_2ms)
        BEGIN
            IF refresh = "11" THEN
                refresh <= "00"
            ELSE 
                refresh <= refresh + 1;
            END IF;
            CASE state is
                WHEN time_hour_min =>
                    left <= hour;
                    right <= minute;--write
                WHEN time_min_sec =>
                    left <= minute;
                    right <= second;--write
                WHEN change_hour =>
                    left <= hour;
                    right <= minute;--write
                WHEN change_min =>
                    left <= hour;
                    right <= minute;--write
            END CASE;
        

                    
        
                

            

        