
Ambiance = Ambiance or {}

module( "Ambiance", package.seeall )

local function duration( min, sec )
	return min * 60 + sec
end

if time.IsChristmas() then
--if game.GetMap() == "gmt_build0c3" then
// CHRISTMAS
Ambiance.Music = {

	// Lobby
	[2] = {
			{ "GModTower/music/christmas/lobby1.mp3", duration( 3, 27 ) },
			{ "GModTower/music/christmas/lobby2.mp3", duration( 2, 24 ) },
	},

	// EPlaza
	[3] = {
		{ "GModTower/music/christmas/entertainment1.mp3", duration( 3, 14 ) },
	},
	
	[9] = {
		{ "gmodtower/lobby/halloween/devhq_ambience.mp3", duration( 3, 14 ) },
	},

	// Theater hallway
	[42] = {
		{ "GModTower/music/theater.mp3", duration( 10, 35 ) },
	},

	// Suites
	[4] = {
		{ "GModTower/music/christmas/suite1.mp3", duration( 4, 20 ) },
		{ "GModTower/music/christmas/suite2.mp3", duration( 2, 34 ) },
		{ "GModTower/music/christmas/suite3.mp3", duration( 5, 37 ) },
	},

	// Arcade
	[38] = {
		{ "GModTower/music/arcade.mp3", duration( 3, 56 ) },
	},

	// Lobby roof
	[43] = {
		{ "GModTower/music/christmas/roof1.mp3", duration( 4, 50 ) },
	},

	// Lake
	[57] = {
		{ "GModTower/music/christmas/lake1.mp3", duration( 2, 37 ) },
	},
	
	// Cabin
	[98] = {
		{ "GModTower/music/christmas/lake1.mp3", duration( 2, 37 ) },
	},

	// Pool
	[56] = {
		{ "GModTower/music/pool1.mp3", duration( 3, 16 ) },
		{ "GModTower/music/pool2.mp3", duration( 3, 28 ) },
	},

	// Gamemodes (manually override for 36 and 37)
	[35] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},
	[36] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},
	[37] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},

	[74] = {
		{ "GModTower/minigolf/music/waiting1.mp3", duration( 0, 32 ) },
		{ "GModTower/minigolf/music/waiting3.mp3", duration( 0, 33 ) },
		{ "GModTower/minigolf/music/waiting5.mp3", duration( 0, 36 ) },
	},

	[75] = {
		{ "GModTower/sourcekarts/music/island_race2.mp3", duration( 3, 34 ) },
		{ "GModTower/sourcekarts/music/raceway_race1.mp3", duration( 2, 12 ) },
		{ "GModTower/sourcekarts/music/island_race3.mp3", duration( 3, 41 ) },
	},

	[76] = {
		{ "GModTower/pvpbattle/startofcolonyround.mp3", duration( 3, 52 ) },
		{ "GModTower/pvpbattle/startofoneslipround.mp3", duration( 5, 59 ) },
		{ "GModTower/pvpbattle/startoffrostbiteround.mp3", duration( 4, 13 ) },
	},

	[77] = {
		{ "GModTower/balls/midori_vox.mp3", duration( 4, 19 ) },
		{ "GModTower/balls/ballsmusicwmemories.mp3", duration( 4, 20 ) },
		{ "GModTower/balls/ballsmusicwsky.mp3", duration( 1, 23 ) },
	},

	[78] = {
		{ "uch/music/round/round_music2.mp3", duration( 2, 14 ) },
		{ "uch/music/round/round_music3.mp3", duration( 0, 50 ) },
		{ "uch/music/round/round_music7.mp3", duration( 1, 43 ) },
	},

	[81] = {
		{ "gmodtower/zom/music/music_round2.mp3", duration( 4, 0 ) },
		{ "gmodtower/zom/music/music_round5.mp3", duration( 4, 1 ) },
		{ "gmodtower/zom/music/music_waiting3.mp3", duration( 0, 30 ) },
	},

	[82] = {
		{ "gmodtower/virus/roundplay2.mp3", duration( 2, 0 ) },
		{ "gmodtower/virus/roundplay4.mp3", duration( 2, 6 ) },
		{ "gmodtower/virus/roundplay3.mp3", duration( 2, 0 ) },
	},
}

