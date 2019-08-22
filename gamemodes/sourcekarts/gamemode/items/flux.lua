
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Flux"
ITEM.Model = "models/gmod_tower/sourcekarts/flux.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/flux" )
ITEM.Entity = "sk_item_flux"
ITEM.MaxUses = 1
ITEM.Length = 8

ITEM.Battle = false
ITEM.Chance = items.RARE
ITEM.MaxPos = 3

function ITEM:Start( ply, kart )

	ply:SpawnItem( self.Entity )

end

function ITEM:End( ply, kart )

	ply:RemoveSpawnedItem()

	for _, ply2 in pairs( player.GetAll() ) do
		PostEvent( ply2, "fluxoff" )
		ply2:SetSlowed( false )
	end

end

items.Register( ITEM )