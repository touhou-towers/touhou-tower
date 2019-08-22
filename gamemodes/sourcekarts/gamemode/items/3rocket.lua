
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "3 Rocket"
ITEM.Model = "models/gmod_tower/sourcekarts/ballionrocket.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/rocket" )
ITEM.Entity = "sk_item_rocket"
ITEM.MaxUses = 3

ITEM.Battle = true
ITEM.Chance = items.UNCOMMON
ITEM.MaxPos = 2

function ITEM:CanStart( ply, kart )
	return ply:CheckShootItem( kart )
end

function ITEM:Start( ply )

	ply:ShootItem( self.Entity )

end

items.Register( ITEM )