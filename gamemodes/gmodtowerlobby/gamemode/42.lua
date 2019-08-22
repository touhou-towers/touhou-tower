concommand.Add("gmt_didupdate", function(ply,cmd,args)
	
	include("gmodtowerlobby/gamemode/curversion.lua")
	
	if IsValid( ply ) && ply:IsPlayer() then
		ply:Msg2("GMT VERSION: " .. GMT_CURVESRION )
	else
		Msg("GMT VERSION: " .. GMT_CURVESRION .. "\n" )
	end
	
end )