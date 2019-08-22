
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Teleporter"
ENT.Author			= "Nican132"
ENT.Contact			= ""
ENT.Purpose			= "For GMod Tower"
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.Model		= "models/gmod_tower/teleporter.mdl"
ENT.TeleportOffset = Vector( 4.8, 0.1, 3.1 )

GtowerPrecacheModel( ENT.Model )

/*
ENT.Places = {
	[1] = {
		["name"] = "Lobby",
		["desc"] = "<color=black>A place to play games and relax</color>",	
	},
	[2] = {
		["name"] = "Suites",
		["desc"] = "<color=black>Relax and store your stuff</color>"
	},
	[3] = {
		["name"] = "Games",
		["desc"] = "<color=black>Choose a game to join</color>",
	}
}
*/

function ENT:TestForPlayer( ply )
	local pos = self:WorldToLocal( ply:GetPos() )
		
	return pos.x > -5 && pos.x < 32 &&
		pos.y > -10 && pos.y < 10 && 
		pos.z > -5 && pos.z < 128	
end