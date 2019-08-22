
BallRacer = {}
BallRacer.StoreId = 5

hook.Add("GTowerStoreLoad", "AddLoadBallracerItems", function()

	GTowerStore:SQLInsert( {
		Name = "Cube",
		description = "Roll down the hill on one surface.",
		unique_Name = "BallRacerCube",
		price = 800,
		model = "models/gmod_tower/cubeball.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )

	GTowerStore:SQLInsert( {
		Name = "Icosahedron",
		description = "We don't know what it is either.",
		unique_Name = "BallRacerIcosahedron",
		price = 500,
		model = "models/gmod_tower/icosahedron.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )

	GTowerStore:SQLInsert( {
		Name = "Cat Orb",
		description = "Aww, look, it has little ears. Ooh, and a tail!",
		unique_Name = "BallRacerCatBall",
		price = 600,
		model = "models/gmod_tower/catball.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )

	GTowerStore:SQLInsert( {
		Name = "Bomb",
		description = "Bomberman would be proud.",
		unique_Name = "BallRacerBomb",
		price = 800,
		model = "models/gmod_tower/ball_bomb.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )

	GTowerStore:SQLInsert( {
		Name = "Geo",
		description = "Pretend you're rolling around in your own Geodesic Psychoisolation Chamber.",
		unique_Name = "BallRacerGeo",
		price = 600,
		model = "models/gmod_tower/ball_geo.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )

	GTowerStore:SQLInsert( {
		Name = "Soccer Ball",
		description = "For all you non-Americans, this is the Football.",
		unique_Name = "BallRacerSoccerBall",
		price = 600,
		model = "models/gmod_tower/ball_soccer.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )

	GTowerStore:SQLInsert( {
		Name = "Spiked Orb",
		description = "Crush everything in your path.",
		unique_Name = "BallRacerSpikedd",
		price = 1000,
		model = "models/gmod_tower/ball_spiked.mdl",
		ClientSide = true,
		upgradable = true,
		storeid = BallRacer.StoreId
	} )
end )
