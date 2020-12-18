LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY main IS
    PORT (
        clk             :   IN  std_logic;                                            --clock of 10 Mhz
        b1, b2, b3, b4  :   IN  std_logic;                                            --button inputs (of 1, 2, 3, 4 respectively)
        display_cathode :   OUT std_logic_vector(6 DOWNTO 0) := "1111111";            -- cathode outputof the 7 segments(1 means the segment is off and 0 means segment is on)
        display_decimal :   OUT std_logic_vector := '1';                              -- cathode output for decimal
        display_anode   :   OUT std_logic_vector(3 DOWNTO 0) := "0000"                -- anode output for the 4 digits
    );
END main;

ARCHITECTURE logic OF main is
    COMPONENT time_clk_1s IS                                    -- component for generating 1Hz signal
        PORT (
            clk     :       IN std_logic;                       -- processor clock input
            clk_1s  :       OUT std_logic := '0'                -- out put of 1Hz signal
        );
    END COMPONENT;

    COMPONENT time_clk_1ms IS                                   -- component for generating 1KHz singal
        PORT (
            clk         :       IN std_logic;                   -- processor clock input
            clk_1ms     :       OUT std_logic := '0'            -- out put of 1KHz signal
        );
    END COMPONENT;

    COMPONENT time_clk_8ms IS                                   -- component for generating 125 Hz singal
        PORT (
            clk         :       IN std_logic;                   -- processor clock input
            clk_8ms     :       OUT std_logic := '0'            -- out put of 125 Hz signal
        );
    END COMPONENT;

    COMPONENT bin2bcd is                                        -- component for converting binary to bcd
        port (  
            bin  : in  unsigned (6 downto 0);               -- binary number input
            bcd1 : out unsigned (3 downto 0);               -- one's place digit 
            bcd2 : out unsigned (3 downto 0)                -- ten's place digit
        );
    END COMPONENT;

    COMPONENT bcd_to_7seg_display is                            -- component for converting bcd to cathode output of 7 segment display
        PORT(
		    bcd				:	IN	STD_LOGIC_VECTOR(3 DOWNTO 0);   --number to display in BCD
            display_7seg	:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0)	--outputs to seven segment display
        );
    END COMPONENT;
    
    TYPE state_type IS (time_hour_min, time_min_sec, change_hour1, change_hour0, change_min1, change_min0);
    -- FSM for different states of the machine
    -- time_hour_min - displaying hh:mm
    -- time_min_sec - displaying mm:ss
    --change_hour1 - changing ten's place digit of hour
    --change_hour0 - changing one's place digit of hour
    --change_min1 - changine ten's place digit of minute
    -- change_min0 - changing one's place digit of minute
    TYPE state_type1 IS (display_time, change_time);
    -- another FSM to simplify some cases
    -- display_time - displaying time
    -- change_time - changint time
    TYPE state_type2 IS (idle, init1, init2, init3, init4);
    -- FSM of buttons to handle presses that last over multiple periods of master clock and double presses
    -- idle - no button is pressed
    -- init1 - b1 is being pressed
    -- init2 - b2 is being pressed
    -- and so on...
    TYPE state_type3 IS (flash, no_flash);
    -- FSM to handle flashing of dot to display second
    -- flash - dot should be on
    -- no_flash - dot should be off
    SIGNAL state3                                               :   state_type3 := no_flash; -- signnal of the FSM3 (default : no_flash)
    SIGNAL state2                                               :   state_type2 := idle;     -- singal of FSM2      (default : idle)
    SIGNAL state1                                               :   state_type1 := display_time;    --singal of FSM1 
    SIGNAL state                                                :   state_type := time_hour_min; --signal of FSM
    SIGNAL clk_1ms                                              :   std_logic := '0';   -- clock signal of 1Khz
    SIGNAL clk_1s                                               :   std_logic := '0';   -- clock signal of 1Hz
    SIGNAL clk_8ms                                              :   std_logic := '0';   -- clock signal of 125Hz
    SIGNAL minute, second, hour, left, right                    :   unsigned(6 DOWNTO 0) := '0';   -- unsigned that stores minute, second, hour, left(number to be displayed in left), right(number to be displayed in the right) respectively(default '0')
    SIGNAL refresh                                              :   unsigned(1 DOWNTO 0) := '0';   -- a counter used for refreshing the display every 4ms
    SIGNAL left1, left0, right1, right0                         :   unsigned(3 downto 0);  -- singals which represent the BCD of the digits to be diplayed in that order(left1 left0 right1 right0)
    SIGNAL segleft1, segleft0, segright1, segright0             :   std_logic_vector(6 DOWNTO 0);  -- signals which represent the cathode output version of the above signals(left1 left0 right1 right0)
