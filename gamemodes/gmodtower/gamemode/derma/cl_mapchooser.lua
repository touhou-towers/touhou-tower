
surface.CreateFont( "VoteTitle", { font = "Bebas Neue", size = 68, weight = 200 } )

surface.CreateFont( "VoteGMTitle", { font = "Bebas Neue", size = 40, weight = 200 } )

surface.CreateFont( "VoteCancel", { font = "TodaySHOP-MediumItalic", size = 40, weight = 200 } )

surface.CreateFont( "VoteTip", { font = "Bebas Neue", size = 32, weight = 200 } )

surface.CreateFont( "VoteText", { font = "Calibri", size = 22, weight = 20 } )



//=======================================================



local PANEL = {}

PANEL.Maps = {}



function PANEL:Init()



	self:ParentToHUD()



	self.Canvas = vgui.Create( "Panel", self )

	self.Canvas:MakePopup()

	self.Canvas:SetKeyboardInputEnabled( false )



	self.lblTitle = vgui.Create( "DLabel", self.Canvas )

	self.lblGMTitle = vgui.Create( "DLabel", self.Canvas )

	self.lblTimer = vgui.Create( "DLabel", self.Canvas )

	self.lblTip = vgui.Create( "DLabel", self.Canvas )



	self.MapList = vgui.Create( "DMapList", self.Canvas )

	self.MapList:SetDrawBackground( false )

	self.MapList:SetSpacing( 4 )



	self.MapPreview = vgui.Create( "DPanel", self.Canvas )



	self.Canvas:Dock( FILL )



	self.Time = RealTime()

	self.VotedMap = nil

	self.HoveredMap = nil



	self.CancelButton = vgui.Create( "DPanel", self.Canvas )

	self.CancelButton.Paint = PanelDrawCancelButton

	self.CancelButton.OnMousePressed = function()

		Derma_Query("Are you sure you no longer want to join this server (you will leave your group)?", "Are you sure?",

			"Yes", function()

				RunConsoleCommand("gmt_mtsrv", 2 )

				GTowerServers:CloseChooser()

				RunConsoleCommand("gmt_leavegroup")

			end,

			"No", EmptyFunction

		)

	end



end

MapsList = {}
GamemodePrefixes =
{
	["ballracer_"] 	= "ballrace",
	["pvp_"] 		= "pvpbattle",
	["virus_"] 		= "virus",
	["uch_"] 		= "ultimatechimerahunt",
	["zm_"]			= "zombiemassacre",
	["minigolf_"] 	= "minigolf",
	["sk_"]			= "sourcekarts",
}
function MapsGetGamemode( map )

	// Get gamemode name based on prefix
	for prefix, gamemodename in pairs( GamemodePrefixes ) do
		if string.find( map, prefix ) then
			return gamemodename
		end
	end

	return "gmodtowerlobby"

end
function MapsRegister( map, mapData )

	// Gather data
	mapData.Gamemode = mapData.Gamemode or MapsGetGamemode( map )

	mapData.Name = mapData.Name or "Unknown"
	mapData.Desc = mapData.Desc or "N/A"
	mapData.Author = mapData.Author or "Unknown"

	if mapData.DateAdded == 0 then
		mapData.DateAdded = os.time()
	end

	if mapData.DateModified == 0 then
		mapData.DateModified = os.time()
	end

	// Update/insert into list
	MapsList[map] = mapData

	//Msg( map, "\n" )

	// Update MySQL
	/*if SERVER && tmysql then
		UpdateSQL( map, mapData )
	end*/

end
MapsRegister( "gmt_ballracer_skyworld01", {
	Name = "Sky World",
	Desc = "The easiest of all the worlds. This world will introduce you to the basic concepts that become harder in the future.",
	Author = "MacDGuy",
	DateAdded = 1249150914,
	DateModified = 1249150914,
	Priority = 1,
} )

MapsRegister( "gmt_ballracer_grassworld01", {
	Name = "Grass World",
	Desc = "Light and fluffy level design with a broader appeal to difficulty.",
	Author = "MacDGuy",
	DateAdded = 1249150914,
	DateModified = 1249150914,
	Priority = 2,
} )

MapsRegister( "gmt_ballracer_memories02", {
	Name = "Memories",
	Desc = "New gameplay gimmicks - repellers and attracters that twist the concept of gravity. Being the hardest, most difficult Ball Race map, it contains the highest level count and randomly chosen left or right paths for replay value.",
	Author = "MacDGuy/Mr. Sunabouzu",
	DateAdded = 1280871103,
	DateModified = 1280871103,
	Priority = 3,
} )

MapsRegister( "gmt_ballracer_khromidro02", {
	Name = "Khromidro",
	Desc = "Inspired by mini golf courses, Khromidro boasts anti-gravity as a feature.",
	Author = "Lifeless",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 4,
} )

MapsRegister( "gmt_ballracer_paradise03", {
	Name = "Paradise",
	Desc = "Capturing the essence of summer, Paradise is a tropical-themed level with a penchant for explosions... and tubes.",
	Author = "Matt",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 5,
} )

