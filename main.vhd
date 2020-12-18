LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;
        b1, b2, b3, b4  :   IN  std_logic;
        display_cathode    :   OUT std_logic_vector(6 DOWNTO 0) := "1111111";
        display_decimal :   OUT std_logic_vector := '1';
        display_anode :   OUT std_logic_vector(3 DOWNTO 0) := "0000" 
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
        display_7seg	:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0)	--outputs to seven segment display
        );
    END COMPONENT;
    
    TYPE state_type IS (time_hour_min, time_min_sec, change_hour1, change_hour0, change_min1, change_min0);
    TYPE state_type1 IS (display_time, change_time);
    TYPE state_type2 IS (idle, init1, init2, init3, init4);
    TYPE state_type3 IS (flash, no_flash);
    SIGNAL state3                                               :   state_type3 := no_flash; 
    SIGNAL state2                                               :   state_type2 := idle;
    SIGNAL state1                                               :   state_type1 := display_time;
    SIGNAL state                                                :   state_type := time_hour_min;
    SIGNAL clk_1ms                                              :   std_logic := '0';
    SIGNAL clk_1s                                               :   std_logic := '0';
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
            CASE state IS
                WHEN time_hour_min =>
                    if rising_edge(clk_1s) THEN
                        state3 <= flash;
                    ELSE
                        state3 <= no_flash;
                    END IF;
                WHEN others =>
            END CASE;
        END PROCESS;
    
    PROCESS(clk_8ms) --display module
        BEGIN
        display_anode <= "0000";
            IF refresh = "11" THEN
                refresh <= "00"
            ELSE 
                refresh <= refresh + 1;
            END IF;
            IF refresh = "00" THEN
                display_cathode <= 7segleft1;
                display_anode(3) <= '1';
            ELSIF refresh = "01" THEN
                display_cathode <= 7segleft0;
                display_anode(2) <= '1';
            ELSIF refresh = "10" THEN
                display_cathode <= 7segright1;
                display_anode(1) <= '1';
            ELSE
                display_cathode <= 7segright0;
                display_anode(0) <= '1';
                CASE state3 is
                    WHEN flash =>
                        display_decimal <= '0';
                    WHEN no_flash =>
                        display_decimal <= '1';
                END CASE;
            END IF;


        END PROCESS;
    
    PROCESS(clk_1ms)
        BEGIN
            CASE state2 IS
                WHEN idle =>
                    CASE state IS
                        WHEN time_hour_min =>
                            IF b1='1' THEN
                                state <= change_hour1;
                                state1 <= change_time;
                                state2 <= init1;
                                state3 <= no_flash;
                            ELSIF b4 = '1' THEN
                                state <= time_min_sec;
                                state2 <= init4;
                            END IF;
                        WHEN time_min_sec =>
                            IF b1 <= '1' THEN
                                state <= change_hour1;
                                state1 <= change_time;
                                state2 <= init1;
                            ELSIF b4 = '1' THEN
                                state <= time_hour_min;
                                state2 <= init4;
                            END IF;
                        WHEN change_hour1 =>
                            IF b1 = '1' THEN
                                state <= time_hour_min;
                                state1 <= display_time;
                                state2 <= init1;
                            ELSIF b4 = '1' THEN
                                state <= change_hour0;
                                state2 <= init4;
                            ELSIF b2 = '1' THEN
                                IF hour > "0010011" THEN
                                    hour <= hour - "0010100";
                                ELSIF hour < "0001110" THEN
                                    hour <= hour + "0001010";
                                ELSE
                                    hour <= "0010100";
                                END IF;
                                state2 <= init2;
                            ELSIF b3 = '1' THEN
                                IF hour > "0001001"
                                    hour <= hour - "0001010";
                                ELSIF hour < "0000100" THEN
                                    hour <= hour + "0010100";
                                ELSE
                                    hour <= "0010100";
                                END IF;
                                state2 <= init3;
                            END IF;
                        WHEN change_hour0 =>
                            IF b1 = '1' THEN
                                state <= time_hour_min;
                                state1 <= display_time;
                                state2 <= init1;
                            ELSIF b4 = '1' THEN
                                state <= change_min1;
                                state2 <= init4;
                            ELSIF b2 = '1' THEN
                                IF hour = "0010111" THEN
                                    hour <= "0010100";
                                ELSIF left0 = "0001001" THEN
                                    hour <= hour - "0001001";
                                ELSE
                                    hour <= hour + '1';
                                END IF;
                                state2 <= init2;
                            ELSIF b3 = '1' THEN
                                IF hour = "0010100" THEN
                                    hour <= "0010111";
                                ELSIF left0 = "0000000" THEN
                                    hour <= hour + "0001001";
                                ELSE
                                    hpur <= hour -'1';
                                END IF;
                                state2 <= init3;
                            END IF;
                        WHEN change_min1 =>
                            IF b1 = '1' THEN
                                state <= time_hour_min;
                                state1 <= display_time;
                                state2 <= init1;
                            ELSIF b4 = '1' THEN
                                state <= change_min0;
                                state2 <= init4;
                            ELSIF b2 = '1' THEN
                                IF minute > "110001" THEN
                                    minute <= minute - "0110010";
                                ELSE
                                    minute <= minute + "0010100";
                                END IF;
                                state2 <= init2;
                            ELSIF b3 ='1' THEN
                                IF minute < "0010100" THEN
                                    minute <= minute + "0110010";
                                ELSE
                                    minute <= minute - "0010100";
                                END IF;
                                state2 <= init3;
                            END IF;
                        WHEN change_min0 =>
                            IF b1 = '1' THEN
                                state <= time_hour_min;
                                state1 <= display_time;
                                state2 <= init1;
                            ELSIF b4 = '1' THEN
                                state <= change_hour1;
                                state2 <= init4;
                            ELSIF b2 = '1' THEN
                                IF right0 = "1001" THEN
                                    minute <= minute - "0001001";
                                ELSE
                                    minute <= minute + '1';
                                END IF;
                                state2 <= init2;
                            ELSIF b3 ='1' THEN
                                IF right0 = "0000" THEN
                                    minute <= minute + "0001001";
                                ELSE
                                    minute <= minute + '1';
                                END IF;
                                state2 <= init3;
                            END IF;
                    END CASE;
                WHEN init1 =>
                    IF b1 = '0' THEN
                        state2 <= idle;
                    END IF;
                WHEN init2 =>
                    IF b2 = '0' THEN
                        state2 <= idle;
                    END IF;
                WHEN init3 =>
                    IF b3 = '0' THEN
                        state2 <= idle;
                    END IF;
                WHEN init4 =>
                    IF b4 = '0' THEN
                        state2 <= idle;
                    END IF;
            END CASE;
        END PROCESS;
    
    WITH state1 SELECT
        left <=     minute WHEN time_min_sec,
                    hour WHEN others;
    WITH state1 SELECT
        right <=    second WHEN time_min_sec,
                    hour WHEN others;
    create_bin2bcd_left: bin2bcd port map (left, left0, left1);
    create_bin2bcd_right: bin2bcd port map (right, right0, right1);
    drive_display_left1: bcd_to_7seg_display port map(left1, 7segleft1);
    drive_display_left0: bcd_to_7seg_display port map(left0, 7segleft0);
    drive_display_right1: bcd_to_7seg_display port map(right1, 7segright1);
    drive_display_right0: bcd_to_7seg_display port map(right0, 7segright0);

                    
        
                

            

        