
util.AddNetworkString('gmt_models')

hook.Add("SQLConnect", "RecheckPlayerModel", function( ply )
	
	if ply._ReloadPlayerModel then
		timer.Simple( 0, hook.Call, "PlayerSetModel", GAMEMODE, ply )
		ply._ReloadPlayerModel = nil
	end

end )


hook.Add("AllowModel", "InventoryCheck", function( ply, model, skin )
		
	if !ply.SQL then
		ply._ReloadPlayerModel = true
		return
	end
	
	local Model = GTowerItems.ModelItems[ model .. "-" .. skin ]
	
	if Model && ply:HasItemById( Model.MysqlId ) then
		return true
	end
	
end )

concommand.Add("gmt_requestmodelupdate", function(ply)

	local tbl = {}

	for name, model in pairs( player_manager.AllValidModels() ) do
	
	for _, SlotList in pairs(ply._GtowerPlayerItems) do
		for _, Item in pairs( SlotList ) do
			if Item.Model == model then
				table.insert(tbl, model)
			end
		end
    end
	
	end
	
	net.Start('gmt_models')
		net.WriteTable( tbl )
	net.Send(ply)
	
end)

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