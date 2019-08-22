
-----------------------------------------------------


// helper func for registering player models

local num = 0

local function RegisterModel( name, friendlyName, desc, model, mdlname, price, scale, store, dateadded )



	if !scale then scale = 1 end

	num = num + 1



	// Player model!

	GTowerItems.RegisterItem( name, {

		Name = friendlyName,

		Description = desc,

		Model = model,

		ModelName = mdlname,

		UniqueInventory = true,

		DrawModel = true,

		CanEntCreate = false,

		--Equippable = true,

		--EquipType = "Model",

		--UniqueEquippable = true,

		ModelItem = true,

		AlwaysAllowModel = true,

		StoreId = 13,

		StorePrice = price,

		InvCategory = "model",

		ModelUseSize = scale,

		DrawName = true,

		MoveSound = "cloth",

	})



	// Figurines!

	/*GTowerItems.RegisterItem( name .. "_figurine" .. num, {

		Name = friendlyName .. " Figurine",

		Description = "A decorative figurine.",

		Model = "models/gmod_tower/trophy_stand.mdl",

		DrawModel = true,

		CanEntCreate = true,

		StoreId = GTowerStore.TOY,

		StorePrice = math.floor( price / 2 ),

		Classname = "gmt_trophy_" .. name,

		InvCategory = "toy",

		DrawName = true,

		MoveSound = "wood",

		FigureModel = model,



		MatchesEnt = function( self, ent )

			return ent.FigureModel == self.FigureModel

		end,

	})



	// Create trophy entity

	local ENT = {

		Type = "anim",

		Base = "gmt_trophy",

		FigureModel = model

	}

	scripted_ents.Register( ENT, "gmt_trophy_" .. name )*/



end



RegisterModel(

	"mdl_spacesuit",

	"Space Suit",

	"Keeps a person alive and comfortable in the harsh environment of outer space.",

	"models/player/spacesuit.mdl",

	"spacesuit",

	950 )



RegisterModel(

	"mdl_robber",

	"Robber",

	"Rob the bank and then some.",

	"models/player/robber.mdl",

	"sniper",

	1500 )



RegisterModel(

	"mdl_zoey",

	"Zoey",

	"Did I ever tell you about the time my buddy Ellis stole a car from the mall and ran over some zombies?",

	"models/player/zoey.mdl",

	"zoey",

	2000 )



RegisterModel(

	"mdl_azuisleet",

	"AzuiSleet",

	"I can never be wrong. It's a curse I have.",

	"models/player/azuisleet1.mdl",

	"rpcop",

	4500 )



RegisterModel(

	"mdl_sunabouzu",

	"Mr. Sunabouzu",

	"Finally some recognition for - wait.",

	"models/player/Sunabouzu.mdl",

	"sunabouzu",

	4000 )



RegisterModel(

	"mdl_libertyprime",

	"Liberty Prime",

	"Death is a preferable alternative to communism.",

	"models/player/sam.mdl",

	"libertyprime",

	2000 )



RegisterModel(

	"mdl_scarecrow",

	"Scarecrow",

	"Now, they will learn the true nature of fear!",

	"models/player/scarecrow.mdl",

	"scarecrow",

	2500 )



RegisterModel(

	"mdl_smith",

	"Agent Smith",

	"Mr. Anderson! Surprised to see me?",

	"models/player/smith.mdl",

	"smith",

	3000 )



RegisterModel(

	"mdl_altair",

	"Altair",

	"Peace be upon you.",

	"models/player/altair.mdl",

	"altair",

	1800 )



RegisterModel(

	"mdl_dinosaur",

	"Dinosaur",

	"Go on, rip it up, you extinct shakey-saurus thing you!",

	"models/player/foohysaurusrex.mdl",

	"dinosaur",

	2500,

	.93 )



RegisterModel(

	"mdl_rorschach",

	"Rorschach",

	"None of you seem to understand. I'm not locked in here with you. You're locked in here with me!",

	"models/player/rorschach.mdl",

	"rorschach",

	8000 )



RegisterModel(

	"mdl_aphaztech",

	"Aperture Haztech",

	"Please assume the party escort submission position.",

	"models/player/aphaztech.mdl",

	"aphaztech",

	2500 )



