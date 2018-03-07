Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY test_clk_divider IS
END ENTITY test_clk_divider;

ARCHITECTURE arch OF test_clk_divider IS
     signal t_clk_in : STD_LOGIC;
      signal  t_clk_out: STD_LOGIC;
	
	COMPONENT clk_divider IS
    port (
        clk_in : in  STD_LOGIC;
        clk_out: out STD_LOGIC
         );
	END COMPONENT;
	
  BEGIN
	DUT : clk_divider
	PORT MAP(clk_in => t_clk_in, clk_out => t_clk_out);
	  
	init : PROCESS
	BEGIN
	 	  
	 	  
		WAIT;
	END PROCESS init;
	
	clk_gen : PROCESS
	BEGIN
		t_clk_in <= '1';
		WAIT FOR 500 ps;
		t_clk_in <= '0';
		WAIT FOR 500 ps;
	END PROCESS clk_gen;
	
END ARCHITECTURE arch;


