
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "GMC"
ITEM.Material = Material( "card" )
ITEM.Entity = "sk_item_gmc"
ITEM.MaxUses = 5
ITEM.Battle = true

function ITEM:Start( ply )

	ply:ShootItem( self.Entity, 1000 )
	ply:GiveMoney( -1 )

end

//items.Register( ITEM )