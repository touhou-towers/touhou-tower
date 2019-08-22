
concommand.Add("gmt_mtsrv", function( ply, command, args ) 

	if ply._LastMultiServerCmd && ply._LastMultiServerCmd > CurTime() then
		return
	end
	
	ply._LastMultiServerCmd = CurTime() + 0.25
	
	local Command = tonumber( args[1] ) or 0
	
	if Command == 1 then
		
		local ServerId = tonumber( args[2] )
		
		if !ServerId then	
			return
		end
		
		if GTowerServers.DEBUG == true then
			Msg( "Multiserver: " .. tostring(ply) .. " requesting to join: " .. ServerId .. "\n" )
		end
		
		local Server = GTowerServers:Get( ServerId )
		
		if Server then
			GTowerServers:AskToJoinServer( ply, Server )
		end
		
	elseif Command == 2 then
		
		GTowerServers:RemovePlayer( ply )
		
		if GTowerServers.DEBUG then
			Msg( "Multiserver: " .. tostring(ply) .. " remove from waiting\n" )
		end
		
	elseif Command == 3 then
	
		if ply._MultiChoosenMap == args[2] then
			return
		end
		
		ply._MultiChoosenMap = args[2]
		
		if ply._WaitingServer then
			local Server = GTowerServers:Get( ply._WaitingServer )
			
			Server:SendMapVote()
		end
		
	else
		
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		
	end

end )

hook.Add("PlayerDisconnected", "GTowerServersRemoveWait", function( ply )
	GTowerServers:RemovePlayer( ply )	
end )

hook.Add("GroupJoined", "RemoveFromServerList", function( ply, Group )
	GTowerServers:RemovePlayer( ply )	
end )

hook.Add("GroupLeft", "RemoveFromServerList", function( ply, Group )	
end )

hook.Add("GTowerGroupOwner", "ChangeServerOwner", function( ply, Group, oldply )
	
	if !oldply then
		return
	end
	
	local ServerId = GTowerServers:GetPlayer( oldply )
	
	if ServerId then
		local Server = GTowerServers:Get( ServerId )
		
		GTowerServers:RemovePlayer( oldply )
		GTowerServers:AddPlayer( ply, Server )
	end

end )

hook.Add("GTowerGroupUpdate", "MultiserverGroupUpdate", function(Group)
	// update the queuetimes (for waiting lists)
	for _,ply in pairs( Group:GetPlayers() ) do
		ply.QueueTime = Group.Owner.QueueTime or 0
	end
end)