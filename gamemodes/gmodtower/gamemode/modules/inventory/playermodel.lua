

hook.Add("SQLConnect", "RecheckPlayerModel", function( ply )
	
	if ply._ReloadPlayerModel then
		timer.Simple( 0, hook.Call, "PlayerSetModel", GAMEMODE, ply )
		ply._ReloadPlayerModel = nil
	end

end )


/*hook.Add("AllowModel", "InventoryCheck", function( ply, model, skin )
	
	if !ply.SQL then
		ply._ReloadPlayerModel = true
		return
	end
	
	local Model = GTowerItems.ModelItems[ model .. "-" .. skin ]
	
	if Model && ply:HasItemById( Model.MysqlId ) then
		return true
	end
	
end )*/


hook.Add("PlayerSetModelPost", "InventoryCheckSkin", function( ply, model, skin )

	if !ply.SQL then
		return
	end
	
	local Model = GTowerItems.ModelItems[ model .. "-" .. skin ]
	
	if Model && Model.ModelSkinId then	
		ply:SetSkin( Model.ModelSkinId )
		return true
	end
	
end )