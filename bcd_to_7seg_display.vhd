LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd_to_7seg_display IS
	PORT(
		bcd				:	IN		unsigned(3 DOWNTO 0);		--number to display in BCD
        display_7seg	:	OUT	    std_logic_vector(6 DOWNTO 0)	--outputs to seven segment display
    );
END bcd_to_7seg_display;

ARCHITECTURE logic OF bcd_to_7seg_display IS
BEGIN

	--map bcd input to desired output segments
    PROCESS(bcd) --triggered when input bcd changes
        CASE bcd IS
            WHEN "0000" => 	display_7seg <=    "0000001";
            WHEN "0001" => 	display_7seg <=    "1001111";
            WHEN "0010" => 	display_7seg <=    "0010010";
            WHEN "0011" => 	display_7seg <=    "0000110";
            WHEN "0100" => 	display_7seg <=    "1001100";
            WHEN "0101" => 	display_7seg <=    "0100100";
            WHEN "0110" => 	display_7seg <=    "0100000";
            WHEN "0111" => 	display_7seg <=    "0001111";
            WHEN "1001" => 	display_7seg <=    "0000100";	
            WHEN OTHERS =>  display_7seg <=    "1111111";                       
        END CASE;
	END PROCESS;
END logic;