--elseif time.IsHalloween() then
elseif game.GetMap() == "gmt_build0h2" then
// HALLOWEEN
Ambiance.Music = {

	// Lobby
	[2] = {
			{ "GModTower/music/halloween/lobby1.mp3", duration( 3, 8 ) },
			{ "GModTower/music/halloween/lobby2.mp3", duration( 2, 37 ) },
	},

	// EPlaza
	[3] = {
		{ "GModTower/music/halloween/haunted.mp3", duration( 3, 34 ) },
	},
	
	[9] = {
		{ "gmodtower/lobby/halloween/devhq_ambience.mp3", duration( 3, 14 ) },
	},
	// Theater hallway
	[42] = {
		{ "GModTower/music/theater.mp3", duration( 10, 35 ) },
	},

	// Suites
	[4] = {
		{ "GModTower/music/halloween/suite1.mp3", duration( 2, 43 ) },
	},

	// Arcade
	[38] = {
		{ "GModTower/music/arcade.mp3", duration( 3, 56 ) },
	},

	// Lobby roof
	[43] = {
		{ "GModTower/music/halloween/roof.mp3", duration( 1, 4 ) },
	},

	// Lake
	[57] = {
		{ "GModTower/music/lakeside.mp3", duration( 2, 19 ) },
		{ "GModTower/music/lakeside2.mp3", duration( 3, 34 ) },
	},
	
	// Cabin
	[98] = {
		{ "GModTower/music/lakeside.mp3", duration( 2, 19 ) },
		{ "GModTower/music/lakeside2.mp3", duration( 3, 34 ) },
	},

	// Pool
	[56] = {
		{ "GModTower/music/pool1.mp3", duration( 3, 16 ) },
		{ "GModTower/music/pool2.mp3", duration( 3, 28 ) },
	},

	// Gamemodes (manually override for 36 and 37)
	[35] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},
	[36] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},
	[37] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},

	[74] = {
		{ "GModTower/minigolf/music/waiting1.mp3", duration( 0, 32 ) },
		{ "GModTower/minigolf/music/waiting3.mp3", duration( 0, 33 ) },
		{ "GModTower/minigolf/music/waiting5.mp3", duration( 0, 36 ) },
	},

	[75] = {
		{ "GModTower/sourcekarts/music/island_race2.mp3", duration( 3, 34 ) },
		{ "GModTower/sourcekarts/music/raceway_race1.mp3", duration( 2, 12 ) },
		{ "GModTower/sourcekarts/music/island_race3.mp3", duration( 3, 41 ) },
	},

	[76] = {
		{ "GModTower/pvpbattle/startofcolonyround.mp3", duration( 3, 52 ) },
		{ "GModTower/pvpbattle/startofoneslipround.mp3", duration( 5, 59 ) },
		{ "GModTower/pvpbattle/startoffrostbiteround.mp3", duration( 4, 13 ) },
	},

	[77] = {
		{ "GModTower/balls/midori_vox.mp3", duration( 4, 19 ) },
		{ "GModTower/balls/ballsmusicwmemories.mp3", duration( 4, 20 ) },
		{ "GModTower/balls/ballsmusicwsky.mp3", duration( 1, 23 ) },
	},

	[78] = {
		{ "uch/music/round/round_music2.mp3", duration( 2, 14 ) },
		{ "uch/music/round/round_music3.mp3", duration( 0, 50 ) },
		{ "uch/music/round/round_music7.mp3", duration( 1, 43 ) },
	},

	[81] = {
		{ "gmodtower/zom/music/music_round2.mp3", duration( 4, 0 ) },
		{ "gmodtower/zom/music/music_round5.mp3", duration( 4, 1 ) },
		{ "gmodtower/zom/music/music_waiting3.mp3", duration( 0, 30 ) },
	},

	[82] = {
		{ "gmodtower/virus/roundplay2.mp3", duration( 2, 0 ) },
		{ "gmodtower/virus/roundplay4.mp3", duration( 2, 6 ) },
		{ "gmodtower/virus/roundplay3.mp3", duration( 2, 0 ) },
	},

}

else

