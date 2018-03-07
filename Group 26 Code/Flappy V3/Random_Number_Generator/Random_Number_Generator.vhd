library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Random_Number_Generator is 
port (clock : in std_logic;
		enable : in std_logic;
		reset : in std_logic;
      random_num : out std_logic_vector (7 downto 0));
end Random_Number_Generator;

architecture Behavioral of Random_Number_Generator is
signal x,y,z : std_logic := '0';
signal rand_temp : std_logic_vector(7 downto 0) := "10101010";
begin



process(clock)
begin

x <= rand_temp(7) xor rand_temp(3);
y <= x xor rand_temp(2);
z <= y xor rand_temp(1);


if (clock = '1' and clock'event) then
if (reset = '1') then
rand_temp(7 downto 0) <= "11100011";

elsif (enable = '1') then


rand_temp(0) <= z;
rand_temp(7) <= rand_temp(6);
rand_temp(6) <= rand_temp(5);
rand_temp(2) <= rand_temp(1);
rand_temp(5) <= rand_temp(4);
rand_temp(4) <= rand_temp(3);
rand_temp(3) <= rand_temp(2);
rand_temp(1) <= rand_temp(0);

end if;
end if;

random_num <= rand_temp;

end process;
end Behavioral;

