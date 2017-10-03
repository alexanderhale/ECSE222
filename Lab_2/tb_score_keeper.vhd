---------------------------------------
-- Author: Alex Hale and Grier Ostermann
-- Email: alexander.hale@mail.mcgill.ca and grier.ostermann@mail.mcgill.ca
--
-- This is a test bench for the score keeper module.
---------------------------------------

-- Import the necessary libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_score_keeper is
end tb_score_keeper;

architecture behaviour of tb_score_keeper is
	component score_keeper is
	Port (
		clk		: in std_logic; -- Clock for the system
		rst		: in std_logic;	-- Resets the score
		paddle_left	: in std_logic;
		paddle_right	: in std_logic;
		counter		: in std_logic_vector (3 downto 0);
		score_left	: out std_logic_vector (3 downto 0);
		score_right	: out std_logic_vector (3 downto 0)
		);
	end component;

	-- Inputs
	signal clk_in		: std_logic;
	signal rst_in		: std_logic;
	signal paddle_left_in	: std_logic;
	signal paddle_right_in	: std_logic;
	signal counter_in	: std_logic_vector (3 downto 0);

	-- Outputs
	signal score_left_out	: std_logic_vector (3 downto 0);
	signal score_right_out	: std_logic_vector (3 downto 0);

	-- Helpers
	constant clk_period : time := 10 ns;

begin

	dut: score_keeper
	port map (
		clk => clk_in,
		rst => rst_in,
		paddle_left => paddle_left_in,
		paddle_right => paddle_right_in,
		counter => counter_in,
		score_left => score_left_out,
		score_right => score_right_out
	);

	-- This process creates a clock signal
	clk_process: process
	begin
		clk_in <= '0';
		wait for clk_period/2;
		clk_in <= '1';
		wait for clk_period/2;
	end process;

	-- This initializes the system by holding the reset high for 2 clock periods
	init: process
	begin
		wait for clk_period;
		rst_in <= '1';
		wait for clk_period;
		rst_in <= '0';
		wait;
	end process;

	-- This is the actual unit test
	test: process
	begin
		wait for clk_period * 3;
	
		-- Check that scores are initialized properly
		assert score_left_out = "0000" report "Error" severity Error;
		assert score_right_out = "0000" report "Error" severity Error;

		-- Check right score
		counter_in <= x"0";
		paddle_left_in <= '0';
		paddle_right_in <= '0';
		wait for clk_period;
		assert score_right_out = "0001" report "Error" severity Error;

		-- Check left score
		counter_in <= x"9";
		paddle_left_in <= '0';
		paddle_right_in <= '0';
		wait for clk_period;
		assert score_left_out = "0001" report "Error" severity Error;

		-- Check right block
		counter_in <= x"9";
		paddle_left_in <= '0';
		paddle_right_in <= '1';
		wait for clk_period;
		assert score_left_out = "0001" report "Error" severity Error;

		-- Check left block
		counter_in <= x"0";
		paddle_left_in <= '1';
		paddle_right_in <= '0';
		wait for clk_period;
		assert score_right_out = "0001" report "Error" severity Error;


		-- This will stop the simulation
		assert false report "Score keeper test success!" severity failure;
	end process;

end behaviour;