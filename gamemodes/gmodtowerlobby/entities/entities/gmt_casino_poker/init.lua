AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_panel_board.lua")
AddCSLuaFile("cl_panel_player.lua")

include("shared.lua")

util.AddNetworkString("ClientPoker")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
end

concommand.Add("gmt_pokertest", function(ply, cmd, args) 
		net.Start( "ClientPoker" )

			net.WriteEntity( ents.FindByClass("gmt_casino_poker")[1] )

			net.WriteEntity( ply )

			net.WriteInt( args[1], 4 )

			net.WriteTable({ply})

		net.Send( ply )
end)
