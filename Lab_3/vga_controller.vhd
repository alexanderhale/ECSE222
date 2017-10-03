-----------------------------------
-- Author: Shabbir Hussain, additions by Alex Hale and Grier Ostermann
-- Email: shabbir.hussain@mail.mcgill.ca / alexander.hale@mail.mcgill.ca, grier.ostermann@mail.mcgill.ca

-- This module handles the synchronization and timing of the VGA output

-- Horizontal Sync
-- Configuration   | Resolution | Sync    | Back  Porch | RGB      | Front porch | Clock
-- 640x480(60Hz)   | 640x480    | 3.8us   |    1.9us    | 25.4 us  |    0.6us    | 25.197 MHz
--                                96 pix      48 pix      640 pix       15 pix 						-- NOTE: changed values to reflect table in manual
-- Total pixels = sync+bp+rgb+fp = 799

-- Veritcal sync
-- Configuration   | Resolution | Sync    | Back  Porch |  RGB       | Front porch    | Clock
-- 640x480(60Hz)   | 640x480    |  2 line |    33 line  |  480 line  |    10 line     | 25.197 MHz
--
-- Total lines = 525



-- HIGHEST POSSIBLE RESOLUTION

-- Horizontal Sync
-- Configuration   | Resolution | Sync    | Back  Porch | RGB      | Front porch | Clock
-- 1280x1024(60Hz) | 1280x1024  | 1.0us   |    2.3us    | 11.9 us  |    0.4us    | 107.56 MHz
--                                108 pix      247 pix    1280 pix      43 pix 
-- Total pixels = sync+bp+rgb+fp = 1678

-- Veritcal sync
-- Configuration   | Resolution | Sync    | Back  Porch |  RGB       | Front porch    | Clock
-- 1280x1024(60Hz) | 1280x1024  |  3 line |    38 line  |  1024 line  |    1 line     | 107.56 MHz
--
-- Total lines = 1066

----------------------------------- 
-- Import the necessary libraries
library ieee;
use ieee.std_logic_1164.all;


-- Declare entity
entity vga_controller is
    Generic(
        -- 640x480
        MAX_H : integer := 800;
        S_H   : integer := 96;
        BP_H  : integer := 48;
        RGB_H : integer := 640;
        FP_H  : integer := 16;

        MAX_V : integer := 525;
        S_V   : integer := 2;
        BP_V  : integer := 33;
        RGB_V : integer := 480;
        FP_V  : integer := 10;

        PIXLS : integer := 307200 -- Total num Pixels = 640 x 480
		  
		  
		  -- 1280 x 1024   (need to change clock speed as well)
--		  MAX_H : integer := 1678;
--        S_H   : integer := 108;
--        BP_H  : integer := 247;
--        RGB_H : integer := 1280;
--        FP_H  : integer := 43;
--
--        MAX_V : integer := 1066;
--        S_V   : integer := 3;
--        BP_V  : integer := 38;
--        RGB_V : integer := 1024;
--        FP_V  : integer := 1;
--
--        PIXLS : integer := 1310720 -- Total num Pixels = 1280 x 1024
           );
    Port (
    --Inputs
    clk         : in std_logic; -- VGA clock
    rst         : in std_logic;

    -- Outputs
	 pixel_x     : out integer;
	 pixel_y		 : out integer;
    vga_blank   : out std_logic;


    vga_hs      : out std_logic;
    vga_vs      : out std_logic;


    vga_clk     : out std_logic;
    vga_sync    : out std_logic	 
    );

end vga_controller;


architecture behaviour of vga_controller is
     signal hpos : integer range 0 to MAX_H := 0;
     signal vpos : integer range 0 to MAX_V := 0;
	 
	 signal vga_hsr : std_logic; -- Temp registers for 
	 signal vga_vsr : std_logic; -- Hsync and Vsync

    signal pixel_xr : integer := 0; -- Pixel position register
	 signal pixel_yr : integer := 0; -- Pixel position register

begin

    -- Map to DAC (digital to analog converter)
    vga_clk <= clk;
	 vga_hs <= vga_hsr;
	 vga_vs <= vga_vsr;
	 vga_sync <= (vga_hsr and vga_vsr);
	 pixel_x <= pixel_xr;
	 pixel_y <= pixel_yr;
	    
    process(clk)
    begin
        if(rst = '1') then
            hpos <= 0;
            vpos <= 0;

            pixel_xr <= 0;
				pixel_yr <= 0;

        elsif rising_edge(clk) then
          
            if (hpos < MAX_H) then
					hpos <= hpos + 1;		-- if hpos has room to move right, increase its position by 1
				else
					hpos <= 0;					-- if hpos has hit the right-hand edge, set it back to 0
					if (vpos < MAX_V) then		
						vpos <= vpos + 1;		-- if vpos has room to move down, increase its position by 1
					else
						vpos <= 0;				-- if vpos has hit the bottom, set it back to 0
					end if;
				end if;
				
         
				if hpos < S_H then
					vga_hsr <= '0';		-- if hpos is in the horizontal sync section, set temp register to 0
				else
					vga_hsr <= '1';
				end if;
				
				if vpos < S_V then
					vga_vsr <= '0';	-- if vpos is in the vertical sync section, set temp register to 0
				else
					vga_vsr <= '1';
				end if;
			
				
				--if (((hpos >= 0) AND (hpos < (S_H + BP_H))) OR (hpos >= (S_H + BP_H + RGB_H))) then
				 -- if (((hpos >= 0) AND (hpos < S_H)) OR ((hpos >= S_H) AND (hpos < (S_H + BP_H))) OR (hpos >= (S_H + BP_H + RGB_H)) OR ((vpos >= 0) AND (vpos < S_V))) then -- checks if we are in any of the "off-screen" sections: front porch, back porch, horizontal sync, vertical sync
				 if( (hpos < S_H+BP_H) or (hpos >= S_H+BP_H+RGB_H) or (vpos < S_V+BP_V) or (vpos >= S_V+BP_V+RGB_V)) then
					vga_blank <= '0';				-- set blank when in a porch or sync section
				else									-- order in if statement: within hsync OR within hBP OR within hFP   (within vsync is covered by those 3 cases)
					vga_blank <= '1';
					
					if (pixel_xr < RGB_H-1) then
						pixel_xr <= pixel_xr + 1;		-- if there is still room to move right in the "on-screen" portion, move one pixel right
					else
						pixel_xr <= 0;						-- if we've reached the right-hand side of the "on-screen" portion, set back to 0
						
						if (pixel_yr < RGB_V-1) then
							pixel_yr <= pixel_yr + 1;	-- if there is still room to move down in the "on-screen" portion, move one line down
						else
							pixel_yr <= 0;					-- if we've reached the bottom of the "on-screen" portion, set back to 0
						end if;
					end if;
				end if;
			
			-- WRITE YOUR CODE ABOVE
			
        end if;
    end process;
end behaviour;
