LIBRARY ieee;                       
USE ieee.std_logic_1164.ALL; 
use ieee.numeric_std.all;  
entity bin2bcd is
    port (  bin  : in  unsigned (6 downto 0);
            bcd1 : out unsigned (3 downto 0);
            bcd2 : out unsigned (3 downto 0)
    );
end bin2bcd;

architecture logic of bin2bcd is 
    SIGNAL bcd  :   unsigned (7 downto 0);
    SIGNAL binx :   unsigned (6 downto 0);
begin
    process ( bin )
        begin
            bcd         <= '0' ;
            binx        <= bin(6 downto 0) ;

            for i in 0 to 6 loop
                if bcd(3 downto 0) > "0100" then
                    bcd(3 downto 0) <= bcd(3 downto 0) + "0011"; 

                end if ;
                if bcd(7 downto 4) > "0100" then
                    bcd(7 downto 4) <=  bcd(7 downto 4) + "0011";    
                end if ;
                bcd <= bcd(6 downto 0) & binx(6) ; 
                binx <= binx(5 downto 0) & '0' ; 
            end loop ;

            bcd2 <= bcd(7  downto 4) ;
            bcd1 <= bcd(3  downto 0) ;
    end process ;
end logic;