AddCSLuaFile("cl_init.lua")
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_player.lua" )

include( "shared.lua" )
include( "sh_player.lua" )

util.AddNetworkString("CLPlayerThink")

hook.Add("PlayerThink", "teast", function(ply)
	net.Start("CLPlayerThink")
	net.WriteEntity(ply)
	net.Broadcast()
end)