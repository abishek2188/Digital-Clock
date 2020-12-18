LIBRARY ieee;                       
USE ieee.std_logic_1164.ALL; 
use ieee.numeric_std.all;  
entity bin2bcd is
    port (  
        bin  : in  unsigned (6 downto 0); --input binary number to be converted to bunary coded decimal
        bcd1 : out unsigned (3 downto 0); --output bcd - one's place digit of bin
        bcd2 : out unsigned (3 downto 0) --output bcd  - ten's place digit of bin
    );
end bin2bcd;

architecture logic of bin2bcd is 
    SIGNAL bcd  :   unsigned (7 downto 0); --signal intialized to 0, to be used in double dabble algortihm to get bcd
    SIGNAL binx :   unsigned (6 downto 0); --signal, used to copy the value of bin into this, because in the algorithm, left shifting would occur which isn't possible with input
begin
    process (bin) --triggered when bin changes. uses double dabble algorithm to convert binary to bcd
        begin
            bcd         <= '0';
            binx        <= bin(6 downto 0);

            for i in 0 to 6 loop
                if bcd(3 downto 0) > "0100" then  --if bcd(3 downto 0)>4
                    bcd(3 downto 0) <= bcd(3 downto 0) + "0011"; -- add 3

                end if;
                if bcd(7 downto 4) > "0100" then --if bcd(7 downto 4)>4
                    bcd(7 downto 4) <=  bcd(7 downto 4) + "0011";    --add 3
                end if;
                bcd <= bcd(6 downto 0) & binx(6); --left shift bcd and put the leftmost bit of binx in the end of bcd
                binx <= binx(5 downto 0) & '0'; --left shift binx and put 0 in the end
            end loop;

            bcd2 <= bcd(7  downto 4); 
            bcd1 <= bcd(3  downto 0);
    end process;
end logic;