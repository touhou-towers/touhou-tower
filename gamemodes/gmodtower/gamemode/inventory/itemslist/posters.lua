

-----------------------------------------------------
module( "GTowerItems", package.seeall )

local function RegisterChildPosters( base, tbl, start, dateadded )

	for id, name in ipairs( tbl ) do

		local nameid = string.lower(string.gsub(name, "%s+", ""))

		--print( "postera" .. id-1+start .. "_" .. nameid, name, id )

		RegisterItem("postera" .. id-1+start .. "_" .. nameid,
		{
			Base = base,
			Name = "Poster: " .. name,
			ModelSkinId = id,
			DateAdded = dateadded,
		})

	end

end

RegisterItem("poster1",{
	Name = "Poster: Classic Video Games",
	Description = "A poster you can use to decorate your suite with.",
	Model = "models/gmod_tower/poster1.mdl",
	ModelSkinId = 0,
	DrawModel = true,
	InvCategory = "posters",
	StoreId = 15,
	StorePrice = 35,
	DrawName = true,
	MoveSound = "paper",

	Manipulator = function( ang, pos, normal )
		ang:RotateAroundAxis( ang:Right(), 270 )
		ang:RotateAroundAxis( ang:Up(), 180 )
		ang:RotateAroundAxis( ang:Forward(), 180 )

		pos = pos + ( normal * 1.05 )

		return pos
	end
})

RegisterItem("poster2",{
	Base = "poster1",
	Name = "Poster: Legend of Zelda: Twilight Princess",
	Model = "models/gmod_tower/poster2.mdl",
	ModelSkinId = 0,
})

RegisterItem("poster3",{
	Base = "poster1",
	Name = "Poster: Portal: Companion Cube",
	Model = "models/gmod_tower/poster3.mdl",
	ModelSkinId = 0,
})

RegisterItem("poster4",{
	Base = "poster1",
	Name = "Poster: Ghostbusters",
	Model = "models/gmod_tower/poster4.mdl",
	ModelSkinId = 0,
})

RegisterItem("poster5_left4dead",{
	Base = "poster1",
	Name = "Poster: Left 4 Dead",
	ModelSkinId = 1,
})

RegisterItem("poster6_waroftheservers",{
	Base = "poster1",
	Name = "Poster: War of the Servers",
	ModelSkinId = 2,
})

RegisterItem("poster7_tf2pryo",{
	Base = "poster1",
	Name = "Poster: TF2: Pyro",
	ModelSkinId = 3,
})

RegisterItem("poster8_district9",{
	Base = "poster1",
	Name = "Poster: District 9",
	ModelSkinId = 4,
})

RegisterItem("poster9_borderlands",{
	Base = "poster1",
	Name = "Poster: Borderlands: Claptrap",
	ModelSkinId = 5,
})

RegisterItem("poster10_silenthill",{
	Base = "poster1",
	Name = "Poster: Silent Hill",
	ModelSkinId = 6,
})

RegisterItem("poster11_hl2",{
	Base = "poster1",
	Name = "Poster: Half-Life 2",
	ModelSkinId = 7,
})

RegisterItem("poster12_kirby",{
	Base = "poster1",
	Name = "Poster: Kirby",
	ModelSkinId = 8,
})

RegisterItem("poster13_gta4",{
	Base = "poster1",
	Name = "Poster: Grand Theft Auto 4",
	ModelSkinId = 9,
})

RegisterItem("poster14_counterstrike",{
	Base = "poster1",
	Name = "Poster: Counter-Strike Source",
	ModelSkinId = 10,
})

RegisterItem("poster15_crysis",{
	Base = "poster1",
	Name = "Poster: Crysis",
	ModelSkinId = 11,
})

RegisterItem("poster16_metalgear",{
	Base = "poster1",
	Name = "Poster: Metal Gear Solid",
	ModelSkinId = 12,
})

RegisterItem("poster17_inception",{
	Base = "poster1",
	Name = "Poster: Inception",
	ModelSkinId = 13,
})

RegisterItem("poster18_prototype",{
	Base = "poster1",
	Name = "Poster: Prototype",
	ModelSkinId = 14,
})

RegisterItem("poster19_bioshock",{
	Base = "poster1",
	Name = "Poster: Bioshock",
	ModelSkinId = 15,
})

RegisterItem("poster20_fallout3",{
	Base = "poster2",
	Name = "Poster: Fallout 3",
	ModelSkinId = 1,
})

RegisterItem("poster21_littlebig",{
	Base = "poster2",
	Name = "Poster: Little Big Planet",
	ModelSkinId = 2,
})

RegisterItem("poster22_audiosurf",{
	Base = "poster2",
	Name = "Poster: Audiosurf",
	ModelSkinId = 3,
})

