---------------------------------------
-- Author: Alex Hale and Grier Ostermann
-- Email: alexander.hale@mail.mcgill.ca and grier.ostermann@mail.mcgill.ca
---------------------------------------

-- Import the necessary libraries
library ieee;
use ieee.std_logic_1164.all;

-- Declare entity
entity ledPong is
	Port (
		clk				: in std_logic; -- Clock for the system
		rst				: in std_logic; -- Resets the game
		paddle_left		: in std_logic; -- Button input from left player
		paddle_right	: in std_logic; -- Button input from right player
		leds				: out std_logic_vector (9 downto 0); -- which of the LEDs are ON
		score_left_segments 	: out std_logic_vector (6 downto 0);  -- Displays the left player's score
		score_right_segments	: out std_logic_vector (6 downto 0)  -- Displays the right player's score
			);
end ledPong;

architecture behaviour of ledPong is
	
	component clock_divider is
		Port (
			clk		: in std_logic; -- Clock for the system
			slow_clk	: out std_logic -- slow clock value
				);
	end component;
	
	component counter is
		Port (
			clk		: in std_logic; -- Clock for the system
			rst		: in std_logic; -- resets the count
			count		: out std_logic_vector (3 downto 0) -- value of counter
				);
	end component;

	component led_decoder is
		Port (
			count		: in std_logic_vector (3 downto 0); -- value of counter
			leds		: out std_logic_vector (9 downto 0) -- which of the LEDs are ON
				);
	end component;
	
	component seven_seg_decoder is
		Port (
			number		: in std_logic_vector (3 downto 0); -- value of counter
			segments		: out std_logic_vector (6 downto 0) -- pattern to be displayed on the 7-segment display
				);
	end component;
	
	component score_keeper is
		Port (
			clk				: in std_logic;  -- Clock for the system
			rst				: in std_logic;  -- Resets the score
			paddle_left		: in std_logic;
			paddle_right 	: in std_logic;
			counter			: in std_logic_vector (3 downto 0);
			score_left		: out std_logic_vector (3 downto 0);
			score_right		: out std_logic_vector (3 downto 0)
		);
		end component;
		
		--Wires
		signal slow_clk 		: std_logic;
		signal count_out		: std_logic_vector (3 downto 0);
		signal score_left_wire 	: std_logic_vector (3 downto 0);
		signal score_right_wire	: std_logic_vector (3 downto 0);

begin 

	--Instatiate the components
	clk_div: clock_divider
	port map (
		clk => clk,
		slow_clk => slow_clk
	);
	
	spec_counter: counter
	port map (
		clk => slow_clk,
		rst => rst,
		count => count_out
	);
	
	led_dec_inst: led_decoder 
	port map (
		count => count_out,
		leds => leds
	);

	score_left: seven_seg_decoder 
	port map (
		number => score_left_wire,
		segments => score_left_segments 
	);

	score_right: seven_seg_decoder 
	port map (
		number => score_right_wire,
		segments => score_right_segments
	);

	score_keeper_module: score_keeper
	port map (
		clk => slow_clk,
		rst => rst,
		paddle_left => not paddle_left,
		paddle_right => not paddle_right,
		counter => count_out,
		score_left => score_left_wire,
		score_right => score_right_wire
	);

end behaviour;