MapsRegister( "gmt_ballracer_sandworld02", {
	Name = "Sand World",
	Desc = "Some might call the desert gritzy. Others might say it has shifting sands. All I know is that it doesn't rain.",
	Author = "Neox",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 6,
} )

MapsRegister( "gmt_ballracer_iceworld03", {
	Name = "Ice World",
	Desc = "Someone built a Ball Race course in the Arctic Circle. They didn't, however, build any snowmen...",
	Author = "Angry Penguin",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 7,
} )

MapsRegister( "gmt_ballracer_nightball", {
	Name = "Night World",
	Desc = "Roll trough this gravity defying world with moving obstacles, lasers, and lots of speed!",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_facile", {
	Name = "Facile",
	Desc = "A simplisic, but difficult world. Avoid repellers in space, or go full hyperspeed while magnetized.",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_flyinhigh01", {
	Name = "Flyin' High",
	Desc = "Easy levels with fun mechanics. Also home to the one and only Bumper Island.",
	Author = "Muffin",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_metalworld", {
	Name = "Metal World",
	Desc = "Hard levels in a world made of metal, also introducing new objects such as crushers, lava and gears.",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_memories04", {
	Name = "Memories",
	Desc = "New gameplay gimmicks - repellers and attracters that twist the concept of gravity. Being the hardest, most difficult Ball Race map, it contains the highest level count and randomly chosen left or right paths for replay value.",
	Author = "MacDGuy/Mr. Sunabouzu",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 7,
} )

/*MapsRegister( "gmt_ballracer_summit", {
	Name = "Summit",
	Desc = "A cold, lighthearted world that focuses on the racing aspect of Ballrace.",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 4,
} )*/

MapsRegister( "gmt_ballracer_neonlights", {
	Name = "Neon Lights",
	Desc = "Bounce around in this funky world full of colorful lights!",
	Author = "PikaUCH",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_waterworld02", {
	Name = "Water World",
	Desc = "Meet water physics in this fun, fast paced world. Float, dive and bounce to victory!",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_spaceworld", {
	Name = "Space World",
	Desc = "Hard, more dynamic levels with new obstacles such as a catapult.",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_rainbowworld", {
	Name = "Rainbow World",
	Desc = "A very FAST paced, yet somewhat difficult map filled with LOADS of bananas and bumpers in the setting of SPACE! Come play and become a Ball-stronaut!",
	Author = "IrZipher",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 8,
} )

MapsRegister( "gmt_ballracer_midorib5", {
	Name = "Midori",
	Desc = "Wait a minute... is that a Robot in the sky?",
	Author = "Lifeless",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 7,
} )

/*MapsRegister( "gmt_ballracer_prism03", {
	Name = "Prism",
	Desc = "A world with a new concept, blocks that move to the rythm of the music! This map is not for beginners.",
	Author = "Bumpy",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 4,
} )*/

MapsRegister( "gmt_ballracer_tranquil", {
	Name = "Tranquil",
	Desc = "A magical world full of... RAINBOWS!",
	Author = "Bumpy",
	DateAdded = 13439137397,
	DateModified = 1439252668,
	Priority = 8,
} )

/*MapsRegister( "gmt_ballracer_miracle", {
	Name = "Miracle",
	Desc = "Venture off into a world of miracles, but be aware of the evil!",
	Author = "Zoephix",
	DateAdded = 1339137397,
	DateModified = 1339252668,
	Priority = 5,
} )*/

MapsRegister( "gmt_pvp_construction01", {
	Name = "Construction Zone",
	Desc = "Inspired by a Half-Life 2: Deathmatch map, dm_construction - this map is sure to please everyone. This map creates layers of carnage.",
	Author = "Mr. Sunabouzu",
	DateAdded = 1249150914,
	DateModified = 1249150914,
} )

MapsRegister( "gmt_pvp_frostbite01", {
	Name = "Frost Bite",
	Desc = "The complete opposite of Meadows. It's large, cold, dark, and unforgiving. There's two power ups and around three medkits on this level. It comes complete with a sniper tower, ice mines, and blow up shacks. This battlefield is geared more towards long range, but can still become close range before you know it.",
	Author = "Mr. Sunabouzu/MacDGuy",
	DateAdded = 1249150914,
	DateModified = 1249150914,
} )

MapsRegister( "gmt_pvp_meadow01", {
	Name = "Meadows",
	Desc = "Based on Metal Gear Solid 3's boss level, this small meadow will offer the most destructive gameplay currently available. With only one power up and one medkit, things are sure to heat up. Watch your enemies fall like pedals.",
	Author = "Mr. Sunabouzu",
	DateAdded = 1249150914,
	DateModified = 1249150914,
} )

MapsRegister( "gmt_pvp_oneslip01", {
	Name = "OneSlip",
	Desc = "Another Jaykin' Bacon promoted map, based on Quake maps. The risks are higher when you're in space. Be careful not to fall off into the black void!",
	Author = "Sniper",
	DateAdded = 1249150914,
	DateModified = 1249150914,
} )

MapsRegister( "gmt_pvp_pit01", {
	Name = "The Pit",
	Desc = "Take being gothic to a whole new level. This map is recommended for anyone who dresses exclusively in black.",
	Author = "Dustpup",
	DateAdded = 1283286092,
	DateModified = 1283301811,
} )

