
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "load.lua" )
AddCSLuaFile( "cl_smallachigui.lua" )
AddCSLuaFile("cl_scoregui.lua")

include("shared.lua")
include("sql.lua")
include("player.lua")
include("throphie.lua")
include("network.lua")
include("load.lua")

local LastPlayerSend = {}

concommand.Add("gmt_reqachi", function( ply, cmd, args )
	
	if !ply._Achivements then
		return
	end
	
	if ply._NextReqAchi && ply._NextReqAchi > CurTime() then
		return
	end
	
	ply._NextReqAchi = CurTime() + 1.0
	
	for k, v in pairs( GtowerAchivements.Achivements ) do
	
		if !ply._AchivementSentValues then
			ply._AchivementSentValues = {}
		end
		
		local Value = ply:GetAchivement( k )
		
		if Value != 0 && math.floor( Value ) != ply._AchivementSentValues[ k ] then
			GtowerAchivements:NetworkUpdate( ply, k )
		end
	
	end
	
end )


concommand.Add("gmt_achidebug", function( ply, cmd, args )
	
	if !ply:IsAdmin() then
		return
	end
	
	local Id = tonumber( args[1] )
	local Value = tonumber( args[2] )
	
	if Id && Value then
		ply:SetAchivement( Id, Value, tonumber(args[3]) )
	end
	
end )