

include( "shared.lua" )


hook.Add( "GTowerScorePlayer", "AddVip", function()
	
	GtowerScoreBoard.Players:Add( "VIP", 5, 20, function( ply ) return "" end, -2, nil, function( ply )
	
		if ( ply.IsVIP && ply:IsVIP() ) then
			return "icons/vip"
		end
		
		return nil
		
	end )

end )
