---------------------------------------
-- Author: Alex Hale and Grier Ostermann
-- Email: alexander.hale@mail.mcgill.ca and grier.ostermann@mail.mcgill.ca
--
-- This test bench makes sure the clock is being slowed adequately.
---------------------------------------

-- Import the necessary libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declare entity
entity tb_clock_divider is
end tb_clock_divider;

architecture behaviour of tb_clock_divider is

	-- Declare the device as a component
	component clock_divider is
	Generic (slow_factor : integer := 1000 );
	Port (
		clk		: in std_logic; -- Clock for the system
		rst		: in std_logic; -- Reset the counter
		slow_clk	: out std_logic -- Slow clock value
		);
	end component;

	-- Inputs
	signal clk_in	: std_logic;
	signal rst_in	: std_logic;

	-- Output
	signal clk_out	: std_logic;

	-- Helper
	constant clk_period	: time := 10 ns;
	constant run_time	: integer := 5000;

begin

	-- Instantiate the divider
	clock_div: clock_divider
	port map (
		clk => clk_in,
		rst => rst_in,
		slow_clk => clk_out
		);

	-- This process creates a clock signal
	clk_process: process
	begin
		clk_in <= '0';
		wait for clk_period/2;
		clk_in <= '1';
		wait for clk_period/2;
	end process;

	-- This is the actual unit test
	test: process
	begin
		rst_in <= '1';
		wait for clk_period;
		-- Check that there is a pulse after 1 million cycles
		assert clk_out = '0' report "Error" severity Error;
		rst_in <= '0';

		wait for clk_period * (run_time);
		assert clk_out = '1' report "Error" severity Error;

		-- This will stop the simulation
		assert false report "Clock Divider test Success!" severity failure;
	end process;

end behaviour;