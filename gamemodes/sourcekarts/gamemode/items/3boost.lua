
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "3 Boost"
ITEM.Model = "models/gmod_tower/sourcekarts/booster.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/boost" )
ITEM.Entity = nil
ITEM.MaxUses = 3

ITEM.Battle = false
ITEM.Chance = items.UNCOMMON
ITEM.MaxPos = 2

function ITEM:Start( ply, kart )

	kart:Boost( 2, .95 )
	ply:AddAchivement( ACHIVEMENTS.SKTURBO, 1 )

end

items.Register( ITEM )