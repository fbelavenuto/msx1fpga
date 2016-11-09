-------------------------------------------------------------------------------
--
-- Based on: $Id: vdp18_col_pack-p.vhd,v 1.3 2006/02/28 22:30:41 arnim Exp $
--
-- Copyright (c) 2006, Arnim Laeuger (arnim.laeuger@gmx.net)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package vdp18_paletas_3bit_pack is

	constant r_c : natural := 0;
	constant g_c : natural := 1;
	constant b_c : natural := 2;

	subtype rgb_val_t    is natural range 0 to 7;
	type    rgb_triple_t is array (natural range 0 to  2) of rgb_val_t;
	type    rgb_table_t  is array (natural range 0 to 15) of rgb_triple_t;

	-- Original
	constant paleta1_c : rgb_table_t := (
	--   R   G   B
		( 0, 0, 0),                   -- Transparent		RGB
		( 0, 0, 0),                   -- Black				000
		( 1, 6, 2),                   -- Medium Green	162
		( 2, 6, 3),                   -- Light Green		263
		( 2, 2, 7),                   -- Dark Blue		227
		( 3, 3, 7),                   -- Light Blue		337
		( 6, 2, 2),                   -- Dark Red			622
		( 2, 7, 7),                   -- Cyan				277
		( 7, 2, 2),                   -- Medium Red		722
		( 7, 3, 3),                   -- Light Red		733
		( 6, 6, 2),                   -- Dark Yellow		662
		( 7, 6, 4),                   -- Light Yellow	764
		( 1, 5, 1),                   -- Dark Green		151
		( 6, 2, 5),                   -- Magenta			625
		( 3, 3, 3),                   -- Gray				333
		( 7, 7, 7)                    -- White				777
	);

	-- MSXBT601
	constant paleta2_c : rgb_table_t := (
	--   R   G   B
		( 0, 0, 0),                   -- Transparent		RB0G
		( 0, 0, 0),                   -- Black				0000
		( 0, 6, 1),                   -- Medium Green	0106
		( 2, 7, 3),                   -- Light Green		2307
		( 2, 2, 7),                   -- Dark Blue		2702
		( 3, 3, 7),                   -- Light Blue		3703
		( 6, 2, 2),                   -- Dark Red			6202
		( 1, 7, 7),                   -- Cyan				1707
		( 7, 2, 2),                   -- Medium Red		7202
		( 7, 3, 3),                   -- Light Red		7303
		( 6, 6, 2),                   -- Dark Yellow		6206
		( 6, 6, 3),                   -- Light Yellow	6306
		( 0, 5, 1),                   -- Dark Green		0105
		( 6, 3, 5),                   -- Magenta			6503
		( 6, 6, 6),                   -- Gray				6606
		( 7, 7, 7)                    -- White				7707
	);

	-- MSX1YUV
	constant paleta3_c : rgb_table_t := (
	--   R  G  B
		( 0, 0, 0),                   -- Transparent		RB0G
		( 0, 0, 0),                   -- Black				0000
		( 0, 6, 1),                   -- Medium Green	2205
		( 2, 7, 3),                   -- Light Green		3306
		( 2, 2, 7),                   -- Dark Blue		2602
		( 3, 3, 7),                   -- Light Blue		3703
		( 6, 2, 2),                   -- Dark Red			5203
		( 1, 7, 7),                   -- Cyan				3706
		( 7, 2, 2),                   -- Medium Red		6203
		( 7, 3, 3),                   -- Light Red		7304
		( 6, 6, 2),                   -- Dark Yellow		6305
		( 6, 6, 3),                   -- Light Yellow	6406
		( 0, 5, 1),                   -- Dark Green		2204
		( 6, 3, 5),                   -- Magenta			5503
		( 6, 6, 6),                   -- Gray				6606
		( 7, 7, 7)                    -- White				7707
	);

	-- ZX Spectrum
	constant paleta4_c : rgb_table_t := (
	--   R  G  B
		( 0, 0, 0),                   -- Transparent		RB0G
		( 0, 0, 0),                   -- Black				0000
		( 0, 7, 0),                   -- Medium Green	0007
		( 0, 7, 7),                   -- Light Green		0707
		( 0, 0, 5),                   -- Dark Blue		0500
		( 0, 0, 7),                   -- Light Blue		0700
		( 5, 0, 0),                   -- Dark Red			5000
		( 0, 5, 5),                   -- Cyan				0505
		( 7, 0, 0),                   -- Medium Red		7000
		( 7, 0, 7),                   -- Light Red		7700
		( 5, 5, 0),                   -- Dark Yellow		5005
		( 7, 7, 0),                   -- Light Yellow	7007
		( 0, 5, 0),                   -- Dark Green		0005
		( 5, 0, 5),                   -- Magenta			5500
		( 5, 5, 5),                   -- Gray				5505
		( 7, 7, 7)                    -- White				7707
	);

	-- FRS Cool Colors
	constant paleta5_c : rgb_table_t := (
	--   R  G  B
		( 0, 0, 0),                   -- Transparent		RB0G
		( 0, 0, 0),                   -- Black				0000
		( 2, 5, 3),                   -- Medium Green	2305
		( 3, 6, 4),                   -- Light Green		3406
		( 1, 2, 5),                   -- Dark Blue		1502
		( 2, 3, 6),                   -- Light Blue		2603
		( 5, 2, 1),                   -- Dark Red			5102
		( 3, 5, 7),                   -- Cyan				3705
		( 6, 3, 2),                   -- Medium Red		6203
		( 7, 4, 2),                   -- Light Red		7204
		( 7, 6, 2),                   -- Dark Yellow		7206
		( 7, 7, 4),                   -- Light Yellow	7407
		( 1, 4, 2),                   -- Dark Green		1204
		( 5, 2, 4),                   -- Magenta			5402
		( 5, 5, 5),                   -- Gray				5505
		( 7, 7, 7)                    -- White				7707
	);

end package;
