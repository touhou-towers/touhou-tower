

function ServerMeta:AddPlayer( ply )
	
	if !IsValid(ply) then
		ErrorNoHalt("Adding a NULL player")
		return
	end

	if self:HasPlayer( ply ) then
		return //Adding twice?
	end
	
	if ply._WaitingServer then
		ErrorNoHalt("Adding a player to a server while the player is in anohter server list.")
		return
	end
	
	table.insert( self.PlayerList, ply )
	
	ply._MultiChoosenMap = ""
	ply._WaitingServer = self.Id

	ply.QueueTime = CurTime()
	if ply:HasGroup() then
		ply:GetGroup():Update()
	end
	
	self:NetworkNeedSend()
	self:TimedThink()
	
end 

function ServerMeta:HasPlayer( ply )
	return table.HasValue( self.PlayerList, ply )
end

function ServerMeta:RemovePlayer( ply )

	//print("Remove player from list", ply)
	for k, v in pairs( self.PlayerList ) do
		if v == ply then
			table.remove( self.PlayerList, k )
		end	
	end
	
	if self:HasPlayer(ply) then
		ErrorNoHalt("Player was not removed from the PlayerList! " .. tostring(ply))
	end

	ply._MultiChoosenMap = ""
	ply._WaitingServer = nil
	
	self:NetworkNeedSend()
	self:TimedThink()

end

//This gets all players on a perfect numerical index
function ServerMeta:GetPlayers()
	
	local Batches = self:GetBatches()
	local List = {}
	
	for _, v in pairs( Batches ) do
		table.Add( List, v )
	end
	
	return List

end

//The numerical index is coresponded to the player position on the waiting list
function ServerMeta:GetListedPlayers()
	
	local Batches = self:GetBatches()
	local List = {}
	
	for k, v in pairs( Batches ) do
		for k1, ply in pairs( v ) do
			List[ self.MaxPlayers * (k-1) + k1 ] = ply
			Msg("Adding ", ply, " to list: " .. k .. " - " .. k1 .. " - " .. self.MaxPlayers .. "\n")
		end
	end
	
	return List

end