Ambiance.Music = {

	// Lobby
	[2] = {
			{ "GModTower/music/lobby1.mp3", duration( 3, 40 ) },
			{ "GModTower/music/lobby2.mp3", duration( 4, 54 ) },
			{ "GModTower/music/lobby3.mp3", duration( 4, 00 ) },
	},

	// EPlaza
	[3] = {
		{ "GModTower/music/plaza.mp3", duration( 3, 41 ) },
	},
	
	[9] = {
		{ "gmodtower/lobby/halloween/devhq_ambience.mp3", duration( 3, 14 ) },
	},
	// Theater hallway
	[42] = {
		{ "GModTower/music/theater.mp3", duration( 10, 35 ) },
	},

	// Suites
	[4] = {
		{ "GModTower/music/suite1.mp3", duration( 4, 41 ) },
		{ "GModTower/music/suite2.mp3", duration( 3, 16 ) },
	},

	// Arcade
	[38] = {
		{ "GModTower/music/arcade.mp3", duration( 3, 56 ) },
	},

	// Lobby roof
	[43] = {
		{ "GModTower/music/lobbyroof.mp3", duration( 1, 34 ) },
	},

	// Lake
	[57] = {
		{ "GModTower/music/lakeside.mp3", duration( 2, 19 ) },
		{ "GModTower/music/lakeside2.mp3", duration( 3, 34 ) },
	},

	// Cabin
	[98] = {
		{ "GModTower/music/lakeside.mp3", duration( 2, 19 ) },
		{ "GModTower/music/lakeside2.mp3", duration( 3, 34 ) },
	},

	// Pool
	[56] = {
		{ "GModTower/music/pool1.mp3", duration( 3, 16 ) },
		{ "GModTower/music/pool2.mp3", duration( 3, 28 ) },
	},

	// Gamemodes (manually override for 36 and 37)
	[35] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},
	[36] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},
	[37] = {
		{ "GModTower/music/gamemodes1.mp3", duration( 2, 1 ) },
		{ "GModTower/music/gamemodes2.mp3", duration( 1, 46 ) },
	},

	[74] = {
		{ "GModTower/minigolf/music/waiting1.mp3", duration( 0, 32 ) },
		{ "GModTower/minigolf/music/waiting3.mp3", duration( 0, 33 ) },
		{ "GModTower/minigolf/music/waiting5.mp3", duration( 0, 36 ) },
	},

	[75] = {
		{ "GModTower/sourcekarts/music/island_race2.mp3", duration( 3, 34 ) },
		{ "GModTower/sourcekarts/music/raceway_race1.mp3", duration( 2, 12 ) },
		{ "GModTower/sourcekarts/music/island_race3.mp3", duration( 3, 41 ) },
	},

	[76] = {
		{ "GModTower/pvpbattle/startofcolonyround.mp3", duration( 3, 52 ) },
		{ "GModTower/pvpbattle/startofoneslipround.mp3", duration( 5, 59 ) },
		{ "GModTower/pvpbattle/startoffrostbiteround.mp3", duration( 4, 13 ) },
	},

	[77] = {
		{ "GModTower/balls/midori_vox.mp3", duration( 4, 19 ) },
		{ "GModTower/balls/ballsmusicwmemories.mp3", duration( 4, 20 ) },
		{ "GModTower/balls/ballsmusicwsky.mp3", duration( 1, 23 ) },
	},

	[78] = {
		{ "uch/music/round/round_music2.mp3", duration( 2, 14 ) },
		{ "uch/music/round/round_music3.mp3", duration( 0, 50 ) },
		{ "uch/music/round/round_music7.mp3", duration( 1, 43 ) },
	},

	[81] = {
		{ "gmodtower/zom/music/music_round2.mp3", duration( 4, 0 ) },
		{ "gmodtower/zom/music/music_round5.mp3", duration( 4, 1 ) },
		{ "gmodtower/zom/music/music_waiting3.mp3", duration( 0, 30 ) },
	},

	[82] = {
		{ "gmodtower/virus/roundplay2.mp3", duration( 2, 0 ) },
		{ "gmodtower/virus/roundplay4.mp3", duration( 2, 6 ) },
		{ "gmodtower/virus/roundplay3.mp3", duration( 2, 0 ) },
	},

}

end
