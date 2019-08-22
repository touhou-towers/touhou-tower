
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Shield"
ITEM.Model = "models/gmod_tower/ball_geo.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/shield" )
ITEM.Entity = "sk_item_shield"
ITEM.MaxUses = 1
ITEM.Length = 9

ITEM.Battle = true
ITEM.Chance = items.UNCOMMON
ITEM.MaxPos = 1

function ITEM:Start( ply, kart )

	ply:SpawnItem( self.Entity )
	kart:SetIsInvincible( true )

end

function ITEM:End( ply, kart )

	ply:RemoveSpawnedItem()
	kart:SetIsInvincible( false )

end

items.Register( ITEM )