RegisterItem("poster23_killingfloor",{
	Base = "poster2",
	Name = "Poster: Killing Floor",
	ModelSkinId = 4,
})

RegisterItem("poster24_gmod",{
	Base = "poster2",
	Name = "Poster: Garry's Mod",
	ModelSkinId = 5,
})

RegisterItem("poster25_arrow",{
	Base = "poster2",
	Name = "Poster: Arrow",
	ModelSkinId = 6,
})

RegisterItem("poster26_facepunch",{
	Base = "poster2",
	Name = "Poster: Facepunch",
	ModelSkinId = 7,
})

RegisterItem("poster27_assassian",{
	Base = "poster2",
	Name = "Poster: Assassin's Creed",
	ModelSkinId = 8,
})

RegisterItem("poster28_zombieland",{
	Base = "poster2",
	Name = "Poster: Zombieland",
	ModelSkinId = 9,
})

RegisterItem("poster29_28days",{
	Base = "poster2",
	Name = "Poster: 28 Days Later",
	ModelSkinId = 10,
})

RegisterItem("poster30_indiania",{
	Base = "poster2",
	Name = "Poster: Indiana Jones",
	ModelSkinId = 11,
})

RegisterItem("poster31_scarface",{
	Base = "poster2",
	Name = "Poster: Scarface",
	ModelSkinId = 12,
})

RegisterItem("poster32_p911",{
	Base = "poster2",
	Name = "Poster: Porsche 911",
	ModelSkinId = 13,
})

RegisterItem("poster33_bmw",{
	Base = "poster2",
	Name = "Poster: BMW",
	ModelSkinId = 14,
})

RegisterItem("poster34_mortalkombat",{
	Base = "poster2",
	Name = "Poster: Mortal Kombat",
	ModelSkinId = 15,
})

RegisterItem("poster35_supersmash",{
	Base = "poster3",
	Name = "Poster: Super Smash Bros.",
	ModelSkinId = 1,
})

RegisterItem("poster36_sf4",{
	Base = "poster3",
	Name = "Poster: Street Fighter 4",
	ModelSkinId = 2,
})

RegisterItem("poster37_batman",{
	Base = "poster3",
	Name = "Poster: Batman",
	ModelSkinId = 3,
})

RegisterItem("poster38_backto",{
	Base = "poster3",
	Name = "Poster: Back to the Future",
	ModelSkinId = 4,
})

RegisterItem("poster39_redrabbit",{
	Base = "poster3",
	Name = "Poster: Red Rabbit",
	Description = "A questionable rabbit poster for you. For a price, of course.",
	ModelSkinId = 5,
	StorePrice = 5000,
})

RegisterItem("poster40_portal2blu",{
	Base = "poster3",
	Name = "Poster: Portal 2: Blue",
	ModelSkinId = 6,
})

RegisterItem("poster41_portal2org",{
	Base = "poster3",
	Name = "Poster: Portal 2: Orange",
	ModelSkinId = 7,
})

RegisterItem("poster42_jakdaxter",{
	Base = "poster3",
	Name = "Poster: Jak & Daxter/Ratchet & Clank",
	ModelSkinId = 8,
})

RegisterItem("poster43_ratchet",{
	Base = "poster3",
	Name = "Poster: Ratchet and Clank",
	ModelSkinId = 9,
})

RegisterItem("poster44_windwaker",{
	Base = "poster3",
	Name = "Poster: Wind Waker",
	ModelSkinId = 10,
})

RegisterItem("poster45_okami",{
	Base = "poster3",
	Name = "Poster: Okami",
	ModelSkinId = 11,
})

RegisterItem("poster46_kingdomhearts",{
	Base = "poster3",
	Name = "Poster: Kingdom Hearts",
	ModelSkinId = 12,
})

RegisterItem("poster47_metroid",{
	Base = "poster3",
	Name = "Poster: Metroid",
	ModelSkinId = 13,
})

RegisterItem("poster48_3ddotgame",{
	Base = "poster3",
	Name = "Poster: 3D Dot Game Heroes",
	ModelSkinId = 14,
})

RegisterItem("poster49_psychonauts",{
	Base = "poster3",
	Name = "Poster: Psychonauts",
	ModelSkinId = 15,
})

RegisterItem("poster50_minecraft",{
	Base = "poster4",
	Name = "Poster: Minecraft",
	ModelSkinId = 1,
})

RegisterItem("poster51_samandmax",{
	Base = "poster4",
	Name = "Poster: Sam and Max",
	ModelSkinId = 2,
})

RegisterItem("poster52_gmt",{
	Base = "poster4",
	Name = "Poster: GMTower - Lobby 1",
	ModelSkinId = 3,
})

