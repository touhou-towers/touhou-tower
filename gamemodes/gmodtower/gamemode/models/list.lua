
local AdminExclusiveModels = {
	/*["sunabouzu"] = {
		"STEAM_0:0:5129735"
	},*/
	["macdguy"] = {
		"STEAM_0:1:6044247"
	},
	["nuggets"] = {
		"STEAM_0:1:15105622", //Nuggets
		"STEAM:0:1:9893012" //Jason
	},
	["redrabbit"] = {
		"STEAM_0:0:474552" //Nican
	},
	/*["azuisleet"]= {
		"STEAM_0:1:4556804" //azuisleet
	},*/
	/*["sam"]= {
		"STEAM_0:1:15862026" // Sam
	},*/
	["foohy"]= {
		"STEAM_0:1:18712009" // Foohy
	},
	["foohy2"]= {
		"STEAM_0:1:18712009" // Foohy
	},
	/*["w0rf0x"]= {
		"STEAM_0:1:6499275" // w0rf0x (from OC)
	},
	["keychain"]= {
		"STEAM_0:0:16958660" // Keychain (from OC)
	},
	["neico"]= {
		"STEAM_0:0:8660547" // Neico (from OC)
	},
	["dragonreborn"]= {
		"STEAM_0:1:16109411" //Dragon Reborn
	},*/
	["clopsy"]= {
		"STEAM_0:0:15339565" //Clopsy
	},
	
	["renamon"]= {
		"STEAM_0:0:4491990", //Voided
		"STEAM_0:0:474552", //Nican
		"STEAM_0:0:10644357" //Thomas
	},
	
	["andy"]= {
		"STEAM_0:1:19359297", //Andy
	},
	
	["digi"] = {
		"STEAM_0:0:474552", //Nican
		"STEAM_0:1:15166061" //Digi
	},
	["house"] = {
		"STEAM_0:0:16320712", //Fallen
		"STEAM_0:0:4491990", // voided - because it's going to be amusing
	},
	["infected"] = { // this must stay here to prevent people from using cl_playermodel
		"STEAM_0:1:6044247", // MacDGuy
		"STEAM_0:0:4491990", // voided
	}
}

local SkinTable = {

	["redrabbit"] = function( ply, skin )
		return skin
	end,
	["digi"] = function( ply, skin )
		return skin
	end,
	
}


/*hook.Add("AllowModel", "AllowGTowerDevs", function( ply, model )
	
	if AdminExclusiveModels[ model ] then
		
		local steam = ply:SteamID()
		
		if table.HasValue( AdminExclusiveModels[ model ], steam ) then
			return true
		else
			return false // explicitly disallow other admins from using this model
		end
		
	end
	
end )*/

hook.Add("PlayerSetModelPost", "ModelsetSkin", function( ply, model, skin )
	
	if SkinTable[ model ] then
		local steam = ply:SteamID()
		
		if table.HasValue( AdminExclusiveModels[ model ], steam ) then
			ply:SetSkin( SkinTable[ model ]( ply, skin ) )
			return true
		end
	end
	
end )