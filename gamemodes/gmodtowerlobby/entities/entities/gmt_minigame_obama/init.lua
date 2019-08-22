AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:Activate()
	
	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then

		phys:EnableMotion(false)

	end
end