MapsRegister( "gmt_pvp_containership02", {
	Name = "Container Ship",
	Desc = "Take the battle across the sea on a moving cargo ship. Dozens of containers for cover and sneak attacks. Multiple layers of action packed destruction. Careful not to fall into the water, as the sharks will surely eat you up for breakfast.",
	Author = "Lifeless",
	DateAdded = 1283286092,
	DateModified = 1339745343,
} )

MapsRegister( "gmt_pvp_colony01", {
	Name = "Colony",
	Desc = "A small group of survivors were discovered living in a secret military base. They were also found to be endlessly shooting each other and respawning.",
	Author = "Zoki",
	DateAdded = 1296944516,
	DateModified = 1296944516,
} )

MapsRegister( "gmt_pvp_subway01", {
	Name = "Subway",
	Desc = "Several decades ago, the major world powers began building a secret underground subway system. It went largely unused until someone stumbled upon the entrance and posted about it on Twitter. Since then, it's been quarantined and denied by every government.",
	Author = "Lifeless",
	DateAdded = 1355168548,
	DateModified = 1355168548,
} )

MapsRegister( "gmt_pvp_shard01", {
	Name = "Shard",
	Desc = "This reminds me of a... reflective surface of some kind. Nah, must be a coincidence.",
	Author = "Matt",
	DateAdded = 1355168548,
	DateModified = 1355168548,
} )

MapsRegister( "gmt_pvp_aether", {
	Name = "Aether",
	Desc = "Some island floating above the clouds, are now a battleground for some worthy combatants. Some say that this is the home to the gods and that some are even watching these battles, so you better be on your best today. You wouldn't want to embarrass yourself in front of gods.",
	Author = "Bumpy",
	DateAdded = 1249150914,
	DateModified = 1249150914,
	Priority = 4,
} )

MapsRegister( "gmt_pvp_mars", {
	Name = "Mars",
	Desc = "A small group of survivors were discovered living in a secret military base. They were also found to be endlessly shooting each other and respawning.",
	Author = "Bumpy / Zoki",
	DateAdded = 1249150914,
	DateModified = 1249150914,
	Priority = 4,
} )

MapsRegister( "gmt_pvp_neo", {
	Name = "Neo",
	Desc = "A virtual world that you somehow ended up in. I guess the best thing to do now is to kill people.",
	Author = "Bumpy",
	DateAdded = 1249150914,
	DateModified = 1249150914,
	Priority = 4,
} )

MapsRegister( "gmt_virus_facility202", {
	Name = "Facility",
	Desc = "Ripped straight out of Goldeneye 64, Facility offers twisting corridors and fast-paced combat.",
	Author = "Polyknetic",
	DateAdded = 1275253872,
	DateModified = 1275253872,
} )

MapsRegister( "gmt_virus_riposte01", {
	Name = "Riposte",
	Desc = "In this Unreal Tournament-inspired map, there are tons of nooks and crannies for both the survivors and infected to use.",
	Author = "Monarch",
	DateAdded = 1275253872,
	DateModified = 1275253872,
} )

MapsRegister( "gmt_virus_aztec01", {
	Name = "Aztec",
	Desc = "Set in an ancient ruin, Aztec is devoid of modern comforts. Due to being relatively unobstructed, Aztec is a sniper's paradise.",
	Author = "",
	DateAdded = 1275258231,
	DateModified = 1275343964,
} )

MapsRegister( "gmt_virus_sewage01", {
	Name = "Sewage",
	Desc = "For some reason, you're in some kind of toxic waste dump. Try not to fall in the water, it's incredibly unpleasant. And lethal.",
	Author = "Sentura",
	DateAdded = 1275258231,
	DateModified = 1275253872,
} )

MapsRegister( "gmt_virus_dust03", {
	Name = "Dust",
	Desc = "Inspired by Counter-Strike: Source's ever-popular Dust map, Dust strikes an interesting balance between long-range and short-range combat.",
	Author = "Lifeless",
	DateAdded = 1276903270,
	DateModified =  1339252668,
} )

MapsRegister( "gmt_virus_metaldream05", {
	Name = "Metal Dreams",
	Desc = "Deep underground, in an abandoned secret base, Metal Dreams has lots of chokepoints. Watch out for infected falling out of the ceiling!",
	Author = "Zoki",
	DateAdded = 1294172505,
	DateModified = 1294267401,
} )

MapsRegister( "gmt_virus_hospital204", {
	Name = "Hospital",
	Desc = "The last place you want to be is in a hospital filled with unknown viruses.",
	Author = "Lifeless",
	DateAdded = 1345329515,
	DateModified = 1345506617,
} )

MapsRegister( "gmt_virus_derelict01", {
	Name = "Derelict Station",
	Desc = "In space, no one can hear you scream. Good thing screaming won't help you anyway.",
	Author = "Matt",
	DateAdded = 1354508003,
	DateModified = 1354508003,
} )

