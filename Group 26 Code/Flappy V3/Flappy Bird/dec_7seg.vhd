library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dec_7seg is
    Port (
        input : in  STD_LOGIC_VECTOR(3 downto 0);
        output: out STD_LOGIC_VECTOR(6 downto 0)
    );
end dec_7seg;

architecture Behavioral of dec_7seg is
begin
    
output <= "0000001" when input = "0000" else "1001111" when input = "0001" else "0010010" when input = "0010" else "0000110" when input = "0011" else "1001100" when input = "0100" else "0100100" when input = "0101" else "0100000" when input = "0110" else "0001111" when input = "0111" else "0000000" when input = "1000" else "0000100" when input = "1001" else "0000000";
	 
end Behavioral;