RegisterModel(

	"mdl_zelda",

	"Zelda",

	"When peace returns to Hyrule, it will be time for us to say goodbye.",

	"models/player/zelda.mdl",

	"zelda",

	4000 )



RegisterModel(

	"mdl_faith",

	"Faith",

	"We call ourselves runners. We exist on the edge between the glass and the reality. The mirror's edge.",

	"models/player/faith.mdl",

	"faith",

	6000 )



RegisterModel(

	"mdl_chrisredfield",

	"Chris Redfield",

	"There are only three S.T.A.R.S. members left now.",

	"models/player/chris.mdl",

	"chris",

	3000 )



RegisterModel(

	"mdl_leonkennedy",

	"Leon Kennedy",

	"Small world, eh? Well, I see that the President's equipped his daughter with... ballistics too.",

	"models/player/leon.mdl",

	"leon",

	5500 )



RegisterModel(

	"mdl_postaldude",

	"Postal Dude",

	"Hi there. Would you like to sign my petition?",

	"models/player/dude.mdl",

	"dude",

	3000 )



RegisterModel(

	"mdl_nikobelic",

	"Niko Bellic",

	"Welcome to America.",

	"models/player/niko.mdl",

	"niko",

	2000 )



RegisterModel(

	"mdl_romanbelic",

	"Roman Bellic",

	"Cousin! Lets go bowling!",

	"models/player/romanbellic.mdl",

	"roman",

	2000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_robot",

	"Robot",

	"Main systems fully online.",

	"models/player/robot.mdl",

	"robot",

	3000 )



RegisterModel(

	"mdl_ironman",

	"Iron Man",

	"\"Iron Man.\" That's kind of catchy. It's got a nice ring to it.",

	"models/Avengers/Iron Man/mark7_player.mdl",

	"ironman",

	7500, nil, nil, 1405502697 )



RegisterModel(

	"mdl_hunter",

	"Hunter",

	"So that's a Hunter, huh? What's he gonna do, go for a jog at me?",

	"models/player/hunter.mdl",

	"hunter",

	5500 )



RegisterModel(

	"mdl_gmen",

	"Gmen",

	"Over time, my husband will desire me less sexually, but he will always enjoy my pies.",

	"models/player/gmen.mdl",

	"gmen",

	5500 )



RegisterModel(

	"mdl_joker",

	"Joker",

	"Do you want to know why I use a knife? Guns are too quick. You can't savor all the... little emotions.",

	"models/player/joker.mdl",

	"joker",

	7750 )



RegisterModel(

	"mdl_gordon",

	"Gordon Freeman",

	"Gordon Freeman, in the flesh - or, rather, in the hazard suit.",

	"models/player/gordon.mdl",

	"gordon",

	5000 )



RegisterModel(

	"mdl_masseffect",

	"Mass Effect Dude",

	"Why is it whenever someone says 'with all due respect', they really mean 'kiss my ass'?",

	"models/player/masseffect.mdl",

	"masseffect",

	8000 )



RegisterModel(

	"mdl_masterchief",

	"Master Chief",

	"Halo. It's finished. No, I think we're just getting started.",

	"models/player/lordvipes/haloce/spartan_classic.mdl",

	"masterchief",

	10000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_subzero",

	"Subzero",

	"I've got a score to settle.",

	"models/player/subzero.mdl",

	"subzero",

	12000 )



RegisterModel(

	"mdl_scorpion",

	"Scorpion",

	"Get over here!",

	"models/player/scorpion.mdl",

	"scorpion",

	13000 )



RegisterModel(

	"mdl_clopsy",

	"Undead Combine",

	"Blarhghghgh",

	"models/player/clopsy.mdl",

	"undeadcombine",

	8000 )



RegisterModel(

	"mdl_nuggets",

	"Boxman",

	"Seriously, who drew this bear mouth on my box!?",

	"models/player/nuggets.mdl",

	"boxman",

	10000 )



RegisterModel(

	"mdl_macdguy",

	"Classy Gentleman",

	"Elegant, classy, modern... I'm the entire package.",

	"models/player/macdguy.mdl",

	"macdguy",

	25000 )



RegisterModel(

	"mdl_raz",

	"Raz",

	"I'm glad you took that ass-kicking I handed to you and turned it into something nice... like gardening.",

	"models/player/raz.mdl",

	"raz",

	8000,

	.50 )



