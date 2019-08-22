
function ServerMeta:GetBatches()
	
	//We don't want a infinite loop
	if self.MaxPlayers == 0 then
		return
	end
	
	local PlayerBatches = {}
	
	local function AddToList( players ) 
		
		if table.Count( players ) > self.MaxPlayers then
			Msg("ERROR: Adding to server a group bigger than the max players!\n")
			for _, ply in pairs( players ) do
				AddToList( {ply} ) 
				return
			end
		end
		
		local Count = 1
		
		//While progresevely checking for the exesting batches
		while PlayerBatches[ Count ] != nil do
			
			local BatchCount = table.Count( PlayerBatches[ Count ] )
			local SpaceLeft = self.MaxPlayers - BatchCount
			
			//If there is enough space left to add all the players togheder
			if SpaceLeft >= table.Count( players ) then
				table.Add( PlayerBatches[ Count ], players )
				//No need to keep searching, just stop it
				return
			end
			
			//Keep looking
			Count = Count + 1
			
		end
		
		//No batches found to add the player
		//Create a new one!
		
		PlayerBatches[ Count ] = {}
		
		for _, ply in pairs( players ) do
			//print(self.Id, "inserted", ply, "into batch", Count)
			table.insert( PlayerBatches[ Count ], ply )
		end
		
	end
	
	//print(self.Id, "Getting batches", self.PlayerList, table.Count(self.PlayerList))

	for _, ply in pairs( self.PlayerList ) do
		//print(self.Id, "Player in list", ply)

		if ply.GetGroup && ply:GroupOwner() then
			AddToList( ply:GetGroup():GetPlayers() )
		elseif IsValid(ply) then
			AddToList( {ply} )
		else
			ErrorNoHalt("Trying to add NULL player to batches " .. tostring(ply))
		end
		
	end

	return PlayerBatches

end