MapsRegister( "gmt_virus_parkinglot", {
	Name = "Parking Lot",
	Desc = "You're stuck deep down in an abandoned parking lot and on top of that a virus broke out... Could it get any worse, nevermind, it just did.",
	Author = "Bumpy",
	DateAdded = 1354508003,
	DateModified = 1354508003,
} )

MapsRegister( "gmt_uch_tazmily01", {
	Name = "Tazmily Village",
	Desc = "In the peaceful village of Tazmily, there are only three absolutes: Mr. Saturn will show up, the Chimera will try to eat Pigmasks, and the retail is hideously expensive.",
	Author = "Charles Wenzel",
	DateAdded = 1285014233,
	DateModified = 1285014233,
} )

MapsRegister( "gmt_uch_clubtitiboo04", {
	Name = "Club Titiboo",
	Desc = "All the Pigmasks come here to party hard, only to be stomped hard by the local Chimera. Drinks are also sold at extortionate prices, so speak easy.",
	Author = "Lifeless",
	DateAdded = 1285014233,
	DateModified = 1285014233,
} )

MapsRegister( "gmt_uch_shadyoaks03", {
	Name = "Shady Oaks",
	Desc = "On the outskirts of town, this small facility still stands. Watch out for the gate though, it doesn't look very strong...",
	Author = "Aska",
	DateAdded = 1285014233,
	DateModified = 1285014233,
} )

MapsRegister( "gmt_uch_laboratory01", {
	Name = "Laboratory",
	Desc = "Situated inside a mad scientist's laboratory, this place doesn't have anything to do with the creation of the Ultimate Chimera. That we know of.",
	Author = "Aska",
	DateAdded = 1285014233,
	DateModified = 1285014233,
} )

MapsRegister( "gmt_uch_camping01", {
	Name = "Camping Grounds",
	Desc = "Try not to sleep...",
	Author = "Batandy",
	DateAdded = 1285014233,
	DateModified = 1285014233,
} )

MapsRegister( "gmt_uch_headquarters02", {
	Name = "Headquarters",
	Desc = "The Pigmasks all thought they'd be safe in their secret headquarters. The Chimera set out to prove them wrong.",
	Author = "Lifeless",
	DateAdded = 1294179714,
	DateModified = 1345329515,
} )

MapsRegister( "gmt_uch_downtown04", {
	Name = "Downtown",
	Desc = "Stop in at your local Rocket Noodle, assuming they haven't changed the menu again.",
	Author = "Matt",
	DateAdded = 1345329515,
	DateModified = 1347455325,
} )

MapsRegister( "gmt_uch_mrsaturnvalley02", {
	Name = "Mr. Saturn Valley",
	Desc = "In a peaceful valley, the strange creatures known as Mr. Saturn live. Unfortunately, the Pigmasks and Chimera found the valley.",
	Author = "Lifeless",
	DateAdded = 1345329515,
	DateModified = 1347187690,
} )

MapsRegister( "gmt_uch_woodland03", {
	Name = "Woodlands",
	Desc = "A chainlink fence won't keep the Chimera out, but it will keep the Pigmasks in.",
	Author = "Matt",
	DateAdded = 1345329515,
	DateModified = 1347455325,
} )

MapsRegister( "gmt_uch_falloff01", {
	Name = "Fall Off",
	Desc = "Fall up, down, in, out, or on, but just don't fall off.",
	Author = "Matt",
	DateAdded = 1347798381,
	DateModified = 1347798381,
} )

MapsRegister( "gmt_uch_snowedin01", {
	Name = "Snowed In",
	Desc = "Cold pork? Sounds gross. Someone should probably heat that up or something. Wait, you're eating it raw?",
	Author = "Matt",
	DateAdded = 1354507791,
	DateModified = 1354507791,
} )

