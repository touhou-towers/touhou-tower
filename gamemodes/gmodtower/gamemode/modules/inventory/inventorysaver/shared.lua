



module("InventorySaver", package.seeall )

SaveMaterial = "models/props_combine/stasisshield_sheet"


function Allow( ply )
	return ply:IsAdmin()
end