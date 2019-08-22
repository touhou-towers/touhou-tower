
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Blob"
ITEM.Model = "models/gmod_tower/ball.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/blob" )
ITEM.Entity = "sk_item_blob"
ITEM.MaxUses = 1
ITEM.Fling = true

ITEM.Battle = true
ITEM.Chance = items.COMMON
ITEM.MaxPos = 1

function ITEM:Start( ply, kart, power )

	if power > .25 then
		ply:FlingItem( self.Entity, 1100 * power )
		ply:EmitSound( SOUND_BLOBTHROW, 100 )
	else
		--ply:DropItem( self.Entity )
		ply:FlingItem( self.Entity, 0 )
		ply:EmitSound( SOUND_BLOB, 100, math.random( 100, 130 ) )
	end

end

items.Register( ITEM )
