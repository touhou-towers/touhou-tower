
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Rocket"
ITEM.Model = "models/gmod_tower/sourcekarts/ballionrocket.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/rocket" )
ITEM.Entity = "sk_item_rocket"
ITEM.MaxUses = 1

ITEM.Battle = true
ITEM.Chance = items.COMMON
ITEM.MaxPos = 1

function ITEM:CanStart( ply, kart )
	return ply:CheckShootItem( kart )
end

function ITEM:Start( ply )
	ply:ShootItem( self.Entity )
end

items.Register( ITEM )