MapsRegister( "gmt_sk_lifelessraceway01", {

	Name = "Lifeless Raceway",

	Desc = "A nostalgic raceway with turns and exciting jumps.",

	Author = "Lifeless",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )



MapsRegister( "gmt_sk_island01_fix", {

	Name = "Drift Island",

	Desc = "This island is home of the famous loop, which is the most representative landmark of the mysterious Island.",

	Author = "Matt",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )

MapsRegister( "gmt_sk_rave", {

	Name = "Rave",

	Desc = "Someone build a racing course inside of a rave party, this better be fun!",

	Author = "Madmijk",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )

/*MapsRegister( "gmt_sk_stadium", {

	Name = "Stadium",

	Desc = "Now is your time to shine. Race at your best infront of a live audience. Be careful though! One small mistake and you'll end up in the water.",

	Author = "Bumpy",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )*/

MapsRegister( "gmt_minigolf_sandbar06", {

	Name = "Sand Bar",

	Desc = "Relax, and listen to the calming waves. Hear the seagulls calling. Wonder where all of the bars are in this sandbar.",

	Author = "Matt",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )



MapsRegister( "gmt_minigolf_waterhole04", {

	Name = "Waterhole",

	Desc = "Go on, take a drink from the watering hole. It won't bite, I promise. Ha ha! I lied!",

	Author = "Lifeless",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )



MapsRegister( "gmt_minigolf_garden05", {

	Name = "Karafuru Gardens",

	Desc = "Look at all the nice lotus flowers. Enjoy the babbling brook. Marvel in the non-zen of it all. PS: Karafuru means colorful in Japanese.",

	Author = "Matt/Aigik",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )



MapsRegister( "gmt_minigolf_moon01", {

	Name = "Moon",

	Desc = "One small step for man, one giant putt for minigolf.",

	Author = "nyro",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )



MapsRegister( "gmt_minigolf_snowfall01", {

	Name = "Snow Fall",

	Desc = "Way up north, there's a peaceful and quiet golf course. Ignoring the fact that it's sub zero temperatures and you're prone to frostbite and hypthermia, we'd say it's a pretty decent place.",

	Author = "Lifeless",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )



MapsRegister( "gmt_minigolf_forest04", {

	Name = "Forest",

	Desc = "This course will take you through a delightful forest with challenging courses.",

	Author = "madmijk and IrZipher",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )

MapsRegister( "gmt_minigolf_desert", {

	Name = "Desert",

	Desc = "Golf your way through the hot desert, on courses build by the pharaohs. Be sure to take a bottle of water with you!",

	Author = "Bumpy",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )

MapsRegister( "gmt_mono_main", {

	Name = "Monotone",

	Desc = "Welcome to the world of Monotone! Shoot ink of the opposite color to navigate your way through the map. Both teams are racing to gather all artifacts spread through the map as quickly as possible.",

	Author = "Bumpy",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )

MapsRegister( "gmt_gr_nile", {

	Name = "The Nile",

	Desc = "A small Egyptic town with food... lots of food.",

	Author = "Bumpy",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )

MapsRegister( "gmt_gr_ruins", {

	Name = "Ruins",

	Desc = "Explore the ancient ruins left behind in this big swamp.",

	Author = "Bumpy",

	DateAdded = 1374298302,

	DateModified = 1374298302,

} )

MapsRegister( "gmt_zm_arena_underpass02", {

	Name = "Underpass",

	Desc = "You've somehow gotten trapped in one city block. There aren't even any good stores around to buy fashionable accessories from. What will you do!?",

	Author = "Matt",

	DateAdded = 1345328453,

	DateModified = 1345506617,

} )

MapsRegister( "gmt_zm_arena_thedocks01", {

	Name = "The Docks",

	Desc = "It turns out that zombies can actually swim. So, you're kind of screwed because this place is apparently an island.",

	Author = "Lifeless",

	DateAdded = 1345328453,

	DateModified = 1345328453,

} )



MapsRegister( "gmt_zm_arena_gasoline01", {

	Name = "Gasoline",

	Desc = "After the apocalypse, gasoline was hideously expensive. Even the zombies thought it was outrageous.",

	Author = "Lifeless",

	DateAdded = 1345328453,

	DateModified = 1345328453,

} )



MapsRegister( "gmt_zm_arena_scrap01", {

	Name = "Scrap",

	Desc = "You'd think that the first place you'd want to go in a zombie apocalypse is a scrap yard, right? Wrong. You just have nowhere to run.",

	Author = "Matt",

	DateAdded = 1345328453,

	DateModified = 1345328453,

} )



MapsRegister( "gmt_zm_arena_acrophobia01", {

	Name = "Acrophobia",

	Desc = "Are you afraid of heights? The zombies certainly aren't. The jury's still out on how they got on top of the building, though.",

	Author = "Lifeless",

	DateAdded = 1345328453,

	DateModified = 1345328453,

} )



MapsRegister( "gmt_zm_arena_trainyard01", {

	Name = "Trainyard",

	Desc = "Trains run back and forth, escorting survivors out of infected areas. Too bad they don't discriminate between targets on the tracks.",

	Author = "Lifeless",

	DateAdded = 1345328453,

	DateModified = 1345328453,

} )



MapsRegister( "gmt_zm_arena_foundation02", {

	Name = "Foundation",

	Desc = "The workers are on strike again. I think the bolter quit before he finished his job. Don't lose your balance on the scaffolding.",

	Author = "Matt",

	DateAdded = 1345328453,

	DateModified = 1345328453,

} )

function MapsGetMapData( map )
	return MapsList[map]
end
function PANEL:SetGamemode( Gamemode )
	print(Gamemode.Maps[math.Rand(1,table.Count(Gamemode.Maps))])


	self.Gamemode = Gamemode


	local map = table.Random( Gamemode.Maps )
	self.HoveredMap = MapsGetMapData( map )



	self:SetupMaps()

	self:SetupPreview()



end



function PanelDrawCancelButton( self )



	if self.Hovered then

		surface.SetDrawColor( 170, 14, 41, 190 )

	else

		surface.SetDrawColor( 0, 0, 0, 150 )

	end



	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )



	draw.SimpleText( "LEAVE", "VoteCancel", self:GetWide()/2, self:GetTall()/2, Color(255,255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )



end



function PANEL:PerformLayout()



	self:SetPos( 0, 0 )

	self:SetSize( ScrW(), ScrH() )



	self.Canvas:SetZPos( 0 )



	self.lblTitle:SetText( "SELECT A MAP" )

	self.lblTitle:SetFont( "VoteTitle" )

	self.lblTitle:SetTextColor( color_white )

	self.lblTitle:SizeToContents()

	self.lblTitle:SetPos( ScrW()/2 - self.lblTitle:GetWide()/2, 50 )



	self.lblGMTitle:SetText( self.Gamemode.Name )

	self.lblGMTitle:SetFont( "VoteGMTitle" )

	self.lblGMTitle:SetTextColor( color_white )

	self.lblGMTitle:SizeToContents()

	self.lblGMTitle:SetPos( ScrW()/2 - self.lblGMTitle:GetWide()/2, 10 )



	self.lblTimer:SetText( "20" )

	self.lblTimer:SetFont( "VoteTitle" )

	self.lblTimer:SetTextColor( color_white )

	self.lblTimer:SetContentAlignment( 5 )

	self.lblTimer:SizeToContents()

	self.lblTimer:SetPos( ScrW() - 95, 25 )



	self.lblTip:SetText("")

	self.lblTip:SetFont( "VoteTip" )

	self.lblTip:SetTextColor( color_white )

	self.lblTip:SetContentAlignment( 5 )

	self.lblTip:SizeToContents()

	self:SetRandomTip()



	self.MapList:SetPos( ScrW() / 4 - self.MapList:GetWide() / 2, 160 )

	self.MapList:SetSize( ScrW()/2, ScrH() - 160 )



	self.MapPreview:SetSize( 500, 430 )

	self.MapPreview:SetPos( ScrW() + self.MapPreview:GetWide(), 160 )

	self.MapPreview:MoveTo( (ScrW() * (3/4)) - self.MapPreview:GetWide() / 2, 160, 0.65 )



	self.CancelButton:SetSize( 250, 40 )

	self.CancelButton:SetPos( ( ScrW() / 2 ) - ( self.CancelButton:GetWide() / 2 ), ScrH() + 40 )

	self.CancelButton:MoveTo( ( ScrW() / 2 ) - ( self.CancelButton:GetWide() / 2 ), ScrH() - 120 - 40 - 20, 0.65 )



	self:UpdateVotes()

	self:UpdatePreview()



end

function MapsGetPreviewIcon( map )

	if map == "gmt_ballracer_nightball" or map == "gmt_gr_ruins" /*or map == "gmt_ballracer_miracle"*/ or map == "gmt_gr_nile" or map == "gmt_ballracer_metalworld"  or map == "gmt_ballracer_neonlights" or map == "gmt_ballracer_facile" or map == "gmt_ballracer_summit" or map == "gmt_ballracer_tranquil" or map == "gmt_ballracer_spaceworld" or map == "gmt_minigolf_desert" or map == "gmt_sk_stadium" or map == "gmt_sk_rave" or map == "gmt_pvp_aether" or map == "gmt_ballracer_rainbowworld" or map == "gmt_pvp_mars" or map == "gmt_pvp_aether" or map == "gmt_pvp_neo" then
		return "gmod_tower/maps/preview/" .. map
	elseif map == "gmt_sk_island01_fix" then
		return "gmod_tower/maps/preview/" .. string.sub( "gmt_sk_island01", 0, -3 )
	else
		return "gmod_tower/maps/preview/" .. string.sub( map, 0, -3 )
	end

end

function PANEL:SetupMaps()


	self.MapList:Clear()



	local Gamemode = self.Gamemode

	local maps = self.Gamemode.Maps



	for id, map in pairs( maps ) do



		// Collect map data

		local mapData = MapsGetMapData( map )

		if !mapData then continue end

		mapData.PreviewIcon = MapsGetPreviewIcon( map )

		local canPlay = GTowerServers:CanPlayMap( map )

		// Setup panel

		local panel = vgui.Create( "DPanel", self.MapList )

		panel:SetPaintBackground( false )



		// Setup main data

		panel.NumVotes = GTowerServers:GetVotes( map )

		panel.Map = map

		panel.Priority = mapData.Priority



		panel.btnMap = vgui.Create( "DButton", panel )

		panel.btnMap:SetText( mapData.Name )

		panel.btnMap:SetSize( 280, 100 )

		panel.btnMap:SetTextColor( color_white )

		panel.btnMap:SetFont( "VoteText" )

		panel.btnMap:SetContentAlignment( 7 )

		panel.btnMap:SetTextInset( 8, 0 )

		if !canPlay then
			panel.btnMap:SetTextColor( Color(255,255,255,5) )
			panel.btnMap.Disabled = true
			panel.btnMap:SetToolTip( "Map disabled due to play amount." )
		end

		panel.btnMap.OnCursorEntered = function()

			self.HoveredMap = mapData

			self:UpdatePreview()

		end



		panel.btnMap.OnCursorExited = function()

			self.HoveredMap = nil

			self:UpdatePreview()

		end



		panel.btnMap.DoClick = function()

			if GTowerServers:CanStillVoteMap() && !panel.btnMap.Disabled then

				GTowerServers:ChooseMap( map )

				self.VotedMap = mapData

				self:UpdateVotes()

				self:UpdatePreview()

			end

		end



		panel.btnMap.CurProgress = 0



		panel.lblVotes = vgui.Create( "DLabel", panel )

		if panel.NumVotes != 0 then

			panel.lblVotes:SetText( panel.NumVotes )

		else

			panel.lblVotes:SetText( "" )

		end



		panel.lblVotes:SetPos( panel.btnMap:GetWide() + 5, 3 )

		panel.lblVotes:SetTextColor( color_white )

		panel.lblVotes:SetFont( "VoteText" )

		panel.lblVotes:SetContentAlignment( 4 )

		panel.lblVotes:SizeToContents()



		self.MapList:AddItem( panel )



	end



	// Shuffle

	//self.MapList:Shuffle()



	// Sort by prioirty, if possible

	self.MapList:SortByMember( "Priority" )



	local panel = vgui.Create( "DPanel", self.MapList )

	panel:SetPaintBackground( false )



	panel.lblUndecided = vgui.Create( "DLabel", panel )

	panel.lblUndecided:SetText( string.format("%s player(s) haven't cast their vote", #player.GetAll() ) )



	panel.lblUndecided:SetTextColor( Color( 180, 180, 180, 255 ) )

	panel.lblUndecided:SetFont( "VoteText" )

	panel.lblUndecided:SetContentAlignment( 5 )

	panel.lblUndecided:SizeToContents()



	self.MapList:AddItem( panel )



end





function PANEL:SetupPreview( map )



	-- Map Preview Container

	local w, h = 500, 500

	self.MapPreview.Paint = function()

		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 160 ) )

	end



	// Map Name

	self.lblMapName = vgui.Create( "DLabel", self.MapPreview )

	self.lblMapName:SetText( self.HoveredMap.Name )

	self.lblMapName:SetTextColor( color_white )

	self.lblMapName:SetFont( "VoteTitle" )

	self.lblMapName:SetTextInset(8, 0)

	self.lblMapName:SetSize(w-10, 64)



	// Map Author

	self.lblAuthor = vgui.Create( "DLabel", self.MapPreview )

	self.lblAuthor:SetText( "Author: " .. self.HoveredMap.Author )

	self.lblAuthor:SetTextColor( color_white )

	self.lblAuthor:SetFont( "VoteText" )

	self.lblAuthor:SetTextInset(8, 0)

	self.lblAuthor:SetSize(w-10, 128)



	// Map icon

	local y = 72

	local realheight = 230



	self.MapIcon = vgui.Create( "DImage", self.MapPreview )

    self.MapIcon:SetOnViewMaterial( self.HoveredMap.PreviewIcon )

	//self.MapIcon:SetFailsafeMatName( "maps/gmt_pvp_default.vmt" ) // handled in gamemode definition

	self.MapIcon:SetSize( 512, 256 )

	self.MapIcon:SetPos( 10, y )



	// Map description

	self.lblDesc = vgui.Create( "DLabel", self.MapPreview )

	self.lblDesc:SetText( self.HoveredMap.Desc or "N/A" )

	self.lblDesc:SetTextColor( color_white )

	self.lblDesc:SetFont( "VoteText" )

	//self.lblDesc:SetWidth( 320 )

	self.lblDesc:SetSize( w - 10*2, 300 )



	y = y + realheight + 10

	self.lblDesc:SetPos( 10, y )

	self.lblDesc:SetWrap(true)

	self.lblDesc:SetContentAlignment(7)



end



PANEL.BarPercent = 0

local gradientUp = surface.GetTextureID( "VGUI/gradient_up" )

local gradientDown = surface.GetTextureID( "VGUI/gradient_down" )



function PANEL:Paint()



	surface.SetDrawColor( Color( 0, 0, 0, 180 ) )

	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )



	self.BarPercent = math.Approach( self.BarPercent, 1, .25 / 50 )



	surface.SetDrawColor( 0, 0, 0, 255 )

	surface.DrawRect( 0, 0, ScrW(), ( 120 * self.BarPercent ) )



	surface.SetTexture( gradientDown )

	surface.DrawTexturedRect( 0, 120 * self.BarPercent, ScrW(), 80 )



	surface.DrawRect( 0, ScrH() - ( 120 * self.BarPercent ), ScrW(), 120 )



	surface.SetTexture( gradientUp )

	surface.DrawTexturedRect( 0, ScrH() - ( ( 120 + 80 ) * self.BarPercent ), ScrW(), 80 )





	local TimeLeft = math.max( GTowerServers.MapEndTime - CurTime(), 0 ) / GTowerServers.MapTotalTime

	local Width = ScrW() * TimeLeft



	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.DrawRect( 0, ScrH() - 120 - 12, Width, 12 )



end





function PANEL:UpdateVotes()



	// Get player count from server

	local ServerId = GTowerServers.ChoosenServerId

	local Server = GTowerServers.Servers[ ServerId ]

	local Players = player.GetAll()

	if Server then

		Players = Server.Players

	end





	for _, panel in pairs( self.MapList:GetItems() ) do



		if !panel.btnMap then

			local undecided = #Players - GTowerServers:GetTotalVotes()

			if undecided > 0 then

				panel.lblUndecided:SetText( string.format("%s player(s) haven't cast their vote", undecided ) )

			else

				panel.lblUndecided:SetText("")

			end



			return

		end



		local NumVotes = GTowerServers:GetVotes( panel.Map )



		if NumVotes != 0 then

			panel.lblVotes:SetText( NumVotes )

		else

			panel.lblVotes:SetText( "" )

		end



		panel.btnMap.Paint = function()



			local x, y = panel.btnMap:GetPos()

			local w, h = panel.btnMap:GetSize()



			local col = Color( 0, 0, 0, 120 )

			local col_progress = Color( 40, 121, 211, 84 )



			if ( panel.btnMap:GetDisabled() ) then

				col = Color( 0, 0, 0, 84 )

			elseif ( panel.btnMap.Depressed ) then

				col = Color( 0, 0, 0, 84 )

			elseif ( panel.btnMap.Hovered ) then

				col = Color( 100, 100, 100, 84 )

			end



			if ( panel.btnMap.bgColor != nil ) then col = panel.btnMap.bgColor end



			draw.RoundedBox( 0, x, y, w, h, col )



			local progress = w * ( NumVotes / #Players )



			if !panel.btnMap.CurProgress || panel.btnMap.CurProgress != progress then



				panel.btnMap.CurProgress = math.Approach( panel.btnMap.CurProgress, progress, FrameTime() * 500 )

				draw.RoundedBox( 0, x, y, panel.btnMap.CurProgress, 30, col_progress )



			else

				draw.RoundedBox( 0, x, y, progress, 30, col_progress )

			end





			// TODO show new/modified icons

			/*if !panel.btnMap.HasMap then

				local downloadTexture = surface.GetTextureID( "vgui/mapselector/download" )

				surface.SetDrawColor( 255, 255, 255, 33 )

				surface.SetTexture( downloadTexture )

				surface.DrawTexturedRect( w - 28, 0, 32, 32 )

			end*/



		end



	end



	self.MapList:InvalidateLayout()



end





function PANEL:UpdatePreview()



	local mapData = nil



	// Hovered map

	if self.HoveredMap then

		mapData = self.HoveredMap



	// Voted map

	elseif self.VotedMap && !self.HoveredMap then

		mapData = self.VotedMap

	end



	if !mapData then return end



	self.lblMapName:SetText( mapData.Name )

	self.MapIcon:SetOnViewMaterial( mapData.PreviewIcon )

	self.lblDesc:SetText( mapData.Desc or "N/A" )

	self.lblAuthor:SetText( "Author: " .. mapData.Author or "N/A" )



	self.MapPreview:InvalidateLayout()



end


net.Receive("VoteScreenFinish",function()

	local map = net.ReadString()

	if !ValidPanel( GTowerServers.MapChooserGUI ) then return end
	GTowerServers.MapChooserGUI:FinishVote( map )
end)


function PANEL:FinishVote( map )


	self.lblTitle:SetText( string.format( "Now Loading %q", MapsList[map].Name ) )

	self.lblTitle:SizeToContents()

	self.lblTitle:SetPos( ScrW()/2 - self.lblTitle:GetWide()/2, 30 )



	local bar = nil

	for _, v in pairs( self.MapList:GetItems() ) do

		if v.btnMap && v.btnMap:GetText() == MapsList[map].Name then

			bar = v.btnMap

		end

	end



	// Copied from Fretta -- temporary until I can come up with something creative

	//	- Maybe animate buttons outward and focus winning map panel in the center?

	timer.Simple( 0.0, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "gmodtower/misc/blip.wav" ) end )

	timer.Simple( 0.2, function() bar.bgColor = nil end )

	timer.Simple( 0.4, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "gmodtower/misc/blip.wav" ) end )

	timer.Simple( 0.6, function() bar.bgColor = nil end )

	timer.Simple( 0.8, function() bar.bgColor = Color( 0, 255, 255 ) surface.PlaySound( "gmodtower/misc/blip.wav" ) end )

	timer.Simple( 1.0, function() bar.bgColor = Color( 100, 100, 100 ) end )



end



// TODO: clean this up

function PANEL:SetRandomTip()



	local tip = self.lblTip:GetText()

	local tips = self.Gamemode.Tips



	if tips then



		while tip == self.lblTip:GetText() do

			tip = string.format( "Tip: %s", table.Random( tips )  )

		end



	else

		tip = ""

	end



	self.lblTip:SetText( tip )

	self.lblTip:SizeToContents()

	self.lblTip:SetPos( ScrW()/2 - self.lblTip:GetWide()/2, ScrH() - 72 )



	self.NextTip = CurTime() + 5



end



function PANEL:Think()



	if self.NextTip && self.NextTip < CurTime() then

		self:SetRandomTip()

	end



	local TimeLeft = GTowerServers.MapEndTime - CurTime()

	if TimeLeft < 0 then TimeLeft = 0 end



	local ElapsedTime = string.FormattedTime( TimeLeft )

	ElapsedTime = math.Round( ElapsedTime.s )



	self.lblTimer:SetText( ElapsedTime )

	self.lblTimer:SizeToContents()



end



vgui.Register( "MapSelector", PANEL, "DPanel" )
