LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;
        b1, b2, b3, b4  :   IN  std_logic;
        display    :   OUT unsigned(27 DOWNTO 0);
        display_decimal :   OUT unsigned(3 DOWNTO 0)
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

    COMPONENT time_clk_8ms IS
        PORT (
            clk         :       IN std_logic;
            clk_8ms     :       OUT std_logic := '0'
        );
    END COMPONENT;

    COMPONENT bin2bcd is
        port (  bin  : in  unsigned (6 downto 0);
            bcd1 : out unsigned (3 downto 0);
            bcd2 : out unsigned (3 downto 0)
        );
    END COMPONENT;

    COMPONENT bcd_to_7seg_display is
        PORT(
		bcd				:	IN		STD_LOGIC_VECTOR(3 DOWNTO 0);		--number to display in BCD
        display_7seg	:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0);	--outputs to seven segment display
        clk_8ms         :   IN      STD_LOGIC
        );
    END COMPONENT;
    
    TYPE state_type IS (time_hour_min, time_min_sec, change_hour, change_min);
    TYPE state_type1 IS (display_time, change_time);
    SIGNAL state1                                               :   state_type1;
    SIGNAL state                                                :   state_type;
    SIGNAL clk_1ms                                              :   std_logic := '0';
    SIGNAL clk_1s                                               :   std_logic := '0';
    SIGNAL clk_2ms                                               :   std_logic := '0';
    SIGNAL clk_8ms                                               :   std_logic := '0';
    SIGNAL minute, temp_minute, second, temp_second, hour, temp_hour     :   unsigned(6 DOWNTO 0) := '0';
    SIGNAL refresh                                              :   unsigned(1 DOWNTO 0) := '0';
    SIGNAL left1, left0, right1, right0    :   unsigned(3 downto 0);
    SIGNAL 7segleft1, 7segleft0, 7segright1, 7segright0     :   std_logic_vector(6 DOWNTO 0);
BEGIN
    create_1s_clock: time_clk_1s port map (clk, clk_1s);
    create_1ms_clock: time_clk_1ms port map (clk, clk_1ms);
    create_8ms_clock: time_clk_8ms port map (clk, clk_8ms);
    PROCESS(clk_1s) --keeping track of time
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
    PROCESS(clk_8ms) --display module
        BEGIN
            IF refresh = "11" THEN
                refresh <= "00"
            ELSE 
                refresh <= refresh + 1;
            END IF;
            IF refresh = "00" THEN
                display(27 DOWNTO 21) <= 7segleft1;
            ELSIF refresh = "01" THEN
                display(20 DOWNTO 14) <= 7segleft0;
            ELSIF refresh = "10" THEN
                display(13 DOWNTO 7) <= 7segright1;
            ELSE
                display(6 DOWNTO 0) <= 7segright0;
            END IF;


        END PROCESS;
    WITH state1 SELECT
        left <=     minute WHEN time_min_sec,
                    hour WHEN others;
    WITH state1 SELECT
        right <=    second WHEN time_min_sec,
                    hour WHEN others;
    create_bin2bcd_left: bin2bcd port map (left, left0, left1);
    create_bin2bcd_right: bin2bcd port map (right, right0, right1);
    drive_display_left1: bcd_to_7seg_display port map(left1, 7segleft1, clk_8ms);
    drive_display_left0: bcd_to_7seg_display port map(left0, 7segleft0, clk_8ms);
    drive_display_right1: bcd_to_7seg_display port map(right1, 7segright1, clk_8ms);
    drive_display_right0: bcd_to_7seg_display port map(right0, 7segright0, clk_8ms);

                    
        
                

            

        