local AdminExclusiveModels = {}

local SkinTable = {
	["redrabbit"] = function(ply, skin)
		return skin
	end,
	["digi"] = function(ply, skin)
		return skin
	end
}

hook.Add(
	"PlayerSetModelPost",
	"ModelsetSkin",
	function(ply, model, skin)
		if SkinTable[model] then
			local steam = ply:SteamID()

			if table.HasValue(AdminExclusiveModels[model], steam) then
				ply:SetSkin(SkinTable[model](ply, skin))
				return true
			end
		end
	end
)