RegisterModel(

	"mdl_midna",

	"Midna",

	"Aww, but it was so nice here in the twilight.. What’s so great about a world of light, anyway?",

	"models/player/midna.mdl",

	"midna",

	18000,

	.4 )



RegisterModel(

	"mdl_knight",

	"Knight",

	"Praise the Sun!",

	"models/player/knight.mdl",

	"knight",

	19000 )



RegisterModel(

	"mdl_isaac",

	"Isaac Clarke",

	"Stick around. I'm full of bad ideas.",

	"models/player/security_suit.mdl",

	"isaac",

	20000 )



RegisterModel(

	"mdl_shaun",

	"Shaun",

	"You've got red on you.",

	"models/player/shaun.mdl",

	"shaun",

	16000 )



RegisterModel(

	"mdl_teslapower",

	"Tesla Armor",

	"Nikola Tesla is so jealous.",

	"models/player/teslapower.mdl",

	"teslapower",

	25000 )



RegisterModel(

	"mdl_rayman",

	"Rayman",

	"Utbay... I'mway Aymanray!",

	"models/player/rayman.mdl",

	"rayman",

	9000 )



RegisterModel(

	"mdl_bobafett",

	"Boba Fett",

	"There's a price on your head and I've come to collect.",

	"models/player/bobafett.mdl",

	"bobafett",

	17000 )



RegisterModel(

	"mdl_chewbacca",

	"Chewbacca",

	"Let the Wookiee win.",

	"models/player/chewbacca.mdl",

	"chewbacca",

	20000 )



RegisterModel(

	"mdl_dishonored_assassin1",

	"Assassin",

	"We all start with innocence, but the world leads us to guilt.",

	"models/player/dishonored_assassin1.mdl",

	"assassin",

	15000 )



RegisterModel(

	"mdl_doomguy",

	"Doom Guy",

	". . .",

	"models/ex-mo/quake3/players/doom.mdl",

	"doomguy",

	10000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_harry_potter",

	"Harry Potter",

	"I'm sorry, Professor... But I must not tell lies!",

	"models/player/harry_potter.mdl",

	"harry_potter",

	15000 )



RegisterModel(

	"mdl_jack_sparrow",

	"Jack Sparrow",

	"I got a jar of dirt!",

	"models/player/jack_sparrow.mdl",

	"jack_sparrow",

	19500 )



RegisterModel(

	"mdl_jawa",

	"Jawa",

	"Utinni!",

	"models/player/jawa.mdl",

	"jawa",

	7000 )



RegisterModel(

	"mdl_marty",

	"Marty McFly",

	"Are you telling me that you built a time machine... out of a DeLorean?",

	"models/player/martymcfly.mdl",

	"marty",

	19850 )



RegisterModel(

	"mdl_samusz",

	"Zero Suit Samus",

	"The last Metroid is in captivity. The galaxy is at peace.",

	"models/player/samusz.mdl",

	"samuszero",

	14000 )



RegisterModel(

	"mdl_skeleton",

	"Skeleton",

	"Spooky scary skeletons send shivers down your spine.",

	"models/player/skeleton.mdl",

	"skeleton",

	14000 ) // Should stay here now. It's a special skin.



RegisterModel(

	"mdl_stormtrooper",

	"Stormtrooper",

	"Aren't you a little short for a Stormtrooper?",

	"models/player/stormtrooper.mdl",

	"stormtrooper",

	11000 )



RegisterModel(

	"mdl_suluigi_galaxy",

	"Luigi",

	"It's-a Luigi time!",

	"models/player/suluigi_galaxy.mdl",

	"luigi",

	14999 )



RegisterModel(

	"mdl_sumario_galaxy",

	"Mario",

	"Ya-hoo!",

	"models/player/sumario_galaxy.mdl",

	"mario",

	15000 )



RegisterModel(

	"mdl_zero",

	"Zero",

	"Somehow... I... I did it... But... It... It cost me everything...",

	"models/player/lordvipes/MMZ/Zero/zero_playermodel_cvp.mdl",

	"zero",

	16000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_hevsuit",

	"HEV Suit",

	"Welcome to the H.E.V. mark 4 protective system.",

	"models/player/normal.mdl",

	"normal",

	5000 )



