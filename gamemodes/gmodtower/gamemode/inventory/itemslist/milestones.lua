
module( "GTowerItems", package.seeall )


GTowerItems.RegisterItem( "VirusFlame", {
	Name = "Virus Flame",
	Description = "Ignite yourself with the flame of the infected!",
	Model = "models/player/virusi.mdl",
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "VirusFlame",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	CreateEquipEntity = function( self )

		local VirusFlame = ents.Create( "gmt_virusflame" )

		if IsValid( VirusFlame ) then
			VirusFlame:SetOwner( self.Ply )
			VirusFlame:SetParent( self.Ply )
			VirusFlame:Spawn()
			VirusFlame:SetupFlame( self.Ply )
			self.Ply:EmitSound( "ambient/fire/ignite.wav", 30, math.random( 170, 200 ) )
		end

		return VirusFlame

	end
} )

GTowerItems.RegisterItem( "VirusRadar", {
	Name = "Radar",
	Description = "Equip this to activate the radar display.",
	Model = "",
	UniqueInventory = true,
	DrawModel = false,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "HUD",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,
	OnEquip = function( self, locationchange )
		--if ClientSettings and not locationchange then
			self.Ply:SetNWBool("VirusRadar",true)
		--end
	end,
	OnUnEquip = function( self )
		--if ClientSettings then
			self.Ply:SetNWBool("VirusRadar",false)
		--end
	end
} )

GTowerItems.RegisterItem( "BallRaceBall", {
	Name = "Ball Race Orb",
	Description = "Step into the ball and get rolling.",
	Model = "models/gmod_tower/ball.mdl",
	MoveSound = Sound( "GModTower/balls/BallRoll.wav" ),
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "BallRaceBall",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	RemoveOnNarnia = true,
	OnlyEquippable = true,
	CreateEquipEntity = function( self )

		local BallRaceBall = ents.Create( "gmt_ballrace" )

		if IsValid( BallRaceBall ) then
			BallRaceBall:SetOwner( self.Ply )
			BallRaceBall:SetPos( self.Ply:GetPos() + Vector( 0, 0, 48 ) )
			BallRaceBall:Spawn()
			self.Ply:EmitSound( "GModTower/balls/TubePop.wav", 30, math.random( 170, 200 ) )
		end

		return BallRaceBall

	end
} )

GTowerItems.RegisterItem( "GolfBall", {
	Name = "Golf Ball",
	Description = "Ever wanted to just play golf on the go?",
	Model = "models/sunabouzu/golf_ball.mdl",
	MoveSound = Sound( "GModTower/minigolf/effects/hit.wav" ),
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "BallRaceBall",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	RemoveOnNarnia = true,
	OnlyEquippable = true,
	CreateEquipEntity = function( self )

		local BallRaceBall = ents.Create( "gmt_golfball" )

		if IsValid( BallRaceBall ) then
			BallRaceBall:SetOwner( self.Ply )
			BallRaceBall:SetPos( self.Ply:GetPos() + Vector( 0, 0, 48 ) )
			BallRaceBall:Spawn()
		end

		return BallRaceBall

	end
} )

GTowerItems.RegisterItem( "VirusAdrenaline", {
	Name = "Adrenaline",
	Description = "Stab this into your boss's wife to prevent her from dying of drug overdose.",
	Model = "models/weapons/w_vir_adrenaline.mdl",
	MoveSound = Sound( "GModTower/virus/weapons/Adrenaline/deploy.wav" ),
	ClassName = "gmt_adrenaline",
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	EquipType = "Weapon",
	Equippable = true,
	WeaponSafe = true,
	NoBank = true,
	Tradable = false,
	IsWeapon = function( self )
		return true
	end
} )

