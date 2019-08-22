
local meta = FindMetaTable("Player")

function meta:IsRabbit()
	local Model = self:GetModel()
	return Model == "models/player/redrabbit2.mdl" || Model == "models/player/redrabbit3.mdl"
end

function meta:IsDigi()
	local model = self:GetModel()
	return model == "models/player/digi.mdl"
end

RabbitItems = {}

hook.Add("LoadInventory","LoadRabbitItems", function()

	local SkinNames = {
		[1] = "Blue Rabbit",
		[2] = "Purple Rabbit",
		[3] = "Orange Rabbit",
		[4] = "Pink Rabbit",
		[5] = "Dark Red Rabbit",
		[6] = "Old Buhyena Rabbit",
		[7] = {"Minion Buhyena Rabbit", nil, "Skin by -DiGi-"},
		[8] = {"White Rabbit",1200},
		[9] = "Bee Rabbit",
		[10] = {"Army Rabbit",650},
		[11] = {"Undead Rabbit",900},
		[12] = "Spider Rabbit",
		[13] = {"Soldier Rabbit",700},
		[14] = {"Gordon Rabbit",1500},
		[15] = {"Lucario Rabbit", nil, "Skin by Nican, dedicated to Yusage/FoxMan."},
		[16] = {"Zombie Rabbit",950},
		[17] = "Lava Rabbit",
		[18] = {"Warning Rabbit", nil, "Skin by Nican."},
		[19] = {"Cube Rabbit", 1000, "Skin by Nican."},
		[20] = {"Joker Rabbit",1200},
		[21] = "Transparent Rabbit",
		[22] = {"Bugs Rabbit",950},
		[23] = {"Ichigo Rabbit",1000},
		[24] = {"Pikachu Rabbit",1500},
		[25] = {"Jazz Rabbit",1250},
		[26] = {"Bunny Rabbit",1200},
		[27] = {"Boota Rabbit",1000, "Skin by Nican. Row Row Fight the Power!"},
		[28] = {"Midna Rabbit",700},
		[29] = {"Ice Rabbit",900},
		[30] = "Tuxedo Rabbit"
	}
	local NewSkinNames = {
		[1] = {"Mickey Rabbit",800, "Skin by Andy^integrity."},
		[2] = {"Santa Rabbit",800, "Ho ho here comes Santa. Skin by Firm."},
		[3] = {"Dr. Manhattan Rabbit", 1000, "Skin by Firm."},
		[4] = {"Batman Rabbit", 1000},
		[5] = "Vampire Rabbit",
		[6] = {"Spock Rabbit",1100},
		[7] = {"Felinae Rabbit", 900, "Skin by Suicide Cupcakes."},
		[8] = {"Avatar Rabbit",1500, "Skin by Cute Coon :3"},
		[9] = {"Louis Rabbit",900, "PEELZ WHERE. Skin by Zargero."},
		[10] = {"Raving Rabbit",1000, "Go home. Skin by Zargero."},
		[11] = {"Cat Rabbit", nil, "Skin by Cat."},
		[12] = {"CandyCane Rabbit", 900, "Skin by Suicide Cupcakes."},
		[13] = {"Tribe Rabbit", 1200, "They are civilized."},
		[14] = {"Wolverine Rabbit", 1000, "Skin by Wolverine and Davey-G"},
		[15] = {"Buhyena Pup Rabbit",1250, "Skin by -DiGi-"},
		[16] = {"GBuhyena Rabbit",1250, "Skin by -DiGi-"},
		[17] = {"Jerry Rabbit", 1350, "Skin by Captain Quirk."},
		[18] = {"Tom Rabbit", 1350, "Skin by Captain Quirk."},
		[19] = {"Hazard Rabbit", nil, "Skin by arleitiss2."},
		[20] = {"Renamon Rabbit", nil, "Blake: \"Only for the real furry.\" Skin by Sapphire Dragon."},
		[21] = {"Flash Rabbit", nil, "Skin by  ningaglio."},
		[22] = {"Hunter Rabbit", nil, "Skin by Andy."},
		[23] = {"Sack Rabbit", 1500, "Skin by AlexGhost."},
		[24] = {"Mr Burns Rabbit", 1500, "Skin by Zexion-91."},
		[25] = {"Cheshire Rabbit", 1400, "Skin by CrimsonFloyd."},
		[26] = {"Ratchet Rabbit", 1400, "Skin by CrimsonFloyd."},
		[27] = {"Gir Rabbit", 1400, "Skin by CrimsonFloyd."},
		[28] = {"PVP Rabbit", 1800, "Skin by Hells High."},
		[29] = {"Pyro Rabbit", 1400, "Skin by CrimsonFloyd."},
		[30] = {"Robot Rabbit", nil},
	}

	local ITEM = {}
	//ITEM.Description = "Use it to become it."
	ITEM.Model = "models/player/redrabbit2.mdl"
	ITEM.DrawModel = true
	ITEM.ModelUseSize = 0.55
	ITEM.ModelItem = true
	ITEM.ModelName = "redrabbit"
	--ITEM.InvCategory = "model"

	local function RegisterItem( i, item, startid )

		local NEWITEM = {}

		for k, v in pairs( ITEM ) do
			NEWITEM[ k ] = v
		end

		NEWITEM.ModelSkinId = i

		if type( item ) == "table" then
			NEWITEM.Name = item[1]

			if item[2] then
				NEWITEM.StoreId = 9
				NEWITEM.StorePrice = item[2]
			end

			NEWITEM.Description = item[3] or "Use it to become it."

		else
			NEWITEM.Name = item
			NEWITEM.Description = "Use it to become it."
		end

		local Name = "rabbitskin" .. string.char(i+startid)

		GTowerItems.RegisterItem( Name, NEWITEM )
		table.insert( RabbitItems, GTowerItems:Get( ITEMS[ Name ] ) )

	end


	for i, v in ipairs( SkinNames ) do
		RegisterItem( i, v, 100 )
	end

	ITEM.Model = "models/player/redrabbit3.mdl"
	ITEM.ModelName = "redrabbit2"

	for i, v in ipairs( NewSkinNames ) do
		RegisterItem( i, v, 150 )
	end

	GTowerItems.RegisterItem( "RabbitTesla", {
		Name = "Rabbit Tesla",
		Description = "Makes your ears have electricity!",
		Model = "",
		UniqueInventory = false,
		DrawModel = false,
		Equippable = true,
		EquipType = "TelsaEars",
		CanEntCreate = false,
		DrawName = true,
		StoreId = 9,
		StorePrice = 2500,
		OverrideOnlyEquippable = true,

		EquippableEntity = true,
		RemoveOnTheater = true,
		CreateEquipEntity = function( self )

			local RabbitShock = ents.Create( "rabbit_tesla" )

			if IsValid( RabbitShock ) then
				RabbitShock:SetRabbit( self.Ply )
				RabbitShock:Spawn()
			end

			return RabbitShock

		end

	} )

	GTowerItems.RegisterItem( "RabbitTeslaCapacitor", {
		Name = "Rabbit Tesla Capacitor",
		Description = "For cool light shows!",
		Model = "",
		UniqueInventory = false,
		DrawModel = false,
		Equippable = true,
		EquipType = "TelsaEars",
		CanEntCreate = false,
		DrawName = true,
		BankAdminOnly = true,

		EquippableEntity = true,
		RemoveOnTheater = true,
		OverrideOnlyEquippable = true,
		CreateEquipEntity = function( self )

			local RabbitShock = ents.Create( "rabbit_teslacapacitor" )

			if IsValid( RabbitShock ) then
				RabbitShock:SetRabbit( self.Ply )
				RabbitShock:Spawn()
			end

			return RabbitShock

		end

	} )

	GTowerItems.RegisterItem( "SkinScroller", {
		Name = "Skin Scroller",
		Description = "See all colors of the rabbit!",
		Model = "",
		UniqueInventory = false,
		DrawModel = false,
		Equippable = true,
		EquipType = "SkinScroller",
		CanEntCreate = false,
		DrawName = true,
		BankAdminOnly = true,

		EquippableEntity = true,
		OverrideOnlyEquippable = true,
		CreateEquipEntity = function( self )

			local SkinScroller = ents.Create( "gmt_skinscroller" )

			if IsValid( SkinScroller ) then
				SkinScroller:SetPos( self.Ply:GetPos() + Vector(0,0,64) )
				SkinScroller:SetParent( self.Ply )
				SkinScroller:SetOwner( self.Ply )
				SkinScroller:Spawn()
			end

			return SkinScroller

		end

	} )

end )


do
	local ENT = {
		Type = "anim"
	}

	if CLIENT then
		function ENT:Think()
			local Owner = self:GetOwner()

			if IsValid( Owner ) then
				if !self.TimeNextThink || self.TimeNextThink < CurTime() then
					local Count = Owner:SkinCount()
					self.CurrentSkin = (self.CurrentSkin or Owner:GetSkin()) + 1

					if self.CurrentSkin > Count then
						self.CurrentSkin = 0
					end

					self.TimeNextThink = CurTime() + 0.1
				end


				Owner:SetSkin( self.CurrentSkin )
			end
		end
		function ENT:Draw() end
	else
		function ENT:Initialize()
			self:DrawShadow( false )
		end

	end

	scripted_ents.Register(ENT, "gmt_skinscroller", false)

end
