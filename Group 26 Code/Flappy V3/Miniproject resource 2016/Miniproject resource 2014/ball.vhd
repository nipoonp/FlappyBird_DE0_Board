-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE ieee.numeric_std.ALL;

LIBRARY lpm;
USE lpm.lpm_components.ALL;

PACKAGE de0core IS
	COMPONENT vga_sync
		PORT(clock_25Mhz                   : IN  std_logic;
			 red, green, blue              : IN  STD_LOGIC_VECTOR(3 downto 0);
			 red_out, green_out, blue_out  : OUT STD_LOGIC_VECTOR(3 downto 0);
			 pixel_row, pixel_column       : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
			 horiz_sync_out, vert_sync_out : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT Random_Number_Generator
		port(clock      : in  std_logic;
			 enable     : in  std_logic;
			 reset      : in  std_logic;
			 random_num : out std_logic_vector(7 downto 0));
	END COMPONENT;

	component char_rom
		PORT(
			character_address  : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
			font_row, font_col : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			clock              : IN  STD_LOGIC;
			rom_mux_output     : OUT STD_LOGIC
		);
	END component;

	component red_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component green_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component blue_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component pipe_red_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component pipe_green_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component pipe_blue_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component bird_red_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component bird_green_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component bird_blue_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component powerup_red_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component powerup_green_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component powerup_blue_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END component;

	component bird_rom
		PORT(
			address : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
			clock   : IN  STD_LOGIC := '1';
			q       : OUT STD_LOGIC
		);
	END component;

END de0core;

-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
LIBRARY work;
USE work.de0core.all;

ENTITY ball IS
	Generic(ADDR_WIDTH : integer := 12; DATA_WIDTH : integer := 1);

	PORT(SIGNAL PB1, PB2, Clock       : IN  std_logic;
		 push_button, switch          : IN  std_logic;
		 SIGNAL Red, Green, Blue      : OUT std_logic_vector(3 downto 0);
		 SIGNAL Horiz_sync, Vert_sync : OUT std_logic;
		 lef, rig                     : in  std_logic);

END ball;

architecture behavior of ball is

	-- Video Display Signals   
	SIGNAL Red_Data, Green_Data, Blue_Data                                                          : std_logic_vector(3 downto 0);
	signal reset, vert_sync_int, font_on, font_on1, font_on2, Direction                             : std_logic;
	signal bird_on, pipe1_on, pipe2_on, pipe3_on, pipe1_top_on, pipe2_top_on, pipe3_top_on, gift_on : std_logic := '0';

	SIGNAL pixel_row, pixel_column                                      : std_logic_vector(10 DOWNTO 0);
	signal random_num                                                   : std_logic_vector(7 downto 0);
	signal random_Number_Generator_Enable                               : std_logic                    := '0';
	signal bird_posX                                                    : std_logic_vector(9 downto 0);
	signal bird_sizeY, bird_sizeX                                       : std_logic_vector(9 DOWNTO 0);
	signal bird_posY, gift_posY                                         : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(200, 10);
	signal pipe1_sizeX, pipe1_sizeY, pipe1_posY                         : std_logic_vector(9 DOWNTO 0);
	signal pipe1_posX                                                   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(640, 10);
	signal pipe2_posX                                                   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(440, 10);
	signal pipe3_posX                                                   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(240, 10);
	signal pipe2_sizeX, pipe2_sizeY, pipe2_posY                         : std_logic_vector(9 DOWNTO 0);
	signal pipe3_sizeX, pipe3_sizeY, pipe3_posY, gift_sizeY, gift_sizeX : std_logic_vector(9 DOWNTO 0);
	signal addres                                                       : std_logic_vector(5 downto 0);
	signal stop                                                         : std_LOGIC                    := '0';
	signal font_out                                                     : std_logic;
	signal score1, score2, score3                                       : std_logic_vector(3 downto 0) := "0000";
	signal final_score1, final_score2, final_score3                     : std_logic_vector(3 downto 0) := "0000";
	signal score_incremented1, score_incremented2, score_incremented3   : std_logic                    := '0';
	signal collision                                                    : std_logic                    := '0';
	signal no_collision                                                 : std_logic                    := '0';
	signal red_address                                                  : STD_LOGIC_VECTOR(14 DOWNTO 0);
	signal green_address                                                : STD_LOGIC_VECTOR(14 DOWNTO 0);
	signal blue_address                                                 : STD_LOGIC_VECTOR(14 DOWNTO 0);
	signal red_background                                               : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal green_background                                             : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal blue_background                                              : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal counter                                                      : integer                      := 0;
	signal mode                                                         : std_logic;
	signal menu_on                                                      : std_logic                    := '1';
	signal red_pipe_address                                             : STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal green_pipe_address                                           : STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal blue_pipe_address                                            : STD_LOGIC_VECTOR(8 DOWNTO 0);
	signal red_pipe_output                                              : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal green_pipe_output                                            : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal blue_pipe_output                                             : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal gift_posX                                                    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(-50, 10);
	signal gift_new                                                     : std_logic                    := '0';
	signal powerup                                                      : std_logic                    := '0';
	signal game_over                                                    : std_logic                    := '0';

	signal game_over_screen             : std_logic                    := '0';
	signal red_bird_address             : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal green_bird_address           : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal blue_bird_address            : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal red_bird_output              : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal green_bird_output            : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal blue_bird_output             : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal life1_on, life2_on, life3_on : std_LOGIC                    := '1';
	signal rand_reset                   : std_LOGIC;
	signal flash                        : std_logic                    := '0';
	signal col_in, row_in               : std_logic_vector(2 downto 0);

	signal red_powerup_address   : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal green_powerup_address : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal blue_powerup_address  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal red_powerup_output    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal green_powerup_output  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	signal blue_powerup_output   : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

	signal bird_add : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal bird_out : STD_LOGIC;

BEGIN
	SYNC : vga_sync
		PORT MAP(clock_25Mhz    => clock,
			     red            => red_data, green => green_data, blue => blue_data,
			     red_out        => red, green_out => green, blue_out => blue,
			     horiz_sync_out => horiz_sync, vert_sync_out => vert_sync_int,
			     pixel_row      => pixel_row, pixel_column => pixel_column);

	random : Random_Number_Generator PORT MAP(
			clock      => clock,
			enable     => '1',
			reset      => rand_reset,
			random_num => random_num);

	Font : char_rom
		Port map(character_address => addres,
			     font_row          => row_in, font_col => col_in,
			     clock             => clock,
			     rom_mux_output    => font_out);

	red_back : red_rom
		Port map(address => red_address,
			     clock   => clock,
			     q       => red_background);

	green_back : green_rom
		Port map(address => green_address,
			     clock   => clock,
			     q       => green_background);

	blue_back : blue_rom
		Port map(address => blue_address,
			     clock   => clock,
			     q       => blue_background);

	red_pipe : pipe_red_rom
		Port map(address => red_pipe_address,
			     clock   => clock,
			     q       => red_pipe_output);

	green_pipe : pipe_green_rom
		Port map(address => green_pipe_address,
			     clock   => clock,
			     q       => green_pipe_output);

	blue_pipe : pipe_blue_rom
		Port map(address => blue_pipe_address,
			     clock   => clock,
			     q       => blue_pipe_output);

	red_bird : bird_red_rom
		Port map(address => red_bird_address,
			     clock   => clock,
			     q       => red_bird_output);

	green_bird : bird_green_rom
		Port map(address => green_bird_address,
			     clock   => clock,
			     q       => green_bird_output);

	blue_bird : bird_blue_rom
		Port map(address => blue_bird_address,
			     clock   => clock,
			     q       => blue_bird_output);

	red_powerup : powerup_red_rom
		Port map(address => red_powerup_address,
			     clock   => clock,
			     q       => red_powerup_output);

	blue_powerup : powerup_green_rom
		Port map(address => green_powerup_address,
			     clock   => clock,
			     q       => green_powerup_output);

	green_powerup : powerup_blue_rom
		Port map(address => blue_powerup_address,
			     clock   => clock,
			     q       => blue_powerup_output);

	b : bird_rom
		Port map(address => bird_add,
			     clock   => clock,
			     q       => bird_out);

	bird_sizeX  <= CONV_STD_LOGIC_VECTOR(8, 10);
	bird_sizeY  <= CONV_STD_LOGIC_VECTOR(8, 10);
	gift_sizeX  <= CONV_STD_LOGIC_VECTOR(8, 10);
	gift_sizeY  <= CONV_STD_LOGIC_VECTOR(8, 10);
	bird_posX   <= CONV_STD_LOGIC_VECTOR(90, 10);
	pipe1_sizeX <= CONV_STD_LOGIC_VECTOR(20, 10);
	pipe1_sizeY <= CONV_STD_LOGIC_VECTOR(60, 10);
	pipe2_sizeX <= CONV_STD_LOGIC_VECTOR(20, 10);
	pipe2_sizeY <= CONV_STD_LOGIC_VECTOR(60, 10);
	pipe3_sizeX <= CONV_STD_LOGIC_VECTOR(20, 10);
	pipe3_sizeY <= CONV_STD_LOGIC_VECTOR(60, 10);
	vert_sync   <= vert_sync_int;

	RGB_Display : Process(stop, bird_posX, bird_posY, pipe1_posX, pipe1_posY, pipe2_sizeX, pipe2_sizeY, pixel_column, pixel_row, bird_sizeX, gift_new, menu_on, game_over)
	BEGIN
		if menu_on = '0' then
			if (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0000010000" and pixel_column <= "0000011110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "010011";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0000100000" and pixel_column <= "0000101110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000011";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0000110000" and pixel_column <= "0000111110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "001111";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0001000000" and pixel_column <= "0001001110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "010010";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0001010000" and pixel_column <= "0001011110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000101";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0001100000" and pixel_column <= "0001101110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "11" & score3;
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0001110000" and pixel_column <= "0001111110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "11" & score2;
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row <= 480 and pixel_column >= "0010000000" and pixel_column <= "0010001110") then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "11" & score1;
				font_on <= font_out;

			-- life
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 350 and pixel_column < 366) then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "001100";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 366 and pixel_column < 382) then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "001001";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 382 and pixel_column < 398) then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000110";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 398 and pixel_column < 414) then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000101";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 414 and pixel_column < 430 and life1_on = '1') then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000000";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 430 and pixel_column < 446 and life2_on = '1') then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000000";
				font_on <= font_out;
			elsif (pixel_row >= 464 and pixel_row < 480 and pixel_column >= 446 and pixel_column < 462 and life3_on = '1') then
				row_in  <= pixel_row(3 downto 1);
				col_in  <= pixel_column(3 downto 1);
				addres  <= "000000";
				font_on <= font_out;
			else
				addres  <= "11" & score1;
				font_on <= '0';
			end if;

			-- Set bird_on ='1' to display ball
			IF ('0' & bird_posX <= '0' & pixel_column + bird_sizeX - 1) AND
			-- compare positive numbers only
			('0' & bird_posX + bird_sizeX >= '0' & pixel_column) AND ('0' & bird_posY <= '0' & pixel_row + bird_sizeX) AND ('0' & bird_posY + bird_sizeX >= '0' & pixel_row) THEN
				bird_add <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(bird_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(bird_posX) - 8), 8);
				if (bird_out = '1') then
					bird_on <= '1';
				else
					bird_on <= '0';
				end if;
			ELSE
				bird_on <= '0';
			END IF;

			if (bird_on = '0') then
				IF ('0' & pipe1_posX <= '0' & pixel_column + pipe1_sizeX) AND ('0' & pipe1_posX + pipe1_sizeX >= '0' & pixel_column) AND (('0' & pipe1_posY >= '0' & pixel_row + pipe1_sizeY + 15) OR ('0' & pipe1_posY + pipe1_sizeY <= '0' & pixel_row - 15)) THEN
					pipe1_on <= '1';
				ELSE
					pipe1_on <= '0';
				END IF;
			end if;

			if (bird_on = '0') then
				IF ('0' & pipe1_posX <= '0' & pixel_column + pipe1_sizeX) AND ('0' & pipe1_posX + pipe1_sizeX >= '0' & pixel_column) AND (('0' & pipe1_posY >= '0' & pixel_row + pipe1_sizeY) OR ('0' & pipe1_posY + pipe1_sizeY <= '0' & pixel_row)) THEN
					pipe1_top_on <= '1';
				ELSE
					pipe1_top_on <= '0';
				END IF;
			end if;

			if (bird_on = '0' and pipe1_on = '0') then
				IF ('0' & pipe2_posX <= '0' & pixel_column + pipe2_sizeX) AND ('0' & pipe2_posX + pipe2_sizeX >= '0' & pixel_column) AND (('0' & pipe2_posY >= '0' & pixel_row + pipe2_sizeY + 15) OR ('0' & pipe2_posY + pipe2_sizeY <= '0' & pixel_row - 15)) THEN
					pipe2_on <= '1';
				ELSE
					pipe2_on <= '0';
				END IF;
			end if;

			if (bird_on = '0' and pipe1_on = '0') then
				IF ('0' & pipe2_posX <= '0' & pixel_column + pipe2_sizeX) AND ('0' & pipe2_posX + pipe2_sizeX >= '0' & pixel_column) AND (('0' & pipe2_posY >= '0' & pixel_row + pipe2_sizeY) OR ('0' & pipe2_posY + pipe2_sizeY <= '0' & pixel_row)) THEN
					pipe2_top_on <= '1';
				ELSE
					pipe2_top_on <= '0';
				END IF;
			end if;

			if (bird_on = '0' and pipe1_on = '0' and pipe2_on = '0') then
				IF ('0' & pipe3_posX <= '0' & pixel_column + pipe3_sizeX) AND ('0' & pipe3_posX + pipe3_sizeX >= '0' & pixel_column) AND (('0' & pipe3_posY >= '0' & pixel_row + pipe3_sizeY + 15) OR ('0' & pipe3_posY + pipe3_sizeY <= '0' & pixel_row - 15)) THEN
					pipe3_on <= '1';
				ELSE
					pipe3_on <= '0';
				END IF;
			end if;

			if (bird_on = '0' and pipe1_on = '0' and pipe2_on = '0') then
				IF ('0' & pipe3_posX <= '0' & pixel_column + pipe3_sizeX) AND ('0' & pipe3_posX + pipe3_sizeX >= '0' & pixel_column) AND (('0' & pipe3_posY >= '0' & pixel_row + pipe3_sizeY) OR ('0' & pipe3_posY + pipe3_sizeY <= '0' & pixel_row)) THEN
					pipe3_top_on <= '1';
				ELSE
					pipe3_top_on <= '0';
				END IF;
			end if;

			if (bird_on = '0' and pipe1_on = '0' and pipe2_on = '0' and pipe3_on = '0') then
				IF ('0' & gift_posX <= '0' & pixel_column + gift_sizeX) AND
				-- compare positive numbers only
				('0' & gift_posX + gift_sizeX >= '0' & pixel_column) AND ('0' & gift_posY <= '0' & pixel_row + gift_sizeX) AND ('0' & gift_posY + gift_sizeX >= '0' & pixel_row) THEN
					gift_on <= '1';
				ELSE
					gift_on <= '0';
				END IF;
			end if;

		elsif menu_on = '1' then
			-- "Flappy Bird"
			row_in <= pixel_row(4 downto 2);
			col_in <= pixel_column(4 downto 2);
			if (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 128 and pixel_column < 160) then
				addres  <= "000110";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 160 and pixel_column < 192) then
				addres  <= "001100";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 192 and pixel_column < 224) then
				addres  <= "000001";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 224 and pixel_column < 256) then
				addres  <= "010000";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 256 and pixel_column < 288) then
				addres  <= "010000";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 288 and pixel_column < 320) then
				addres  <= "011001";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 352 and pixel_column < 384) then
				addres  <= "000010";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 384 and pixel_column < 416) then
				addres  <= "001001";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 416 and pixel_column < 448) then
				addres  <= "010010";
				font_on <= font_out;
			elsif (pixel_row >= 96 and pixel_row < 124 and pixel_column >= 448 and pixel_column < 480) then
				addres  <= "000100";
				font_on <= font_out;
			--training mode
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 192 and pixel_column < 224) then
				addres  <= "010100";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 224 and pixel_column < 256) then
				addres  <= "010010";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 256 and pixel_column < 288) then
				addres  <= "000001";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 288 and pixel_column < 320) then
				addres  <= "001001";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 320 and pixel_column < 352) then
				addres  <= "001110";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 352 and pixel_column < 384) then
				addres  <= "001001";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 384 and pixel_column < 416) then
				addres  <= "001110";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 416 and pixel_column < 448) then
				addres  <= "000111";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 448 and pixel_column < 480 and switch = '1') then
				addres  <= "011011";
				font_on <= font_out;
			elsif (pixel_row >= 256 and pixel_row < 288 and pixel_column >= 224 and pixel_column < 256 and switch = '0') then
				addres  <= "011011";
				font_on <= font_out;
			elsif (pixel_row >= 192 and pixel_row < 224 and pixel_column >= 160 and pixel_column < 192 and switch = '1') then
				addres  <= "011011";
				font_on <= font_out;
			elsif (pixel_row >= 256 and pixel_row < 288 and pixel_column >= 384 and pixel_column < 416 and switch = '0') then
				addres  <= "011011";
				font_on <= font_out;
			--"game mode"

			elsif (pixel_row >= 256 and pixel_row < 288 and pixel_column >= 256 and pixel_column < 288) then
				addres  <= "010000";
				font_on <= font_out;
			elsif (pixel_row >= 256 and pixel_row < 288 and pixel_column >= 288 and pixel_column < 320) then
				addres  <= "001100";
				font_on <= font_out;
			elsif (pixel_row >= 256 and pixel_row < 288 and pixel_column >= 320 and pixel_column < 352) then
				addres  <= "000001";
				font_on <= font_out;
			elsif (pixel_row >= 256 and pixel_row < 288 and pixel_column >= 352 and pixel_column < 384) then
				addres  <= "011001";
				font_on <= font_out;
				
				
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 240 and pixel_column < 248) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010101";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 248 and pixel_column < 256) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010011";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 256 and pixel_column < 264) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000101";
				font_on <= font_out;
						elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 272 and pixel_column < 280) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010011";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 280 and pixel_column < 288) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010111";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 288 and pixel_column < 296) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "001111";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 304 and pixel_column < 312) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010100";
				font_on <= font_out;
						elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 312 and pixel_column < 320) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "001111";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 328 and pixel_column < 336) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000011";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 336 and pixel_column < 344) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "001000";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 344 and pixel_column < 352) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000001";
				font_on <= font_out;
						elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 352 and pixel_column < 360) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "001110";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 360 and pixel_column < 368) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "000111";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 368 and pixel_column < 376) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "000101";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 384 and pixel_column < 392) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "001101";
				font_on <= font_out;
						elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 392 and pixel_column < 400) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "001111";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 400 and pixel_column < 408) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000100";
				font_on <= font_out;
			elsif (pixel_row >= 336 and pixel_row < 344 and pixel_column >= 408 and pixel_column < 416) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000101";
				font_on <= font_out;
				
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 240 and pixel_column < 248) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010101";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 248 and pixel_column < 256) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010011";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 256 and pixel_column < 264) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000101";
				font_on <= font_out;
						elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 272 and pixel_column < 280) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "000010";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 280 and pixel_column < 288) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010101";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 288 and pixel_column < 296) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010100";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 296 and pixel_column < 304) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010100";
				font_on <= font_out;
						elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 304 and pixel_column < 312) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "001111";
				font_on <= font_out;
					elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 312 and pixel_column < 320) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "001110";
				font_on <= font_out;	
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 320 and pixel_column < 328) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "110010";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 336 and pixel_column < 344) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "010100";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 344 and pixel_column < 352) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "001111";
				font_on <= font_out;
						elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 360 and pixel_column < 368) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010011";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 368 and pixel_column < 376) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010100";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 376 and pixel_column < 384) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "000001";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 384 and pixel_column < 392) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010010";
				font_on <= font_out;
						elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 392 and pixel_column < 400) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "010100";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 408 and pixel_column < 416) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000111";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 416 and pixel_column < 424) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000001";
				font_on <= font_out;
						elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 424 and pixel_column < 432) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);	
				addres  <= "001101";
				font_on <= font_out;
			elsif (pixel_row >= 352 and pixel_row < 360 and pixel_column >= 432 and pixel_column < 440) then
						row_in <= pixel_row(2 downto 0);
			col_in <= pixel_column(2 downto 0);
				addres  <= "000101";
				font_on <= font_out;
			
			else
				font_on <= '0';
			end if;

		end if;

		red_address   <= CONV_STD_LOGIC_VECTOR((64 * CONV_INTEGER(pixel_row)) + CONV_INTEGER(pixel_column(5 downto 0)), 15);
		green_address <= CONV_STD_LOGIC_VECTOR((64 * CONV_INTEGER(pixel_row)) + CONV_INTEGER(pixel_column(5 downto 0)), 15);
		blue_address  <= CONV_STD_LOGIC_VECTOR((64 * CONV_INTEGER(pixel_row)) + CONV_INTEGER(pixel_column(5 downto 0)), 15);

		if (bird_on = '1') then
			red_bird_address   <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(bird_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(bird_posX) - 8), 8);
			green_bird_address <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(bird_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(bird_posX) - 8), 8);
			blue_bird_address  <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(bird_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(bird_posX) - 8), 8);

			Red_Data   <= red_bird_output;
			Green_Data <= green_bird_output;
			Blue_Data  <= blue_bird_output;

		elsif (gift_on = '1') then
			red_powerup_address   <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(gift_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(gift_posX) - 8), 8);
			green_powerup_address <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(gift_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(gift_posX) - 8), 8);
			blue_powerup_address  <= CONV_STD_LOGIC_VECTOR((16 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(gift_posY) - 8)) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(gift_posX) - 8), 8);

			Red_Data   <= red_powerup_output;
			Green_Data <= green_powerup_output;
			Blue_Data  <= blue_powerup_output;

		elsif (pipe1_on = '1' or pipe2_on = '1' or pipe3_on = '1') then
			Red_Data   <= "0011";
			Green_Data <= "0011";
			Blue_Data  <= "0011";
		elsif (pipe1_top_on = '1' or pipe2_top_on = '1' or pipe3_top_on = '1') then
			if (pipe1_top_on = '1') then
				red_pipe_address   <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe1_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe1_posX)), 9);
				green_pipe_address <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe1_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe1_posX)), 9);
				blue_pipe_address  <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe1_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe1_posX)), 9);
			elsif (pipe2_top_on = '1') then
				red_pipe_address   <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe2_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe2_posX)), 9);
				green_pipe_address <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe2_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe2_posX)), 9);
				blue_pipe_address  <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe2_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe2_posX)), 9);
			elsif (pipe3_top_on = '1') then
				red_pipe_address   <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe3_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe3_posX)), 9);
				green_pipe_address <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe3_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe3_posX)), 9);
				blue_pipe_address  <= CONV_STD_LOGIC_VECTOR((20 * (CONV_INTEGER(pixel_row) - CONV_INTEGER(pipe3_posY))) + (CONV_INTEGER(pixel_column) - CONV_INTEGER(pipe3_posX)), 9);
			end if;

			Red_Data   <= red_pipe_output;
			Green_Data <= green_pipe_output;
			Blue_Data  <= blue_pipe_output;
		else
			Red_Data   <= red_background;
			Green_Data <= green_background;
			Blue_Data  <= blue_background;
		end if;

		if (flash = '1') then
			Red_Data   <= not red_background;
			Green_Data <= not green_background;
			Blue_Data  <= not blue_background;
		end if;

		if (menu_on = '1') then
			Red_Data   <= red_background;
			Green_Data <= green_background;
			Blue_Data  <= blue_background;
		end if;

		if (pixel_row < 1 or (pixel_row >= 440 and pixel_row < 452)) then
			Red_Data   <= "0011";
			Green_Data <= "0011";
			Blue_Data  <= "0011";
		elsif (pixel_row >= 452) then
			Red_Data   <= "1111";
			Green_Data <= "1111";
			Blue_Data  <= "1111";
		end if;

		if (font_on = '1') then
			Red_Data   <= "0000";
			Green_Data <= "0000";
			Blue_Data  <= "0000";
		else
			null;
		end if;

	END process RGB_Display;

	Move_Ball : process
		variable init                                                      : std_logic                    := '1';
		variable is_clicked                                                : std_logic                    := '0';
		variable first_clicked                                             : std_logic                    := '0';
		variable level                                                     : integer                      := 1;
		variable count                                                     : integer                      := 0;
		variable count_gravity                                             : integer                      := 0;
		variable gift_on                                                   : std_logic                    := '0';
		variable gift_type                                                 : integer                      := 1;
		variable reset_game                                                : std_logic                    := '0';
		variable slowdown_on                                               : std_logic                    := '0';
		variable slowdown_score1, no_collision_score1, no_collision_score2 : std_logic_vector(3 downto 0) := "0000";
		variable slowdown_score2                                           : std_logic_vector(3 downto 0) := "0000";
		variable dy                                                        : integer                      := 0;
		variable generate_powerup                                          : std_LOGIC                    := '0';
		variable button_pressed                                            : std_LOGIC                    := '0';
		variable pause                                                     : std_logic                    := '0';
		variable gravity_c                                                 : integer range 0 to 5         := 1;
	BEGIN
		-- Move ball once every vertical sync
		WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';

		if game_over = '1' then
			menu_on       <= '1';
			game_over     <= '0';
			bird_posY     <= CONV_STD_LOGIC_VECTOR(200, 10);
			pipe3_posX    <= CONV_STD_LOGIC_VECTOR(640, 10);
			pipe2_posX    <= CONV_STD_LOGIC_VECTOR(440, 10);
			pipe1_posX    <= CONV_STD_LOGIC_VECTOR(240, 10);
			first_clicked := '0';
		end if;

		if pb2 = '0' then
			menu_on <= '1';
		end if;

		if menu_on = '1' then
			stop       <= '1';
			rand_reset <= '1';
			if switch = '1' then
				mode <= '1';
			elsif switch = '0' then
				mode <= '0';
			end if;
			if push_button = '0' then
				menu_on <= '0';
			end if;

		elsif menu_on = '0' then
			IF pb1 = '0' and button_pressed = '0' then
				stop           <= '1';
				button_pressed := '1';
				pause          := '1';
				first_clicked  := '0';

			elsif pb1 = '0' and button_pressed = '1' then
				stop           <= '0';
				button_pressed := '0';
				pause          := '0';
			elsif pb1 = '1' and button_pressed = '0' then
				stop  <= '0';
				pause := '0';

			elsif pb1 = '1' and button_pressed = '1' then
				stop          <= '1';
				pause         := '1';
				first_clicked := '0';

			end if;
		end if;

		if pause = '0' then
			if first_clicked = '0' and lef = '0' then
				stop       <= '1';
				rand_reset <= '0';
			elsif lef = '1' and first_clicked = '0' then
				stop          <= '0';
				first_clicked := '1';
			end if;

			if stop = '0' then
				if mode = '1' then
					level := 1;
				elsif mode = '0' and slowdown_on = '0' then
					if score2 = "0001" then
						level := 1;
					elsif score2 = "0010" then
						level := 2;
					elsif score2 = "0011" then
						level := 2;
					elsif score2 = "0100" then
						level := 3;
					elsif score2 = "0101" then
						level := 3;
					elsif score2 = "0110" then
						level := 3;
					elsif score2 = "0111" then
						level := 4;
					elsif score2 = "1000" then
						level := 4;
					elsif score2 = "1001" then
						level := 5;
					elsif (slowdown_on = '1') then
						level := 1;
						if ((score2 = slowdown_score2 + 1) and (score1 = slowdown_score1)) then
							slowdown_on := '0';
						end if;
					elsif (no_collision = '1') then
						level := 4;
						if ((score2 = no_collision_score2 + 1) and (score1 = no_collision_score1)) then
							no_collision        <= '0';
							no_collision_score1 := "0000";
							no_collision_score2 := "0000";
							level               := 1;
						end if;
					end if;

				end if;

				if (gift_new = '1') then
					gift_posX <= gift_posX - level;
				else
					gift_posX <= CONV_STD_LOGIC_VECTOR(-50, 10);
				end if;
				if '0' & gift_posX <= CONV_STD_LOGIC_VECTOR(0, 11) then
					gift_new <= '0';
				end if;

				if ('0' & pipe1_posX <= CONV_STD_LOGIC_VECTOR(10, 11)) then
					random_Number_Generator_Enable <= '1';
					pipe1_posX                     <= CONV_STD_LOGIC_VECTOR(640, 10);
					pipe1_posY                     <= ("00" & random_num) + 100;
				else
					pipe1_posX                     <= pipe1_posX - level;
					random_Number_Generator_Enable <= '0';
				end if;

				if ('0' & pipe2_posX <= CONV_STD_LOGIC_VECTOR(10, 11)) then
					random_Number_Generator_Enable <= '1';
					pipe2_posX                     <= CONV_STD_LOGIC_VECTOR(640, 10);
					pipe2_posY                     <= ("00" & random_num) + 100;
				else
					pipe2_posX                     <= pipe2_posX - level;
					random_Number_Generator_Enable <= '0';
				end if;

				if ('0' & pipe3_posX <= CONV_STD_LOGIC_VECTOR(10, 11)) then
					random_Number_Generator_Enable <= '1';
					pipe3_posX                     <= CONV_STD_LOGIC_VECTOR(640, 10);
					pipe3_posY                     <= ("00" & random_num) + 100;
					if gift_new = '1' then
						gift_new <= '0';
					end if;
				else
					pipe3_posX                     <= pipe3_posX - level;
					random_Number_Generator_Enable <= '0';
				end if;
				if ((lef = '1' and is_clicked = '0') or (count > 0 and count <= 3)) then
					is_clicked    := '1';
					count         := count + 1;
					count_gravity := 0;
					bird_posY     <= bird_posY - 15;
				elsif ((lef = '0' and is_clicked = '1')) then
					is_clicked    := '0';
					count         := 0;
					count_gravity := count_gravity + 1;
					bird_posY     <= bird_posY + count_gravity;

				else
					if (gravity_c = 5) then
						count_gravity := count_gravity + 1;
						gravity_c     := 0;
					end if;
					gravity_c := gravity_c + 1;
					bird_posY <= bird_posY + count_gravity;
					count     := 0;

				end if;
				flash <= '0';
				IF (bird_posY <= 10) THEN
					bird_posY <= bird_sizeX + 5;
				elsif (('0' & bird_posY) >= (440 - bird_sizeX)) THEN
					game_over    <= '1';
					final_score1 <= score1;
					final_score2 <= score2;
					final_score3 <= score3;
					reset_game   := '1';
					stop         <= '1';

				--		
				elsif (((((((bird_posX + bird_sizeX) >= (pipe1_posX - pipe1_sizeX)) and ((bird_posX + bird_sizeX) <= (pipe1_posX + pipe1_sizeX))) or (((bird_posX) >= (pipe1_posX - pipe1_sizeX)) and ((bird_posX) <= (pipe1_posX + pipe1_sizeX)))) and ((bird_posY <= (pipe1_posY -
										pipe1_sizeY)) or ((bird_posY + bird_sizeY) >= (pipe1_posY + pipe1_sizeY)))) or (((((bird_posX + bird_sizeX) >= (pipe2_posX - pipe2_sizeX)) and ((bird_posX + bird_sizeX) <= (pipe2_posX))) or (((bird_posX) >= (pipe2_posX - pipe2_sizeX)) and ((bird_posX)
										<= (pipe2_posX + pipe2_sizeX)))) and ((bird_posY <= (pipe2_posY - pipe2_sizeY)) or ((bird_posY + bird_sizeY) >= (pipe2_posY + pipe2_sizeY)))) or (((((bird_posX + bird_sizeX) >= (pipe3_posX - pipe3_sizeX)) and ((bird_posX + bird_sizeX) <= (pipe3_posX))) or
								((
										(bird_posX) >= (pipe3_posX - pipe3_sizeX)) and ((bird_posX) <= (pipe3_posX + pipe3_sizeX)))) and ((bird_posY <= (pipe3_posY - pipe3_sizeY)) or ((bird_posY + bird_sizeY) >= (pipe3_posY + pipe3_sizeY))))) and rig = '0' and no_collision = '0') then
					             flash         <= '1';
					             gift_new      <= '0';
					             stop          <= '1';
					             first_clicked := '0';
					             bird_posY     <= CONV_STD_LOGIC_VECTOR(200, 10);
					             pipe3_posX    <= CONV_STD_LOGIC_VECTOR(640, 10);
					             pipe2_posX    <= CONV_STD_LOGIC_VECTOR(440, 10);
					             pipe1_posX    <= CONV_STD_LOGIC_VECTOR(240, 10);

					             if life3_on = '1' then
						         life3_on <= '0';
					             elsif life2_on = '1' and life3_on = '0' then
						         life2_on <= '0';
					             elsif life2_on = '0' and life3_on = '0' and life1_on = '0' then
						         game_over    <= '1';
						         final_score1 <= score1;
						         final_score2 <= score2;
						         final_score3 <= score3;
						         reset_game   := '1';
						         stop         <= '1';
					             elsif life2_on = '0' and life3_on = '0' then
						         life1_on <= '0';
					             end if;

				                 end if;

				                 if (bird_posX > (pipe1_posX + pipe1_sizeX) and score_incremented1 = '0') then
					             score1             <= score1 + 1;
					             score_incremented1 <= '1';
					             if (score1 = "1001") then
						         score2           <= score2 + 1;
						         generate_powerup := '1';
						         score1           <= "0000";
					             elsif (score2 = "1001" and score1 = "1001") then
						         score3 <= score3 + 1;
						         score2 <= "0000";
						         score1 <= "0000";
					             end if;
				                 elsif (bird_posX > (pipe2_posX + pipe2_sizeX) and score_incremented2 = '0') then
					             score1             <= score1 + 1;
					             score_incremented2 <= '1';
					             if (score1 = "1001") then
						         score2 <= score2 + 1;
						         score1 <= "0000";
					             elsif (score2 = "1001" and score1 = "1001") then
						         score3 <= score3 + 1;
						         score2 <= "0000";
						         score1 <= "0000";
					             end if;
				                 elsif (bird_posX > (pipe3_posX + pipe3_sizeX) and score_incremented3 = '0') then
					             score1             <= score1 + 1;
					             score_incremented3 <= '1';
					             if (score1 = "1001") then
						         score2 <= score2 + 1;
						         score1 <= "0000";
					             elsif (score2 = "1001" and score1 = "1001") then
						         score3 <= score3 + 1;
						         score2 <= "0000";
						         score1 <= "0000";
					             end if;
				                 elsif (bird_posX < (pipe1_posX + pipe1_sizeX) and score_incremented1 = '1') then
					             score_incremented1 <= '0';
				                 elsif (bird_posX < (pipe2_posX + pipe2_sizeX) and score_incremented2 = '1') then
					             score_incremented2 <= '0';
				                 elsif (bird_posX < (pipe3_posX + pipe3_sizeX) and score_incremented3 = '1') then
					             score_incremented3 <= '0';
				                 end if;

				                 if score1 = random_num(3 downto 0) and mode = '0' and gift_new = '0' then --needs to become random and different types
					             gift_new  <= '1';
					             gift_posX <= pipe3_posX - 60;

					             gift_type        := 0;
					             gift_posY        <= ("00" & random_num) + 100;
					             generate_powerup := '0';
				                 end if;

				                 if (((((bird_posX + bird_sizeX) >= (gift_posX - gift_sizeX)) and ((bird_posX + bird_sizeX) <= (gift_posX + gift_sizeX))) or ((((bird_posX) >= (gift_posX - gift_sizeX)) and ((bird_posX) <= (gift_posX + gift_sizeX))))) and ((((bird_posY + bird_sizeY) >= (
									gift_posY - gift_sizeY)) and ((bird_posY + bird_sizeY) <= (gift_posY + gift_sizeY))) or ((((bird_posY) >= (gift_posY - gift_sizeY)) and ((bird_posY) <= (gift_posY + gift_sizeY)))))) then
					gift_new  <= '0';
					gift_posX <= CONV_STD_LOGIC_VECTOR(-50, 10);

					if gift_type = 1 then
						if (life1_on = '0' and life2_on = '0' and life3_on = '0') then
							life1_on <= '1';
							life2_on <= '0';
							life3_on <= '0';
						elsif (life2_on = '0' and life3_on = '0' and life1_on = '1') then
							life2_on <= '1';

						elsif (life3_on = '0' and life2_on = '1' and life1_on = '1') then
							life3_on <= '1';
						end if;
					elsif gift_type = 2 then
						slowdown_on     := '1';
						slowdown_score1 := score1;
						slowdown_score1 := score2;
					elsif gift_type = 3 then
						life1_on <= '1';
						life2_on <= '1';
						life3_on <= '1';
					elsif gift_type = 0 and no_collision = '0' then
						no_collision        <= '1';
						no_collision_score1 := score1;
						no_collision_score2 := score2;
					end if;
				end if;

				if reset_game = '1' then
					level            := 1;
					gift_new         <= '0';
					generate_powerup := '0';
					score1           <= "0000";
					score2           <= "0000";
					score3           <= "0000";
					life1_on         <= '1';
					life2_on         <= '1';
					life3_on         <= '1';
					reset_game       := '0';
					no_collision     <= '0';
				end if;

			end if;
		end if;
	END process Move_Ball;

END behavior;

