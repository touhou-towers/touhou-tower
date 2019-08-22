
hook.Add("SQLStartColumns", "SQLSelectHat", function()
	SQLColumn.Init( {
		["column"] = "hat",
		["update"] = function( ply ) 
			return GTowerHats:GetHat( ply )
		end,
		["defaultvalue"] = function( ply )
			GTowerHats:SetHat( ply, 0 )
		end,
		["onupdate"] = function( ply, val ) 
			//Timer for next frame because store data has not yet loaded
			timer.Simple( 0.0, function() GTowerHats.SetHat( GTowerHats, ply, val ) end)
		end
	} )
end )

concommand.Add("gmt_sethat", function( ply, cmd, args )
	
	if hook.Call( "CanUpateHat", GAMEMODE, ply ) == true || GTowerHats:Admin( ply ) then
		local Return = GTowerHats:SetHat( ply, args[1] ) 
		
		if Return then
			ply:Msg2( Return )
		end
	end
	
end )


function GTowerHats:SetHat( ply, hat, replacing )
	if !IsValid(ply) then return end

	if !hat then
		hat = 0
	end

	if GAMEMODE.NoHats then return end
	
	//if self.DEBUG then
	//	Msg("Setting " .. ply:Name() .. " hat to: " .. tostring( hat ) .. "\n")
	//	Msg( debug.traceback() )
	//end
	
	if string.len( hat ) > 3 then //If it is too big, it msut be a string
		hat = self:GetHatByName( string.Trim( hat ) )
	else
		hat = tonumber( hat )
	end

	if self.DEBUG then Msg( tostring( ply ) .. " chaning to hat " .. tostring(hat) .. "\n") end
	
	local HatTbl = self.Hats[ hat ]
	local LastHat = ply.PlayerHat
	
	if hat == 0 || !HatTbl then
		ply.PlayerHat = 0
		if self.DEBUG then Msg("Hat not found with id ".. hat .. "\n") end
	else
		ply.PlayerHat = hat
		
		local StoreId = GTowerStore:GetItemByName( HatTbl.unique_Name )
		
		if !StoreId || ply:GetLevel( StoreId ) == 0 then
			ply.PlayerHat = 0
			if self.DEBUG then Msg("Player does not have the right to wear the hat" .. hat .. "\n") end
		end
	end
	
	if LastHat == ply.PlayerHat && !replacing then
		return
	end
	
	if ply.PlayerHat == 0 then
		ply:RemoveHat()
		return "You are no longer wearing a hat"
	end
	
	if self.DEBUG then Msg( tostring( ply ) .. " is using hat " .. hat .. "\n") end
	
	ply:ReplaceHat( HatTbl.model, ply.PlayerHat )
	
	if HatTbl.ModelSkin then
		ply.Hat:SetSkin( HatTbl.ModelSkin )
	end
	
	return "You are now using the " .. HatTbl.Name

end

function GTowerHats:GetHat( ply )
	if GAMEMODE.NoHats then return nil end //DO NOT ALLOW HATS TO BE SET

	return ply.PlayerHat
end

// for respawning the hats when a player respawns IE game.CleanUpMap in pvpbattle
hook.Add("PlayerSpawn", "PlayerRecreateHat", function(ply)
	if ply.PlayerHat then
		GTowerHats:SetHat(ply, ply.PlayerHat, true)
	end
end)