BEGIN
    create_1s_clock: time_clk_1s port map (clk, clk_1s);        -- initialization to generate signal of 1Hz
    create_1ms_clock: time_clk_1ms port map (clk, clk_1ms);     -- initialization to generate singal of 1KHz
    create_8ms_clock: time_clk_8ms port map (clk, clk_8ms);     -- initialization to generate signal of 125 Hz
    
    PROCESS(clk_1s) --process to keep track of time and update every second(runs every time clk_1s changes)
        BEGIN
            CASE state1 IS
                WHEN display_time =>            -- process only updates time if the state is display_time
                    IF rising_edge(clk_1s) THEN -- only does it on the rising edge of the signal
                        second <= second + 1;   
                        IF (second = "111100") THEN    -- if second is 60, make it 0 and increase minute
                            second <= '0';
                            minute <= minute + 1;
                            IF (minute = "111100") THEN -- if minute is 60, make it 0 and increase hour
                                minute <= '0';         
                                hour <= hour + 1;
                                IF (hour = "011000") THEN   -- if hour is 24, make it 0
                                    hour <= '0';
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                WHEN change_time => -- nothing happens in this state
            END CASE;
            CASE state IS
                WHEN time_hour_min =>           -- if hh:mm is being displayed, turn on the dot on rising edge of signal and turn it off on falling edge
                    if rising_edge(clk_1s) THEN
                        state3 <= flash;        -- state3 is the FSM used to keep track of the dot
                    ELSE
                        state3 <= no_flash;
                    END IF;
                WHEN others =>
            END CASE;
        END PROCESS;
    
    PROCESS(clk_8ms) --this is the process used to refresh the display with updated numbers and switch between each digit every 4ms
        BEGIN
        display_anode <= "0000";    -- all anodes are turned off in the beginning
            IF refresh = "11" THEN  -- if the digit is being displayed is 4th, change the digit to be displayed to 1st
                refresh <= "00";
            ELSE                    -- else increase the counter by 1 to change the digit to be displayed(the next digit)
                refresh <= refresh + 1; 
            END IF;
            IF refresh = "00" THEN              -- if 1st digit is to be displayed, send the corresponding values to the output
                display_cathode <= segleft1;    
                display_anode(3) <= '1';        -- turns on 1st digit
            ELSIF refresh = "01" THEN           -- if 2nd digit is to be displayed, send the corresponding values to the output
                display_cathode <= segleft0;
                display_anode(2) <= '1';        -- turns on 2nd digit
            ELSIF refresh = "10" THEN           -- if 3rd digit is to be displayed, send the corresponding values to the output
                display_cathode <= segright1;
                display_anode(1) <= '1';        -- turns on 3rd digit
            ELSE                                -- if 4th digit is to be displayed, send the corresponding values to the output
                display_cathode <= segright0;  
                display_anode(0) <= '1';        -- turns on 4th digit
                CASE state3 is              -- to check whether the dot should also be on or not(using states)
                    WHEN flash =>           -- dot is on when flash
                        display_decimal <= '0';
                    WHEN no_flash =>        -- dot is off when no_flash
                        display_decimal <= '1';
                END CASE;
            END IF;


        END PROCESS;
    
    PROCESS(clk_1ms)                                    -- process to check the input of the buttons and change states and singals accordingly
        BEGIN
            CASE state2 IS                              -- checks the state of buttons before and decide what to do accordingly
                WHEN idle =>                            -- only when none of the buttons was pressed before(state2 is idle), any changes to thhe clock would occur
                    CASE state IS                       -- checks which state the clock is in using state and do the changes accordingly
                        WHEN time_hour_min =>           -- clock is displaying hh:mm
                            IF b1='1' THEN              -- if button1(mode) has been pressed
                                state <= change_hour1;  -- changes state to change ten's place of hour
                                state1 <= change_time;  -- changes state to change_time to stop clock from updating every second(look at the process for tracking time for details)
                                state2 <= init1;        -- state to describe that button 1 is being pressed
                                state3 <= no_flash;     -- turns off dot if it was flashing
                            ELSIF b4 = '1' THEN         -- elsif button4(change) has been pressed
                                state <= time_min_sec;  -- changes display mode
                                state2 <= init4;        -- state to describe that button 4 is being pressed
                            END IF;                     -- don't care b2 and b3(no effect)
                        WHEN time_min_sec =>            -- clock is displaying mm:ss
                            IF b1 <= '1' THEN           -- if button1(mode) has been pressed
                                state <= change_hour1;  -- changes state to change ten's place of hour
                                state1 <= change_time;  -- changes state to change_time to stop clock from updating every second(look at the process for tracking time for details)
                                state2 <= init1;        -- state to describe that button 1 is being pressed
                            ELSIF b4 = '1' THEN         -- elsif button4(change) has been pressed
                                state <= time_hour_min; -- changes display mode to show hh:mm
                                state2 <= init4;        -- state to describe that button 4 is being pressed
                            END IF;                     -- don't care for b2 and b3(no effect)
                        WHEN change_hour1 =>            -- clock is changing hour's ten's place digit
                            IF b1 = '1' THEN            -- if button1(mode) has been pressed
                                state <= time_hour_min; -- changes state to display time hh:mm after with the new time that was set
                                state1 <= display_time; -- changes state to displaying time
                                state2 <= init1;        -- state to describe that button 1 is being pressed
                            ELSIF b4 = '1' THEN         -- elsif button4(change) has been pressed
                                state <= change_hour0;  -- changes state to change hour's one place digit
                                state2 <= init4;        -- state to describe that button 4 is being pressed
                            ELSIF b2 = '1' THEN         -- elsif button2(+) has been pressed(to increase the digit)
                                IF hour > "0010011" THEN    -- if hour > 19, subtract 20(eg. 23 => 3)
                                    hour <= hour - "0010100";
                                ELSIF hour < "0001110" THEN --if hour < 14, add 10(eg. 12 => 22)
                                    hour <= hour + "0001010";
                                ELSE                        --else make it 20(as hour's one place can't be greater than 4 when ten's place is 2)(eg. 17 => 20)
                                    hour <= "0010100";
                                END IF;
                                state2 <= init2;        -- state to describe that button 2 is being pressed
                            ELSIF b3 = '1' THEN          -- if button3(-) has been pressed(to decrease the digit)
                                IF hour > "0001001" THEN -- if hour is greater than 9, subtract 10(eg. 13 => 3)
                                    hour <= hour - "0001010";
                                ELSIF hour < "0000100" THEN --if hour is less than 4, add 20 (eg. 03 => 23)
                                    hour <= hour + "0010100";
                                ELSE                        --else make it 20(as hour's one place can't be greater than 4 when ten's place is 2)(eg. 5 => 20)
                                    hour <= "0010100"; 
                                END IF;
                                state2 <= init3;            -- state to describe that button 3 is being pressed
                            END IF;
                        WHEN change_hour0 =>        -- clock is changing hour's one's place digit
                            IF b1 = '1' THEN        -- if button1(mode) has been pressed
                                state <= time_hour_min;     -- changes state to display time hh:mm after with the new time that was set
                                state1 <= display_time;     -- changes state to displaying time
                                state2 <= init1;            -- state to describe that button 1 is being pressed
                            ELSIF b4 = '1' THEN             -- if button4(change) has been pressed
                                state <= change_min1;       -- changes state to change minute's ten's place digit
                                state2 <= init4;            -- state to describe that button 4 is being pressed
                            ELSIF b2 = '1' THEN             -- if button2(+) has been pressed(to increase the digit)
                                IF hour = "0010111" THEN    --if hour = 23, make it 20
                                    hour <= "0010100";
                                ELSIF left0 = "0001001" THEN --left0 is the one's place digit of hour(look at display driver below for details). if left0 is 9, subtract 9 from hour(eg. 39 => 30)
                                    hour <= hour - "0001001";
                                ELSE                         -- else increase hour by 1(eg. 35 => 36)
                                    hour <= hour + '1'; 
                                END IF;
                                state2 <= init2;            -- state to describe that button 2 is being pressed
                            ELSIF b3 = '1' THEN                 -- if button3(-) has been pressed(to decrease the digit)
                                IF hour = "0010100" THEN        --if hour = 20, make it 23
                                    hour <= "0010111";
                                ELSIF left0 = "0000000" THEN    --left0 is the one's place digit of hour(look at display driver below for details). if left0 is 0, add 9(eg. 10 => 19)
                                    hour <= hour + "0001001";
                                ELSE                            --else subtract 1(eg. 36 => 35)
                                    hour <= hour -'1';
                                END IF;
                                state2 <= init3;                -- state to describe that button 3 is being pressed
                            END IF;
                        WHEN change_min1 =>                 --clock is changing minute's ten's place digit
                            IF b1 = '1' THEN                -- if button1(mode) has been pressed
                                state <= time_hour_min;         -- changes state to display time hh:mm after with the new time that was set
                                state1 <= display_time;         -- changes state to displaying time
                                state2 <= init1;                -- state to describe that button 1 is being pressed
                            ELSIF b4 = '1' THEN                 -- if button4(change) has been pressed
                                state <= change_min0;           --changes state to change minute's one's place digit
                                state2 <= init4;                -- state to describe that button 4 is being pressed
                            ELSIF b2 = '1' THEN                 -- if button2(+) has been pressed(to increase the digit)
                                IF minute > "110001" THEN       --if minute > 49, subtract 50(eg. 52 => 02)
                                    minute <= minute - "0110010";
                                ELSE                            -- else increase 10 (eg. 13=> 23)
                                    minute <= minute + "0001010";
                                END IF;
                                state2 <= init2;                -- state to describe that button 2 is being pressed
                            ELSIF b3 ='1' THEN                  -- if button3(-) has been pressed(to decrease the digit)
                                IF minute < "0001010" THEN      --if minute < 10 add 50 (eg. 9 => 59)
                                    minute <= minute + "0110010";
                                ELSE                             -- else subtract 10 (eg. 19 => 9)
                                    minute <= minute - "0010100";
                                END IF;
                                state2 <= init3;            -- state to describe that button 3 is being pressed
                            END IF;
                        WHEN change_min0 =>                 --clock is changing minute's one's place digit
                            IF b1 = '1' THEN                 -- if button1(mode) has been pressed
                                state <= time_hour_min;     -- changes state to display time hh:mm after with the new time that was set
                                state1 <= display_time;     -- changes state to displaying time
                                state2 <= init1;            -- state to describe that button 1 is being pressed
                            ELSIF b4 = '1' THEN             -- if button4(change) has been pressed
                                state <= change_hour1;     -- changes state to change ten's place of hour
                                state2 <= init4;            -- state to describe that button 4 is being pressed
                            ELSIF b2 = '1' THEN             -- if button2(+) has been pressed(to increase the digit)
                                IF right0 = "1001" THEN     --right0 is the bcd of one's place digit of minute(look at display driver for details). if right0 is 9, subtract 9 (eg. 59 => 50)
                                    minute <= minute - "0001001";
                                ELSE
                                    minute <= minute + '1'; --else add 1(eg. 34 => 35)
                                END IF;
                                state2 <= init2;            -- state to describe that button 2 is being pressed
                            ELSIF b3 ='1' THEN              -- if button3(-) has been pressed(to decrease the digit)
                                IF right0 = "0000" THEN     --right0 is the bcd of one's place digit of minute(look at display driver for details). if right0 is 0, add 9(eg. 00 => 09)
                                    minute <= minute + "0001001";
                                ELSE                        --else decrease 1(eg. 01 => 00)
                                    minute <= minute + '1';
                                END IF;
                                state2 <= init3;            -- state to describe that button 3 is being pressed
                            END IF;
                    END CASE;
                WHEN init1 =>               -- if button1 was pressed before
                    IF b1 = '0' THEN        -- only if b1 is 0, change the state to idle, else if b1 is still pressed, don't make any change
                        state2 <= idle;
                    END IF;
                WHEN init2 =>               -- if button2 was pressed before
                    IF b2 = '0' THEN        -- only if b2 is 0, change the state to idle, else if b2 is still pressed, don't make any change
                        state2 <= idle;
                    END IF;
                WHEN init3 =>               -- if button3 was pressed before
                    IF b3 = '0' THEN        -- only if b3 is 0, change the state to idle, else if b3 is still pressed, don't make any change
                        state2 <= idle;
                    END IF;
                WHEN init4 =>               -- if button4 was pressed before
                    IF b4 = '0' THEN        -- only if b4 is 0, change the state to idle, else if b4 is still pressed, don't make any change
                        state2 <= idle;
                    END IF;
            END CASE;
        END PROCESS;
    
    WITH state1 SELECT --DISPLAY DRIVER(the entire code below this takes care of the display output values according to which state is currently active)
        left <=     minute WHEN time_min_sec, --left signal is assigned minute only when mm:ss is being displayed, rest of the states, it is hour
                    hour WHEN others;
    WITH state1 SELECT
        right <=    second WHEN time_min_sec, --right signal is assigned minute only when mm:ss is being displayed, rest of the states, it is hour
                    minute WHEN others;
    create_bin2bcd_left: bin2bcd port map (left, left0, left1); --takes left as input and outputs the bcd(left1 left0)
    create_bin2bcd_right: bin2bcd port map (right, right0, right1); --takes right as input and outputs binary coded decimal(right1 right0)
    drive_display_left1: bcd_to_7seg_display port map(left1, segleft1); --takes left1 bcd as input and outputs seven segment output segleft1
    drive_display_left0: bcd_to_7seg_display port map(left0, segleft0); --takes left0 bcd as input and outputs seven segment output segleft0
    drive_display_right1: bcd_to_7seg_display port map(right1, segright1); --takes right1 bcd as input and outputs seven segment output segright1
    drive_display_right0: bcd_to_7seg_display port map(right0, segright0); --takes right0 bcd as input and outputs seven segment output segright0

END logic;

                    
        
                

            

        