RegisterItem("poster53_pvpbattle",{
	Base = "poster4",
	Name = "Poster: PVP Battle",
	ModelSkinId = 4,
})

RegisterItem("poster54_ballrace",{
	Base = "poster4",
	Name = "Poster: Ball Race",
	ModelSkinId = 5,
})

RegisterItem("poster55_virus",{
	Base = "poster4",
	Name = "Poster: Virus",
	ModelSkinId = 6,
})

RegisterItem("poster56_vidcritter",{
	Base = "poster4",
	Name = "Poster: Video Game Critters",
	ModelSkinId = 7,
	StorePrice = 100
})

RegisterItem("poster57_ico",{
	Base = "poster4",
	Name = "Poster: ICO",
	ModelSkinId = 8,
})

RegisterItem("poster58_conker",{
	Base = "poster4",
	Name = "Poster: Conker's Bad Fur Day",
	ModelSkinId = 9,
})

RegisterItem("poster59_mario",{
	Base = "poster4",
	Name = "Poster: Mario",
	ModelSkinId = 10,
})

RegisterItem("poster60_alienswarm",{
	Base = "poster4",
	Name = "Poster: Alien Swarm",
	ModelSkinId = 11,
})

RegisterItem("poster61_pokemon",{
	Base = "poster4",
	Name = "Poster: Pokemon",
	ModelSkinId = 12,
})

RegisterItem("poster62_eureka",{
	Base = "poster4",
	Name = "Poster: Eureka",
	ModelSkinId = 13,
})

RegisterItem("poster63_banjo",{
	Base = "poster4",
	Name = "Poster: Banjo Kazooie",
	ModelSkinId = 14,
})

RegisterItem("poster64_housemd",{
	Base = "poster4",
	Name = "Poster: House MD",
	ModelSkinId = 15,
})

// Poster A
// =============================

RegisterItem("postera1",{
	Base = "poster1",
	Name = "Poster: Quake",
	Model = "models/gmod_tower/postera1.mdl",
	ModelSkinId = 0,
})

RegisterItem("postera2",{
	Base = "poster1",
	Name = "Poster: Sly Cooper",
	Model = "models/gmod_tower/postera2.mdl",
	ModelSkinId = 0,
})

RegisterItem("postera3",{
	Base = "poster1",
	Name = "Poster: Pug Life",
	Model = "models/gmod_tower/postera3.mdl",
	ModelSkinId = 0,
})

RegisterItem("postera4",{
	Base = "poster1",
	Name = "Poster: Lion King",
	Model = "models/gmod_tower/postera4.mdl",
	ModelSkinId = 0,
})
local posters = {
	["a1"] = {
		"Saints Row 4",
		"Terraria",
		"Amnesia",
		"Back To The Future 3",
		"Serious Cat",
		"Company of Heroes 2",
		"Duke Nukem",
		"Dust An Elysian Tail",
		"Payday",
		"Fox",
		"Farcry 3",
		"Grand Theft Auto 5",
		"The Aristocats",
		"Hotline Miami",
		"Arma 3"
	},
	["a2"] = {
		"Metro Last Light",
		"Breaking Bad",
		"Bioshock Infinite",
		"Postal 2",
		"Rayman",
		"Sanctum 2",
		"Kerbal Space Program",
		"Killzone",
		"Super Hexagon",
		"Trials Evolution",
		"Age of Empires 2: Age of Kings",
		"WatchDogs",
		"Hang In There, Baby",
		"Time Splitters 2",
		"James Bond",
	},
	["a3"] = {
		"Tron",
		"Django Unchained",
		"The Little Mermaid",
		"The Walking Dead",
		"Army of Two",
		"Dead Space",
		"Pokemon",
		"Attack on Titan",
		"Indie Games",
		"Daft Punk",
		"Doctor Who",
		":V",
		"Space Blues",
		"Portal",
		"Runner 2",
	},
	["a4"] = {
		"Pokemon",
		"Avengers",
		"Ocarina Of Time",
		"Mass Effect",
		"Sonic Generations",
		"Cave Story",
		"Three Wolf Moon",
		"Mother 3",
		"Inglorious Basterds",
		"Pigmasks Unite",
		"Legend of Zelda",
		"Pirates of the Caribbean",
		"Sherlock Holmes",
		"Scream",
		"The Dark Knight",
	},
}

RegisterChildPosters( "postera1", posters.a1, 5, 1399197707 )
RegisterChildPosters( "postera2", posters.a2, 20, 1399197707 )
RegisterChildPosters( "postera3", posters.a3, 35, 1399197707 )
RegisterChildPosters( "postera4", posters.a4, 50, 1399197707 )

