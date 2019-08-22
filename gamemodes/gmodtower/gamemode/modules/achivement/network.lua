
local DEBUG = false

GtowerAchivements.PlayerNetworkSend = function( ply )
	
	if #ply._AchivementNetwork == 0 then
		return
	end
	
	local SpaceLeft = 255 - 10
	
	if DEBUG then Msg("Sending to the client: " , ply , "\n") end
	
	umsg.Start( "GTAch", ply )
	
	while #ply._AchivementNetwork > 0 do
				
		local ItemId = table.remove( ply._AchivementNetwork )
		local Item = GtowerAchivements:Get( ItemId )
		local NWData = Item._NWInfo
		
		if DEBUG then Msg( "\tAchivement: ",Item.Name, "\n") end
			
		SpaceLeft = SpaceLeft - NWData[2] - 2
			
		if SpaceLeft < 0 then
			table.insert( ply._AchivementNetwork, ItemId )
			break
		end
			
		local Value = math.floor( ply:GetAchivement( ItemId ) )
			
		if !ply._AchivementSentValues then
			ply._AchivementSentValues = {}
		end
	
		ply._AchivementSentValues[ ItemId ] = Value
			
			
		if NWData[3] then
			Value = Value - NWData[3]
		end
			
		umsg.Short( ItemId )
		umsg[ NWData[1] ]( Value )
			
	end
	
	umsg.End()

	return #ply._AchivementNetwork > 0

end

/*
hook.Add("PlayerThink", "GTowerAchievementNetwork", function(ply)
		
		if ply._AchivementNetwork && #ply._AchivementNetwork > 0 then
			
			local SpaceLeft = 255 - 10
			 
			if DEBUG then Msg("Sending to the client: " , ply , "\n") end
			
			umsg.Start( "GTAch", ply )
			
			while #ply._AchivementNetwork > 0 do
				
				local ItemId = table.remove( ply._AchivementNetwork )
				local Item = GtowerAchivements:Get( ItemId )
				local NWData = Item._NWInfo
				
				if DEBUG then Msg( "\tAchivement: ",Item.Name, "\n") end
				
				SpaceLeft = SpaceLeft - NWData[2] - 2
				
				if SpaceLeft < 0 then
					table.insert( ply._AchivementNetwork, ItemId )
					break
				end
				
				local Value = math.floor( ply:GetAchivement( ItemId ) )
				
				if !ply._AchivementSentValues then
					ply._AchivementSentValues = {}
				end
				ply._AchivementSentValues[ ItemId ] = Value
				
				
				if NWData[3] then
					Value = Value - NWData[3]
				end
				
				umsg.Short( ItemId )
				umsg[ NWData[1] ]( Value )
				
			end
			
			umsg.End()
		
		end

end )
*/