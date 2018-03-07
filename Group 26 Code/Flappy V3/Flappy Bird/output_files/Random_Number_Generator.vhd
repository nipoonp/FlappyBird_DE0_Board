library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Random_Number_Generator is
    generic ( width : integer :=  32 ); 
port (enable : in std_logic;
      random_num : out std_logic_vector (width-1 downto 0));
end Random_Number_Generator;

architecture Behavioral of Random_Number_Generator is
begin
process(enable)
variable rand_temp : std_logic_vector(width-1 downto 0):=(width-1 => '1',others => '0');
variable temp : std_logic := '0';
begin
if(enable = '1') then
temp := rand_temp(width-1) xor rand_temp(width-2);
rand_temp(width-1 downto 1) := rand_temp(width-2 downto 0);
rand_temp(0) := temp;
random_num <= rand_temp;
end if;
end process;
end Behavioral;
