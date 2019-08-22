
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function BallRacer:OpenStore( ply )
	GTowerStore:OpenStore( ply, 5 )
end