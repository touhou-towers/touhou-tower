AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bumpy/update_board.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

net.Receive("SetUpdateSkin",function()
	local ent = net.ReadEntity()
	local skin = net.ReadInt(8)

	if IsValid(ent) then
		ent:SetSkin(skin)
	end

end)

util.AddNetworkString("SetUpdateSkin")
