
local NetworkPlySend = {}
local NetworkRoomSend = {}

local SizePerMessage = 40


local function SendRoomData( buffer, rp )
	
	local SendCount = math.min( math.floor( (255-16) / SizePerMessage ), #buffer )
	local SendIds = {}
	
	for i=1, SendCount do
		table.insert( SendIds, table.remove( buffer ) )
	end
	
	if #SendIds == 0 then
		return SendIds
	end
	
	umsg.Start("GRoom", rp )
	
		umsg.Char( 0 )
		umsg.Char( #SendIds )
		
		for _, Room in pairs( SendIds ) do
			
			local ValidOwner = IsValid( Room.Owner )
			
			umsg.Char( Room.Id )
			umsg.Bool( ValidOwner )
			
			if ValidOwner then
				if GTowerHats then
					for _, hat in ipairs( GTowerHats.Hats ) do
						if hat.unique_Name then
							local level = Room.Owner:GetLevel( hat.id ) //Get the sql id, and get the player level
							umsg.Bool( level > 0 )
						end
					end
				end
				
			end
			
		end
			
	umsg.End()

	return SendIds
	
end




timer.Create("GTowerRoomsSendData", 1.0, 0, function()

	if #NetworkRoomSend > 0 then
		
		local Ids = SendRoomData( NetworkRoomSend, nil ) // a nil RP sends to all players
		
		for ply, buffer in pairs( NetworkPlySend ) do
			for k, id in pairs( buffer ) do
				if table.HasValue( Ids, id ) then
					table.remove( buffer, k )
				end
			end
		end
		
	end


	for ply, buffer in pairs( NetworkPlySend ) do
		
		if #buffer > 0 then
			SendRoomData( buffer, ply )
		end
		
		//If there are not extra items to add, just remove it from the list!
		if #buffer == 0 then
			NetworkPlySend[ ply ] = nil
		end
		
	end

end )

hook.Add("RoomLoaded", "SendRoomInfo", function( ply, RoomId )
	if !table.HasValue( NetworkRoomSend, RoomId ) then
		table.insert( NetworkRoomSend, RoomId )
	end
end )

hook.Add("RoomUnLoaded", "SendRoomInfo", function( RoomId )
	if !table.HasValue( NetworkRoomSend, RoomId ) then
		table.insert( NetworkRoomSend, RoomId )
	end
end )

hook.Add("SQLConnect", "SendRoomData", function( ply )

	NetworkPlySend[ ply ] = {}
	
	for k, Room in pairs( GtowerRooms.Rooms ) do
		
		if IsValid( Room.Owner ) then
			table.insert( NetworkPlySend[ ply ], Room )
		end
		
	end

end )

hook.Add("PlayerDisconnected", "DeleteRoomData", function( ply )
	NetworkPlySend[ ply ] = nil
end )

concommand.Add("gmt_roomnetwork", function( ply, cmd, args )

	if ply == NULL then
		
		PrintTable( NetworkPlySend )
		PrintTable( NetworkRoomSend )
		
	end

end )