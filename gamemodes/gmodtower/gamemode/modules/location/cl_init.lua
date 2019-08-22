
include("shared.lua")

module("Location", package.seeall )

hook.Add("GTowerScorePlayer", "AddLocation", function()
	
	GtowerScoreBoard.Players:Add( 
		"Location", 
		4, 
		150, 
		function(ply) 
			ply.GLocation = nil
			return ply:LocationName()
		end, 
		95 
	)

end )