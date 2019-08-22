
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


module("adverts", package.seeall )


 SQL.getDB():Query("SELECT `id`,`Name`,`imageName` FROM gm_advertlist WHERE `enabled`=1", function( res, status, err )

	if status != 1 then
		ErrorNoHalt( err )
		return
	end
	
	for _, v in pairs( res ) do
	
		local ImageName = v["imageName"]
		local BaseName = string.sub( ImageName, 0, string.find( ImageName, "%." ) - 1 )
		local Id = tonumber( v["id"] )
		
		local FileLocation = "materials/" .. MaterialBaseFolder .. Id .. BaseName .. ".vtf"
		
		
		if DEBUG then
			print("Checking file: '../" .. FileLocation .. "'\n")
		end
		
		//Check if the .vtf file exists and can be sent to the client
		if file.Exists( "../" .. FileLocation ) then
	
			AdvertData[ Id ] = {
				Id = Id,
				Name = v["Name"],
				ImageName = ImageName,		
				BaseName = BaseName,
			}
			
			resource.AddFile( FileLocation )
			
		end
	
	end
	
	if DEBUG then
		PrintTable( AdvertData )
	end
	
end, 1 )

local function SendAdvertData( ply )

	local BytesLeft = 255
	
	umsg.Start("Advert", ply )
		
		for k, data in pairs( AdvertData ) do
			
			if DEBUG then
				Msg("Sending to player: " .. tostring(k) .. "\n")
			end
			
			if !table.HasValue( ply._SendAdvertData, k ) then
				
				BytesLeft = BytesLeft - 4 - string.len( data.BaseName ) - 1 - string.len( data.Name ) - 1
				
				if BytesLeft <= 0 then
					break
				end
				
				umsg.Long( data.Id )
				umsg.String( data.BaseName )
				umsg.String( data.Name )
				
				table.insert( ply._SendAdvertData, k )
				
				if DEBUG then
					Msg("\t" .. tostring(k) .. "sent. \n")
				end
				
			end
			
		end
	
	umsg.End()
	
	if table.Count( ply._SendAdvertData ) != table.Count( AdvertData ) then
		return true
	end
	
end

hook.Add( "PlayerInitialSpawn", "SendAdvertsData", function( ply )
	
	if ply:IsBot() || table.Count( AdvertData ) == 0 then
		return
	end
	
	if !ply._SendAdvertData then
		ply._SendAdvertData = {}
	end
	
	ClientNetwork.AddPacket( ply, "AdvertData", SendAdvertData )

end )