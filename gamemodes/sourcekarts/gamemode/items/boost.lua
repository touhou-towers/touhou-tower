
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Boost"
ITEM.Model = "models/gmod_tower/sourcekarts/booster.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/boost" )
ITEM.Entity = nil
ITEM.MaxUses = 1

ITEM.Battle = false
ITEM.Chance = items.COMMON
ITEM.MaxPos = 2

function ITEM:Start( ply, kart )

	kart:Boost( 2, 1 )
	ply:AddAchivement( ACHIVEMENTS.SKTURBO, 1 )

end

items.Register( ITEM )
