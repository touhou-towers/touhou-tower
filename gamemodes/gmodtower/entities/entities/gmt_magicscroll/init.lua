
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:SetSolid(SOLID_VPHYSICS)

	self:SetTrigger(true)

	self:DrawShadow(false)
	self:SetPos(self:GetPos() + Vector(0,0,10))

end
