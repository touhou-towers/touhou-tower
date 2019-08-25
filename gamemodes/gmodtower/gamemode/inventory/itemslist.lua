module("GTowerItems", package.seeall)

AddCSLuaFile("itemslist/trophies.lua")
AddCSLuaFile("itemslist/models.lua")
AddCSLuaFile("itemslist/construction.lua")
AddCSLuaFile("itemslist/fireworks.lua")
AddCSLuaFile("itemslist/milestones.lua")
AddCSLuaFile("itemslist/pets.lua")
AddCSLuaFile("itemslist/posters.lua")
AddCSLuaFile("itemslist/food.lua")
AddCSLuaFile("itemslist/bonemods.lua")

include("itemslist/trophies.lua")
include("itemslist/milestones.lua")
include("itemslist/construction.lua")
include("itemslist/fireworks.lua")
include("itemslist/pets.lua")
include("itemslist/models.lua")
include("itemslist/posters.lua")
include("itemslist/food.lua")
include("itemslist/bonemods.lua")

RegisterItem(
	"wooddeskwow",
	{
		Name = "Wooden Desk",
		Description = "This desk is imported directly from the Swedish furniture store, Bullseye.",
		Model = "models/splayn/rp/of/desk1.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 1300,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"gmt_texthat",
	{
		Name = "Text Hat",
		Description = "A customizable text hat. Wear your words.",
		Model = "models/gmod_tower/fedorahat.mdl",
		UniqueInventory = true,
		UniqueEquippable = true,
		DrawModel = true,
		Equippable = true,
		EquipType = "TextHat",
		ClassName = "gmt_wearable_texthat",
		CanEntCreate = false,
		CanRemove = true,
		DrawName = true,
		Tradable = true,
		StoreId = 8,
		StorePrice = 30000,
		RemoveOnDeath = true,
		RemoveOnNoEntsLoc = true,
		ExtraMenuItems = function(item, menu)
			table.insert(
				menu,
				{
					["Name"] = "Set Height Offset",
					["function"] = function()
						local curHeight = LocalPlayer():GetInfoNum("gmt_hatheight", 0) or 0

						Derma_SliderRequest(
							"Hat Height",
							"Please enter the height you wish the text to float above your head.",
							curHeight,
							-50,
							50,
							0,
							function(val)
								RunConsoleCommand("gmt_hatheight", val)
							end
						)
					end
				}
			)

			table.insert(
				menu,
				{
					["Name"] = "Set Text",
					["function"] = function()
						local curText = LocalPlayer():GetInfo("gmt_hattext") or ""

						Derma_StringRequest(
							"Hat Text",
							"Please enter the text you would like to float above your head.",
							curText,
							function(text)
								if string.find(text, "#") then
									text = string.gsub(text, "#", "")
								end
								RunConsoleCommand("gmt_hattext", text)
							end
						)
					end
				}
			)
		end,
		EquippableEntity = true,
		OverrideOnlyEquippable = true,
		CreateEquipEntity = function(self)
			local hatEnt = ents.Create("gmt_wearable_texthat")

			if IsValid(hatEnt) then
				hatEnt.IsActiveEquippable = true
				hatEnt:SetPos(self.Ply:GetPos())
				hatEnt:SetOwner(self.Ply)
				hatEnt:SetParent(self.Ply)
				hatEnt.Owner = self.Ply

				hatEnt:Spawn()
			end

			return hatEnt
		end
	}
)

RegisterItem(
	"trampoline",
	{
		Name = "Trampoline",
		Description = "Jump around all crazy like!",
		Model = "models/gmod_tower/trampoline.mdl",
		ClassName = "gmt_trampoline",
		UniqueInventory = false,
		DrawModel = true,
		CanRemove = true,
		StoreId = 22,
		StorePrice = 500
	}
)

RegisterItem(
	"PresentAdmin",
	{
		Name = "Admin Present",
		Description = "",
		Model = "models/items/cs_gift.mdl",
		ClassName = "gmt_item_adminpresent",
		UniqueInventory = false,
		DrawModel = true,
		CanRemove = true,
		StorePrice = 100
	}
)

RegisterItem(
	"PresentBirthday",
	{
		Name = "Birthday Present",
		Description = "",
		Model = "models/gmod_tower/present.mdl",
		ClassName = "gmt_item_present",
		UniqueInventory = false,
		DrawModel = true,
		CanRemove = true,
		StorePrice = 100
	}
)

RegisterItem(
	"blender",
	{
		Name = "Blender",
		Description = "Blend ingredients and make smoothies!",
		Model = "models/sunabouzu/fancy_blender.mdl",
		ClassName = "gmt_item_blender",
		UniqueInventory = true,
		DrawModel = true,
		StoreId = 25,
		StorePrice = 4000
	}
)

RegisterItem(
	"bar01",
	{
		Name = "Bar Table",
		Description = "A table, stolen from a bar.",
		Model = "models/props/cs_militia/bar01.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 400,
		MoveSound = "furniture2"
	}
)

RegisterItem(
	"endtable",
	{
		Name = "End Table",
		Description = "A small table you can put next to something.",
		Model = "models/sunabouzu/end_table.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 250,
		MoveSound = "furniture",
		NewItem = false
	}
)

RegisterItem(
	"barstool",
	{
		Name = "Bar Stool",
		Description = "Sit up high, just like at a bar.",
		Model = "models/props/cs_militia/barstool01.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 65,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"bed",
	{
		Name = "Suite Bed",
		Description = "Sleep off your worries.",
		Model = "models/gmod_tower/suitebed.mdl",
		ClassName = "gmt_suitebed",
		UniqueInventory = false,
		DrawModel = true,
		CanRemove = false,
		InvCategory = "1", -- suite
		MoveSound = "furniture"
	}
)

RegisterItem(
	"chair01a",
	{
		Name = "Bar chair.",
		Description = "",
		Model = "models/props_interiors/furniture_chair01a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"black_sofa",
	{
		Name = "Black Sofa",
		Description = "A black expensive large sofa for your guests.",
		Model = "models/gmod_tower/css_couch.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 400,
		MoveSound = "furniture3"
	}
)
--[[
RegisterItem("banana_bed",{
	Name = "Banana Bed",
	Description = "'Sleepin' in dat Vitamin B6' -Basical 2018 [LIMITED ITEM]",
	Model = "models/props/banana_bed.mdl",
	ClassName = "gmt_bananabed",
	DrawModel = true,
	MoveSound = "furniture"
})
--]]
RegisterItem(
	"brrepeller",
	{
		Name = "Repeller",
		Description = "Magnets n' shit.",
		Model = "models/props_memories/memories_positon.mdl",
		ClassName = "gmt_repeller",
		DrawModel = true
	}
)

RegisterItem(
	"statueofbreen",
	{
		Name = "Statue Of Breen",
		Description = "",
		Model = "models/props_combine/breenbust.mdl",
		ClassName = "gmt_statueofbreen",
		DrawModel = true,
		MoveSound = "vo/Citadel/br_gravgun.wav"
	}
)

RegisterItem(
	"rbrchrwhite",
	{
		Name = "Rubber Chair: White",
		Description = "A white, rubber chair.",
		Model = "models/mirrorsedge/seat_blue2.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 375,
		NewItem = false,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"rbrchrblue",
	{
		Name = "Rubber Chair: Blue",
		Description = "A blue, rubber chair.",
		Model = "models/mirrorsedge/seat_blue1.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 375,
		NewItem = false,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"whitebench",
	{
		Name = "White Bench",
		Description = "A nice modern bench.",
		Model = "models/mirrorsedge/bench_wooden.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 400,
		NewItem = false,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"bookshelf3",
	{
		Name = "Suite Shelf",
		Description = "A shelf with books on it.",
		Model = "models/props/cs_office/bookshelf3.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 100,
		MoveSound = "furniture2"
	}
)

RegisterItem(
	"breenglobe",
	{
		Name = "Globe",
		Description = "Look at the earth and study its geography.",
		Model = "models/props_combine/breenglobe.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"cabinet",
	{
		Name = "Letter Box Cabinet",
		Description = "Used to store mail with.",
		Model = "models/props_lab/partsbin01.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 35
	}
)

RegisterItem(
	"cabitnetdarw",
	{
		Name = "Cabinet Drawer",
		Description = "A nice piece of furniture to keep your suite looking good.",
		Model = "models/props_interiors/furniture_cabinetdrawer02a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 185,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"chair1",
	{
		Name = "Chair",
		Description = "A homely chair to sit on.",
		Model = "models/props_c17/furniturechair001a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 90,
		MoveSound = "wood"
	}
)

RegisterItem(
	"chairantique",
	{
		Name = "Antique Chair",
		Description = "An old chair that can really add some class to your suite.",
		Model = "models/props/de_inferno/chairantique.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 95,
		MoveSound = "wood"
	}
)

RegisterItem(
	"chairrstool",
	{
		Name = "Metal Stool",
		Description = "Cold and uncomfortable - but useful.",
		Model = "models/props_c17/chair_stool01a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 55,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"clipboard",
	{
		Name = "Clipboard",
		Description = "Manage your company.",
		Model = "models/props_lab/clipboard.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"clock",
	{
		Name = "Clock",
		Description = "Semi-working clock.",
		Model = "models/props_combine/breenclock.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"coffee_mug3",
	{
		Name = "Coffee Mug",
		Description = "A coffee mug that's just for looks.",
		Model = "models/props/cs_office/coffee_mug3.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 10,
		MoveSound = "glass"
	}
)

RegisterItem(
	"computer",
	{
		Name = "Desktop Computer",
		Description = "Another computer because you need more power.",
		Model = "models/props/cs_office/computer_case.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 500
	}
)

RegisterItem(
	"computer_display",
	{
		Name = "Desktop Display w/ Keyboard",
		Description = "This display comes with a keyboard and a mouse.",
		Model = "models/props/cs_office/computer.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 150
	}
)

RegisterItem(
	"computer_monitor",
	{
		Name = "Desktop Display",
		Description = "Another display for your computer.",
		Model = "models/props/cs_office/computer_monitor.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 130
	}
)

RegisterItem(
	"medchair",
	{
		Name = "Modern Desk Chair",
		Description = "A modern chair for your desk.",
		Model = "models/gmod_tower/medchair.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 400
	}
)

RegisterItem(
	"meddesk",
	{
		Name = "Modern Desk",
		Description = "A large modern desk.",
		Model = "models/gmod_tower/meddesk.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 1000
	}
)

RegisterItem(
	"meddeskcor",
	{
		Name = "Fancy Desk Corner",
		Description = "A large fancy desk corner.",
		Model = "models/gmod_tower/meddeskcor.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 400
	}
)

RegisterItem(
	"couch",
	{
		Name = "Couch",
		Description = "A couch that's both comfortable and stylish.",
		Model = "models/props/cs_militia/couch.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 200,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"deckchair",
	{
		Name = "Deck Chair",
		Description = "A comfy and affordable deck chair.",
		Model = "models/deckchair.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 85,
		MoveSound = "wood"
	}
)

RegisterItem(
	"deskchair",
	{
		Name = "Suite Desk Chair",
		Description = "Sit in this fancy desk chair.",
		Model = "models/props/cs_office/chair_office.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 85,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"file_box",
	{
		Name = "Filing Box",
		Description = "A file box to store all your files.",
		Model = "models/props/cs_office/file_box.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 35,
		UseSound = "use_paperstack.wav",
		MoveSound = "paper"
	}
)

RegisterItem(
	"fire_extinguisher",
	{
		Name = "Fire Extinguisher",
		Description = "Put out fires with this.",
		Model = "models/props/cs_office/fire_extinguisher.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 35,
		UseSound = "use_fireextinguisher.wav"
	}
)

RegisterItem(
	"frame",
	{
		Name = "Picture Frame",
		Description = "Remember Alyx's family with this picture.",
		Model = "models/props_lab/frame002a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"furnituredrawer001a",
	{
		Name = "Drawer",
		Description = "A simple drawer to add to your suite.",
		Model = "models/props_c17/furnituredrawer001a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 40,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"furnituredrawer002a",
	{
		Name = "Drawer",
		Description = "A small and simple drawer for your suite.",
		Model = "models/props_c17/furnituredrawer002a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 35,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"furnituredrawer003a",
	{
		Name = "Drawer",
		Description = "A tall and simple drawer for your suite.",
		Model = "models/props_c17/furnituredrawer003a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 20,
		MoveSound = "furniture"
	}
)

RegisterItem(
	"furnituredresser001a",
	{
		Name = "Dresser",
		Description = "A dresser to keep your clothes together.",
		Model = "models/props_c17/furnituredresser001a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 45,
		MoveSound = "furniture2"
	}
)

RegisterItem(
	"furnituretable001a",
	{
		Name = "Table",
		Description = "A small round table to place things on.",
		Model = "models/props_c17/furnituretable001a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 70,
		MoveSound = "furniture2"
	}
)

RegisterItem(
	"furnituretable002a",
	{
		Name = "Table",
		Description = "A square table to place your things on.",
		Model = "models/props_c17/furnituretable002a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 40,
		MoveSound = "furniture2"
	}
)

RegisterItem(
	"furniture_couch02a",
	{
		Name = "Furniture Couch",
		Description = "Sit in this couch and enjoy the fire.",
		Model = "models/props/de_inferno/furniture_couch02a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 250,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"furniture_shelf01a",
	{
		Name = "Shelf",
		Description = "Place trophies or other items in this nice shelf.",
		Model = "models/props/cs_militia/furniture_shelf01a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 115,
		MoveSound = "furniture3"
	}
)

RegisterItem(
	"gmtdesk",
	{
		Name = "Computer Desk",
		Description = "Place your computer and other things on this desk.",
		Model = "models/gmod_tower/gmtdesk.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 450
	}
)

RegisterItem(
	"gun_cabinet",
	{
		Name = "Gun Cabinet",
		Description = "A display cabinet filled with authentic shotguns.",
		Model = "models/props/cs_militia/gun_cabinet.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 500,
		MoveSound = "wood"
	}
)

RegisterItem(
	"huladoll",
	{
		Name = "Hula Doll",
		Description = "Reminds you of a place you'd like to be.",
		Model = "models/props_lab/huladoll.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 5,
		ClassName = "gmt_hula"
	}
)

RegisterItem(
	"propgun",
	{
		Name = "Prop Gun",
		Description = "Spook your friends with this fake gun!",
		Model = "models/weapons/w_357.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 500
	}
)

RegisterItem(
	"jar01a",
	{
		Name = "Jar",
		Description = "A collectible jar filled with imagination.",
		Model = "models/props_lab/jar01a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"lamp",
	{
		Name = "Desktop Lamp",
		Description = "Add some light to your desktop.",
		Model = "models/props_lab/desklamp01.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 15,
		MoveSound = "furniture2"
	}
)

RegisterItem(
	"microwave",
	{
		Name = "Microwave",
		Description = "Cook things to perfection in minutes.",
		Model = "models/props/cs_office/microwave.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 100,
		UseSound = "use_microwave.wav"
	}
)

RegisterItem(
	"oldmicrowave",
	{
		Name = "Old Microwave",
		Description = "Old, but still usable.",
		Model = "models/props/cs_militia/microwave01.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 80
	}
)

RegisterItem(
	"patiochair01",
	{
		Name = "Patio Chair",
		Description = "A comfy outdoor patio chair.",
		Model = "models/props/de_tides/patio_chair.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 135
	}
)

RegisterItem(
	"patiochair02",
	{
		Name = "Metal Chair",
		Description = "A comfy metal outdoor patio chair.",
		Model = "models/props/de_tides/patio_chair2.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 1,
		StorePrice = 100
	}
)

RegisterItem(
	"phone",
	{
		Name = "Phone",
		Description = "A phone to keep you in contact with the world.",
		Model = "models/props/cs_office/phone.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 20,
		UseSound = "use_phone.wav"
	}
)

RegisterItem(
	"plant1",
	{
		Name = "Office Plant",
		Description = "A tall plant that fits any place.",
		Model = "models/props/cs_office/plant01.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 30
	}
)

RegisterItem(
	"bball",
	{
		Name = "Beach Ball",
		Description = "We stole this from the pool, don't tell anyone!",
		Model = "models/gmod_tower/beachball.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 500,
		ClassName = "gmt_beachball",
		NewItem = false
	}
)

RegisterItem(
	"thermos",
	{
		Name = "Thermos",
		Description = "Keep drinks nice and warm.",
		Model = "models/props_2fort/thermos.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 75,
		NewItem = false
	}
)

RegisterItem(
	"pot01a",
	{
		Name = "Tea Kettle",
		Description = "Brew tea with this pot.",
		Model = "models/props_interiors/pot01a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)
RegisterItem(
	"compositionnotebook",
	{
		Name = "Notebook",
		Description = "Well, maybe there's something useful written in it related to smoothies. Then again, maybe it's just amusing drawings.",
		Model = "models/sunabouzu/notebook_elev.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 25,
		StorePrice = 400
	}
)

RegisterItem(
	"lsaber",
	{
		Name = "Toy Light Saber",
		Description = "Use the force, Luke.",
		Model = "models/gmod_tower/toy_lightsaber.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 5000,
		ClassName = "gmt_lightsaber",
		MoveSound = "lightsaber",
		NewItem = false
	}
)

RegisterItem(
	"toytrainsmall",
	{
		Name = "Toy Train Small",
		Description = "Choo Choo (but small)",
		ClassName = "gmt_toy_train_small",
		Model = "models/minitrains/loco/swloco007.mdl",
		DrawModel = true,
		StorePrice = 5000,
		StoreId = 22
	}
)

RegisterItem(
	"toytrain",
	{
		Name = "Toy Train",
		Description = "Choo Choo!",
		ClassName = "gmt_toy_train",
		Model = "models/minitrains/loco/swloco007.mdl",
		DrawModel = true,
		StorePrice = 6000,
		StoreId = 22
	}
)

RegisterItem(
	"toybumper",
	{
		Name = "Toy Bumper",
		Description = "Great for any Hula Doll Ballrace contest!",
		Model = "models/gmod_tower/bumper.mdl",
		MoveSound = Sound("GModTower/balls/bumper.wav"),
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 350,
		ClassName = "gmt_tinybumper",
		NewItem = false
	}
)

RegisterItem(
	"plush_fox",
	{
		Name = "Plushy: Fox",
		Description = "A cute fuzzy plush.",
		Model = "models/gmod_tower/plush_fox.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 1500,
		ModelSkinId = 0,
		NewItem = false,
		UseSound = "move_plush.wav",
		MoveSound = "plush"
	}
)
RegisterItem(
	"plush_fox2",
	{
		Base = "plush_fox",
		Name = "Plushy: Blue Fox",
		ModelSkinId = 1
	}
)
RegisterItem(
	"plush_fox3",
	{
		Base = "plush_fox",
		Name = "Plushy: Grey Fox",
		ModelSkinId = 2
	}
)
RegisterItem(
	"plush_fox4",
	{
		Base = "plush_fox",
		Name = "Plushy: Pink Fox",
		ModelSkinId = 3
	}
)
RegisterItem(
	"plush_fox5a",
	{
		Base = "plush_fox",
		Name = "Plushy: Orange Fox",
		ModelSkinId = 4
	}
)
RegisterItem(
	"plush_penguin",
	{
		Name = "Plushy: Penguin (Red Tie)",
		Description = "A cute fuzzy plush.",
		Model = "models/gmod_tower/plush_penguin.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 22,
		StorePrice = 1800,
		ModelSkinId = 0,
		UseSound = "use_penguin.wav",
		NewItem = false
	}
)

RegisterItem(
	"plush_penguin2",
	{
		Base = "plush_penguin",
		Name = "Plushy: Penguin (Blue Tie)",
		ModelSkinId = 1
	}
)

RegisterItem(
	"plush_penguin3",
	{
		Base = "plush_penguin",
		Name = "Plushy: Penguin (Whacky Orange Tie)",
		ModelSkinId = 2
	}
)

RegisterItem(
	"plush_penguin4",
	{
		Base = "plush_penguin",
		Name = "Plushy: Penguin (Black Tie)",
		ModelSkinId = 3
	}
)

RegisterItem(
	"plush_penguin5",
	{
		Base = "plush_penguin",
		Name = "Plushy: Penguin (Pink Tie)",
		ModelSkinId = 4
	}
)
RegisterItem(
	"shotglass",
	{
		Name = "Shot Glass",
		Description = "Take a virtual shot.",
		Model = "models/sunabouzu/shot_glass.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 100,
		NewItem = false,
		MoveSound = "glass"
	}
)

RegisterItem(
	"nbottle",
	{
		Name = "Noir Bottle",
		Description = "A nice bottle.",
		Model = "models/sunabouzu/noir_bottle.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 200,
		NewItem = false,
		MoveSound = "glass"
	}
)

RegisterItem(
	"pot02a",
	{
		Name = "Pot",
		Description = "Used to cook food.",
		Model = "models/props_interiors/pot02a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"potted_plant1",
	{
		Name = "Potted Plant",
		Description = "A nice plant.",
		Model = "models/props/de_inferno/potted_plant2.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 10
	}
)

RegisterItem(
	"potted_plant2",
	{
		Name = "Potted Plant Small",
		Description = "A small nice plant.",
		Model = "models/props/de_inferno/potted_plant1.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 10
	}
)

RegisterItem(
	"pottery02",
	{
		Name = "Round Pot",
		Description = "A rounded pot.",
		Model = "models/props_c17/pottery02a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"pottery03",
	{
		Name = "Flat Pot",
		Description = "A flat pot for plants.",
		Model = "models/props_c17/pottery03a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"pottery04",
	{
		Name = "Vase",
		Description = "Holds all your flowers.",
		Model = "models/props_c17/pottery04a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"pottery06",
	{
		Name = "Fancy Pot",
		Description = "A pot with a nifty design.",
		Model = "models/props_c17/pottery06a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"pottery07",
	{
		Name = "Large Vase",
		Description = "A large vase.",
		Model = "models/props_c17/pottery07a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)

RegisterItem(
	"pottery09",
	{
		Name = "Ancient Pot",
		Description = "An old pot.",
		Model = "models/props_c17/pottery09a.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 5
	}
)
RegisterItem(
	"1984",
	{
		Name = "1984",
		Description = "Think GMT is an Orwellian soceity? Don't know what that means? Read 1984, then.",
		Model = "models/sunabouzu/book_single1.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 250
	}
)
RegisterItem(
	"book3",
	{
		Name = "Coverless Book",
		Description = "Blue coverless book",
		Model = "models/sunabouzu/book_single1.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 250,
		ModelSkinId = 3,
		MoveSound = "paper"
	}
)
RegisterItem(
	"book2",
	{
		Name = "Coverless Book",
		Description = "Red coverless book",
		Model = "models/sunabouzu/book_single1.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 250,
		ModelSkinId = 1,
		MoveSound = "paper"
	}
)
RegisterItem(
	"pilepaper",
	{
		Name = "Pile Of Papers",
		Description = "You should really keep your desk cleaner, you know. What's this, case notes?",
		Model = "models/sunabouzu/paper_stack.mdl",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 6,
		StorePrice = 150,
		UseSound = "use_paperstack.wav",
		MoveSound = "paper"
	}
)
RegisterItem(
	"radio",
	{
		Name = "Radio",
		Description = "Listen to some music and chill out.",
		Model = "models/props/cs_office/radio.mdl",
		ClassName = "gmt_radio",
		UniqueInventory = true,
		DrawModel = true,
		CanRemove = false,
		StoreId = 7,
		StorePrice = 500,
		InvCategory = "7" -- electronics
	}
)

RegisterItem(
	"remotecontrol",
	{
		Name = "Remote Control",
		Description = "Turn on and off your TV with ease.",
		Model = "models/props/cs_office/projector_remote.mdl",
		ClassName = "gmt_room_remote",
		UniqueInventory = false,
		DrawModel = true,
		StoreId = 7,
		StorePrice = 15
	}
)
--[[
/*RegisterItem("tinyslot",{
	Name = "Mini Slotmachine",
	Description = "Going to the casino not your thing? Don't worry! With this mini slotmachine you can live the gambling experience from your own suite!",
	Model = "models/gmod_tower/casino/slotmachine.mdl",
	ClassName = "gmt_toyslots",
	UniqueInventory = false,
	NewItem = false,
	DrawModel = true,
	StoreId = 7,
	StorePrice = 4250,
	ItemScale = 0.7,
})*/

// No content for em yet
/*RegisterItem("lightcube",{
	Name = "Light Cube",
	Description = "Decorate your suite with some shiny ambient lighting, totally not from Rave.",
	Model = "models/gmod_tower/kartracer/rave/light_cube.mdl",
	NewItem = false,
	DrawModel = true,
	StoreId = 7,
	StorePrice = 2500,
})
RegisterItem("glowdonut",{
	Name = "Glowing Donut",
	Description = "A big glowing, RGB donut. Perfect for rave parties.",
	Model = "models/gmod_tower/kartracer/rave/glowing_donut.mdl",
	NewItem = false,
	DrawModel = true,
	StoreId = 7,
	StorePrice = 5000,
})

RegisterItem("neon_tube1",{
	Name = "Neon Tube (pink)",
	Description = "A cool neon tube.",
	Model = "models/gmod_tower/kartracer/rave/neon_tube.mdl",
	UniqueInventory = false,
	DrawModel = true,
	StoreId = 7,
	StorePrice = 125,
	ModelSkinId = 0,
	NewItem = false
})

RegisterItem("neon_tube2",{
	Base = "neon_tube1",
	Name = "Neon Tube (cyan)",
	ModelSkinId = 5,
})

RegisterItem("neon_tube3",{
	Base = "neon_tube1",
	Name = "Neon Tube (yellow)",
	ModelSkinId = 10,
})

RegisterItem("neon_tube4",{
	Base = "neon_tube1",
	Name = "Neon Tube (green)",
	ModelSkinId = 15,
})

RegisterItem("neon_tube5",{
	Base = "neon_tube1",
	Name = "Neon Tube (orange)",
	ModelSkinId = 20,
})

RegisterItem("neon_tube6",{
	Base = "neon_tube1",
	Name = "Neon Tube (purple)",
	ModelSkinId = 25,
})*/

--]]

RegisterItem(
    "oldtv",
    {
        Name = "Old TV",
        Description = "Incase new technology isn't your thing.",
        Model = "models/props_spytech/tv001.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 7,
        StorePrice = 250,
        NewItem = false
    }
)

RegisterItem(
    "wcooler",
    {
        Name = "Water Cooler",
        Description = "Keep your guests hydrated with this nice water cooler.",
        Model = "models/props_spytech/watercooler.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 7,
        StorePrice = 750,
        NewItem = false
    }
)
RegisterItem(
    "handscan",
    {
        Name = "Hand Scanner",
        Description = "An extra security measure for your holy bathroom.",
        Model = "models/maxofs2d/button_04.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 7,
        StorePrice = 525,
        NewItem = false
    }
)
RegisterItem(
    "modernlamp",
    {
        Name = "Modern Lamp",
        Description = "A nice working lamp to put on your desk.",
        Model = "models/gmod_tower/lamp02.mdl",
        UniqueInventory = false,
        DrawModel = true,
        ClassName = "gmt_modernlamp",
        StoreId = 7,
        StorePrice = 500,
        NewItem = false,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "turntab",
    {
        Name = "Turn Table",
        Description = "Show everyone that you're the best DJ in town!",
        Model = "models/props_vtmb/turntable.mdl",
        UniqueInventory = false,
        DrawModel = true,
        UseSound = "use_scratch.wav",
        StoreId = 27,
        StorePrice = 525
    }
)

RegisterItem(
    "oldpcmonitor",
    {
        Name = "Old Computer Monitor",
        Description = "What cable does this use again?",
        Model = "models/props_lab/monitor01a.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 7,
        StorePrice = 145,
        NewItem = false
    }
)

RegisterItem(
    "restauranttable",
    {
        Name = "Restaurant Table",
        Description = "A fancy table used mostly for restaurants.",
        Model = "models/props/de_tides/restaurant_table.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 145
    }
)

RegisterItem(
    "sidetable",
    {
        Name = "Bed Side Table",
        Description = "Put your reading glasses on.",
        Model = "models/gmod_tower/bedsidetable.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 70,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "sofa",
    {
        Name = "Sofa",
        Description = "An expensive large sofa for your guests.",
        Model = "models/props/cs_office/sofa.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 350,
        MoveSound = "furniture3"
    }
)
RegisterItem(
    "pinkbed",
    {
        Name = "Heart Bed",
        Description = "A big, heart shaped pink bed.",
        Model = "models/props_vtmb/heartbed.mdl",
        ClassName = "gmt_pinkbed",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1250,
        MoveSound = "cloth"
    }
)
RegisterItem(
    "simsbedpink",
    {
        Name = "Pink Bed",
        Description = "Unveil the princess inside you.",
        Model = "models/sims/gm_pinkbed.mdl",
        ClassName = "gmt_simsbed",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 775,
        MoveSound = "cloth"
    }
)
RegisterItem(
    "comfbed",
    {
        Name = "Comfy Bed",
        Description = "A nice, comfy bed.",
        Model = "models/gmod_tower/comfybed.mdl",
        ClassName = "gmt_comfybed",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 750,
        MoveSound = "cloth"
    }
)

RegisterItem(
    "filingcabinetwithbooze",
    {
        Name = "Filing Cabinet",
        Description = "These are the only things that ever need to be filed anyway.",
        Model = "models/sunabouzu/noir_cabinet.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1000
    }
)

RegisterItem(
    "kitchtable",
    {
        Name = "Kitchen Table",
        Description = "A modern kitchen table.",
        Model = "models/gmod_tower/kitchentable.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 750,
        NewItem = false,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "comfchair",
    {
        Name = "Comfy Chair",
        Description = "A nice, comfy chair.",
        Model = "models/gmod_tower/comfychair.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 425,
        MoveSound = "furniture"
    }
)
RegisterItem(
    "illusive",
    {
        Name = "Desk Chair",
        Description = "This desk chair is so futuristic that it transcends comfortable back down to extremely uncomfortable.",
        Model = "models/haxxer/me2_props/illusive_chair.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 500,
        MoveSound = "furniture"
    }
)
RegisterItem(
    "reclining",
    {
        Name = "Reclining Chair",
        Description = "A cool, futuristic chair.",
        Model = "models/haxxer/me2_props/reclining_chair.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 525,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "blackcurtain",
    {
        Name = "Black Curtains",
        Description = "Nice curtains if you're not a fan of sunlight.",
        Model = "models/sunabouzu/mansion_curtains.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 275,
        NewItem = false
    }
)
RegisterItem(
    "mpillar",
    {
        Name = "Big Pillar",
        Description = "Perfect for making constructions with.",
        Model = "models/sunabouzu/mansion_pillar.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 500,
        NewItem = false,
        MoveSound = "concrete"
    }
)
RegisterItem(
    "mshelf",
    {
        Name = "Metal Shelving",
        Description = "It does everything all those other, lesser shelves do, but it's made of metal!",
        Model = "models/sunabouzu/metal_shelf.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 400,
        NewItem = false
    }
)

RegisterItem(
    "sofachair",
    {
        Name = "Sofa Chair",
        Description = "Comfy and large - perfect for relaxing in.",
        Model = "models/props/cs_office/sofa_chair.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 175,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "suitecouch",
    {
        Name = "Suite Sofa",
        Description = "Sit down on a comfy couch.",
        Model = "models/gmod_tower/suitecouch.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 300,
        MoveSound = "furniture3"
    }
)

RegisterItem(
    "suitelamp",
    {
        Name = "Suite Lamp",
        Description = "A decorative lamp.",
        Model = "models/gmod_tower/suite_lamptakenfromhl2.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 25,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "suiteshelf",
    {
        Name = "Suite Shelf",
        Description = "Place tons of items on these shelves.",
        Model = "models/gmod_tower/suiteshelf.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 320,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "lbookshelf",
    {
        Name = "Tall Bookcase",
        Description = "Become a thespian with all these books.",
        Model = "models/sims/gm_bookcase.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 750,
        MoveSound = "wood"
    }
)

RegisterItem(
    "suitespeaker",
    {
        Name = "Small Speakers",
        Description = "A tall speaker that makes you look richer.",
        Model = "models/gmod_tower/suitspeaker.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 27,
        StorePrice = 30,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "suitetable",
    {
        Name = "Suite Table",
        Description = "A well-crafted table for your stuff.",
        Model = "models/gmod_tower/suitetable.mdl",
        ClassName = "gmt_room_table",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 200,
        MoveSound = "furniture2"
    }
)

RegisterItem(
    "sunshrine",
    {
        Name = "Sunabouzu Shrine",
        Description = "A shrine in honor of Sunabouzu.",
        Model = "models/gmod_tower/sunshrine.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 6,
        StorePrice = 150000,
        BuyPrice = 500
    }
)

RegisterItem(
    "tablecoffe",
    {
        Name = "Coffee Table",
        Description = "Place your coffee on this nice table.",
        Model = "models/props/de_inferno/tablecoffee.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 150,
        MoveSound = "furniture2"
    }
)

RegisterItem(
    "table_shed",
    {
        Name = "Wooden Table",
        Description = "A very large durable table.",
        Model = "models/props/cs_militia/table_shed.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 95,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "toothbrushset01",
    {
        Name = "Tooth Brush Set",
        Description = "Keep your tooth brushes in one set.",
        Model = "models/props/cs_militia/toothbrushset01.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 6,
        StorePrice = 5
    }
)

RegisterItem(
    "tv",
    {
        Name = "TV",
        Description = "Watch YouTube and other videos.",
        Model = "models/gmod_tower/suitetv.mdl",
        ClassName = "gmt_room_tv",
        UniqueInventory = true,
        DrawModel = true,
        CanRemove = false,
        InvCategory = "7" -- electronics
    }
)

RegisterItem(
    "tvcabinet",
    {
        Name = "TV Cabinet",
        Description = "Organize your entertainment with this TV cabinet.",
        Model = "models/gmod_tower/gt_woodcabinet01.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 500,
        MoveSound = "furniture3"
    }
)

RegisterItem(
    "tv_large",
    {
        Name = "Bigscreen TV",
        Description = "Watch YouTube and other videos on a larger screen.",
        Model = "models/gmod_tower/suitetv_large.mdl",
        ClassName = "mediaplayer_tv",
        UniqueInventory = true,
        DrawModel = true,
        CanRemove = false,
        StoreId = 7,
        StorePrice = 3150
    }
)

RegisterItem(
    "wood_table",
    {
        Name = "Wood Table",
        Description = "A small, but durable wood table.",
        Model = "models/props/cs_militia/wood_table.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 75,
        MoveSound = "wood"
    }
)

RegisterItem(
    "theater_seat",
    {
        Name = "Traincar Seat",
        Description = "A nice seat that you'd find at a train station.",
        Model = "models/props_trainstation/traincar_seats001.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 250
    }
)

RegisterItem(
    "tseat",
    {
        Name = "Theater Seat",
        Description = "A must have for all home theater.",
        Model = "models/gmod_tower/theater_seat.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 525,
        NewItem = false
    }
)

RegisterItem(
    "picnic_table",
    {
        Name = "Picnic Table",
        Description = "Setup a picnic or host an event with this table.",
        Model = "models/gmod_tower/patio_table.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 150,
        MoveSound = "wood"
    }
)

RegisterItem(
    "sack_plushie",
    {
        Name = "Sack Plushie",
        Description = "Holiday version of everyone's favorite plushie.",
        Model = "models/gmod_tower/sackplushie.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 10,
        StorePrice = 3500,
        MoveSound = "cloth"
    }
)

RegisterItem(
    "snowman",
    {
        Name = "Snowman",
        Description = "A wonderous snowman that will bring holiday cheer.",
        Model = "models/gmod_tower/snowman.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 10,
        StorePrice = 600,
        UseSound = "use_snowman.mp3"
    }
)

RegisterItem(
    "candycane",
    {
        Name = "Candy Cane",
        Description = "Candy cane wrapped in ribbons.",
        Model = "models/gmod_tower/candycane.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 10,
        StorePrice = 80,
        UseSound = "use_candycane.wav"
    }
)

RegisterItem(
    "obamacutout",
    {
        Name = "Obama Cutout",
        Description = "Your very own Obama cutout.",
        Model = "models/gmod_tower/obamacutout.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 22,
        StorePrice = 1500,
        MoveSound = "wood"
    }
)

RegisterItem(
    "rubikscube",
    {
        Name = "Huge Rubik's Cube",
        Description = "Play with your cubes, Rubik.",
        Model = "models/gmod_tower/rubikscube.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 22,
        StorePrice = 800
    }
)

RegisterItem(
    "portaltoy",
    {
        Name = "Portal Papertoy",
        Description = "Portal, paper edition!",
        Model = "models/gmod_tower/portaltoy.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 22,
        StorePrice = 1000,
        ClassName = "gmt_portal"
    }
)

RegisterItem(
    "plazabooth",
    {
        Name = "Food Court Booth",
        Description = "The food court booth just for you!",
        Model = "models/gmod_tower/plazabooth.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 400
    }
)

RegisterItem(
    "plazaboothstore",
    {
        Name = "Food Court Table",
        Description = "Food court table, ripped right off the ground.",
        Model = "models/gmod_tower/courttable.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 150
    }
)

RegisterItem(
    "coffeetable",
    {
        Name = "Modern Coffee Table",
        Description = "A nice coffee table for your drinks.",
        Model = "models/gmod_tower/coffeetable.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 800
    }
)

RegisterItem(
    "pianostool",
    {
        Name = "Piano Stool",
        Description = "Sit on this and play your piano with style.",
        Model = "models/fishy/furniture/piano_seat.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 27,
        StorePrice = 150
    }
)
RegisterItem(
    "rave_ball",
    {
        Name = "Rave Ball",
        Description = "Get your rave on with this musical orb. Splashes colorful bursts, and unlike the disco ball, can give people seizures (use responsively).",
        Model = "models/gmod_tower/discoball.mdl",
        ClassName = "gmt_raveball",
        UniqueInventory = true,
        EnablePhyiscs = true,
        DrawModel = true,
        StoreId = 27,
        StorePrice = 30000
    }
)
RegisterItem(
    "autopiano",
    {
        Name = "Piano",
        Description = "Autoplay well known tunes with this magical piano.",
        Model = "models/fishy/furniture/piano.mdl",
        UniqueInventory = true,
        DrawModel = true,
        StoreId = 27,
        StorePrice = 8000,
        ClassName = "gmt_item_piano"
    }
)

RegisterItem(
    "drumset",
    {
        Name = "Drum Set",
        Description = "Start your own band with this working drumset!",
        Model = "models/map_detail/music_drumset.mdl",
        UniqueInventory = false,
        DrawModel = true,
        ClassName = "gmt_instrument_drums",
        NewItem = false,
        StoreId = 27,
        StorePrice = 10000
    }
)
RegisterItem(
    "woodcrate",
    {
        Name = "Wooden Crate",
        Description = "What's a Source game without crates?",
        Model = "models/props_junk/wood_crate001a.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 75,
        NewItem = false,
        MoveSound = "wood"
    }
)
RegisterItem(
    "ballarrow",
    {
        Name = "Red Arrow",
        Description = "An red arrow from Ballrace, useful to point at stuff.",
        Model = "models/gmod_tower/arrow.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 500,
        NewItem = false
    }
)
RegisterItem(
    "jerrycan",
    {
        Name = "Jerrycan",
        Description = "A jerrycan, useful to store liquids in.",
        Model = "models/props_farm/oilcan01b.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 1250,
        NewItem = false
    }
)
RegisterItem(
    "cardbox",
    {
        Name = "Cardboard Box",
        Description = "Useful for building forts!",
        Model = "models/props_junk/cardboard_box001a.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 25,
        NewItem = false,
        MoveSound = "cloth"
    }
)
RegisterItem(
    "tire",
    {
        Name = "Tire",
        Description = "For your future car.",
        Model = "models/props_2fort/tire001.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 125,
        NewItem = false,
        MoveSound = "cloth"
    }
)
RegisterItem(
    "redvalve",
    {
        Name = "Red Valve",
        Description = "You may not buy 3 valves.",
        Model = "models/props_mining/crank02.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 50,
        NewItem = false
    }
)
RegisterItem(
    "goldingot",
    {
        Name = "Pure Gold Ingot",
        Description = "The finest gold around. Show off your juicy GMC with this ingot.",
        Model = "models/props_mining/ingot001.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 100000,
        NewItem = false
    }
)
RegisterItem(
    "woodpile",
    {
        Name = "Wood Pile",
        Description = "The leftover wood that stood at the Merchant's house. Collected for your placing-pleasure!",
        Model = "models/props_forest/woodpile_indoor.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 175,
        NewItem = false
    }
)
RegisterItem(
    "mopbucket",
    {
        Name = "Mop And Bucket",
        Description = "To keep your suite extra clean.",
        Model = "models/props_2fort/mop_and_bucket.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 100,
        NewItem = false
    }
)
RegisterItem(
    "waterspigot",
    {
        Name = "Water Spigot",
        Description = "Forget your kitchen sink, and get your water out of the ground!",
        Model = "models/props_farm/water_spigot.mdl",
        ClassName = "gmt_spigot",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 275,
        NewItem = false
    }
)

RegisterItem(
    "woodgametable",
    {
        Name = "Wooden Table",
        Description = "A wooden multipurpose table.",
        Model = "models/gmod_tower/gametable.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1000,
        MoveSound = "furniture2",
        DateAdded = 1399291083
    }
)

RegisterItem(
    "ttttable",
    {
        Name = "TicTacToe Table",
        Description = "Play TicTacToe in your suite.",
        Model = "models/gmod_tower/gametable.mdl",
        ClassName = "gmt_tictactoe",
        DrawModel = true,
        StoreId = 22,
        StorePrice = 2000,
        NewItem = false,
        MoveSound = "furniture2"
    }
)

RegisterItem(
    "suitetetris",
    {
        Name = "Blockles Machine",
        Description = "Your own personal Blockles machine!",
        Model = "models/gmod_tower/gba.mdl",
        ClassName = "gmt_tetris",
        DrawModel = true
    }
)

RegisterItem(
    "modelrocket",
    {
        Name = "Model Rocket",
        Description = "One small rocket for men, one giant gap for wallet-kind.",
        Model = "models/props_spytech/rocket002_skybox.mdl",
        ClassName = "gmt_modelrocket",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 2250,
        NewItem = false
    }
)
RegisterItem(
    "weathervane",
    {
        Name = "Weather Vane",
        Description = "Tell where the north is, that is, if you place it right.",
        Model = "models/props_2fort/weathervane001.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 500,
        NewItem = false
    }
)
RegisterItem(
    "saturnplush",
    {
        Name = "Mr. Saturn",
        Description = "Am happy. Am in trouble. No, wait. Am happy.",
        Model = "models/uch/saturn.mdl",
        DrawModel = true,
        StoreId = 22,
        StorePrice = 3500,
        NewItem = false
    }
)
RegisterItem(
    "trafficcone",
    {
        Name = "Traffic Cone",
        Description = "Block of the streets- or rather, your suite with this traffic cone.",
        Model = "models/props/de_vertigo/trafficcone_clean.mdl",
        DrawModel = true,
        StoreId = 6,
        StorePrice = 50,
        NewItem = false
    }
)

RegisterItem(
    "turkeydish",
    {
        Name = "Turkey Dinner",
        Description = "Turkey dinner has never been more pixelated before.",
        Model = "models/gmod_tower/turkey.mdl",
        DrawModel = true,
        StoreId = 18,
        StorePrice = 1000
    }
)
RegisterItem(
    "hwcandybucket",
    {
        Name = "Candy Bucket",
        Description = "Trick or treat! Oh, it's already filled up!",
        Model = "models/gmod_tower/halloween_candybucket.mdl",
        DrawModel = true,
        StoreId = 19,
        StorePrice = 500,
        UseSound = "use_candy.wav"
    }
)
RegisterItem(
    "hwgravestone",
    {
        Name = "R.I.P. Tombstone",
        Description = "Remember when FPS games didn't suck?",
        Model = "models/gmod_tower/halloween_gravestone.mdl",
        DrawModel = true,
        StoreId = 19,
        StorePrice = 1800,
        UseSound = "use_ripstone.mp3"
    }
)
RegisterItem(
    "hwmincauldron",
    {
        Name = "Mini Cauldron",
        Description = "A decorative mini cauldron.",
        Model = "models/gmod_tower/halloween_minicauldron.mdl",
        DrawModel = true,
        StoreId = 19,
        StorePrice = 1000,
        UseSound = "use_cauldron.mp3"
    }
)
RegisterItem(
    "hwtoyspider",
    {
        Name = "Toy Spider",
        Description = "Love spiders? So do we!",
        Model = "models/gmod_tower/halloween_spidertoy.mdl",
        DrawModel = true,
        StoreId = 19,
        StorePrice = 800,
        UseSound = "use_spider.wav"
    }
)
RegisterItem(
    "hwhouse",
    {
        Name = "Scary House",
        Description = "Boo.",
        Model = "models/gmod_tower/halloween_scaryhouse.mdl",
        DrawModel = true,
        StoreId = 19,
        StorePrice = 1600,
        UseSound = "use_hauntedhouse.mp3"
    }
)
RegisterItem(
    "hwtraincart",
    {
        Name = "Toy Train Cart",
        Description = "A toy cart from the Haunted Mansion ride.",
        Model = "models/gmod_tower/halloween_minitraincar.mdl",
        DrawModel = true,
        StoreId = 19,
        StorePrice = 3000
    }
)
RegisterItem(
    "toysmokemachine",
    {
        Name = "Fog Machine",
        Description = "Fog up your place with this smoke machine.",
        Model = "models/gmod_tower/halloween_fogmachine.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 19,
        StorePrice = 3000,
        ClassName = "gmt_smokemachine"
    }
)

RegisterItem(
    "mikucake",
    {
        Name = "Miku's Birthday Cake",
        Description = "",
        Model = "models/gmod_tower/mikucake.mdl",
        UniqueInventory = false,
        DrawModel = true,
        Tradable = false
    }
)
RegisterItem(
    "mikucake_slice",
    {
        Name = "Miku's Birthday Cake (slice)",
        Description = "",
        Model = "models/gmod_tower/mikucake_slice.mdl",
        UniqueInventory = false,
        DrawModel = true
    }
)
RegisterItem(
    "typewriter",
    {
        Name = "Typewriter",
        Description = "The incessant clacking is enough to drive any man insane. That's why I became a private eye.",
        Model = "models/sunabouzu/typewriter.mdl",
        DrawModel = true,
        StoreId = 7,
        StorePrice = 1500,
        UseSound = "use_typewriter.wav"
    }
)
RegisterItem(
    "bigspeaker",
    {
        Name = "Big Speaker",
        Description = "Increase the effectiveness of your sound system tenfold.",
        Model = "models/sunabouzu/speaker.mdl",
        DrawModel = true,
        StoreId = 27,
        StorePrice = 1000
    }
)
RegisterItem(
    "desklamp",
    {
        Name = "Desk Lamp",
        Description = "Perfect for reading a book, or for interrogating a suspect.",
        Model = "models/gmod_tower/lamp01.mdl",
        DrawModel = true,
        StoreId = 7,
        StorePrice = 600,
        MoveSound = "furniture2"
    }
)
RegisterItem(
    "oldphone",
    {
        Name = "Old Phone",
        Description = "Stuck in the past? Prove it with this ancient phone.",
        Model = "models/sunabouzu/old_phone.mdl",
        DrawModel = true,
        StoreId = 7,
        StorePrice = 400,
        UseSound = "use_oldphone.wav",
        MoveSound = "furniture"
    }
)

RegisterItem(
    "grain",
    {
        Name = "Grain Sack",
        Description = "A sack full of grain.",
        Model = "models/props_granary/grain_sack.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 500,
        NewItem = false,
        MoveSound = "cloth"
    }
)
RegisterItem(
    "bushsmall",
    {
        Name = "Small Bush",
        Description = "A small bush to decorate your garden with, or home!",
        Model = "models/garden/gardenbush2.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 250,
        NewItem = false
    }
)
RegisterItem(
    "bushbig",
    {
        Name = "Big Bush",
        Description = "A bigger version of that other bush, for even better gardens.",
        Model = "models/garden/gardenbush.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 350,
        NewItem = false
    }
)
RegisterItem(
    "bushred",
    {
        Name = "Small Red Bush",
        Description = "A red bush to put in your garden.",
        Model = "models/gmod_tower/plant/largebush01.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 150,
        NewItem = false
    }
)
RegisterItem(
    "ferns",
    {
        Name = "Ferns",
        Description = "Nice ferns for in your garden.",
        Model = "models/hessi/palme.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 175,
        NewItem = false
    }
)
RegisterItem(
    "wildbush",
    {
        Name = "Wild Bush",
        Description = "Collected from Narnia, this wild bush will sure make your garden look interesting.",
        Model = "models/props/de_inferno/largebush02.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 175,
        NewItem = false
    }
)
RegisterItem(
    "lavenderbush",
    {
        Name = "Lavender Bush",
        Description = "A nice lavender bush. Will surely make your suite smell great!",
        Model = "models/props/de_inferno/largebush03.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 200,
        NewItem = false
    }
)

RegisterItem(
    "rosebush",
    {
        Name = "Rose Bush",
        Description = "Nice red roses packed in a bush.",
        Model = "models/props/de_inferno/largebush04.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 210,
        NewItem = false
    }
)
RegisterItem(
    "hydrabush",
    {
        Name = "Big Hydrangea Bush",
        Description = "A big hydrangea bush.",
        Model = "models/props/de_inferno/largebush05.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 375,
        NewItem = false
    }
)
RegisterItem(
    "fallentree",
    {
        Name = "Fallen Tree Trunk",
        Description = "A fallen over tree trunk.",
        Model = "models/props_foliage/fallentree01.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 750,
        NewItem = false
    }
)
RegisterItem(
    "treestump",
    {
        Name = "Tree Stump",
        Description = "This was once a tree...",
        Model = "models/props_foliage/tree_stump01.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 375,
        NewItem = false
    }
)
RegisterItem(
    "bigrock",
    {
        Name = "Big Rock",
        Description = "A big rock to place in your garden.",
        Model = "models/props_nature/rock_worn001.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 250,
        NewItem = false
    }
)
RegisterItem(
    "rockpile",
    {
        Name = "Rock Pile",
        Description = "A pile of rocks, nice to decorate your garden with.",
        Model = "models/props_nature/rock_worn_cluster002.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 175,
        NewItem = false
    }
)
RegisterItem(
    "ggnome",
    {
        Name = "Garden Gnome",
        Description = "A gnome that the bird made on his own, hence the price!",
        Model = "models/props_junk/gnome.mdl",
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1000,
        NewItem = false
    }
)

RegisterItem(
    "leatherarmchair",
    {
        Name = "Leather Armchair",
        Description = "No* cows were harmed in the making of this chair. *Lots of",
        Model = "models/props_vtmb/armchair.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 700,
        MoveSound = "furniture2"
    }
)

RegisterItem(
    "leathersofa",
    {
        Name = "Leather Sofa",
        Description = "Triple the Leather Armchair fun! Wow!",
        Model = "models/props_vtmb/sofa.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1700,
        MoveSound = "furniture3"
    }
)

RegisterItem(
    "chairfancyhotel",
    {
        Name = "Hotel Chair",
        Description = "We stole this chair from a hotel just for you. Don't tell anybody.",
        Model = "models/props_vtmb/chairfancyhotel.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1100,
        MoveSound = "furniture"
    }
)

RegisterItem(
    "brownarmchair",
    {
        Name = "Brown Armchair",
        Description = "Only has one cushion, and it makes a really awful cushion fort.",
        Model = "models/splayn/rp/lr/chair.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 800,
        MoveSound = "furniture2"
    }
)

RegisterItem(
    "brownsofa",
    {
        Name = "Brown Sofa",
        Description = "Comes with three cushions, for a fort that's way better than the Brown Armchair one.",
        Model = "models/splayn/rp/lr/couch.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 2000,
        MoveSound = "furniture3"
    }
)

RegisterItem(
    "moderncouchpt",
    {
        Name = "Modern Couch",
        Description = "Made from the finest yak hair and goose down, you'd think this would be comfortable. Unfortunately, the inside is yak hair and the outside is goose down. Also, it's modern.",
        Model = "models/pt/lobby/pt_couch.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 1,
        StorePrice = 1400,
        MoveSound = "furniture3"
    }
)

RegisterItem(
    "btoilet",
    {
        Name = "Toilet",
        Description = "A toilet with comfort in mind.",
        Model = "models/props_c17/furnituretoilet001a.mdl",
        DrawModel = true,
        StoreId = 21,
        StorePrice = 75,
        UseSound = "use_toilet.wav"
    }
)
RegisterItem(
    "haybale",
    {
        Name = "Hay Bale",
        Description = "A special hay bale that you can't buy!",
        Model = "models/props_gameplay/haybale.mdl",
        DrawModel = true,
        MoveSound = "cloth"
    }
)

-- Duel items
RegisterItem(
    "DuelMain",
    {
        Name = "Duel - Magnums",
        Description = "Duel a single player on the server for GMC or for fun. One time use.",
        Model = "models/weapons/w_357.mdl",
        UniqueInventory = false,
        DrawModel = true,
        Equippable = false,
        CanEntCreate = false,
        CanRemove = true,
        DrawName = true,
        --Tradable = true,
        --InvCategory = "duel",

        StoreId = 24,
        StorePrice = 150,
        WeaponClass = "weapon_357",
        WeaponName = "Magnums",
        ExtraMenuItems = function(item, menu, slot)
            table.insert(
                menu,
                {
                    ["Name"] = "Duel A Player",
                    ["function"] = function()
                        Derma_DuelRequest(
                            item.Name,
                            "Select the player you want to duel and the max bet amount.",
                            0,
                            function(ply, amount)
                                if IsValid(ply) then
                                    RunConsoleCommand(
                                        "gmt_duelinvite",
                                        LocalPlayer():EntIndex(),
                                        ply:EntIndex(),
                                        item.WeaponClass,
                                        amount,
                                        item.WeaponName,
                                        item.MysqlId
                                    )
                                end
                            end,
                            nil,
                            "INVITE TO DUEL",
                            "CANCEL"
                        )
                    end
                }
            )
        end
    }
)

RegisterItem(
    "DuelSword",
    {
        Base = "DuelMain",
        Name = "Duel - Swords",
        Model = "models/weapons/w_pvp_swd.mdl",
        StorePrice = 180,
        WeaponClass = "weapon_sword",
        WeaponName = "Swords"
    }
)

RegisterItem(
    "DuelShotgun",
    {
        Base = "DuelMain",
        Name = "Duel - Shotguns",
        Model = "models/weapons/w_shotspas12z.mdl",
        StorePrice = 180,
        WeaponClass = "weapon_spas12",
        WeaponName = "Shotguns"
    }
)

RegisterItem(
    "DuelDouble",
    {
        Base = "DuelMain",
        Name = "Duel - Double Barrel Shotguns",
        Model = "models/weapons/w_vir_doubleb.mdl",
        StorePrice = 180,
        WeaponClass = "weapon_doublebarrel",
        WeaponName = "Double Barrel Shotguns"
    }
)

RegisterItem(
    "DuelFlak",
    {
        Base = "DuelMain",
        Name = "Duel - Flak Hand Cannon",
        Model = "models/weapons/w_vir_flakhg.mdl",
        StorePrice = 100,
        WeaponClass = "weapon_flakhandgun",
        WeaponName = "Flak Hand Cannon"
    }
)

RegisterItem(
    "DuelSci",
    {
        Base = "DuelMain",
        Name = "Duel - Sci-Fi Handgun",
        Model = "models/weapons/w_vir_scifihg.mdl",
        StorePrice = 125,
        WeaponClass = "weapon_scifihandgun",
        WeaponName = "Sci-Fi Handgun"
    }
)
--[[ bokre
RegisterItem( "DuelSnowball", {
	Base = "DuelMain",
	Name = "Duel - Snowballs",
	Model = "models/weapons/w_snowball.mdl",
	StorePrice = 250,
	WeaponClass = "weapon_snowball",
	WeaponName = "Snowballs",
} )
--]]
RegisterItem(
    "Duel9mm",
    {
        Base = "DuelMain",
        Name = "Duel - 9MM Pistol",
        Model = "models/weapons/w_vir_9mm1.mdl",
        StorePrice = 175,
        WeaponClass = "weapon_9mm",
        WeaponName = "9MM Pistol"
    }
)

RegisterItem(
    "DuelAkimbo",
    {
        Base = "DuelMain",
        Name = "Duel - Akimbos",
        Model = "models/weapons/w_pvp_akimbo.mdl",
        StorePrice = 180,
        WeaponClass = "weapon_akimbo",
        WeaponName = "Akimbo"
    }
)

RegisterItem(
    "DuelRPG",
    {
        Base = "DuelMain",
        Name = "Duel - Rockets",
        Model = "models/weapons/w_rocket_launcher.mdl",
        StorePrice = 250,
        WeaponClass = "weapon_rpg",
        WeaponName = "RPGs"
    }
)

RegisterItem(
    "DuelSMG",
    {
        Base = "DuelMain",
        Name = "Duel - Sub-Machine Guns",
        Model = "models/weapons/w_smg1.mdl",
        StorePrice = 150,
        WeaponClass = "weapon_smg1",
        WeaponName = "SMGs"
    }
)

RegisterItem(
    "DuelFists",
    {
        Base = "DuelMain",
        Name = "Duel - Fists",
        Model = "models/weapons/w_pvp_ire.mdl",
        StorePrice = 180,
        WeaponClass = "weapon_rage",
        WeaponName = "Fists"
    }
)

RegisterItem(
    "DuelSniper",
    {
        Base = "DuelMain",
        Name = "Duel - Snipers",
        Model = "models/weapons/w_pvp_as50.mdl",
        StorePrice = 200,
        WeaponClass = "weapon_sniper",
        WeaponName = "Snipers"
    }
)

RegisterItem(
    "DuelChainsaw",
    {
        Base = "DuelMain",
        Name = "Duel - Chainsaws",
        Model = "models/weapons/w_pvp_chainsaw.mdl",
        StorePrice = 200,
        WeaponClass = "weapon_chainsaw",
        WeaponName = "Chainsaws"
    }
)

RegisterItem(
    "DuelNES",
    {
        Base = "DuelMain",
        Name = "Duel - NES Zapper",
        Model = "models/weapons/w_pvp_neslg.mdl",
        StorePrice = 250,
        WeaponClass = "weapon_neszapper",
        WeaponName = "NES Zapper"
    }
)

RegisterItem(
    "DuelXM8",
    {
        Base = "DuelMain",
        Name = "Duel - XM8",
        Model = "models/weapons/w_pvp_xm8.mdl",
        StorePrice = 250,
        WeaponClass = "weapon_xm8",
        WeaponName = "XM8"
    }
)

RegisterItem(
    "DuelM1Garand",
    {
        Base = "DuelMain",
        Name = "Duel - M1 Garand",
        Model = "models/weapons/w_pvp_m1.mdl",
        StorePrice = 200,
        WeaponClass = "weapon_m1grand",
        WeaponName = "M1 Garand"
    }
)

RegisterItem(
    "DuelRagingBull",
    {
        Base = "DuelMain",
        Name = "Duel - Raging Bull",
        Model = "models/weapons/w_pvp_ragingb.mdl",
        StorePrice = 250,
        WeaponClass = "weapon_ragingbull",
        WeaponName = "Raging Bull"
    }
)

RegisterItem(
    "DuelCrossbow",
    {
        Base = "DuelMain",
        Name = "Duel - Crossbow",
        Model = "models/weapons/w_crossbow.mdl",
        StorePrice = 200,
        WeaponClass = "weapon_crossbow",
        WeaponName = "Crossbow"
    }
)

RegisterItem(
    "Duel357",
    {
        Base = "DuelMain",
        Name = "Duel - .357",
        Model = "models/weapons/w_357.mdl",
        StorePrice = 200,
        WeaponClass = "weapon_357",
        WeaponName = ".357"
    }
)

RegisterItem(
    "stocking",
    {
        Name = "Stocking",
        Description = "A decorative stocking for all your small gifts.",
        Model = "models/wilderness/stocking.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 10,
        StorePrice = 125
    }
)

for i = 0, 8 do
    RegisterItem(
        "presenta" .. i,
        {
            Name = "Big Present #" .. (i + 1),
            Description = "A decorative large present to put under your christmas tree.",
            Model = "models/wilderness/presenta.mdl",
            UniqueInventory = false,
            DrawModel = true,
            StoreId = 10,
            ModelSkinId = i,
            StorePrice = 180
        }
    )
end

for i = 0, 7 do
    RegisterItem(
        "present2b" .. i,
        {
            Name = "Present #" .. (i + 1),
            Description = "A decorative present to put under your christmas tree.",
            Model = "models/wilderness/presentb.mdl",
            UniqueInventory = false,
            DrawModel = true,
            StoreId = 10,
            ModelSkinId = i,
            StorePrice = 80
        }
    )
end

RegisterItem(
    "christmastree",
    {
        Name = "Christmas Tree w/ Lights and Train",
        Description = "A celebrative christmas tree with its own train set and lights!",
        Model = "models/wilderness/hanukkahtree.mdl",
        ClassName = "gmt_christmas_tree",
        UniqueInventory = true,
        DrawModel = true,
        CanRemove = true,
        StoreId = 10,
        StorePrice = 10000
    }
)

RegisterItem(
    "christmastreesimple",
    {
        Name = "Christmas Tree",
        Description = "A celebrative christmas tree!",
        Model = "models/wilderness/hanukkahtree.mdl",
        ClassName = "gmt_christmas_tree_simple",
        UniqueInventory = true,
        DrawModel = true,
        CanRemove = true,
        StoreId = 10,
        StorePrice = 3000
    }
)

RegisterItem(
    "ppiece",
    {
        Name = "Puzzle Piece",
        Description = "These pieces.. THEY JUST WONT FIT!",
        Model = "models/gmod_tower/puzzlepiece1.mdl",
        UniqueInventory = false,
        DrawModel = true,
        StoreId = 6,
        StorePrice = 75
    }
)
--gmtc items

RegisterItem(
    "rustedbike",
    {
        Name = "Rusted Bycicle",
        Description = "Wheels don't turn anymore btw.",
        Model = "models/props_junk/bicycle01a.mdl",
        DrawModel = true,
        StoreId = 28,
        StorePrice = 80,
        NewItem = false
    }
)

RegisterItem(
    "woodshardpiece",
    {
        Name = "Wooden Shard",
        Description = "Someone threw this at me.",
        Model = "models/Gibs/wood_gib01b.mdl",
        DrawModel = true,
        StoreId = 28,
        StorePrice = 5,
        NewItem = false
    }
)

RegisterItem(
    "metalwrench",
    {
        Name = "Wrench",
        Description = "Nice lil' tool to fix your... tools with?",
        Model = "models/props_c17/tools_wrench01a.mdl",
        DrawModel = true,
        StoreId = 28,
        StorePrice = 35,
        NewItem = false
    }
)

RegisterItem(
    "apologyletter",
    {
        Name = "Apology Letter",
        Description = "You'll never get this out of me.",
        Model = "models/props_c17/paper01.mdl",
        DrawModel = true,
        StoreId = 28,
        StorePrice = 100000000,
        NewItem = false
    }
)
