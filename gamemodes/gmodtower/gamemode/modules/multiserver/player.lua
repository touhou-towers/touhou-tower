
function GTowerServers:RemovePlayer( ply )

	local ServerId = self:GetPlayer( ply )

	if ServerId then

		local Server = self:Get( ServerId )

		if Server then
			Server:RemovePlayer( ply )
			net.Start("MultiserverJoinRemove")
				net.WriteInt(0,2)
			net.Send(ply)
		end

	end

end

function GTowerServers:GetPlayer( ply )
	return ply._WaitingServer
end

function GTowerServers:AddPlayer( ply, Server )

	self:RemovePlayer( ply )

	Server:AddPlayer( ply )
	ply._WaitingServer = Server.Id

	net.Start("MultiserverJoinRemove")
		net.WriteInt(1,2)
		net.WriteString(Server.GamemodeValue)
	net.Send(ply)

end

function GTowerServers:AskToJoinServer( ply, Server )

	if GTowerServers:Gamemode() != "gmodtowerlobby" then
		//Do not allow players to join on other servers when it is not the lobby
		return
	end

	local OldServer = self:GetPlayer( ply )

	if OldServer then
		self:RemovePlayer( ply )

		if OldServer == Server.Id then // Don't add the player back
			if self.DEBUG then Msg( ply, " removing from waiting list.\n") end
			return
		end
	end

	//Check if the player is qualified to join the server
	local Gamemode = Server:Gamemode()

	//Is the groups module loaded?
	if GTowerGroup then
		//Does the player have a group
		if ply:HasGroup() then

			//If the player has group and he is not the owner, he is not to be added
			if !ply:GroupOwner() then
				umsg.Start("GServ", ply )
					umsg.Char( 7 )
				umsg.End()

				if self.DEBUG then	Msg( "Multiserver: " .. tostring(ply) .. " is not the group owner\n" ) end

				return
			end

		//If the server only accepts groups, don't even bother adding him
		elseif Gamemode.GroupJoin == true then
			umsg.Start("GServ", ply )
				umsg.Char( 8 )
			umsg.End()

			if self.DEBUG then	Msg( "Multiserver: " .. tostring(ply) .. " can not join. Only group.\n" ) end
		end

	end

	GTowerServers:AddPlayer( ply, Server )

	if self.DEBUG then	Msg( "Multiserver: " .. tostring(ply) .. " Joined the list to join the server " .. Server.Id .. "\n" ) end

end
