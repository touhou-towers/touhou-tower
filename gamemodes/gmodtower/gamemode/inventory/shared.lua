
ITEMS = {}

GTowerItems = {}
GTowerItems.Items = {}
GTowerItems.SortedItems = {}
GTowerItems.DEBUG = false

GTowerItems.MaxDistance = 510
GTowerItems.DragMaxDistance = GTowerItems.MaxDistance * 5
GTowerItems.EquippableSlots = 8
GTowerItems.BarStoreId = 4
GTowerItems.OnlyHitWorld = true

GTowerItems.DefaultInvCount = 36 + 4
GTowerItems.DefaultBankCount = 275

GTowerItems.MaxInvCount = 127
GTowerItems.MaxBankCount = 350

/*
	Each slot will be allowed an array of specific EquipType
*/
GTowerItems.WearablesList = {
	[1] = {"TelsaEars","StealthBox"}, //Mostly head stuff
	[2] = {"Jetpack","Backpack"}, //The back, jetpack?
	[3] = {"BallRaceBall","VirusFlame"}, //Overall
}

GTowerItems.Sounds = {
	Move = {
		["default"] 	= Sound( "GModTower/inventory/move_default.wav" ),
		["wood"] 		= Sound( "GModTower/inventory/move_wood.wav" ),
		["concrete"] 	= Sound( "GModTower/inventory/move_concrete.wav" ),
		["furniture"] 	= Sound( "GModTower/inventory/move_furn.wav" ),
		["furniture2"] 	= Sound( "GModTower/inventory/move_furn2.wav" ),
		["furniture3"] 	= Sound( "GModTower/inventory/move_furn3.wav" ),
		["paper"] 		= Sound( "GModTower/inventory/move_paper.wav" ),
		["glass"] 		= Sound( "GModTower/inventory/move_glass.wav" ),
		["guitar"] 		= Sound( "GModTower/inventory/move_guitar.wav" ),
		["cloth"] 		= Sound( "GModTower/inventory/move_cloth.wav" ),
		["plush"] 		= Sound( "GModTower/inventory/move_plush.wav" ),
		["lightsaber"] 	= Sound( "GModTower/inventory/use_lightsaber.wav" ),
	},
	//Equip = {},
	//Use = {},
}

function GTowerItems:IsEquipSlot( id )
	return id && id <= GTowerItems.EquippableSlots && id > 0
end

function GTowerItems:Get( id )
	return self.Items[ id ]
end

function GTowerItems:FindByEntity( ent )
	if !IsValid( ent ) then
		return nil, 1
	end

	if ent._GTInvSQLId then
		return ent._GTInvSQLId
	end

	if ent:IsPlayer() || ent._GTInvSQLId == false then
		return nil
	end

	local Owner = ent:GetOwner()

	if IsValid( Owner ) && Owner:IsPlayer() then
		return nil
	end

    for _, v in pairs(self.Items) do
        if v:IsMyEnt( ent ) then
			if v.AllowEntBackup == true then
				ent._GTInvSQLId = v.MysqlId
			end

            return v.MysqlId
        end
    end

	ent._GTInvSQLId = false

    return nil
end

function GTowerItems:FindByFile( Name )
	return ITEMS[ Name ]
end

function GTowerItems:CreateById( id, ply, data )
	local Item = self.Items[ id ]

    if !Item then
		return
	end

	local o = {}

	setmetatable( o, {
		__index = Item
	} )

	if !ply && CLIENT then
		o.Ply = LocalPlayer()
	else
		o.Ply = ply
	end

	if o:OnCreate( data ) == false then //failed to create the item
		return nil
	end

    return o
end

function GTowerItems:AllowPosition( item, pos )
	if self:IsEquipSlot( pos ) && item.Equippable != true then
		return false
	end

	return true
end

// the regular AllowPosition doesn't understand the bank on the client
function GTowerItems:AllowPositionEx( item, panel )
	return !panel:IsEquipSlot() || item.Equippable
end

function AngleWithinPrecisionError(ang, target)
	return (ang < target + 0.2 && ang > target - 0.2)
end