RegisterModel(

	"mdl_spytf2",

	"Spy",

	"I never really was on your side.",

	"models/player/drpyspy/spy.mdl",

	"spytf2",

	20000 )



RegisterModel(

	"mdl_solidsnake",

	"Big Boss",

	"Do you think love can bloom even on a battlefield?",

	"models/player/big_boss.mdl",

	"solidsnake",

	15000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_yoshi",

	"Yoshi",

	"Yooshi!",

	"models/player/yoshi.mdl",

	"yoshi",

	15000, nil, nil, 1405502697 )



-- Too many megabytes

--[[RegisterModel(

	"mdl_helite",

	"Elite",

	"WORT WORT WORT!",

	"models/player/lordvipes/h2_elite/eliteplayer.mdl",

	"helite",

	11000, nil, nil, 1405502697 )]]



-- Spases

--[[RegisterModel(

	"mdl_grayfox",

	"Gray Fox",

	"I've come from another world to do battle with you.",

	"models/player/lordvipes/Metal_Gear_Rising/gray_fox_playermodel_cvp.mdl",

	"grayfox",

	15000, nil, nil, 1405502697 )]]



-- Too many megabytes

--[[RegisterModel(

	"mdl_jcdenton",

	"JC Denton",

	"My vision is augmented.",

	"models/player/lordvipes/de_jc/jcplayer.mdl",

	"jcdenton",

	5000, nil, nil, 1405502697 )]]



RegisterModel(

	"mdl_crimsonlance",

	"Crimson Lance",

	"I work for the Atlas corporation.",

	"models/player/lordvipes/bl_clance/crimsonlanceplayer.mdl",

	"crimsonlance",

	14000, nil, nil, 1405502697 )



-- Too many megabytes

--[[RegisterModel(

	"mdl_nighthawkre",

	"Nighthawk",

	"Also known as ''LONE WOLF''",

	"models/player/lordvipes/residentevil/nighthawk/nighthawk_playermodel_cvp.mdl",

	"nighthawk",

	8000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_hunk",

	"Hunk",

	"This is war; survival is your responsibility.",

	"models/player/lordvipes/residentevil/HUNK/hunk_playermodel_cvp.mdl",

	"hunk",

	9000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_geth",

	"Geth",

	"Our analysis of organic humor suggests an 87.3% chance that you expect us to respond with, ''You are only human.''",

	"models/player/lordvipes/masseffect/geth/geth_trooper_playermodel_cvp.mdl",

	"geth",

	12000, nil, nil, 1405502697 )]]



-- Too many megabytes

--[[RegisterModel(

	"mdl_franklin",

	"Franklin",

	"You cool? Cool what? Slinging dope and throwing up gang signs?",

	"models/GrandTheftAuto5/Franklin.mdl",

	"franklin",

	5000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_trevor",

	"Trevor",

	"I need to masturbate or meditate... or both of them.",

	"models/GrandTheftAuto5/Trevor.mdl",

	"trevor",

	5000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_michael",

	"Michael",

	"I'm rich. I'm miserable. I'm pretty average for this town, really.",

	"models/GrandTheftAuto5/Michael.mdl",

	"michael",

	5000, nil, nil, 1405502697 )]]



RegisterModel(

	"mdl_jackskellington",

	"Jack Skellington",

	"I'm a master of fright, and a demon of light.",

	"models/vinrax/player/Jack_player.mdl",

	"jackskellington",

	12000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_deadpool",

	"Deadpool",

	"BANG-BANG BANG BANG BANG!",

	"models/player/deadpool.mdl",

	"deadpool",

	14000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_deathstroke",

	"Deathstroke",

	"I'm a goddam killing machine!",

	"models/norpo/ArkhamOrigins/Assassins/Deathstroke_ValveBiped.mdl",

	"deathstroke",

	14000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_carley",

	"Carley",

	"",

	"models/nikout/carleypm.mdl",

	"carley",

	15000, nil, nil, 1405502697 )



-- Hats don't work

--[[RegisterModel(

	"mdl_atlas",

	"Atlas",

	"",

	"models/bots/survivor_mechanic.mdl",

	"atlas",

	15000, nil, nil, 1405502697 )]]



