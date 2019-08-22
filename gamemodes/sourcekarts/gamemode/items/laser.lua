
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Laser"
ITEM.Model = "models/gmod_tower/sourcekarts/flux.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/laser" )
ITEM.Entity = "sk_item_laser"
ITEM.MaxUses = 1
ITEM.Length = 5

ITEM.Battle = true
ITEM.Chance = items.UNCOMMON
ITEM.MaxPos = 3

function ITEM:Start( ply, kart )

	ply:SpawnItem( self.Entity )

end

function ITEM:End( ply, kart )

	ply:RemoveSpawnedItem()

end

items.Register( ITEM )