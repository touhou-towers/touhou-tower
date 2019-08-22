
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Hand"
ITEM.Model = "models/gmod_tower/discoball.mdl"
ITEM.Material = Material( "card" )
ITEM.Entity = nil
ITEM.MaxUses = 1

ITEM.Battle = true
ITEM.Chance = items.RARE
ITEM.MaxPos = 3

function ITEM:Start( ply, kart )

	local players = {}
	for _, ply2 in pairs( player.GetAll() ) do

		if ply:GetItem() != 0 then
			table.insert( players, ply2 )
		end

	end

	local playertosteal = table.Random( players )

	ply:GiveItem( playertosteal:GetItem() )
	playertosteal:ClearItems()

	// TODO Notify!!!

end

//items.Register( ITEM )