RegisterModel(

	"mdl_tronanon",

	"Tron Anon",

	"The only way to win the game is not to play.",

	"models/player/anon/anon.mdl",

	"tronanon",

	11000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_alice",

	"Alice",

	"My Wonderland is shattered. It's dead to me.",

	"models/player/alice.mdl",

	"alice",

	12000, nil, nil, 1405502697 )


--[[
RegisterModel(

	"mdl_windranger",

	"Wind Ranger",

	"Taste my arrow!",

	"models/heroes/windranger/windranger.mdl",

	"windranger",

	30000, nil, nil, 1405502697 )
--]]


--[[RegisterModel(

	"mdl_soria",

	"Soria",

	"",

	"models/player/soria.mdl",

	"soria",

	15000, nil, nil, 1405502697 )]]



RegisterModel(

	"mdl_ash",

	"Red",

	"Gotta catch them all!",

	"models/player/red.mdl",

	"ash",

	10000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_megaman",

	"Mega Man",

	"What if I become a maverick?",

	"models/vinrax/player/megaman64_player.mdl",

	"megaman",

	9000, .75, nil, 1405502697 )



RegisterModel(

	"mdl_kiliksoul",

	"Kilik",

	"You'll never stand a chance without dedication.",

	"models/player/hhp227/kilik.mdl",

	"kilik",

	29000, nil, nil, 1405502697 )



-- Broken textures

--[[RegisterModel(

	"mdl_bond",

	"James Bond",

	"Vodka Martini, shaken not stirred.",

	"models/player/bond.mdl",

	"bond",

	10000, nil, nil, 1405502697 )]]



RegisterModel(

	"mdl_freddykruger",

	"Freddy Kruger",

	"1, 2 Freddy's coming for you.",

	"models/player/freddykruger.mdl",

	"freddykruger",

	16000, nil, nil, 1405502697 )



RegisterModel(

	"mdl_greenarrow",

	"The Arrow",

	"My name is Oliver Queen, and you have failed this city!",

	"models/player/greenarrow.mdl",

	"greenarrow",

	15000, nil, nil, 1405502697 )

--[[
RegisterModel(

		"mdl_haroldlott",

		"Harold Lott",

		"Dosh! Grab it while you can, lads.",

		"models/player/haroldlott.mdl",

		"haroldlott",

		35000 )
	--]]

	--[[
	RegisterModel(

	"mdl_walterwhite",

	"Walter White",

	"I am the one who knocks.",

	"models/Agent_47/agent_47.mdl",

	"walterwhite",

	6000, nil, nil, 1405502697 )
	--]]

RegisterModel(

	"mdl_linktp",

	"Link",

	"Hyaaaa!",

	"models/player/linktp.mdl",

	"linktp",

	15000, nil, nil, 1405502697 )



-- Not available yet

--[[RegisterModel(

	"mdl_ornstein",

	"Ornstein",

	"The guardian of Heide cathedral",

	"models/nikout/darksouls2/characters/olddragonslayer.mdl",

	"ornstein",

	60000, nil, nil, 1405502697 )]]



GTowerItems.RegisterItem( "mdl_blockdude", {

	Name = "Blockdude",

	Description = "Minecraft, I'm talkin' 'bout Minecraft... You can now load your Minecraft skin for everybody to see!",

	Model = "models/player/mcsteve.mdl",

	ModelName = "steve",

	UniqueInventory = false,

	DrawModel = true,

	CanEntCreate = false,

	Equippable = true,

	EquipType = "Model",

	UniqueEquippable = true,

	ModelItem = true,

	AlwaysAllowModel = true,

	StoreId = 13,

	StorePrice = 17000,

	InvCategory = "model",

	ModelUseSize = .75,

	DrawName = true,

	MoveSound = "cloth",



	ExtraMenuItems = function ( item, menu )

		table.insert( menu, {

			[ "Name" ] = "Set Skin",

			[ "function" ] = function()

				Derma_StringRequest(

					"Blockdude Skin",

					"Please enter a valid Minecraft user account to use as your skin. This is case sensative. \nWarning: Using explicit skins is bannable.",

					LocalPlayer():GetInfo( "cl_minecraftskin" ) or "",

					function(text) MinecraftSendUpdatedSkin(text) end

				)

			end

		} )

	end

})
