library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_divider is
    Port (
        clk_in : in  STD_LOGIC;
        clk_out: out STD_LOGIC
    );
end clk_divider;

architecture Behavioral of clk_divider is
    signal temporal: STD_LOGIC := '1';
    signal counter : integer range 0 to 100000000 := 0;
begin
    process (clk_in) 
    begin
        if (clk_in'event and clk_in = '1') then
            if (counter = 100000000/2) then
                temporal <= NOT(temporal);
                counter <= 1;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_out <= temporal;
end Behavioral;