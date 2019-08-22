


local function FindPlayer( steamid )

	local ply = nil
	
	for _, v in ipairs( player.GetAll() ) do
		if ( v:SteamID() == steamid ) then
			ply = v
		end
	end
	
	return ply
	
end

concommand.Add( "gmt_vip_makevip", function( ply, cmd, args )
	
	if ( !ply:IsAdmin() ) then return end
	
	if #args != 2 then
		ply:PrintMessage( HUD_PRINTCONSOLE, "gmt_vip_makevip <steamid> <enabled>\n" )
		return
	end
	
	local steamid = args[ 1 ]
	
	if !string.match( steamid, "^(STEAM_0)" ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, "Invalid steamid\n" );
		return
	end
	
	local enabled = tobool( args[ 2 ] )
	
	local otherPly = FindPlayer( steamid )
	
	if ( otherPly == nil ) then
	
		ply:PrintMessage( HUD_PRINTCONSOLE, "Warning: No player with steamid is on server, performing DB query anyway!\n" )
		
		Vip.AddVIP( steamid )
		ply:PrintMessage( HUD_PRINTCONSOLE, steamid .. " is now a VIP.\n" )
		
		return
		
	end
	
	otherPly:SetVIP( enabled, true )
	ply:PrintMessage( HUD_PRINTCONSOLE, tostring( otherPly ) .. " is now a VIP.\n" )

end )

concommand.Add( "gmt_vip_tempvip", function( ply, cmd, args )

	if ( !ply:IsAdmin() ) then return end
	
	if #args != 2 then
		ply:PrintMessage( HUD_PRINTCONSOLE, "gmt_vip_makevip <steamid> <enabled>\n" )
		return
	end
	
	local steamid = args[ 1 ]
	
	if !string.match( steamid, "^(STEAM_0)" ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, "Invalid steamid\n" );
		return
	end
	
	local enabled = tobool( args[ 2 ] )
	
	local otherPly = FindPlayer( steamid )
	
	if ( otherPly == nil ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, "Unable to find a player with that steamid.\n" )
		return
	end
	
	otherPly:SetVIP( enabled )
	ply:PrintMessage( HUD_PRINTCONSOLE, tostring( otherPly ) .. " is now a temporary VIP.\n" )
	
end )