

// helper function to register fireworks
local function RegisterFirework( intName, Name, desc, model, skin, price )

	local unique = false
	
	if intName == "fountain" then
		unique = true
	end
	
	GTowerItems.RegisterItem( "fwork_" .. intName, {
		Name = Name,
		Description = desc,
		Model = model,
		ModelSkinId = skin or 1,
		ClassName = "firework_" .. intName,
		
		DrawModel = true,
		CanRemove = true,
		NoBank = false,
		BankAdminOnly = true,
		InvCategory = "fireworks",
		
		UniqueInventory = unique,
		
		AllowAnywhereDrop = true,
		RemoveOnTheater = true, // disallow dropping in theater
		
		StoreId = 14,
		StorePrice = price
	} )
end

RegisterFirework(
	"blossom",
	"Blossom Firework",
	"Rocket-based firework that explodes like a blossoming flower.",
	"models/gmod_tower/firework_groundrocket.mdl",
	1,
	100 )

RegisterFirework(
	"fountain",
	"Fountain Firework",
	"Emits a fountain of wonderous colored sparks.",
	"models/gmod_tower/firework_fountain.mdl",
	0,
	125 )

RegisterFirework(
	"multi",
	"Multi Firework",
	"Rocket-based firework that explodes with two shades of colors.",
	"models/gmod_tower/firework_rocket.mdl",
	0,
	80 )

RegisterFirework(
	"palm",
	"Palm Firework",
	"Rocket-based firework that explodes in the shape of a palm tree.",
	"models/gmod_tower/firework_rocket.mdl",
	1,
	350 )

RegisterFirework(
	"ring",
	"Ring Firework",
	"Rocket-based firework that explodes in a ring-like pattern.",
	"models/gmod_tower/firework_rocket.mdl",
	2,
	130 )

RegisterFirework(
	"rocket",
	"Rocket Firework",
	"Rocket-based firework that explodes from the center.",
	"models/gmod_tower/firework_groundrocket.mdl",
	0,
	50 )

RegisterFirework(
	"spinner",
	"Spinner Firework",
	"Spins and jumps all around while emitting colorful sparks.",
	"models/gmod_tower/firework_spinner.mdl",
	0,
	150 )

RegisterFirework(
	"spinrocket",
	"Spinning Rocket Firework",
	"Rocket-based firework that lifts off while spinning and explodes in multiple colors.",
	"models/gmod_tower/firework_groundrocket.mdl",
	3,
	90 )

RegisterFirework(
	"wine",
	"Wine Firework",
	"Rocket-based firework that explodes in the shape of a wine glass.",
	"models/gmod_tower/firework_rocket.mdl",
	3,
	400 )

RegisterFirework(
	"screamer",
	"Screamer Firework",
	"Rocket-based firework that emits a loud sound.",
	"models/gmod_tower/firework_groundrocket.mdl",
	2,
	75 )

RegisterFirework(
	"ufo",
	"UFO Firework",
	"Spins and travels around like a small UFO would.",
	"models/gmod_tower/firework_ufo.mdl",
	0,
	60 )

RegisterFirework(
	"firefly",
	"Fireflies",
	"Shoots colorful lights in a random upward pattern which twinkle like fireflies.",
	"models/gmod_tower/firework_fountain.mdl",
	0,
	150 )