GTowerItems.RegisterItem( "TakeOnBall", {
	Name = "Take On Me",
	Description = "Increase your speed and become '80s pop!",
	Model = "models/gmod_tower/takeonball.mdl",
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "TakeOnBall",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	CanUse = true,
	Tradable = false,
	UseDesc = "Toggle Material",

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	RemoveOnNarnia = true,
	OverrideOnlyEquippable = true,
	CreateEquipEntity = function( self )

		local TakeOn = ents.Create( "gmt_takeonme" )

		if IsValid( TakeOn ) then
			TakeOn:SetOwner( self.Ply )
			TakeOn:SetParent( self.Ply )
			TakeOn:Spawn()
			TakeOn:SetTakeOn( self.Ply )
			self.Ply:EmitSound( "GModTower/balls/TubePop.wav", 30, math.random( 170, 200 ) )
		end

		return TakeOn

	end,
	OnUse = function( self )
		if IsValid( self.Ply ) && self.Ply:IsPlayer() && IsValid( self.Ply.TakeOn ) then
			self.Ply.TakeOn:ToggleMaterial()
		end

		return self
	end
} )


GTowerItems.RegisterItem( "StealthBox", {
	Name = "Stealth Box",
	Description = "Sneak around the lobby.",
	Model = "models/gmod_tower/stealth box/box.mdl",
	MoveSound = Sound( "physics/cardboard/cardboard_box_break3.wav" ),
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "StealthBox",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,

	EquippableEntity = true,
	RemoveOnDeath = true,
	RemoveOnTheater = true,
	CreateEquipEntity = function( self )

		local StealthBox = ents.Create( "gmt_stealthbox" )

		if IsValid( StealthBox ) then
			StealthBox:SetOwner( self.Ply )
			StealthBox:SetParent( self.Ply )
			StealthBox:Spawn()
			StealthBox:SetBoxHolder( self.Ply )

			self.Ply:EmitSound( "physics/cardboard/cardboard_box_break1.wav", 30, math.random( 170, 200 ) )
		end

		return StealthBox

	end
} )

GTowerItems.RegisterItem( "Bumper", {
	Name = "Bumper",
	Description = "Place a bumper from Ball Race anywhere you'd like.",
	Model = "models/gmod_tower/bumper.mdl",
	MoveSound = Sound( "GModTower/balls/bumper.wav" ),
	ClassName = "gmt_bumper",
	UniqueInventory = true,
	DrawModel = true,
	CanEntCreate = true,
	DrawName = true,
	CanRemove = false,
	BankAdminOnly = true,
	Tradable = false,
} )

GTowerItems.RegisterItem( "UCHGhost", {
	Name = "Ghost",
	Description = "You could have been the life of the party, if you weren't already dead.",
	Model = "models/UCH/mghost.mdl",
	MoveSound = Sound( "UCH/pigs/die.wav" ),
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "Model",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,
	OnEquip = function( self )
		if UCHAnim && SERVER then
			UCHAnim.SetupPlayer( self.Ply, UCHAnim.TYPE_GHOST )
		end
	end,
	OnUnEquip = function( self )
		if UCHAnim && SERVER then
			UCHAnim.ClearPlayer( self.Ply )
		end
	end
} )

GTowerItems.RegisterItem( "UCHPig", {
	Name = "Pigmask",
	Description = "Suiciding does not cause a Bag of Pork Chops to drop.",
	Model = "models/UCH/pigmask.mdl",
	MoveSound = Sound( "UCH/pigs/snort1.wav" ),
	UniqueInventory = true,
	DrawModel = true,
	Equippable = true,
	UniqueEquippable = true,
	EquipType = "Model",
	CanEntCreate = false,
	DrawName = true,
	CanRemove = false,
	NoBank = true,
	Tradable = false,
	OnEquip = function( self )
		if UCHAnim && SERVER then
			UCHAnim.SetupPlayer( self.Ply, UCHAnim.TYPE_PIG )
		end
	end,
	OnUnEquip = function( self )
		if UCHAnim && SERVER then
			UCHAnim.ClearPlayer( self.Ply )
		end
	end
} )
