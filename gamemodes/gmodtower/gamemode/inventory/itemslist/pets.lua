
module( "GTowerItems", package.seeall )


GTowerItems.RegisterItem( "MelonPet", {

	Name = "Melon Pet",
	Description = "A joyful melon pet!",

	Model = "models/props_junk/watermelon01.mdl",

	DrawModel = true,
	Equippable = true,

	UniqueInventory = false,
	UniqueEquippable = false,

	EquipType = "Pet",

	CanEntCreate = false,
	DrawName = true,
	CanRemove = true,
	Tradable = true,

	StoreId = 26,
	StorePrice = 15000,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,

	ExtraMenuItems = function (item, menu)
		table.insert(menu, {
			["Name"] = "Give Name",
			["function"] = function()
				local curText = LocalPlayer():GetInfo("gmt_petname") or ""
				
				Derma_StringRequest(
					"Pet Name",
					"Please enter the name of your cute pet!",
					curText,
					function (text) RunConsoleCommand("gmt_petname",text) end
				)
			end
		})
	end,

	CreateEquipEntity = function( self )

		local pet = ents.Create( "gmt_pet" )

		if IsValid( pet ) then

			self.Ply.Pet = pet

			pet:Teleport( self.Ply )
			pet:SetOwner( self.Ply )
			pet:Spawn()

		end

		return pet

	end
} )

GTowerItems.RegisterItem( "RubikPet", {

	Name = "Rubik Pet",
	Description = "Solve me...",

	Model = "models/gmod_tower/rubikscube.mdl",

	DrawModel = true,
	Equippable = true,

	UniqueInventory = false,
	UniqueEquippable = false,

	EquipType = "Pet",

	CanEntCreate = false,
	DrawName = true,
	CanRemove = true,
	Tradable = true,

	StoreId = 26,
	StorePrice = 12000,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	ExtraMenuItems = function (item, menu)
		table.insert(menu, {
			["Name"] = "Give Name",
			["function"] = function()
				local curText = LocalPlayer():GetInfo("gmt_petname_cube") or ""
				
				Derma_StringRequest(
					"Pet Name",
					"Please enter the name of your cute pet!",
					curText,
					function (text) RunConsoleCommand("gmt_petname_cube",text) end
				)
			end
		})
	end,
	CreateEquipEntity = function( self )

		local pet = ents.Create( "gmt_pet_rubiks" )

		if IsValid( pet ) then

			self.Ply.Pet = pet

			pet:Teleport( self.Ply )
			pet:SetOwner( self.Ply )
			pet:Spawn()

		end

		return pet

	end
} )

GTowerItems.RegisterItem( "BcornPet", {

	Name = "Balloonicorn Pet",
	Description = "Oh my goodness! Is it Balloonicorn? The Mayor of Pyroland? Don't be ridiculous, we're talking about an inflatable unicorn. He's the Municipal Ombudsman.",

	Model = "models/player/items/all_class/pet_balloonicorn.mdl",

	DrawModel = true,
	Equippable = true,

	UniqueInventory = false,
	UniqueEquippable = false,

	EquipType = "Pet",

	CanEntCreate = false,
	DrawName = true,
	CanRemove = true,
	Tradable = true,

	StoreId = 26,
	StorePrice = 22000,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	ExtraMenuItems = function (item, menu)
		table.insert(menu, {
			["Name"] = "Give Name",
			["function"] = function()
				local curText = LocalPlayer():GetInfo("gmt_petname_bcorn") or ""
				
				Derma_StringRequest(
					"Pet Name",
					"Please enter the name of your cute pet!",
					curText,
					function (text) RunConsoleCommand("gmt_petname_bcorn",text) end
				)
			end
		})
	end,
	CreateEquipEntity = function( self )

		local pet = ents.Create( "gmt_pet_balloonicorn" )

		if IsValid( pet ) then
			pet:SetOwner( self.Ply )
			pet:SetParent( self.Ply )
			pet:Spawn()
		end

		return pet

	end
} )

--[[GTowerItems.RegisterItem( "TurtlePet", {

	Name = "Turtle Pet",
	Description = "Bringing out the shell. Also not a soup.",

	--Model = "models/props/de_tides/vending_turtle.mdl",
	Model = "models/gmod_tower/plush_turtle.mdl",
	
	DrawModel = true,
	Equippable = true,

	UniqueInventory = false,
	UniqueEquippable = false,

	EquipType = "Pet",

	CanEntCreate = false,
	DrawName = true,
	CanRemove = true,
	Tradable = true,

	StoreId = 26,
	StorePrice = 20000,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	ExtraMenuItems = function (item, menu)
		table.insert(menu, {
			["Name"] = "Give Name",
			["function"] = function()
				local curText = LocalPlayer():GetInfo("gmt_petname") or ""
				
				Derma_StringRequest(
					"Pet Name",
					"Please enter the name of your cute pet!",
					curText,
					function (text) RunConsoleCommand("gmt_petname_turtle",text) end
				)
			end
		})
	end,
	CreateEquipEntity = function( self )

		local pet = ents.Create( "gmt_pet_turtle" )

		if IsValid( pet ) then
			pet:SetOwner( self.Ply )
			pet:SetParent( self.Ply )
			pet:Spawn()
		end

		return pet

	end
} )]]

GTowerItems.RegisterItem( "ParticleSystemVIP", {
	Name = "Particle: Beauty Cone",
	Description = "Shiny.",
	//Model = "models/gmod_tower/particleball.mdl",
	Model = "models/weapons/w_pvp_ire.mdl",
	DrawModel = false,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "Particle",
	CanEntCreate = false,
	DrawName = true,

	StoreId = 29,
	StorePrice = 30000,

	Tradable = false,
	UniqueInventory = true,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnNoEntsLoc = true,
	RemoveOnTheater = true,
	OverrideOnlyEquippable = true,
	CreateEquipEntity = function( self )

		local particle = ents.Create( "gmt_wearable_particle_base" )

		if IsValid( particle ) then
			particle:SetOwner( self.Ply )
			particle:SetParent( self.Ply )
			particle:Spawn()
		end

		return particle

	end
} )